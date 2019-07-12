//
//  BG2TransformComponent.swift
//  bg2e-mac
//
//  Created by Fernando Serrano Carpena on 29/06/2019.
//  Copyright © 2019 Fernando Serrano Carpena. All rights reserved.
//

import Foundation

public class BG2TransformComponent: BG2SceneComponent {
    private var matrixInternal: matrix_float4x4 = matrix_identity_float4x4
    private var worldMatrixInternal: matrix_float4x4 = matrix_identity_float4x4
    private var invalid: Bool = false
    
    public var matrix: matrix_float4x4 {
        get {
            return matrixInternal
        }
        set {
            matrixInternal = newValue
            if let so = sceneObject {
                BG2TransformComponent.invalidateWorldMatrix(ofObject: so)
            }
        }
    }
    
    public var worldMatrix: matrix_float4x4 {
        get {
            // If invalid, use worldTransform to calculate the new world matrix value and store it in worldMatrixInternal
            if invalid, let so = sceneObject {
                worldMatrixInternal = BG2TransformComponent.worldTransform(ofObject: so)
            }
            return worldMatrixInternal
        }
    }
    
    public override init() {
        super.init()
    }
    
    static func worldTransform(ofObject sceneObject: BG2SceneObject) -> matrix_float4x4 {
        var result: matrix_float4x4 = matrix_identity_float4x4
        var parentMatrix: matrix_float4x4 = matrix_identity_float4x4
        
        if let p = sceneObject.parent {
            parentMatrix = BG2TransformComponent.worldTransform(ofObject: p)
        }
        
        if let trx = sceneObject.transform {
            trx.invalid = false
            result = parentMatrix * trx.matrix
        }
        
        return result
    }
    
    static func invalidateWorldMatrix(ofObject sceneObject: BG2SceneObject) {
        if let trx = sceneObject.transform {
            trx.invalid = true
        }
        sceneObject.children { BG2TransformComponent.invalidateWorldMatrix(ofObject: $0) }
    }
}

// Scene object extensions
public extension BG2SceneObject {
    var transform: BG2TransformComponent? {
        get {
            return component(ofType: BG2TransformComponent.self) as? BG2TransformComponent
        }
    }
    
    var worldMatrix: matrix_float4x4 {
        get {
            if let trx = transform {
                return trx.worldMatrix
            }
            else {
                return matrix_identity_float4x4
            }
        }
    }
}
