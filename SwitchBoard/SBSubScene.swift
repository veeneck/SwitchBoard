//
//  SBSubScene.swift
//  SwitchBoard
//
//  Created by Ryan Campbell on 8/17/16.
//  Copyright © 2016 Phalanx Studios. All rights reserved.
//

import SpriteKit

open class SBSubScene {
    
    public var sceneNode : SKNode?
    
    var sceneName : String
    
    weak public var parentScene : SKScene? = nil
    
    public init(name:String) {
        self.sceneName = name
    }
    
    public func loadSceneFile(parent:SKScene, prepAnimation:Bool) {
        let sceneReference = SKReferenceNode(fileNamed: self.sceneName)
        self.sceneNode = (sceneReference?.childNode(withName: "root")!.copy() as! SKNode)
        
        if prepAnimation {
            self.sceneNode?.position = CGPoint(x:0, y:1700)
        }
        
        self.parentScene = parent
        self.willMove(to: parent.view!)
    }
    
    open func willMove(to view: SKView) {
        
    }
    
    open func animateIntoView() {
        let move = SKAction.move(to: CGPoint(x:0, y:0), duration: 1)
        move.timingMode = .easeInEaseOut
        self.sceneNode?.run(move)
    }
    
    open func animateOutOfView() {
        self.sceneNode?.run(SKAction.wait(forDuration: 1)) {
            self.sceneNode?.removeFromParent()
            self.sceneNode = nil
        }
    }
    
}
