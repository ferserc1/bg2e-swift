# bg2 engine Swift APPI

## Create a new app

### File structure

The structure of the files and directories is free, but if you decide to choose another structure, you must take it into account to modify the paths specified in the following instructions. Here we detail the proposal of directories that we propose. At the end of this example, we will have implemented a very basic test application with bg2 engine.

- root
	* MyProject.xcodeproj
	* Common (here we'll place application files that are shared between the mac and iOS app)
		+ RotatingComponent.swift (see "common" section)
		+ RendererDelegate.swift (see "common" section)
		+ data (from bg2 engine data resources)
	* iOS or Mac App
		+ iOS or Mac specific files
	* bg2e  (engine source)
		+ Shaders
		+ Source
		+ Other bg2 engine source code and resources

The engine source is extracted directly from the bg2 engine source code, located at `[bg2e root]/bg2e/bg2e`.

### iOS (Storyboard)

- Create a project or target with the template iOS App, using storyboards for the user interface
- Open the main storyboard and change the class to MTKView
- In the target setttings, at `Build Settings` section, search for the section `Objective-C Bridging Header`, and set the path `bg2e/Shaders/ShaderCommon.h`
- Create a group at the root of the project with the name `bg2e`, and add the content of the `bg2e` folder. It should look like this, in Project navigator:

* MyProject
	- bg2e
		+ Shaders
		+ Source
	- iOS App file group
		+ app files

- Modify the view controller source code. Please note that this code will not work until the "Common" section is completed:

```swift
import UIKit
import MetalKit

class ViewController: UIViewController {
	var renderer: BG2Renderer?

	override func viewDidLoad() {
		super.viewDidLoad()
		
		guard let metalView = view as? MTKView else {
			fatalError("Please, set the view to be an instance of MTKView")
		}
		
		renderer = BG2Renderer(metalView: metalView)
		renderer?.delegate = RendererDelegate()
	}
}
```

### macOS (Storyboard)

- Create a project or target with the template Mac App, using storyboards for the user interface
- Open the main storyboard and change the class to MTKView
- Add the following code to the `viewDidLoad()` function, in `ViewController.swift`
- In the target setttings, at `Build Settings` section, search for the section `Objective-C Bridging Header`, and set the path `bg2e/Shaders/ShaderCommon.h`
- Create a group at the root of the project with the name `bg2e`, and add the content of the `bg2e` folder. It should look like this, in Project navigator:

* MyProject
	- bg2e
		+ Shaders
		+ Source
	- Mac App file group
		+ app files

- Modify the view controller source code. Please note that this code will not work until the "Common" section is completed:

```swift
import UIKit
import MetalKit

class ViewController: NSViewController {
	var renderer: BG2Renderer?

	override func viewDidLoad() {
		super.viewDidLoad()
		
		guard let metalView = view as? MTKView else {
			fatalError("Please, set the view to be an instance of MTKView")
		}
		
		renderer = BG2Renderer(metalView: metalView)
		renderer?.delegate = RendererDelegate()
	}
}
```

### Common

The following files must to be created at the Common folder. If you have one target for mac app and one for iOS app, you will have to add them both.

- Add the following files to the `Common` folder. If you have two targets for macOS and iOS application, don't forget to add the files to both targets

**RotatingComponent.swift:**

```Swift
import Foundation

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
```

**RendererDelegate.swift:**

```Swift
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
```

-- Add the `data` folder from bg2 engine resources to the common group. If you have two targets for macOS and iOS application, don't forget to add the files to both targets.

