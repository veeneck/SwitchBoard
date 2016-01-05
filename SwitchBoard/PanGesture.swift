//
//  PanGesture.swift
//  Fort
//
//  Created by Ryan Campbell on 10/23/14.
//  Copyright (c) 2014 Ryan Campbell. All rights reserved.
//

import SpriteKit
import Foundation
import Particleboard

/**
 Pan gesture for SBGameScene's camera. No need to ever call publicly. Can be intilized by calling `registerGestures` on the scene.
*/
public class PanGesture : UIPanGestureRecognizer {
    
    func handlePan(recognizer:UIPanGestureRecognizer, target:SKCameraNode) {
        switch(recognizer.state) {
            
        case UIGestureRecognizerState.Changed:
            self.handlePanChanged(recognizer, target: target)
            
        case UIGestureRecognizerState.Ended:
            self.handlePanEnded(recognizer, target: target)
            
        default:
            break
        }
    }
    
    func handlePanChanged(recognizer:UIPanGestureRecognizer, target:SKCameraNode) {
        
        /// Find the offset moved, and slide the node to the new point. setTranslation() makes it so that each frame, the difference in x/y is reported.
        /// Without it, the x/y would keep growing from the original center of the screen.
        let translation = recognizer.translationInView(self.view!)
        let newPosition = CGPoint(x:target.position.x - translation.x, y:target.position.y + translation.y)
        target.position = newPosition
        recognizer.setTranslation(CGPointZero, inView: self.view!)

    }
    
    func handlePanEnded(recognizer:UIPanGestureRecognizer, target:SKCameraNode) {
        
        /// Code to determine the direction and force of the swipe.
        let velocity = recognizer.velocityInView(self.view)
        let magnitude = sqrt((velocity.x * velocity.x) + (velocity.y * velocity.y))
        let slideMultiplier = magnitude / 200
        let slideFactor = 0.05 * slideMultiplier
        
        /// Find the final point to pan to, and keep it within bounds.
        let finalPoint = CGPoint(
            x:target.position.x - (velocity.x * slideFactor),
            y:target.position.y + (velocity.y * slideFactor)
        )

        /// Ease to point
        let move = SKAction.moveTo(finalPoint, duration: 0.5)
        move.timingFunction = QuadraticEaseOut
        target.runAction(move)
    }
    

}
