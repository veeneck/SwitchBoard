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

open class SBSubScene {
    
    public var sceneNode : SKNode?
    
    var sceneName : String
    
    weak public var parentScene : SKScene? = nil
    
    var animationPrepped : Bool = false
    
    var addedToScene : Bool = false
    
    struct Animation {
        
        static let movementTime : TimeInterval = 0.7
        
        static let delayTime : TimeInterval = 0.3

        
    }
    
    /// Sound to play when the card is animated
    var slideSound : SKAction {
        return PBSound.sharedInstance.getSKActionForSound(fileName: "cardboard_slide.wav")
    }
    
    public init(name:String) {
        self.sceneName = name
    }
    
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
    
    public func prepForDisplay(parent:SKScene, animated:Bool) {
        if animated {
            self.hideFromView()
            self.animationPrepped = true
        }
        
        self.parentScene = parent
        self.willMove(to: parent.view!)
    }
    
    /// Called when subscene is initialized, but not necessarily added to screen or in view.
    open func willMove(to view: SKView) {
        
    }
    
    /// Called after subscene has animated or appeared into view
    open func didMove(to view: SKView) {
        
    }
    
    /// Called after subscene has animated or appeared into view
    open func didReturn(to view: SKView) {
        
    }
    
    open func animateIntoView() {
        if self.animationPrepped {
            let move = SKAction.move(to:CGPoint(x: 1365, y: 768), duration: Animation.movementTime)
            move.timingMode = .easeInEaseOut
            let rotate = SKAction.rotate(toAngle: 0, duration: Animation.movementTime)
            self.sceneNode?.run(SKAction.sequence([SKAction.wait(forDuration: Animation.delayTime),
                                                   SKAction.group([move, rotate, self.slideSound])])) {
                                                    
                                                    if self.addedToScene {
                                                        self.didReturn(to: self.parentScene!.view!)
                                                    }
                                                    else {
                                                        self.didMove(to: self.parentScene!.view!)
                                                    }
                                                
            }
        }
        else {
            if self.addedToScene {
                self.didReturn(to: self.parentScene!.view!)
            }
            else {
                self.didMove(to: self.parentScene!.view!)
            }
        }
        self.addedToScene = true
    }
    
    open func animateOutOfView() {
        self.sceneNode?.run(SKAction.wait(forDuration: Animation.movementTime + Animation.delayTime)) {
            self.hideFromView()
        }
    }
    
    open func hideFromView() {
        self.sceneNode?.position = CGPoint(x:1700, y:2700)
        self.sceneNode?.zRotation = -0.1
    }

    deinit {
        self.sceneNode?.removeFromParent()
        self.sceneNode = nil
    }
}
