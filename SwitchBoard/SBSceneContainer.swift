//
//  SBSceneContainer.swift
//  SwitchBoard
//
//  Created by Ryan Campbell on 12/19/15.
//  Copyright © 2015 Phalanx Studios. All rights reserved.
//

import SpriteKit

public struct SBSceneContainer {
    
    enum SceneGroup : Int {
        case Main = 0, World, Battle, Misc
        
        /// flag to indicate whether all scenes in this group should load with this one
        var loadGroup : Bool {
            switch self {
            case .Main: return false
            case .World: return true
            case .Battle: return false
            case .Misc: return false
            }
        }
    }
    
}
