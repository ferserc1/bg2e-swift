//
//  BG2Light.swift
//  bg2e-mac
//
//  Created by Fernando Serrano Carpena on 10/07/2019.
//  Copyright © 2019 Fernando Serrano Carpena. All rights reserved.
//

import Foundation

public class BG2Light {
    private var lightData: ShaderLight = ShaderLight()
    
    public var shaderLightData: ShaderLight {
        get {
            return lightData
        }
    }
    
    public enum LightType {
        case directionalLight
        case pointLight
        case spotLight
        case disabledLight
    };
    
    public init() {
        lightData.color = vector_float3(1.0,1.0,1.0)
        lightData.attenuation = vector_float3(1.0, 0.5, 0.1)
        lightData.position = vector_float3(0.0, 0.0, 0.0)
        lightData.direction = vector_float3(0.0, 0.0, 1.0)
        lightData.intensity = 1.0;
        lightData.type = DirectionalLightType
    }
}

// Phong light properties
public extension BG2Light {
    var lightType: LightType {
        get {
            switch lightData.type {
            case DirectionalLightType:
                return .directionalLight
            case PointLightType:
                return .pointLight
            case SpotLightType:
                return .spotLight
            default:
                return .disabledLight
            }
        }
        set {
            switch newValue {
            case .directionalLight:
                lightData.type = DirectionalLightType
            case .pointLight:
                lightData.type = PointLightType
            case .spotLight:
                lightData.type = SpotLightType
            default:
                lightData.type = DisabledLightType
            }
        }
    }
    
    var color: SIMD3<Float> {
        get {
            return lightData.color
        }
        set {
            lightData.color = newValue
        }
    }
        
    var intensity: Float {
        get {
            return lightData.intensity
        }
        set {
            lightData.intensity = newValue
        }
    }
    
    var attenuation: SIMD3<Float> {
        get {
            return lightData.attenuation
        }
        set {
            lightData.attenuation = newValue
        }
    }

    var position: SIMD3<Float> {
        get {
            return lightData.position
        }
        set {
            lightData.position = newValue
        }
    }
    
    var direction: SIMD3<Float> {
        get {
            return lightData.direction
        }
        set {
            lightData.direction = newValue
        }
    }
}

public extension BG2Light {
    var lightTypeCode: Int {
        get {
            switch self.lightType {
            case .directionalLight:
                return 4
            case .pointLight:
                return 5
            case .spotLight:
                return 1
            default:
                return 0
            }
        }
        set {
            switch newValue {
            case 4:
                self.lightType = .directionalLight
            case 5:
                self.lightType = .pointLight
            case 1:
                self.lightType = .spotLight
            default:
                self.lightType = .disabledLight
            }
        }
    }
    
    var constantAttenuation: Float {
        get {
            return attenuation.x
        }
        set {
            attenuation.x = newValue
        }
    }
    var linearAttenuation: Float {
        get {
            return attenuation.y
        }
        set {
            attenuation.y = newValue
        }
    }
    var quadraticAttenuation: Float {
        get {
            return attenuation.z
        }
        set {
            attenuation.z = newValue
        }
    }
}
