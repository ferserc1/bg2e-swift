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
    
    public var albedo: SIMD4<Float> = SIMD4<Float>(1,1,1,1)
    public var albedoTexture: MTLTexture! = nil
    public var albedoScale: SIMD2<Float> = SIMD2<Float>(1,1)
    public var albedoUV: Int = 0
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
    public var alphaCutoff: Float = 0.5
    
    public var ambientOcclussionTexture: MTLTexture! = nil
    public var ambientOcclussionUV: Int = 0
    
    public var metallic: Float = 0
    public var metallicTexture: MTLTexture! = nil
    public var metallicScale: SIMD2<Float> = SIMD2<Float>(1,1)
    public var metallicTextureChannel: Int = 0
    public var metallicUV: Int = 0
    
    public var roughness: Float = 1
    public var roughnessTexture: MTLTexture! = nil
    public var roughnessScale: SIMD2<Float> = SIMD2<Float>(1,1)
    public var roughnessTextureChannel: Int = 0
    public var roughnessUV: Int = 0
    
    public var fresnel: SIMD4<Float> = SIMD4<Float>(1,1,1,1)
    
    public var normalTexture: MTLTexture! = nil
    public var normalScale: SIMD2<Float> = SIMD2<Float>(1,1)
    public var normalUV: Int = 0
    
    public var castShadows: Bool = true
    public var unlit: Bool = false
    public var cullFace: Bool = true
    public var visibleToShadows: Bool = true
    public var visible: Bool = true
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
