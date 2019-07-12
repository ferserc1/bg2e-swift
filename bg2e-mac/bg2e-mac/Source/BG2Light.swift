//
//  BG2Light.swift
//  bg2e-mac
//
//  Created by Fernando Serrano Carpena on 10/07/2019.
//  Copyright © 2019 Fernando Serrano Carpena. All rights reserved.
//

import Foundation

public class BG2Light {
    public enum LightType {
        case directionalLight
        case pointLight
        case spotLight
        case disabledLight
    };
    
    public var lightType: LightType = .directionalLight
    public var color: SIMD4<Float> = SIMD4<Float>(1,1,1,1)
    public var intensity: Float = 1.0
    public var attenuation: SIMD3<Float> = SIMD3<Float>(1,0.5,0.1)
    public var position: SIMD3<Float> = SIMD3<Float>(0,0,0)
    public var direction: SIMD3<Float> = SIMD3<Float>(0,0,1)
    public var coneAngle: Float = Float(40).degreesToRadians
    public var coneAttenuation: Float = 12
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
