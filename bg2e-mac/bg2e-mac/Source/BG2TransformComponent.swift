//
//  BG2TransformComponent.swift
//  bg2e-mac
//
//  Created by Fernando Serrano Carpena on 29/06/2019.
//  Copyright © 2019 Fernando Serrano Carpena. All rights reserved.
//

import Foundation

public class BG2TransformComponent: BG2SceneComponent {
    public var matrix: matrix_float4x4 = matrix_identity_float4x4
    
    public override init() {
        super.init()
    }
}
