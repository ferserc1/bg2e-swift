//
//  Renderer.swift
//  bg2e-mac
//
//  Created by Fernando Serrano Carpena on 29/06/2019.
//  Copyright © 2019 Fernando Serrano Carpena. All rights reserved.
//

import MetalKit

public protocol BG2RendererDelegate: class {
    func createScene(renderer: BG2Renderer) -> BG2SceneObject
    func resize(_ view: MTKView, drawableSizeWillChange size: CGSize)
    func update(_ delta: Float, renderer: BG2Renderer)
}

public class BG2Renderer: NSObject {
    public var device: MTLDevice!
    public var commandQueue: MTLCommandQueue!
    public var depthStencilState: MTLDepthStencilState!
    
    public var delegate: BG2RendererDelegate? {
        didSet {
            self.sceneRoot = delegate?.createScene(renderer: self)
        }
    }
    
    var metalView: MTKView
    
    public var mainCamera: BG2CameraComponent? = nil
    public var sceneRoot: BG2SceneObject? = nil
    
    public lazy var shaderLibrary: MTLLibrary = {
        do {
            let frameworkBundle = Bundle(for: type(of: self))
            return try device.makeDefaultLibrary(bundle: frameworkBundle)
        } catch {
            fatalError(error.localizedDescription)
        }
    }()
    
    // Factory shader to be used with polyLists.
    // TODO: implement different options, like deferred render, phong shader
    // PBR shaders, etc. using different parametrizations of the Renderer class
    public lazy var polyListShaderFactory: BG2ShaderFactory = {
        return BG2ShaderFactory(withRenderer: self)
    }()
    
    func buildDepthStencilState() {
        let descriptor = MTLDepthStencilDescriptor()
        descriptor.depthCompareFunction = .less
        descriptor.isDepthWriteEnabled = true
        depthStencilState = self.device.makeDepthStencilState(descriptor: descriptor)
    }
    
    public init(metalView: MTKView) {
        self.metalView = metalView
        
        guard let device = MTLCreateSystemDefaultDevice() else {
            fatalError("No GPU available")
        }
        self.device = device
        self.metalView.device = device
        self.metalView.depthStencilPixelFormat = .depth32Float
        commandQueue = device.makeCommandQueue()

        super.init()
        
        metalView.clearColor = MTLClearColor(red: 1.0, green: 1.0, blue: 0.8, alpha: 1.0)
        metalView.delegate = self
        
        buildDepthStencilState()
    }
}

extension BG2Renderer: MTKViewDelegate {
    public func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        guard let camera = mainCamera else {
            return
        }
        
        let aspect: Float = Float(view.bounds.size.width) / Float(view.bounds.size.height)
        camera.projection = matrix_float4x4(perspectiveFov: 45, near: 0.1, far: 100.0, aspect: aspect)
        
        delegate?.resize(view, drawableSizeWillChange: size)
    }
    
    public func draw(in view: MTKView) {
        // Call delegate "update" method
        // TODO: pass a valid delta time
        delegate?.update(1.0 / 60.0, renderer: self)
        
        guard let descriptor = view.currentRenderPassDescriptor,
            let commandBuffer = commandQueue.makeCommandBuffer(),
            let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: descriptor),
            let camera = mainCamera,
            let scene = sceneRoot
        else {
            return
        }
        
        scene.update(delta: 1.0 / 60.0)
        
        renderEncoder.setDepthStencilState(depthStencilState)

        polyListShaderFactory.beginRender(fromCamera: camera,
                                          renderEncoder: renderEncoder)
        scene.draw(fromCamera: camera, renderEncoder: renderEncoder)
        
        renderEncoder.endEncoding()

        guard let drawable = view.currentDrawable else {
            return
        }
        commandBuffer.present(drawable)
        commandBuffer.commit()
    }
}
