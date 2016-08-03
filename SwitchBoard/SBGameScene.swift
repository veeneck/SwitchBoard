//
//  SBGameScene.swift
//  SwitchBoard
//
//  Created by Ryan Campbell on 12/19/15.
//  Copyright © 2015 Phalanx Studios. All rights reserved.
//

import SpriteKit
import GameplayKit
#if os(iOS)
import Particleboard
import ReplayKit
#elseif os(OSX)
import ParticleboardOS
#endif

/**
 Default template for a game scene. Each custom scene in a project should extend this in order to work with other items like `SBSceneManager`, `PanGesture`, etc. Benefits of extending this class are:
 
 - Built in layering. See `WorldLayer`
 - Built in debug layer that auto clears
 - Ties to viewDelegate for easy scene switching and management of atlases
 - Built in screen recording through `previewViewController`
 - Call `registureGestures` to automatically enable panning and zooming of your scene
 
 **Note**: This project is still in development, so some items / implementations aren't flexible. If you encounter problems, the source is heavily documented.
*/
public class SBGameScene : SKScene {
    
    /**
     Layers representing SKNodes in the scene. Currently, this is hard coded to 4 groups as `enums` can't be extended or modifier. For true open sourcing, this needs to be rethought and layers need to be something that you can register.
     
     - World: The layer that gameplay takes place on. Automatically created.
     - UI: The layer that UI takes place on. Not automatically created.
     - Debug: A layer that is meant to be wiped each frame and only turned on in debug mode.
     - PermanentDebug: A debug layer for drawing that is not wiped each frame.
    */
    public enum WorldLayer : Int {
        case World = 0, UI, Debug, PermanentDebug
    }
    
    /// When constraining the camera, use this struct to adjust beyond the size of the BG
    public struct CameraBounds {
        var lowerYOffset : CGFloat = 0
        var leftXOffset : CGFloat = 0
        var upperYOffset : CGFloat = 0
        var rightXOffset : CGFloat = 0
        
        public init(lower:CGFloat, left:CGFloat, upper:CGFloat, right:CGFloat) {
            self.lowerYOffset = lower
            self.leftXOffset = left
            self.upperYOffset = upper
            self.rightXOffset = right
        }
    }

    /// Layer nodes to hold world, UI, debug, other sub layers.
    public var layers = [SKNode]()
    
    /// Cache the accumulated frame of the BG
    public var bgSizeCache : CGRect? = nil
    
    /// The delegate that handles any switch board / scenemanagement related functions. Stored on 
    /// the scene object so that children scenes can easily access the functionality.
    public var sbViewDelegate : SBViewDelegate?
    
    /// Handle on default camera bounds for the scene
    public var cameraBounds : CameraBounds = CameraBounds(lower: 0, left: 0, upper: 0, right: 0)
    
    #if os(iOS)
        /// ReplayKit preview view controller used when viewing recorded content.
        /// See README for example usages as the extension is not showing in the documentation.
        public weak var previewViewController: RPPreviewViewController?
    
        /// Quick lookup to determine if currently recording
        public var recording: Bool = false
    #endif
    
    // MARK: Layers and Child Nodes
    
    /// This can be used for any game, but is somewhat limited since it only supports 4 layers. Constructs the 4 layers and adds them to the scene
    /// in addition to storing locally under `layers` for quick lookup. Goal is to avoid using `childNodeWithName` when adding or accessing elements.
    public func buildWorldLayers() {
        /// world node must be added in .sks file
        var worldNode = SKNode()
        if let world = self.childNode(withName: "World") {
            worldNode = world
            self.layers.insert(world, at: WorldLayer.World.rawValue)
        }
        
        /// Debug will be a child of world, so that they move together
        let debug = SKNode()
        debug.name = "DebugLayer"
        worldNode.addChild(debug)
        
        /// Debug will be a child of world, so that they move together
        let permdebug = SKNode()
        permdebug.position = CGPoint(x:0, y:0)
        permdebug.name = "PermanentDebugLayer"
        permdebug.zPosition = 3
        self.addChild(permdebug)
    }
    
    /// Add a child node to one of our four hard coded layers.
    public func addChild(node:SKNode, layer:WorldLayer) {
        if(layer == WorldLayer.Debug) {
            if let debugLayer = self.layers[WorldLayer.World.rawValue].childNode(withName: "DebugLayer") {
                debugLayer.addChild(node)
            }
        }
        else if(layer == WorldLayer.PermanentDebug) {
            if let debugLayer = self.childNode(withName: "PermanentDebugLayer") {
                debugLayer.addChild(node)
            }
        }
        else {
            self.layers[layer.rawValue].addChild(node)
        }
        
    }

    // MARK: Registering Gestures
    
    #if os(iOS)
    
    /// Call this to register pinch and pan gestures which will be tied to "World/bg" in your node tree. See `setCameraBounds`.
    public func registerGestures() {
        
        /// Pan setupaction: #selector(gameViewController.cardTapped(_:))
        let panRecognizer = PanGesture(target:self, action:#selector(self.detectPan(recognizer:)))
        self.view!.addGestureRecognizer(panRecognizer)
        
        /// Pinc to zoom setup
        let pinchRecognizer = PinchGesture(target:self, action:#selector(self.detectPinch(recognizer:)))
        self.view!.addGestureRecognizer(pinchRecognizer)
        
    }
    
    public func detectPan(recognizer:UIPanGestureRecognizer) {
        let handler = recognizer as! PanGesture
        if let camera = self.childNode(withName: "Camera") as? SKCameraNode {
            handler.handlePan(recognizer: recognizer, target: camera)
        }
    }
    
    public func detectPinch(recognizer:UIPinchGestureRecognizer) {
        let handler = recognizer as! PinchGesture
        if let camera = self.childNode(withName: "Camera") as? SKCameraNode {
            handler.handlePinch(recognizer: recognizer, target: camera)
        }
    }
    
    #endif
    
    // MARK: Camera Constraints
    
    /// Bind the camera to the size of any node in your scene named "bg" that is a child of "World". This is automaticaly called from functions that change perspective like PinchGesture. You can also call on your own if you manually change the scale of the scene.
    public func setCameraBounds(offsetBounds:CameraBounds) {
        if let camera = self.childNode(withName: "Camera") as? SKCameraNode,
            let bg = self.childNode(withName: "World/bg") {
                
                // Find size of scene, and size of bg node which contains all ndoes that make up the board
                let scaledSize = CGSize(width: size.width * camera.xScale, height: size.height * camera.yScale)
                var bgSize  = self.bgSizeCache
                if bgSize == nil {
                    bgSize = bg.calculateAccumulatedFrame()
                    self.bgSizeCache = bgSize
                }
                
                /*
                Work out how far within this rectangle to constrain the camera.
                We want to stop the camera when we get within 0pts of the edge of the screen,
                unless the level is so small that this inset would be outside of the level.
                */
                let xInset = min((scaledSize.width / 2), bgSize!.width / 2)
                let yInset = min((scaledSize.height / 2), bgSize!.height / 2)
                
                // Use these insets to create a smaller inset rectangle within which the camera must stay.
                let insetContentRect = bgSize!.insetBy(dx: xInset, dy: yInset)
                
                // Define an `SKRange` for each of the x and y axes to stay within the inset rectangle.
                let xRange = SKRange(
                    lowerLimit: insetContentRect.minX - offsetBounds.leftXOffset,
                    upperLimit: insetContentRect.maxX - offsetBounds.rightXOffset)
                let yRange = SKRange(
                    lowerLimit: insetContentRect.minY - (offsetBounds.lowerYOffset * camera.yScale),
                    upperLimit: insetContentRect.maxY - offsetBounds.upperYOffset)
                
                // Constrain the camera within the inset rectangle.
                let levelEdgeConstraint = SKConstraint.positionX(xRange, y: yRange)
                levelEdgeConstraint.referenceNode = bg
                
                camera.constraints = [levelEdgeConstraint]
        }
    }

    // MARK: Preloading Assets
    
    
    /// Each scene should override this to preload necessary assets
    public class func loadSceneAssetsWithCompletionHandler(handler:()->()) {
        DispatchQueue.global(qos: .background).async {
            // Call and load shared assets here
            
            DispatchQueue.main.async {
                handler()
            }
        }
    }
    
    /// Scenes internally call this so that all preloading is handled by this one function
    /// See hack: http://stackoverflow.com/questions/22480962/nsgenericexception-reason-collection-nsconcretemaptable-xxx
    /// Can get rid of the dispatch_async if preload is fixed
    public class func loadAndCacheSceneAssets(atlasNames:Array<String>, handler:()->()) {
        
        /// Filter out items already in cache
        let uncachedNames = atlasNames.filter({ SBCache.sharedInstance.object(forKey: $0) == nil})
        
        /// Build texture array to preload
        var textures = Array<SKTextureAtlas>()
        for (_, name) in uncachedNames.enumerated() {
            textures.append(SKTextureAtlas(named: name))
        }
        
        /// If needed textures, preload them. Otherwise, go straight to handler callback
        if textures.count > 0 {
            SKTextureAtlas.preloadTextureAtlases(textures, withCompletionHandler: {
                DispatchQueue.main.async {
                    for (key, name) in uncachedNames.enumerated() {
                        
                        print("\(name) was not in cache, so it was just loaded")
                        SBCache.sharedInstance.setObject(textures[key], forKey: name)
                    }
                    handler()
                }
            })
        }
        else {
            print("Everything for this scene was loaded from cache")
            handler()
        }
        
    }
    
    // MARK: Cleanup

    /// Called automatically and will remove nodes and actions. After this, a log line should print indicating the scene
    /// was successfully deallocated. If you don't see the log line, there is probably a memory leak somewhere.
    override public func willMove(from view: SKView) {
        self.removeAllChildren()
        self.removeAllActions()
    }
    
    deinit {
        print("\n THIS SCENE WAS REMOVED FROM MEMORY (DEINIT) \n")
    }
    
    // MARK: Debug Layer
    
    /// Call this to replace the debug layer each frame. Example use would be lines drawing a characters heading. The heading updates each frame.
    /// Instead of keeping tabs of the lines, this just deletes the entire debug layer and recreates it.
    /// TODO: Create DebugNode with extended functionality?
    public func updateDebugLayer() {
        if let debugLayer = self.layers[WorldLayer.World.rawValue].childNode(withName: "DebugLayer") {
            debugLayer.removeFromParent()
            
            /// Debug will be a child of world, so that they move together
            let debug = SKNode()
            debug.name = "DebugLayer"
            debug.zPosition = 2
            self.layers[WorldLayer.World.rawValue].addChild(debug)
        }
    }

    
}
