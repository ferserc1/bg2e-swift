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
                return self.material.isTransparent
            }
        }
        set {
            self.material.isTransparent = newValue
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
            return self.material.castShadows
        }
        set {
            self.material.castShadows = newValue
        }
    }
    
    public var unlit: Bool  {
        get {
            return self.material.unlit
        }
        set {
            self.material.unlit = newValue
        }
    }
    
    public var cullFace: Bool = true
    
    public var visibleToShadows: Bool  {
        get {
            return self.material.visibleToShadows
        }
        set {
            self.material.visibleToShadows = newValue
        }
    }
    
    public var visible: Bool  {
        get {
            return self.material.visible
        }
        set {
            self.material.visible = newValue
        }
    }
    
    private var material: PBRMaterial
    
    init() {
        material = PBRMaterial()
        material.albedo = vector_float4(1,1,1,1)
        material.albedoScale = vector_float2(1,1)
        material.albedoUV = 0
        material.isTransparent = false
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
        
        material.castShadows = true
        material.unlit = false
        material.visibleToShadows = true
        material.visible = true
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
            .origin: MTKTextureLoader.Origin.bottomLeft
        ]
        // TODO: Texture cache
        return try textureLoader.newTexture(URL: path, options: textureLoaderOptions)
    }
}

extension BG2Material {
    func draw(encoder: MTLRenderCommandEncoder) {
        encoder.setFragmentBytes(&self.material, length: MemoryLayout<PBRMaterial>.stride, index: Int(PBRMaterialUniformIndex.rawValue))
        encoder.setFragmentTexture(self.albedoTexture, index: Int(AlbedoTextureIndex.rawValue))
        
        // TODO: other textures
        // TODO: function constants
    }
}


