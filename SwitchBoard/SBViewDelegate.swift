//
//  SBViewDelegate.swift
//  SwitchBoard
//
//  Created by Ryan Campbell on 12/19/15.
//  Copyright © 2015 Phalanx Studios. All rights reserved.
//

import SpriteKit

public protocol SBViewDelegate {
    
    var scenes : Dictionary<String, SBSceneContainer> { get set }
    
    func sceneDidFinish(nextScene:SBSceneContainer)
    
}
