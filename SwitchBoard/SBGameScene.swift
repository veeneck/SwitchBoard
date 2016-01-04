//
//  SBGameScene.swift
//  SwitchBoard
//
//  Created by Ryan Campbell on 12/19/15.
//  Copyright © 2015 Phalanx Studios. All rights reserved.
//

import SpriteKit
import ReplayKit

/// Global texture cache to minimize loading screens. Cleared only during major scene group changes
public var globalTextureCache = Dictionary<String, SKTextureAtlas>()

public class SBGameScene : SKScene {
    
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
        var previewViewController: RPPreviewViewController?
    #endif

    // MARK: Registering Gestures
    
    public func registerGestures() {
        
        /// Pan setup
        let panRecognizer = PanGesture(target:self, action:"detectPan:")
        self.view!.addGestureRecognizer(panRecognizer)
        
        /// Pinc to zoom setup
        let pinchRecognizer = PinchGesture(target:self, action:"detectPinch:")
        self.view!.addGestureRecognizer(pinchRecognizer)
        
    }
    
    public func detectPan(recognizer:UIPanGestureRecognizer) {
        let handler = recognizer as! PanGesture
        if let camera = self.childNodeWithName("Camera") as? SKCameraNode {
            handler.handlePan(recognizer, target: camera)
        }
    }
    
    public func detectPinch(recognizer:UIPinchGestureRecognizer) {
        let handler = recognizer as! PinchGesture
        if let camera = self.childNodeWithName("Camera") as? SKCameraNode {
            handler.handlePinch(recognizer, target: camera)
        }
    }
    
    // MARK: Camera Constraints
        
    public func setCameraBounds(offsetBounds:CameraBounds) {
        if let camera = self.childNodeWithName("Camera") as? SKCameraNode,
            let bg = self.childNodeWithName("World/bg") {
                
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

    /// MARK: Preloading Assets
    
    
    // Each scene should override this to preload necessary assets
    public class func loadSceneAssetsWithCompletionHandler(handler:()->()) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), {
            
            // Call and load shared assets here
            
            dispatch_async(dispatch_get_main_queue(), {
                handler()
            })
        })
    }
    
    /// Scenes internally call this so that all preloading is handled by this one function
    /// See hack: http://stackoverflow.com/questions/22480962/nsgenericexception-reason-collection-nsconcretemaptable-xxx
    /// Can get rid of the dispatch_async if preload is fixed
    public class func loadAndCacheSceneAssets(atlasNames:Array<String>, handler:()->()) {
        
        // If already in cache, just return
        // This prevents the flicker of the loading screen
        if(globalTextureCache[atlasNames[0]] != nil) {
            handler()
        }
        else {
            var textures = Array<SKTextureAtlas>()
            for name in atlasNames {
                textures.append(SKTextureAtlas(named: name))
            }
            SKTextureAtlas.preloadTextureAtlases(textures, withCompletionHandler: {
                dispatch_async(dispatch_get_main_queue(), {
                    for (key, name) in atlasNames.enumerate() {
                        globalTextureCache[name] = textures[key]
                    }
                    handler()
                })
            })
        }
    }
    
}
