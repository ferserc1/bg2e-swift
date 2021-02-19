//
//  BG2EMaterial.swift
//  bg2e-mac
//
//  Created by Fernando Serrano Carpena on 30/06/2019.
//  Copyright © 2019 Fernando Serrano Carpena. All rights reserved.
//

import MetalKit

public class BG2Material {
    public var name: String = ""
    public var groupName: String = ""
    
    public var albedo: vector_float4 {
        get {
            return self.material.albedo
        }
        set {
            self.material.albedo = newValue
        }
    }
    
    public var albedoTexture: MTLTexture! = nil
    
    public var albedoScale: vector_float2 {
        get {
            return self.material.albedoScale
        }
        set {
            self.material.albedoScale = newValue
        }
    }
    
    public var albedoUV: Int  {
        get {
            return Int(self.material.albedoUV)
        }
        set {
            self.material.albedoUV = Int32(newValue)
        }
    }
    
    public var isTransparent: Bool {
        get {
            if albedoTexture == nil {
                return albedo.w < 1
            } else {
                return self.material.isTransparent != 0
            }
        }
        set {
            self.material.isTransparent = newValue ? 1 : 0
        }
    }
    
    public var alphaCutoff: Float {
        get {
            return self.material.alphaCutoff
        }
        set {
            self.material.alphaCutoff = newValue
        }
    }
    
    public var ambientOcclussionTexture: MTLTexture! = nil
    
    public var ambientOcclussionUV: Int {
        get {
            return Int(self.material.aoUV)
        }
        set {
            self.material.aoUV = Int32(newValue)
        }
    }
    
    public var metallic: Float  {
        get {
            return self.material.metallic
        }
        set {
            self.material.metallic = newValue
        }
    }
    
    public var metallicTexture: MTLTexture! = nil
    
    public var metallicScale: vector_float2  {
        get {
            return self.material.metallicScale
        }
        set {
            self.material.metallicScale = newValue
        }
    }
    
    public var metallicTextureChannel: Int  {
        get {
            return Int(self.material.metallicChannel)
        }
        set {
            self.material.metallicChannel = Int32(newValue)
        }
    }
    
    public var metallicUV: Int  {
        get {
            return Int(self.material.metallicUV)
        }
        set {
            self.material.metallicUV = Int32(newValue)
        }
    }
    
    public var roughness: Float  {
        get {
            return self.material.roughness
        }
        set {
            self.material.roughness = newValue
        }
    }
    
    public var roughnessTexture: MTLTexture! = nil
    
    public var roughnessScale: vector_float2  {
        get {
            return self.material.roughnessScale
        }
        set {
            self.material.roughnessScale = newValue
        }
    }
    
    public var roughnessTextureChannel: Int  {
        get {
            return Int(self.material.roughnessChannel)
        }
        set {
            self.material.roughnessChannel = Int32(newValue)
        }
    }
    
    public var roughnessUV: Int  {
        get {
            return Int(self.material.roughnessUV)
        }
        set {
            self.material.roughnessUV = Int32(newValue)
        }
    }
    
    public var fresnel: vector_float4  {
        get {
            return self.material.fresnel
        }
        set {
            self.material.fresnel = newValue
        }
    }
    
    public var normalTexture: MTLTexture! = nil
    
    public var normalScale: vector_float2  {
        get {
            return self.material.normalScale
        }
        set {
            self.material.normalScale = newValue
        }
    }
    
    public var normalUV: Int  {
        get {
            return Int(self.material.normalUV)
        }
        set {
            self.material.normalUV = Int32(newValue)
        }
    }
    
    public var castShadows: Bool  {
        get {
            return self.material.castShadows != 0
        }
        set {
            self.material.castShadows = newValue ? 1 : 0
        }
    }
    
    public var unlit: Bool  {
        get {
            return self.material.unlit != 0
        }
        set {
            self.material.unlit = newValue ? 1 : 0
        }
    }
    
    public var cullFace: Bool = true
    
    public var visibleToShadows: Bool  {
        get {
            return self.material.visibleToShadows != 0
        }
        set {
            self.material.visibleToShadows = newValue ? 1 : 0
        }
    }
    
    public var visible: Bool  {
        get {
            return self.material.visible != 0
        }
        set {
            self.material.visible = newValue ? 1 : 0
        }
    }
    
    private var material: ShaderMaterial
    
    init() {
        material = ShaderMaterial()
        material.albedo = vector_float4(1,1,1,1)
        material.albedoScale = vector_float2(1,1)
        material.albedoUV = 0
        material.isTransparent = 0
        material.alphaCutoff = 0.5
        
        material.aoUV = 0;
        
        material.metallic = 0
        material.metallicScale = vector_float2(1,1)
        material.metallicChannel = 0
        material.metallicUV = 0
        
        material.roughness = 1
        roughnessScale = vector_float2(1,1)
        material.roughnessChannel = 0
        material.roughnessUV = 0
        
        material.fresnel = vector_float4(1,1,1,1)
        
        material.normalScale = vector_float2(1,1)
        material.normalUV = 0
        
        material.castShadows = 1
        material.unlit = 0
        material.visibleToShadows = 1
        material.visible = 1
    }
}

public extension BG2Material {
    func setAlbedoTexture(withPath path: URL, uv: Int = 0, renderer: BG2Renderer) throws {
        albedoTexture = try loadTexture(withPath: path, renderer: renderer)
        albedoUV = uv
    }
    
    func setMetallicTexture(withPath path: URL, channel: Int = 0, uv: Int = 0, renderer: BG2Renderer) throws {
        metallicTexture = try loadTexture(withPath: path, renderer: renderer)
        metallicTextureChannel = channel
        metallicUV = uv
    }
    
    func setRoughnessTexture(withPath path: URL, channel: Int = 0, uv: Int = 0, renderer: BG2Renderer) throws {
        roughnessTexture = try loadTexture(withPath: path, renderer: renderer)
        roughnessTextureChannel = channel
        roughnessUV = uv
    }
     
    func setAmbientOcclussionTexture(withPath path: URL, uv: Int = 0, renderer: BG2Renderer) throws {
        ambientOcclussionTexture = try loadTexture(withPath: path, renderer: renderer)
        ambientOcclussionUV = uv
    }
    
    func setNormalTexture(withPath path: URL, uv: Int = 0, renderer: BG2Renderer) throws {
        normalTexture = try loadTexture(withPath: path, renderer: renderer)
        normalUV = 0
    }
    
    func loadTexture(withPath path: URL, renderer: BG2Renderer) throws -> MTLTexture! {
        let textureLoader = MTKTextureLoader(device: renderer.device)
        let textureLoaderOptions: [MTKTextureLoader.Option: Any] = [
            .origin: MTKTextureLoader.Origin.bottomLeft,
            .SRGB: false
        ]
        // TODO: Texture cache
        return try textureLoader.newTexture(URL: path, options: textureLoaderOptions)
    }
}

public extension BG2Material {
    func makeFunctionConstants() -> MTLFunctionConstantValues {
        let functionConstants = MTLFunctionConstantValues()
        var property = albedoTexture != nil
        functionConstants.setConstantValue(&property, type: .bool, index: Int(FuncConstColorTextureIndex.rawValue))
        
        property = metallicTexture != nil
        functionConstants.setConstantValue(&property, type: .bool, index: Int(FuncConstMetallicTextureIndex.rawValue))

        property = roughnessTexture != nil
        functionConstants.setConstantValue(&property, type: .bool, index: Int(FuncConstRoughnessTextureIndex.rawValue))

        property = ambientOcclussionTexture != nil
        functionConstants.setConstantValue(&property, type: .bool, index: Int(FuncConstAOTextureIndex.rawValue))

        property = normalTexture != nil
        functionConstants.setConstantValue(&property, type: .bool, index: Int(FuncConstNormalTextureIndex.rawValue))
                
        return functionConstants
    }
}

extension BG2Material {
    func draw(encoder: MTLRenderCommandEncoder) {
        encoder.setFragmentBytes(&self.material, length: MemoryLayout<ShaderMaterial>.stride, index: Int(PBRMaterialUniformIndex.rawValue))
        encoder.setFragmentTexture(self.albedoTexture, index: Int(AlbedoTextureIndex.rawValue))
        encoder.setFragmentTexture(self.metallicTexture, index: Int(MetallicTextureIndex.rawValue))
        encoder.setFragmentTexture(self.roughnessTexture, index: Int(RoughnessTextureIndex.rawValue))
        encoder.setFragmentTexture(self.normalTexture, index: Int(NormalTextureIndex.rawValue))
        encoder.setFragmentTexture(self.ambientOcclussionTexture, index: Int(AOTextureIndex.rawValue))
    }
}


