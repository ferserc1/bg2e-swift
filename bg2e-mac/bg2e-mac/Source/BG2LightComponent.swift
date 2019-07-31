//
//  BG2LightComponent.swift
//  bg2e-mac
//
//  Created by Fernando Serrano Carpena on 12/07/2019.
//  Copyright © 2019 Fernando Serrano Carpena. All rights reserved.
//

import Foundation

public class BG2LightComponent: BG2SceneComponent {
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
    
    public override func update(delta: Float) {
        guard let sc = sceneObject else {
            return
        }
        if sc.transformChanged || !_transformUpdated {
            let worldMatrix = sc.worldMatrix
            _light.position = (worldMatrix * SIMD4<Float>(0.0,0.0,0.0,1.0)).xyz
            _light.direction = normalize(_light.position - (worldMatrix * SIMD4<Float>(0.0,0.0,1.0,1.0)).xyz)
            _transformUpdated = true
        }
    }
}

public extension BG2SceneObject {
    var light: BG2LightComponent? {
        get {
            return component(ofType: BG2LightComponent.self) as? BG2LightComponent
        }
    }
}
