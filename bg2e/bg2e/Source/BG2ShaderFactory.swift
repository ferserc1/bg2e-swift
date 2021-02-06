//
//  BG2Shader.swift
//  bg2e-mac
//
//  Created by Fernando Serrano Carpena on 05/08/2019.
//  Copyright © 2019 Fernando Serrano Carpena. All rights reserved.
//

import MetalKit

public class BG2ShaderFactory {
    private var renderer: BG2Renderer
    
    private var fragmentUniforms = BasicShaderFragmentUniforms()
    
    public init(withRenderer renderer: BG2Renderer) {
        self.renderer = renderer
    }
    
    open func setup(pipelineDescriptor desc: MTLRenderPipelineDescriptor, material: BG2Material) {
        desc.colorAttachments[0].pixelFormat = .bgra8Unorm
        desc.depthAttachmentPixelFormat = .depth32Float
        
        let functionConstants = material.makeFunctionConstants()
        
        desc.label = "Default shader pipeline"
        let library = renderer.shaderLibrary
        desc.vertexFunction = library.makeFunction(name: "vertex_main")
        do {
            desc.fragmentFunction = try library.makeFunction(name: "fragment_main", constantValues: functionConstants)
        } catch let error {
            fatalError(error.localizedDescription)
        }
    }
    
    open func beginRender(fromCamera cam: BG2CameraComponent, renderEncoder: MTLRenderCommandEncoder) {
        let shaderLights = BG2LightComponent.shaderLights
        
        fragmentUniforms.lightCount = uint(shaderLights.count)
        fragmentUniforms.cameraPosition = cam.view.position
        
        renderEncoder.setFragmentBytes(shaderLights,
                                       length: MemoryLayout<ShaderLight>.stride * shaderLights.count,
                                       index: Int(LightUniformIndex.rawValue))
        renderEncoder.setFragmentBytes(&fragmentUniforms,
                                       length: MemoryLayout<BasicShaderFragmentUniforms>.stride,
                                       index: Int(FragmentUniformIndex.rawValue))
    }
}
