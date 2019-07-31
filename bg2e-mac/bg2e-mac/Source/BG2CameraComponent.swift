//
//  BG2ECameraComponent.swift
//  bg2e-mac
//
//  Created by Fernando Serrano Carpena on 09/07/2019.
//  Copyright © 2019 Fernando Serrano Carpena. All rights reserved.
//

import Foundation

public class BG2CameraComponent : BG2SceneComponent {
    public var projection: float4x4 = matrix_identity_float4x4
    
    public var view: float4x4 {
        get {
            if let so = sceneObject {
                let world = so.worldMatrix;
                return world.inverse;
            } else {
                return matrix_identity_float4x4;
            }
        }
    }
    
    public override init() {
        super.init()
    }
}

// Scene object extensions
public extension BG2SceneObject {
    var camera: BG2CameraComponent? {
        get {
            return component(ofType: BG2CameraComponent.self) as? BG2CameraComponent
        }
    }
}
