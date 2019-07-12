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
    
    // TODO: Calculate the view position using the position of the
    // camera node in the scene graph
    public var position: float4x4 = matrix_identity_float4x4
    
    public var view: float4x4 {
        get {
            return  self.position.inverse
        }
        set {
            self.position = newValue.inverse
        }
    }
    
    public override init() {
        super.init()
    }
}
