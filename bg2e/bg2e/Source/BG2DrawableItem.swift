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
    
    private var shaderFactory: BG2ShaderFactory

    public init(polyList: BG2PolyList, renderer: BG2Renderer) {
        self.polyList = polyList
        self.material = BG2Material()
        self.renderer = renderer
        
        self.shaderFactory = renderer.polyListShaderFactory
    }
    
    public init(polyList: BG2PolyList, material: BG2Material, renderer: BG2Renderer) {
        self.polyList = polyList
        self.material = material
        self.renderer = renderer
        
        self.shaderFactory = renderer.polyListShaderFactory
    }
    
    public init(polyList: BG2PolyList, material: BG2Material, transform: float4x4, renderer: BG2Renderer) {
        self.polyList = polyList
        self.material = material
        self.transform = transform
        self.renderer = renderer
        
        self.shaderFactory = renderer.polyListShaderFactory
    }
    
    public lazy var pipelineState: MTLRenderPipelineState = {
        let descriptor = MTLRenderPipelineDescriptor()
        let plState: MTLRenderPipelineState
        
        do {
            descriptor.label = "DrawableItem pipeline"
        
            // Use material and poly list properties to setup the shader
            shaderFactory.setup(pipelineDescriptor: descriptor, material: material)
            //descriptor.vertexDescriptor = polyList.vertexDescriptor
            descriptor.vertexDescriptor = MTKMetalVertexDescriptorFromModelIO(polyList.mesh!.vertexDescriptor)
            
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
                                   normal: matrix_float3x3.init(normalFrom4x4: itemWorldMatrix))
        
        renderEncoder.setVertexBytes(&uniforms,
                                     length: MemoryLayout<MatrixState>.stride,
                                     index: Int(MatrixStateIndex.rawValue))
        
        material.draw(encoder: renderEncoder)
        polyList.draw(encoder: renderEncoder)
    }
}
