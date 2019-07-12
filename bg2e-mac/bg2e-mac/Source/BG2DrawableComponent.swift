//
//  BG2DrawableComponent.swift
//  bg2e-mac
//
//  Created by Fernando Serrano Carpena on 12/07/2019.
//  Copyright © 2019 Fernando Serrano Carpena. All rights reserved.
//

import Foundation

public class BG2DrawableComponent: BG2SceneComponent {
    
    public var drawableItems: [BG2DrawableItem] = []
    
    public override init() {
        super.init()
    }
    
    // Life cycle functions
    override func draw() {
        let trx: matrix_float4x4
        if let sceneObject = self.sceneObject {
            trx = sceneObject.worldMatrix
        } else {
            trx = matrix_identity_float4x4
        }
        
        // TODO: Draw elements
    }
}

// SceneObject extensions
public extension BG2SceneObject {
    var drawable: BG2DrawableComponent? {
        get {
            return component(ofType: BG2DrawableComponent.self) as? BG2DrawableComponent
        }
    }
}