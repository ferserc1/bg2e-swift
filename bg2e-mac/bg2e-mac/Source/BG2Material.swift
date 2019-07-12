//
//  BG2EMaterial.swift
//  bg2e-mac
//
//  Created by Fernando Serrano Carpena on 30/06/2019.
//  Copyright © 2019 Fernando Serrano Carpena. All rights reserved.
//

import MetalKit

public class BG2Material {
    
    public var albedo: SIMD4<Float> = SIMD4<Float>(1,1,1,1)
    public var metallic: Float = 0
    public var roughness: Float = 1
    public var lightEmission: Float = 0
    
    private var _isTransparent: Bool = false
    public var isTransparent: Bool {
        get {
            if albedoTexture == nil {
                return albedo.w < 1
            } else {
                return _isTransparent
            }
        }
        set {
            _isTransparent = newValue
        }
    }
    
    public var textureScale: SIMD2<Float> = SIMD2<Float>(1,1)
    public var textureOffset: SIMD2<Float> = SIMD2<Float>(0,0)
    public var albedoTexture: MTLTexture! = nil
    public var metallicTexture: MTLTexture! = nil
    public var metallicTextureChannel: Int = 0
    public var roughnessTexture: MTLTexture! = nil
    public var roughnessTextureChannel: Int = 0
    public var lightEmissionTexture: MTLTexture! = nil
    public var lightEmissionTextureChannel: Int = 0
    public var ambientOcclussionTexture: MTLTexture! = nil
    public var ambientOcclussionTextureChannel: Int = 0

    public var normalTexture: MTLTexture! = nil
    public var normalScale: SIMD2<Float> = SIMD2<Float>(1,1)
    public var normalOffset: SIMD2<Float> = SIMD2<Float>(0,0)
    
    public var castShadows: Bool = true
    public var cullFace: Bool = true
    public var unlit: Bool = false
    
    // Compatibility attributes (used to transform v1 to v2 materials)
    public var invertRoughness: Bool = false    // The roughness texture is calculated inverting the reflectionAmount v1 property
}

public extension BG2Material {
    func setAlbedoTexture(withPath path: URL, renderer: BG2Renderer) throws {
        albedoTexture = try loadTexture(withPath: path, renderer: renderer)
    }
    
    func setMetallicTexture(withPath path: URL, channel: Int = 0, renderer: BG2Renderer) throws {
        metallicTexture = try loadTexture(withPath: path, renderer: renderer)
        metallicTextureChannel = channel
    }
    
    func setRoughnessTexture(withPath path: URL, channel: Int = 0, renderer: BG2Renderer) throws {
        roughnessTexture = try loadTexture(withPath: path, renderer: renderer)
        roughnessTextureChannel = channel
    }
    
    func setLightEmissionTexture(withPath path: URL, channel: Int = 0, renderer: BG2Renderer) throws {
        lightEmissionTexture = try loadTexture(withPath: path, renderer: renderer)
        lightEmissionTextureChannel = channel
    }
 
    func setAmbientOcclussionTexture(withPath path: URL, channel: Int = 0, renderer: BG2Renderer) throws {
        ambientOcclussionTexture = try loadTexture(withPath: path, renderer: renderer)
        ambientOcclussionTextureChannel = channel
    }
    
    func setNormalTexture(withPath path: URL, renderer: BG2Renderer) throws {
        normalTexture = try loadTexture(withPath: path, renderer: renderer)
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
