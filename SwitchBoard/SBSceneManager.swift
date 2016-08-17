//
//  SBSceneManager.swift
//  SwitchBoard
//
//  Created by Ryan Campbell on 1/5/16.
//  Copyright © 2016 Phalanx Studios. All rights reserved.
//

import SpriteKit
import GameplayKit

/**
 This is the main class powering scene management, and should be created in the view controller. This class handles state, preloading, when to show the loading scene, communicating with the view, and caching. This class isn't meant to be publicly accessed. Instead, it conforms to SBViewDelegate which provides public functions that can be accessed. The reason for this is because this object holds onto cache, so we don't want to store a copy of it on each scene -- instead, there should only be one copy that is attached to each scene as it loads.
*/
public class SBSceneManager : SBViewDelegate {
    
    /// The main SKView of the game
    weak var view : SKView?
    
    /// This holds on to the loading scene and keeps it permanenty cached. Hard coded to Loading.sks currently.
    public let loadingScene : SKScene
    
    /// Manually called by individual scenes when they want to maintain state the next time they are displayed.
    var sceneCache = Dictionary<String, SBGameScene>()
    
    /// Handle on the current scene
    public var currentScene : SBSceneContainer?
    
    /// All scene objects that can be played.
    public var scenes = Dictionary<String, SBSceneContainer>()
    
    // MARK: Initializing a SBSceneManager
    
    /// Requires a view to initialize. Won't present anything on init. Instead, SBSceneContainers must be registered, and `sceneDidFinish` must be called with the initial scene to view.
    public init(view:SKView) {
        self.view = view
        self.loadingScene = SBGameScene(fileNamed:"Loading")!
    }
    
    // MARK: Registering Scenes
    
    /// Main way to add SBSceneContainers to the pool of available scenes.
    public func registerScene(key:String, scene:SBSceneContainer) {
        self.scenes[key] = scene
    }
    
    // MARK: Loading Scenes
    
    /// The standard method to load a scene and then present it
    internal func loadAndPresentScene(sceneObj:SBSceneContainer) {
        
        /// If the scene is cached, set it to current scene and present it
        /// This is specifically an entire scene cached, not just the textures
        if let scene = self.sceneCache[sceneObj.name] {
            self.currentScene = sceneObj
            self.presentScene(scene: scene, sceneObj: sceneObj)
        }
        /// else show loading screen and fully load scene. clear cache if needed
        else {
            /// Change cache if major scene change, in which case set bool to preload all related scene assets
            var fullReset : Bool = false
            if(self.clearSceneCacheIfNecessary(sceneObj: sceneObj)) {
                fullReset = true
                
                /// Show loading screen on every load except for inital game startup
                if self.currentScene != nil {
                    self.presentScene(scene: self.loadingScene, sceneObj: nil)
                }
                
            }
            /// Load assets for this scene, and present it
            sceneObj.classType.loadAndCacheSceneAssets(atlasNames: sceneObj.atlases) {
                sceneObj.classType.loadSceneAssetsWithCompletionHandler() {
                    
                    if let scene = sceneObj.classType.init(fileNamed: sceneObj.name) {
                        scene.userData = sceneObj.userData
                        scene.sbViewDelegate = self
                        self.currentScene = sceneObj
                        self.presentScene(scene: scene, sceneObj: sceneObj)
                        
                        /// We actually do the preload of related scene assets here so that it doesn't happen in background while
                        /// main assets are loading. This happens after, which will prevent duplicate loading of atlases
                        if(fullReset) {
                            self.preloadRelatedScenesInBackground(sceneObj: sceneObj)
                        }
                    }
            }
            }
        }
        
    }
    
    internal func presentScene(scene:SKScene, sceneObj:SBSceneContainer?) {
        // Configure the view.
        let skView = self.view
        //skView?.showsFPS = true
        //skView?.showsNodeCount = true
        //skView.showsPhysics = true
        //skView.showsDrawCount = true
        
        /* Sprite Kit applies additional optimizations to improve rendering performance */
        skView?.ignoresSiblingOrder = true
        
        /* Set the scale mode to scale to fit the window */
        scene.scaleMode = .aspectFill
        
        /* Remove gestures from last scene */
        self.removeGestureRecognizer()
        
        /// Cut the framerate down to 30 FPS
        //skView.frameInterval = 1
        skView?.preferredFramesPerSecond = 60
                
        if(sceneObj?.transition != nil) {
            let transition = sceneObj!.transition!
            transition.pausesIncomingScene = true
            transition.pausesOutgoingScene = false
            skView?.presentScene(scene, transition:transition)
        }
        else {
            skView?.presentScene(scene)
        }
    }
    
    /// Public facing method to play a scene. Pass in the next SBSceneContainer to get that scene to load.
    public func sceneDidFinish(nextScene:SBSceneContainer) {
        self.loadAndPresentScene(sceneObj: nextScene)
    }
    
    /// Method to remove all gesture recognizers from the view
    public func removeGestureRecognizer() {
        #if os(iOS)
        if self.view?.gestureRecognizers != nil {
            for gesture in self.view!.gestureRecognizers! {
                self.view!.removeGestureRecognizer(gesture)
            }
        }
        #endif
    }

    // MARK: Caching
    
    internal func clearSceneCacheIfNecessary(sceneObj:SBSceneContainer) -> Bool {
        /// If major scene change, clear cache, or if first scene to be shown
        if((sceneObj.category != self.currentScene?.category && sceneObj.category != SBSceneContainer.SceneGroup.Misc) || self.currentScene == nil) {
            self.sceneCache.removeAll(keepingCapacity: false)
            
            var tempCache = Dictionary<String, SKTextureAtlas>()
            
            /// Copy any items needed for next scene into temp cache
            for key in sceneObj.atlases {
                if let cachedVersion = SBCache.sharedInstance.object(forKey: key as AnyObject) as? SKTextureAtlas {
                    tempCache[key] = cachedVersion
                }
            }
            
            /// Clear cache
            SBCache.sharedInstance.removeAllObjects()
            
            /// Populate cache with the temp cache objects that we know we need for next scene
            for (key, value) in tempCache {
                print("\(key) was already cached and the next scene needs it. Keep it -- don't delete it.")
                SBCache.sharedInstance.setObject(value, forKey: key as AnyObject)
            }

            
            return true
        }
        return false
    }
    
    // If a scene group requires it, preload all related assets
    // For example, when loading world map, camp will also be loaded
    internal func preloadRelatedScenesInBackground(sceneObj:SBSceneContainer) {
        if(sceneObj.category.loadGroup) {
            for (_, scene) in self.scenes {
                if(scene.name != sceneObj.name && scene.category == sceneObj.category) {
                    scene.classType.loadAndCacheSceneAssets(atlasNames: scene.atlases) {
                        scene.classType.loadSceneAssetsWithCompletionHandler(handler: {})
                    }
                }
            }
        }
    }
    
}
