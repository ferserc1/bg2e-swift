//
//  ViewController.swift
//  Mac Playground
//
//  Created by Fernando Serrano Carpena on 6/2/21.
//

import Cocoa
import MetalKit

class ViewController: NSViewController {
    var renderer: BG2Renderer?
    //var drawableItem: BG2DrawableItem?
    //var scene: BG2SceneObject?
    
    var timeToUpdate: Float = 0
    

    override func viewDidLoad() {
        super.viewDidLoad()

        guard let metalView = view as? MTKView else {
            fatalError("Please, set the view to be an instance of MTKView")
        }
        
        renderer = BG2Renderer(metalView: metalView)
        
        // createScene()
        
        renderer?.delegate = self
    }

//    func createScene() {
//        guard let renderer = renderer else {
//            fatalError("Could not create scene: invalid renderer")
//        }
//
//        scene = BG2SceneObject(withRenderer: renderer)
//
//        let cameraNode = BG2SceneObject(withRenderer: renderer)
//        let camera = BG2CameraComponent()
//        let aspect: Float = Float(view.bounds.size.width) / Float(view.bounds.size.height)
//        camera.projection = float4x4.init(perspectiveFov: 45, near: 0.1, far: 100.0, aspect: aspect)
//        //camera.position = float4x4.init(translate: SIMD3<Float>(0, 0, -3))
//        cameraNode.addComponent(camera)
//
//        renderer.mainCamera = camera;
//
//        var transform = BG2TransformComponent()
//        transform.matrix =
//            matrix_float4x4.init(translate: SIMD3<Float>(0,1,-3)) *
//            matrix_float4x4.init(rotationX: Float(12).degreesToRadians)
//
//        cameraNode.addComponent(transform)
//
//        scene?.addChild(cameraNode)
//
//        let lightNode = BG2SceneObject(withRenderer: renderer)
//        let light = BG2LightComponent()
//        lightNode.addComponent(light)
//
//        transform = BG2TransformComponent()
//        transform.matrix =
//            matrix_float4x4.init(rotationY: Float(33).degreesToRadians) *
//            matrix_float4x4.init(rotationX: Float(55).degreesToRadians) *
//            matrix_float4x4.init(translate: SIMD3<Float>(0,0,5))
//        lightNode.addComponent(transform)
//        //lightTransform = transform
//
//        scene?.addChild(lightNode)
//
//        let drawable = loadDrawable()
//        let drawableNode = BG2SceneObject(withRenderer: renderer)
//        drawableNode.addComponent(drawable)
//        drawableNode.addComponent(BG2TransformComponent())
//        drawableNode.addComponent(RotatingComponent())
//        scene?.addChild(drawableNode)
//
//        renderer.sceneRoot = scene
//    }

    
}

extension ViewController: BG2RendererDelegate {
    func createScene(renderer: BG2Renderer) -> BG2SceneObject {

        let scene = BG2SceneObject(withRenderer: renderer)
        
        let cameraNode = BG2SceneObject(withRenderer: renderer)
        let camera = BG2CameraComponent()
        let aspect: Float = Float(view.bounds.size.width) / Float(view.bounds.size.height)
        camera.projection = float4x4.init(perspectiveFov: 45, near: 0.1, far: 100.0, aspect: aspect)
        //camera.position = float4x4.init(translate: SIMD3<Float>(0, 0, -3))
        cameraNode.addComponent(camera)
        
        renderer.mainCamera = camera;
        
        var transform = BG2TransformComponent()
        transform.matrix =
            matrix_float4x4.init(translate: SIMD3<Float>(0,1,-3)) *
            matrix_float4x4.init(rotationX: Float(12).degreesToRadians)
        
        cameraNode.addComponent(transform)
        
        scene.addChild(cameraNode)
        
        let lightNode = BG2SceneObject(withRenderer: renderer)
        let light = BG2LightComponent()
        lightNode.addComponent(light)
        
        transform = BG2TransformComponent()
        transform.matrix =
            matrix_float4x4.init(rotationY: Float(33).degreesToRadians) *
            matrix_float4x4.init(rotationX: Float(55).degreesToRadians) *
            matrix_float4x4.init(translate: SIMD3<Float>(0,0,5))
        lightNode.addComponent(transform)
        //lightTransform = transform
        
        scene.addChild(lightNode)
        
        let drawable = loadDrawable()
        let drawableNode = BG2SceneObject(withRenderer: renderer)
        drawableNode.addComponent(drawable)
        drawableNode.addComponent(BG2TransformComponent())
        drawableNode.addComponent(RotatingComponent())
        
        return scene
    }
    
    func loadDrawable() -> BG2DrawableComponent {
        guard let url = Bundle.main.url(forResource: "test_cube", withExtension: "bg2"),
              let renderer = renderer else {
            fatalError("Could not load drawable")
        }
        
        let model = BG2ModelLoad(contentsOfFile: url, renderer: renderer)
        let drawableComponent = BG2DrawableComponent()
        for item in model.drawableItems {
            drawableComponent.drawableItems.append(item)
        }
        
        return drawableComponent
    }
    
    func resize(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        
    }
    
    func update(_ delta: Float, renderer: BG2Renderer) {
        
    }
}

