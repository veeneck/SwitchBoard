//
//  PinchGesture.swift
//  Fort
//
//  Created by Ryan Campbell on 10/23/14.
//  Copyright (c) 2014 Ryan Campbell. All rights reserved.
//

import SpriteKit

class PinchGesture : UIPinchGestureRecognizer {
    
    func handlePinch(recognizer:UIPinchGestureRecognizer, target:SKCameraNode) {
        switch(recognizer.state) {
            
        case UIGestureRecognizerState.Changed:
            self.handlePinchChanged(recognizer, target: target)
            
        case UIGestureRecognizerState.Ended:
            self.handlePinchEnded(recognizer, target: target)
            
        default:
            break
        }
    }
    
    func handlePinchChanged(recognizer:UIPinchGestureRecognizer, target:SKCameraNode) {
        
        /// Change the scale within bounds. By default, the camera is inverse to the scene, so this first calculation will reverse that effect
        var scale = target.xScale * (1 + (1 - recognizer.scale))
        scale = self.boundScaleToWindow(scale, target:target)
        target.setScale(scale)
        recognizer.scale = 1.0
        self.updateCameraBounds(target)
    }
    
    func handlePinchEnded(recognizer:UIPinchGestureRecognizer, target:SKCameraNode) {
        self.updateCameraBounds(target)
    }
    
    func updateCameraBounds(target:SKCameraNode) {
        if let scene = target.scene as? SBGameScene {
            scene.setCameraBounds()
        }
    }
    
    func boundScaleToWindow(scale:CGFloat, target:SKCameraNode) -> CGFloat {
        
        if let scene = target.scene as? SBGameScene,
           let bgSize = scene.bgSizeCache {
                let maxWidthScale = bgSize.width / scene.size.width
                let maxHeightScale = bgSize.height / scene.size.height
                if scale > maxWidthScale || scale > maxHeightScale {
                    return min(maxHeightScale, maxWidthScale)
                }
                if scale < 0.6 {
                    return 0.6
                }
        }
        else {
            if(scale > 1.2) {
                return 1.2
            }
            if(scale < 0.6) {
                return 0.6
            }
        }
        
        return scale
    }
    
}
