//
//  SBGameScene.swift
//  SwitchBoard
//
//  Created by Ryan Campbell on 12/19/15.
//  Copyright © 2015 Phalanx Studios. All rights reserved.
//

import SpriteKit
import ReplayKit

public class SBGameScene : SKScene {
    
    public enum WorldLayer : Int {
        case World = 0, UI, Debug, PermanentDebug
    }

    /// Layer nodes to hold world, UI, debug, other sub layers.
    public var layers = [SKNode]()
    
    /// Cache the accumulated frame of the BG
    public var bgSizeCache : CGRect? = nil
    
    /// The delegate that handles any switch board / scenemanagement related functions. Stored on 
    /// the scene object so that children scenes can easily access the functionality.
    public var viewDelegate : SBViewDelegate?
    
    #if os(iOS)
        /// ReplayKit preview view controller used when viewing recorded content.
        var previewViewController: RPPreviewViewController?
    #endif
    
    // MARK: Registering Gestures
    
    private func registerGestures() {
        
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
    
    /// MARK: CAMERA
    
    public func setCameraBounds() {
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
                let heightOfActionBar : CGFloat = 130
                let xRange = SKRange(lowerLimit: insetContentRect.minX, upperLimit: insetContentRect.maxX)
                let yRange = SKRange(lowerLimit: insetContentRect.minY - heightOfActionBar, upperLimit: insetContentRect.maxY)
                
                // Constrain the camera within the inset rectangle.
                let levelEdgeConstraint = SKConstraint.positionX(xRange, y: yRange)
                levelEdgeConstraint.referenceNode = bg
                
                camera.constraints = [levelEdgeConstraint]
        }
    }

    
}
