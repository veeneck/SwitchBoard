//
//  PanGesture.swift
//  Fort
//
//  Created by Ryan Campbell on 10/23/14.
//  Copyright (c) 2014 Ryan Campbell. All rights reserved.
//

import SpriteKit
import Foundation

#if os(iOS)
    import Particleboard
#elseif os(OSX)
    import AppKit
    import ParticleboardOS
#endif

/**
 Pan gesture for SBGameScene's camera. No need to ever call publicly. Can be intilized by calling `registerGestures` on the scene.
*/

#if os(iOS)

public class PanGesture : UIPanGestureRecognizer {
    
    func handlePan(recognizer:UIPanGestureRecognizer, target:SKCameraNode) {
        switch(recognizer.state) {
            
        case UIGestureRecognizerState.changed:
            self.handlePanChanged(recognizer: recognizer, target: target)
            
        case UIGestureRecognizerState.ended:
            self.handlePanEnded(recognizer: recognizer, target: target)
            
        default:
            break
        }
    }
    
    func handlePanChanged(recognizer:UIPanGestureRecognizer, target:SKCameraNode) {
        
        /// Find the offset moved, and slide the node to the new point. setTranslation() makes it so that each frame, the difference in x/y is reported.
        /// Without it, the x/y would keep growing from the original center of the screen.
        let translation = recognizer.translation(in: self.view!)
        let newPosition = CGPoint(x:target.position.x - translation.x, y:target.position.y + translation.y)
        target.position = newPosition
        recognizer.setTranslation(CGPoint(x:0, y:0), in: self.view!)
        
    }
    
    func handlePanEnded(recognizer:UIPanGestureRecognizer, target:SKCameraNode) {
        
        /// Code to determine the direction and force of the swipe.
        let velocity = recognizer.velocity(in: self.view)
        let magnitude = sqrt((velocity.x * velocity.x) + (velocity.y * velocity.y))
        let slideMultiplier = magnitude / 200
        let slideFactor = 0.05 * slideMultiplier
        
        /// Find the final point to pan to, and keep it within bounds.
        let finalPoint = CGPoint(
            x:target.position.x - (velocity.x * slideFactor),
            y:target.position.y + (velocity.y * slideFactor)
        )
        
        /// Ease to point
        let move = SKAction.move(to: finalPoint, duration: 0.5)
        move.timingFunction = QuadraticEaseOut
        target.run(move)
    }

}
    
#else
    
public class PanGesture : NSPanGestureRecognizer {
    
    func handlePan(recognizer:NSPanGestureRecognizer, target:SKCameraNode) {
        switch(recognizer.state) {
            
        case NSGestureRecognizerState.changed:
            self.handlePanChanged(recognizer: recognizer, target: target)
            
        case NSGestureRecognizerState.ended:
            self.handlePanEnded(recognizer: recognizer, target: target)
            
        default:
            break
        }
    }
    
    
    func handlePanChanged(recognizer:NSPanGestureRecognizer, target:SKCameraNode) {
        
        /// Find the offset moved, and slide the node to the new point. setTranslation() makes it so that each frame, the difference in x/y is reported.
        /// Without it, the x/y would keep growing from the original center of the screen.
        let translation = recognizer.translation(in: self.view!)
        let newPosition = CGPoint(x:target.position.x - translation.x, y:target.position.y + translation.y)
        target.position = newPosition
        recognizer.setTranslation(CGPoint(x:0, y:0), in: self.view!)
        
    }
    
    
    func handlePanEnded(recognizer:NSPanGestureRecognizer, target:SKCameraNode) {
        
        /// Code to determine the direction and force of the swipe.
        let velocity = recognizer.velocity(in: self.view)
        let magnitude = sqrt((velocity.x * velocity.x) + (velocity.y * velocity.y))
        let slideMultiplier = magnitude / 200
        let slideFactor = 0.05 * slideMultiplier
        
        /// Find the final point to pan to, and keep it within bounds.
        let finalPoint = CGPoint(
            x:target.position.x - (velocity.x * slideFactor),
            y:target.position.y + (velocity.y * slideFactor)
        )
        
        /// Ease to point
        let move = SKAction.move(to: finalPoint, duration: 0.5)
        move.timingFunction = QuadraticEaseOut
        target.run(move)
    }
    
}
    
#endif
