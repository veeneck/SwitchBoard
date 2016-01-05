//
//  SBSceneContainer.swift
//  SwitchBoard
//
//  Created by Ryan Campbell on 12/19/15.
//  Copyright © 2015 Phalanx Studios. All rights reserved.
//

import SpriteKit

/**
    Object representing each scene. By giving paramaters like transition, preloadable, etc we can have the SBSceneManager run everything dynamically.
*/
public struct SBSceneContainer {
    
    /**
     SceneGroups define which scenes share assets and should be loaded / cached together. Currently, this is hard coded to 4 groups as `enums` can't be extended or modifier. For true open sourcing, this needs to be rethought and scene groups need to be something that you can register.
     
     - Main: Main menu
     - World: World map, travel, camp, etc
     - Battle: Game level
     - Misc: Other groupings
    */
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
    public let classType : SBGameScene.Type
    
    /// The name of the scene .sks file to load
    public let name : String
    
    /// Default transition into this scene
    public let transition : SKTransition?
    
    /// Whether or not the next scene should be preloaded.
    public let preloadable : Bool
    
    /// Used to store specific data like "Intro" for type of Story scene
    public var userData = NSMutableDictionary()
    
    /// Which SceneGroup this scene belongs to
    public var category : SceneGroup = SceneGroup.World
    
    // MARK: Initializing a SBSceneContainer
    
    /// Main initializer to set all required parameters
    public init(classType:SBGameScene.Type, name:String, transition:SKTransition? = nil, preloadable:Bool = false, category:SceneGroup = SceneGroup.World) {
        self.classType = classType
        self.name = name
        self.transition = transition
        self.preloadable = preloadable
        self.category = category
    }

    
}
