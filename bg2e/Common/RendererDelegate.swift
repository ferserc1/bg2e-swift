//
//  RendererDelegate.swift
//  bg2e
//
//  Created by Fernando Serrano Carpena on 6/2/21.
//

import MetalKit

public class RendererDelegate {
    
}

extension RendererDelegate: BG2RendererDelegate {
    public func createScene(renderer: BG2Renderer) -> BG2SceneObject {

        let scene = BG2SceneObject(withRenderer: renderer)
        
        let cameraNode = BG2SceneObject(withRenderer: renderer)
        let camera = BG2CameraComponent()
        cameraNode.addComponent(camera)
        
        renderer.mainCamera = camera;
        
        var transform = BG2TransformComponent()
        transform.matrix =
            matrix_float4x4.init(translate: SIMD3<Float>(0,2,-4)) *
            matrix_float4x4.init(rotationX: Float(22).degreesToRadians)
        
        cameraNode.addComponent(transform)
        
        scene.addChild(cameraNode)
        
        let lightNode = BG2SceneObject(withRenderer: renderer)
        let light = BG2LightComponent()
        light.light.intensity = 0.2
        lightNode.addComponent(light)
        
        transform = BG2TransformComponent()
        transform.matrix =
            matrix_float4x4.init(rotationY: Float(-33).degreesToRadians) *
            matrix_float4x4.init(rotationX: Float(65).degreesToRadians) *
            matrix_float4x4.init(translate: SIMD3<Float>(0,0,5))
        lightNode.addComponent(transform)
        //lightTransform = transform
        
        scene.addChild(lightNode)
        
        let drawable = loadDrawable(renderer: renderer)
        let drawableNode = BG2SceneObject(withRenderer: renderer)
        drawableNode.addComponent(drawable)
        drawableNode.addComponent(BG2TransformComponent())
        drawableNode.addComponent(RotatingComponent())
        scene.addChild(drawableNode)
        
        return scene
    }
    
    func loadDrawable(renderer: BG2Renderer) -> BG2DrawableComponent {
        guard let url = Bundle.main.url(forResource: "test_cube", withExtension: "bg2") else {
            fatalError("Could not load drawable")
        }
        
        let model = BG2ModelLoad(contentsOfFile: url, renderer: renderer)
        let drawableComponent = BG2DrawableComponent()
        for item in model.drawableItems {
            drawableComponent.drawableItems.append(item)
        }
        
        return drawableComponent
    }
    
    public func resize(_ view: MTKView, drawableSizeWillChange size: CGSize, renderer: BG2Renderer) {
        guard let camera = renderer.mainCamera else {
            return
        }
        
        let aspect: Float = Float(view.bounds.size.width) / Float(view.bounds.size.height)
        camera.projection = float4x4.init(perspectiveFov: 45, near: 0.1, far: 100.0, aspect: aspect)
        //camera.position = float4x4.init(translate: SIMD3<Float>(0, 0, -3))
    }
    
    public func update(_ delta: Float, renderer: BG2Renderer) {
        
    }
}
