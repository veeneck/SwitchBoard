//
//  SBSubScene.swift
//  SwitchBoard
//
//  Created by Ryan Campbell on 8/17/16.
//  Copyright © 2016 Phalanx Studios. All rights reserved.
//

import SpriteKit

#if os(iOS)
    import Particleboard
#elseif os(OSX)
    import ParticleboardOS
#endif

/**
    Spritekit scene transitions are pretty limited, especially if you want one node to stick around (i.e.: menu, button, etc). The goal of this class is to create smaller scenes that act similar to normal scenes, but can be controlled with a custom transition.
 */
open class SBSubScene {
    
    /// Handle on the actual root node of the scene
    public var sceneNode : SKNode?
    
    /// SKS file to load
    var sceneName : String
    
    /// Each subscene will be handled by one master scene. Logic should be implemented in custom master scene
    weak public var parentScene : SKScene? = nil
    
    /// Is this subscene in position to be animated in, or is it already where it needs to be
    var animationPrepped : Bool = false
    
    /// Has this subscene been presented yet. useufl to determine if first time loading, or if returning. Helps know when to reuse or create assets
    var addedToScene : Bool = false
    
    /// Hard coded data for our hard coded custom transition
    public struct Animation {
        
        static let movementTime : TimeInterval = 0.7
        
        static let delayTime : TimeInterval = 0.3
        
        public static func totalAnimationTime() -> TimeInterval {
            return Animation.movementTime + Animation.delayTime
        }

        
    }
    
    /// Sound to play when the card is animated
    public var slideSound : SKAction {
        return PBSound.sharedInstance.getSKActionForSound(fileName: "cardboard_slide.wav")
    }
    
    // MARK: Init
    
    /// For now, only set the scene name. This is so that the class can be created, but the preloading can be done whenever the caller is ready.
    public init(name:String) {
        self.sceneName = name
    }
    
    /// Preload the scene file in the background. Cache it. Assumes SKTextureAtlases were already include in SBSceneContainer for parent scene.
    public func loadSceneFile(callback:@escaping ()->()) {
        DispatchQueue.global(qos: .background).async {
            
            let sceneReference = SKReferenceNode(fileNamed: self.sceneName)
            let node = (sceneReference?.childNode(withName: "root")!.copy() as? SKNode)
                
            
            DispatchQueue.main.async {
                self.sceneNode = node
                SBCache.sharedInstance.setObject(self, forKey: "subscene_\(self.sceneName)" as AnyObject)
                callback()
            }
        }
       
    }
    
    /// Call this just before presenting the scene
    public func prepForDisplay(parent:SKScene, animated:Bool) {
        if animated {
            self.hideFromView()
            self.animationPrepped = true
        }
        
        self.parentScene = parent
        self.willMove(to: parent.view!)
    }
    
    // MARK: Keyframes
    
    /// Called when subscene is initialized, but not necessarily added to screen or in view.
    open func willMove(to view: SKView) {
        
    }
    
    /// Called after subscene has animated or appeared into view
    open func didMove(to view: SKView) {
        
    }
    
    /// Called after subscene has animated or appeared into view for a second time
    open func didReturn(to view: SKView) {
        
    }
    
    /// Override if you want an intro animation to play when the scene moves or returns to view.
    open func willAnimate(to view:SKView, callback:@escaping()->()) {
        callback()
    }
    
    /// Override if you want an outro animation to play when the scene leaves view.
    open func willAnimate(from view:SKView, callback:@escaping()->()) {
        callback()
    }
    
    // MARK: Transitions
    
    /// Move the scene into view
    open func slideIntoView() {
        
        /// If animating, slide it into view
        if self.animationPrepped {
            let move = SKAction.move(to:CGPoint(x: 1365, y: 768), duration: Animation.movementTime)
            move.timingMode = .easeOut
            let rotate = SKAction.rotate(toAngle: 0, duration: Animation.movementTime)
            self.sceneNode?.run(SKAction.group([move, rotate, slideSound])) {
                
                /// Callback determined by whether or nto scene has been presented before
                if self.addedToScene {
                    self.didReturn(to: self.parentScene!.view!)
                }
                else {
                    self.didMove(to: self.parentScene!.view!)
                    self.addedToScene = true
                }
                                                    
                                                
            }
        }
        else {
            /// Callback determined by whether or nto scene has been presented before
            if self.addedToScene {
                self.didReturn(to: self.parentScene!.view!)
            }
            else {
                self.didMove(to: self.parentScene!.view!)
                self.addedToScene = true
            }
        }
    }
    
    /// Doesn't actually slide out of view. Instead, waits for next subscene to slide into view, and then deletes this scene
    open func slideOutOfView() {
        self.sceneNode?.run(SKAction.wait(forDuration: Animation.movementTime + Animation.delayTime)) {
            self.hideFromView()
        }
    }
    
    /// Resets the scene to its animationPrepped position off screen, which both hides this scene and gets it ready for next presentation.
    open func hideFromView() {
        self.sceneNode?.position = CGPoint(x:1365, y:2900)
        self.sceneNode?.zRotation = 0
    }

    /// Make sure scene is removed from parent when full SKTransition happens
    deinit {
        self.sceneNode?.removeFromParent()
        self.sceneNode = nil
    }
}
