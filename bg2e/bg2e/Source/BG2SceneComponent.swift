//
//  BG2SceneComponent.swift
//  bg2e-mac
//
//  Created by Fernando Serrano Carpena on 29/06/2019.
//  Copyright © 2019 Fernando Serrano Carpena. All rights reserved.
//

import MetalKit

open class BG2SceneComponent {
    public var typeName: String {
        get {
            return String(describing: type(of: self))
        }
    }
    
    internal var sceneObjectInternal: BG2SceneObject? = nil

    public init() {
        
    }
    
    // Life cycle functions
    open func componentAdded() {
        
    }
    
    open func componentRemoved() {
        
    }
    
    open func update(delta: Float) {
        
    }
    
    open func draw(viewMatrix: matrix_float4x4, projectionMatrix: matrix_float4x4, renderEncoder: MTLRenderCommandEncoder) {
        
    }
}

// Scene functions
public extension BG2SceneComponent {
    var sceneObject: BG2SceneObject? {
        get {
            return sceneObjectInternal
        }
    }
    
    var parentSceneObject: BG2SceneObject? {
        get {
            guard let so = sceneObject,
                let parent = so.parent else {
                return nil
            }
            return parent
        }
    }
    
    var renderer: BG2Renderer? {
        get {
            guard let sceneObject = sceneObject else {
                return nil
            }
            return sceneObject.renderer
        }
    }
}

