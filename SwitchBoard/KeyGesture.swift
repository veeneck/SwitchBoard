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
}

#endif
