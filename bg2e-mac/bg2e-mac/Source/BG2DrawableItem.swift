//
//  BG2DrawableItem.swift
//  bg2e-mac
//
//  Created by Fernando Serrano Carpena on 03/07/2019.
//  Copyright © 2019 Fernando Serrano Carpena. All rights reserved.
//

import MetalKit
import simd

public class BG2DrawableItem {
    private var renderer: BG2Renderer
    
    public var polyList: BG2PolyList
    public var material: BG2Material
    public var transform: float4x4 = float4x4(diagonal: SIMD4<Float>(1, 1, 1, 1))

    public init(polyList: BG2PolyList, renderer: BG2Renderer) {
        self.polyList = polyList
        self.material = BG2Material()
        self.renderer = renderer
    }
    
    public init(polyList: BG2PolyList, material: BG2Material, renderer: BG2Renderer) {
        self.polyList = polyList
        self.material = material
        self.renderer = renderer
    }
    
    public init(polyList: BG2PolyList, material: BG2Material, transform: float4x4, renderer: BG2Renderer) {
        self.polyList = polyList
        self.material = material
        self.transform = transform
        self.renderer = renderer
    }
    
    public lazy var pipelineState: MTLRenderPipelineState = {
        let descriptor = MTLRenderPipelineDescriptor()
        let plState: MTLRenderPipelineState
        
        do {
            descriptor.colorAttachments[0].pixelFormat = .bgra8Unorm
            descriptor.depthAttachmentPixelFormat = .depth32Float
            descriptor.label = "DrawableItem pipeline"
            let library = renderer.shaderLibrary
            descriptor.vertexFunction = library.makeFunction(name: "vertex_main")
            descriptor.fragmentFunction = library.makeFunction(name: "fragment_main")
            descriptor.vertexDescriptor = polyList.vertexDescriptor
            
            // DrawableItem have all the information aboutn link material properties to shader inputs
            
            plState = try renderer.device.makeRenderPipelineState(descriptor: descriptor)
        } catch {
            fatalError(error.localizedDescription)
        }
        
        return plState
    }()
    
    public func draw(worldMatrix: matrix_float4x4, viewMatrix: matrix_float4x4, projectionMatrix: matrix_float4x4, renderEncoder: MTLRenderCommandEncoder) {
        renderEncoder.setRenderPipelineState(pipelineState)
        let itemWorldMatrix = worldMatrix * self.transform
        var uniforms = MatrixState(model: itemWorldMatrix,
                                   view: viewMatrix,
                                   projection: projectionMatrix,
                                   normal: matrix_float3x3.init(normalFrom4x4: self.transform))
        
        renderEncoder.setVertexBytes(&uniforms,
                                     length: MemoryLayout<MatrixState>.stride,
                                     index: polyList.nextAvailableBufferIndex)
        renderEncoder.setFragmentTexture(self.material.albedoTexture, index: Int(0))
        
        polyList.draw(encoder: renderEncoder)
    }
}
