# SwitchBoard

Convenient scene management functions and extensions for SpriteKit projects. Goal is to include tools for:

- Loading and caching scenes from .sks files
- Group scenes together when similar assets need to be loaded / unloaded
- Add extensions like scene recording to SKScene
- Handle world and debug layers

## Status

In progress.

Not battle hardened and tested. Still useful though.

Not designed for full flexibility. Scope limited to my projects. I would say 90% could be easily reused.

## Dependencies

Needs the Particleboard framework to build. As of this writing, Particleboard is only included for easing functions, so a hard coded easing function could replace this. Subject to change.

## Usage

### **Loading and Switching Scenes**

Let's start by loading one scene. First, create the scene with this criteria:

- FirstScene.swift which contains a class of `FirstScene : SBGameScene`
- FirstScene.sks

Next, register the scene in your View Controller. Place this in your `viewDidLoad`:

```swift
/// Store a strong reference to the scene manager.
var sceneManager : SBSceneManager?

override func viewDidLoad() {

    super.viewDidLoad()

    /// Create an instance of the scene manager
    self.sceneManager = SBSceneManager(view: self.view as! SKView)

    /// Register a scene
    self.sceneManager?.registerScene("FirstScene", 
        scene: SBSceneContainer(
            classType: FirstScene.self, 
            name: "FirstScene", 
            transition: nil, 
            preloadable: true, 
            category: SBSceneContainer.SceneGroup.World, 
            atlases: ["atlas1", "atlas2"]))

    /// Display the scene
    if let initialScene = self.sceneManager?.scenes["FirstScene"] {
        /// Perform more logic like loading a save file here
        self.sceneManager?.sceneDidFinish(initialScene)
    }

}
```

At this point, your first scene should properly show and the actual class type of `FirstScene` is loaded. Also, the atlases needed for the scene were loading in the background, and they will be smartly cached by the scene manager.

Next up, switch to a new scene. 

Create your second scene as you did the first. Back in the View Controller, register the second scene in exactly the same fashion as the first.

```swift
/// Register a scene
self.sceneManager?.registerScene("SecondScene", 
scene: SBSceneContainer(
classType: SecondScene.self, 
name: "SecondScene", 
transition: nil, 
preloadable: true, 
category: SBSceneContainer.SceneGroup.World, 
atlases: ["atlas3", "atlas4"]))
```

In `FirstScene`, we can place this code anywhere:

```swift
if let nextScene = self.sbViewDelegate?.scenes["SecondScene"] {
    self.sbViewDelegate?.sceneDidFinish(nextScene)
}
```

Because our scenes extend `SBGameScene`, the `sbViewDelegate` has a reference to the `SBSceneManager`. Again, all caching, preloading and transitions will be automatically handled.

From here, register as many scenes as you like, and switching between scenes is just a matter of that one if statement and a call to `sceneDidFinish(:nextScene)`.

### **Setting a Loading Scene**

If the `SBSceneManager` detects that the atlases for the next scene are not cached, or if switching to a new `SBSceneContainer.SceneGroup`, a Loading scene will be presented. Currently, this is **hard coded** to `Loading.sks`. So, if you create that in your project, it will be used.

### **Scene Groups**

Sometimes you want to clear cache between a scene, and sometimes you want to retain it. For example, imagine a world map with sub scenes like a store or troop management. You don't want the user to see a loading screen between that navigation. By setting `SBSceneContainer.SceneGroup`, the scenes will be loaded and cleared together. Then, when the user transitions to a scene of a different group, cache will be cleared, a loading screen will be presented, and the new assets loaded.

### **Loading Your Own Assets**

If you don't want to use the autoloading feature, just supply an empty array for the `atlases` parameter when registering a scene. Then, in your own code, you can use the built in completion handler:

```swift
override class func loadSceneAssetsWithCompletionHandler(handler:()->()) {
    SBGameScene.loadAndCacheSceneAssets(["atlas1", "atlas2"], handler: handler)
}
```

This allows you to perform logic before loading the assets. By then calling `loadAndCacheSceneAssets`, the caching mechanism is still utilized.

### **Extendeding SBGameScene**

Here is an example of how I extend SBGameScene to utilize all of the features it has:

```swift
class GameScene : SBGameScene {

    /// Stored reference to UI / HUD elemtns for quick lookup
    weak var ui : UINode?

    // MARK: World Layers

    /// Setup an array of child SKNodes to hold different visual elements
    override func buildWorldLayers() {

        /// I have an action bar at bototm of screen, so this will offset camera boundaries.
        self.cameraBounds = CameraBounds(lower: 100, left: 0, upper: 0, right: 0)

        /// Change width of scene if iPad
        if UIDevice.currentDevice().userInterfaceIdiom == .Pad {
            self.size = CGSize(width: 2048, height: 1536)
        }
        
        /// Call SBGamescene .buildWorldLayers which will set up the array of world nodes.
        super.buildWorldLayers()

        /// Manually create my own UI layer since it is custom and not empty. Add it to self.layers for easy adding and lookup
        let ui = UINode()
        ui.name = "UI"
        self.childNodeWithName("Camera")?.addChild(ui)
        ui.initDefaults(self)
        self.layers.append(ui)
        self.ui = ui

        /// Set the camera as the scenes camera.
        self.camera = self.childNodeWithName("Camera") as? SKCameraNode

        /// Contrain the camera
        self.setCameraBounds(self.cameraBounds)
    }

    // MARK: Debug

    /// If debug is enabled in my project, call super function to clean the debug layer every frame.
    override func updateDebugLayer() {
        if(Debug.Layers.enabled) {
            super.updateDebugLayer()
        }
    }

}

```

By doing this, I'll have the support of `SBGameScene`, and can then add onto `GameScene` for code specific to my project. In the example above, I showed a small snippet of that with the UI layer. The idea behind layers is that the camera will know what the world is, adding children won't require searching the node tree, etc. 

### **Screen Recording**

Example code to use screen recording:

```swift
func recordButtonTapped() {
    if let scene = self.scene as? GameScene {
        if(scene.recording) {
            scene.stopScreenRecordingWithHandler({ [weak self] in
                if let icon = self?.root?.childNodeWithName("button_Record") as? SKSpriteNode {
                    icon.texture = SKTexture(imageNamed: "icon_Record")
                }
            })
        }
        else {
            if let icon = self.root?.childNodeWithName("button_Record") as? SKSpriteNode {
                icon.texture = SKTexture(imageNamed: "icon_StopRecord")
            }
            scene.startScreenRecording()
        }
    }
}
```

## Documentation

Docs are located at [veeneck.github.io/SwitchBoard](http://veeneck.github.io/SwitchBoard) and are generated with [Jazzy](https://github.com/Realm/jazzy). The config file for the documentation is in the project as `config.yml`. Docs can be generated by running this command **in** the project directory:

jazzy --config {PATH_TO_REPOSITORY}/SwitchBoard/SwitchBoard/config.yml

**Note**: The output in the `config.yml` is hard coded to one computer. Edit the file and update the `output` flag to a valid location.
