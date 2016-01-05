//
//  SBViewDelegate.swift
//  SwitchBoard
//
//  Created by Ryan Campbell on 12/19/15.
//  Copyright © 2015 Phalanx Studios. All rights reserved.
//

import SpriteKit

/**
 Each scene must be aware of how to finish and start the next scene. Instead of extending the view controller and continusouly accessing that, we can create a class that implements this protocol. In this project, SBSceneManager implements this protocol, and each scene contains a reference to the scene manager. Then, each scene can just access the scene manager for informaiton on scenes, and also trigger a new scene to begin without worrying about the view.
*/
public protocol SBViewDelegate {
    
    /// List of all available scenes that the implementer is aware of.
    var scenes : Dictionary<String, SBSceneContainer> { get set }
    
    /// Indicate that the current scene is done, and the passed in scene should begin.
    func sceneDidFinish(nextScene:SBSceneContainer)
    
}
