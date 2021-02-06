# bg2 engine Swift APPI

## Create a new app

### File structure

The structure of the files and directories is free, but if you decide to choose another structure, you must take it into account to modify the paths specified in the following instructions. Here we detail the proposal of directories that we propose

- root
	* MyProject.xcodeproj
	* Common (here we'll place application files that are shared between the mac and iOS app)
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

### Common

The following files must to be created at the Common folder. If you have one target for mac app and one for iOS app, you will have to add them both 
