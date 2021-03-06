//
//  PinchGesture.swift
//  Fort
//
//  Created by Ryan Campbell on 10/23/14.
//  Copyright (c) 2014 Ryan Campbell. All rights reserved.
//

import SpriteKit

/**
 Pinch gesture for SBGameScene's camera. No need to ever call publicly. Can be intilized by calling `registerGestures` on the scene.
*/
public class PinchGesture : UIPinchGestureRecognizer {
    
    func handlePinch(recognizer:UIPinchGestureRecognizer, target:SKCameraNode) {
        switch(recognizer.state) {
            
        case UIGestureRecognizerState.changed:
            self.handlePinchChanged(recognizer: recognizer, target: target)
            
        case UIGestureRecognizerState.ended:
            self.handlePinchEnded(recognizer: recognizer, target: target)
            
        default:
            break
        }
    }
    
    func handlePinchChanged(recognizer:UIPinchGestureRecognizer, target:SKCameraNode) {
        
        /// Change the scale within bounds. By default, the camera is inverse to the scene, so this first calculation will reverse that effect
        var scale = target.xScale * (1 + (1 - recognizer.scale))
        scale = PinchGesture.boundScaleToWindow(scale: scale, target:target)
        target.setScale(scale)
        recognizer.scale = 1.0
        PinchGesture.updateCameraBounds(target: target)
    }
    
    func handlePinchEnded(recognizer:UIPinchGestureRecognizer, target:SKCameraNode) {
        PinchGesture.updateCameraBounds(target: target)
    }
    
    public class func updateCameraBounds(target:SKCameraNode) {
        if let scene = target.scene as? SBGameScene {
            scene.setCameraBounds(offsetBounds: scene.cameraBounds)
        }
    }
    
    public class func boundScaleToWindow(scale:CGFloat, target:SKCameraNode) -> CGFloat {
        
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
