//
//  BG2LightComponent.swift
//  bg2e-mac
//
//  Created by Fernando Serrano Carpena on 12/07/2019.
//  Copyright © 2019 Fernando Serrano Carpena. All rights reserved.
//

import Foundation

public class BG2LightComponent: BG2SceneComponent {
    private static var _sceneLights: [BG2LightComponent] = []
    public static var sceneLights: [BG2LightComponent] {
        get {
            return _sceneLights
        }
    }
    
    private static var _shaderLightsChanged: Bool = true
    private static var _shaderLights: [ShaderLight] = []
    public static var shaderLights: [ShaderLight] {
        get {
            if (_shaderLightsChanged) {
                _shaderLights.removeAll(keepingCapacity: true)
                for l in _sceneLights {
                    _shaderLights.append(l.light.shaderLightData)
                }
                _shaderLightsChanged = false
            }
            return _shaderLights
        }
    }
    
    private let _light: BG2Light = BG2Light()
    private var _transformUpdated: Bool = false
    
    public var light: BG2Light {
        get {
            return _light
        }
    }
    
    public override init() {
        super.init()
    }
    
    public override func componentAdded() {
        if BG2LightComponent._sceneLights.firstIndex(of: self) != nil {
            return
        }
        BG2LightComponent._sceneLights.append(self)
        BG2LightComponent._shaderLights.append(self.light.shaderLightData)
    }
    
    public override func componentRemoved() {
        guard let index = BG2LightComponent._sceneLights.firstIndex(of: self) else {
            return
        }
        BG2LightComponent._sceneLights.remove(at: index)
        BG2LightComponent._shaderLights.remove(at: index)
    }
    
    public override func update(delta: Float) {
        guard let sc = sceneObject else {
            return
        }
        if sc.transformChanged || !_transformUpdated {
            BG2LightComponent._shaderLightsChanged = true
            let worldMatrix = sc.worldMatrix
            _light.position = (worldMatrix * SIMD4<Float>(0.0,0.0,0.0,1.0)).xyz
            _light.direction = normalize(_light.position - (worldMatrix * SIMD4<Float>(0.0,0.0,1.0,1.0)).xyz)
            _transformUpdated = true
        }
    }
}

extension BG2LightComponent: Equatable {
    public static func == (lhs: BG2LightComponent, rhs: BG2LightComponent) -> Bool {
        lhs === rhs
    }
}

public extension BG2SceneObject {
    var light: BG2LightComponent? {
        get {
            return component(ofType: BG2LightComponent.self) as? BG2LightComponent
        }
    }
}
