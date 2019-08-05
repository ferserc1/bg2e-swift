//
//  RotatingComponent.swift
//  Mac Playground
//
//  Created by Fernando Serrano Carpena on 31/07/2019.
//  Copyright © 2019 Fernando Serrano Carpena. All rights reserved.
//

import Foundation
import bg2e_mac

public class RotatingComponent: BG2SceneComponent {
    
    public override init() {
        super.init()
    }
    
    public override func update(delta: Float) {
        guard let so = self.sceneObject,
            let transform = so.transform
        else {
            return
        }
        
        transform.matrix *= matrix_float4x4.init(rotationY: delta)
    }
}
