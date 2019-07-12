//
//  Renderer.swift
//  bg2e-mac
//
//  Created by Fernando Serrano Carpena on 29/06/2019.
//  Copyright © 2019 Fernando Serrano Carpena. All rights reserved.
//

import MetalKit

public protocol BG2RendererDelegate: class {
    func update(_ delta: Float)
}

public class BG2Renderer: NSObject {
    public var device: MTLDevice!
    public var commandQueue: MTLCommandQueue!
    public var depthStencilState: MTLDepthStencilState!
    
    public var delegate: BG2RendererDelegate?
    
    var metalView: MTKView
    
    public lazy var shaderLibrary: MTLLibrary = {
        do {
            let frameworkBundle = Bundle(for: type(of: self))
            return try device.makeDefaultLibrary(bundle: frameworkBundle)
        } catch {
            fatalError(error.localizedDescription)
        }
    }()
    
    func buildDepthStencilState() {
        let descriptor = MTLDepthStencilDescriptor()
        descriptor.depthCompareFunction = .less
        descriptor.isDepthWriteEnabled = true
        depthStencilState = self.device.makeDepthStencilState(descriptor: descriptor)
    }
    
    // TODO: Testing purposes, remove
    private var drawableItem: BG2DrawableItem? = nil
    private var camera: BG2CameraComponent? = nil
    
    public func setDrawableItem(_ drawable: BG2DrawableItem) {
        drawableItem = drawable
    }
    
    public func setCamera(_ camera: BG2CameraComponent) {
        self.camera = camera
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
        guard let camera = camera else {
            return
        }
        
        let aspect: Float = Float(view.bounds.size.width) / Float(view.bounds.size.height)
        camera.projection = matrix_float4x4(perspectiveFov: 45, near: 0.1, far: 100.0, aspect: aspect)
    }
    
    public func draw(in view: MTKView) {
        // Call delegate "update" method
        // TODO: pass a valid delta time
        delegate?.update(0.0)
        
        guard let descriptor = view.currentRenderPassDescriptor,
            let commandBuffer = commandQueue.makeCommandBuffer(),
            let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: descriptor),
            let drawableItem = drawableItem,
            let camera = camera
        else {
            return
        }
        
        renderEncoder.setDepthStencilState(depthStencilState)
        
        drawableItem.draw(viewMatrix: camera.view,
                          projectionMatrix: camera.projection,
                          renderEncoder: renderEncoder)

        renderEncoder.endEncoding()
        

        guard let drawable = view.currentDrawable else {
            return
        }
        commandBuffer.present(drawable)
        commandBuffer.commit()
    }
}
