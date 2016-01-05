//
//  SBSceneContainer.swift
//  SwitchBoard
//
//  Created by Ryan Campbell on 12/19/15.
//  Copyright © 2015 Phalanx Studios. All rights reserved.
//

import SpriteKit

public struct SBSceneContainer {
    
    public enum SceneGroup : Int {
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
    
    /// The actual class of the scene. Need this to properly unarchive
    let classType : SBGameScene.Type
    
    /// The name of the scene .sks file to load
    let name : String
    
    /// Default transition into this scene
    let transition : SKTransition?
    
    /// Whether or not the next scene should be preloaded.
    /// Hard coded as true for lightweight scenes where I know memory won't be an issue
    let preloadable : Bool
    
    /// Used to store specific data like "Intro" for type of Story scene
    public var userData = NSMutableDictionary()
    
    var category : SceneGroup = SceneGroup.World
    
    public init(classType:SBGameScene.Type, name:String, transition:SKTransition? = nil, preloadable:Bool = false, category:SceneGroup = SceneGroup.World) {
        self.classType = classType
        self.name = name
        self.transition = transition
        self.preloadable = preloadable
        self.category = category
    }

    
}
