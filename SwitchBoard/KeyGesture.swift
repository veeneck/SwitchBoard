//
//  KeyGesture.swift
//  SwitchBoard
//
//  Created by Ryan Campbell on 3/6/17.
//  Copyright © 2017 Phalanx Studios. All rights reserved.
//


#if os(OSX)
import Foundation
import SpriteKit
import ParticleboardOS

public extension SBGameScene {
        
    public func handleKeyPress() {
        if self.movementKeysEnabled {
            self.handleMovementKeys()
            self.handleCameraZoom()
        }
        /*if (Keyboard.sharedKeyboard.justPressed(keys: Key.Up)) {
            print("up")
        } else if (Keyboard.sharedKeyboard.pressed(keys: Key.Space, Key.Return)) {
            // two keys
        } else if (Keyboard.sharedKeyboard.justReleased(keys: Key.Space, Key.W, Key.T, Key.LeftShift)) {
            // many keys
        }*/
    }
    
    public func handleMovementKeys() {
        var direction = float2(x:0, y:0)
        if (Keyboard.sharedKeyboard.justPressed(keys: Key.Up) || Keyboard.sharedKeyboard.pressed(keys:Key.Up)) {
            direction += float2(x:0, y:15)
        }
        if (Keyboard.sharedKeyboard.justPressed(keys: Key.Down) || Keyboard.sharedKeyboard.pressed(keys:Key.Down)) {
            direction += float2(x:0, y:-15)
        }
        if (Keyboard.sharedKeyboard.justPressed(keys: Key.Left) || Keyboard.sharedKeyboard.pressed(keys:Key.Left)) {
            direction += float2(x:-15, y:0)
        }
        if (Keyboard.sharedKeyboard.justPressed(keys: Key.Right) || Keyboard.sharedKeyboard.pressed(keys:Key.Right)) {
            direction += float2(x:15, y:0)
        }
        
        if let camera = self.childNode(withName: "Camera") as? SKCameraNode {
            camera.position += direction
        }
    }
    
    public func handleCameraZoom() {
        var direction : CGFloat = 0
        if (Keyboard.sharedKeyboard.justPressed(keys: Key.Z) || Keyboard.sharedKeyboard.pressed(keys:Key.Z)) {
            direction += 0.02
        }
        if (Keyboard.sharedKeyboard.justPressed(keys: Key.X) || Keyboard.sharedKeyboard.pressed(keys:Key.X)) {
            direction -= 0.02
        }
        
        if let camera = self.childNode(withName: "Camera") as? SKCameraNode {
            var scale = camera.xScale + direction
            scale = self.boundScaleToWindow(scale: scale, target:camera)
            camera.setScale(scale)
            self.updateCameraBounds(target: camera)
        }
    }
    
    public func updateCameraBounds(target:SKCameraNode) {
        if let scene = target.scene as? SBGameScene {
            scene.setCameraBounds(offsetBounds: scene.cameraBounds)
        }
    }
    
    public func boundScaleToWindow(scale:CGFloat, target:SKCameraNode) -> CGFloat {
        
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

#endif
