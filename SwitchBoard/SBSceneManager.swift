//
//  SBSceneManager.swift
//  SwitchBoard
//
//  Created by Ryan Campbell on 1/5/16.
//  Copyright © 2016 Phalanx Studios. All rights reserved.
//

import SpriteKit
import GameplayKit
#if os(iOS)
    import Particleboard
#elseif os(OSX)
    import ParticleboardOS
#endif

/**
 This is the main class powering scene management, and should be created in the view controller. This class handles state, preloading, when to show the loading scene, communicating with the view, and caching. This class isn't meant to be publicly accessed. Instead, it conforms to SBViewDelegate which provides public functions that can be accessed. The reason for this is because this object holds onto cache, so we don't want to store a copy of it on each scene -- instead, there should only be one copy that is attached to each scene as it loads.
*/
public class SBSceneManager : SBViewDelegate {
    
    /// The main SKView of the game
    weak var view : SKView?
    
    /// This holds on to the loading scene and keeps it permanenty cached. Hard coded to Loading.sks currently.
    public var loadingScene : SBGameScene? = nil
    
    /// Manually called by individual scenes when they want to maintain state the next time they are displayed.
    var sceneCache = Dictionary<String, SBGameScene>()
    
    /// Handle on the current scene
    public var currentScene : SBSceneContainer?
    
    /// All scene objects that can be played.
    public var scenes = Dictionary<String, SBSceneContainer>()
    
    /// Static variable to be used to make loading screens take up a minimum amount of time
    let ARTIFICAL_LOADING_DELAY : Double = 1
    
    // MARK: Initializing a SBSceneManager
    
    /// Requires a view to initialize. Won't present anything on init. Instead, SBSceneContainers must be registered, and `sceneDidFinish` must be called with the initial scene to view.
    public init(view:SKView) {
        self.view = view
    }
    
    // MARK: Public API
    
    /// Main way to add SBSceneContainers to the pool of available scenes.
    public func registerScene(key:String, scene:SBSceneContainer) {
        self.scenes[key] = scene
    }
    
    /// For loading to work, this has to be called after scenes are registered.
    /// Loads the loading scene into memory and never lets go throughout lifetime of app
    public func preloadLoadingScene() {
        if let sceneObj = self.scenes["Loading"] {
            self.loadingScene = sceneObj.classType.init(fileNamed: sceneObj.name)
        }
    }
    
    /// Public facing method to play a scene. Pass in the next SBSceneContainer to get that scene to load.
    public func sceneDidFinish(nextScene:SBSceneContainer) {
        self.prepareNextScene(sceneObj: nextScene)
    }
    
    // MARK: Loading Scenes
    
    /// The standard method to load a scene and then present it
    internal func prepareNextScene(sceneObj:SBSceneContainer) {
        
        /// Present scene if cached, otherwise continue executing
        if !self.presentCachedScene(sceneObj: sceneObj) {
      
            /// Present loading scene and clear cache if necessary.
            /// Assuming loading is required, set desired fake delay for loading screen
            var delay : Double = 0
            if self.requiresLoadingScreen(sceneObj: sceneObj) {
                delay = self.ARTIFICAL_LOADING_DELAY
            }
            
            /// Now that cached scenes have been handled, and loading screen is showing, actually do work to present desired scene
            self.loadAndPresentScene(sceneObj: sceneObj, delay: delay)
            
        }
        
    }
    
    /// Now that cached scenes have been handled, and loading screen is showing, actually do work to present desired scene
    internal func loadAndPresentScene(sceneObj:SBSceneContainer, delay:Double) {
        
        /// Delay loading next scene because we don't want lag when Loading Scene animates in
        Time.delay(delay: delay) {
            
            /// Load assets for this scene, specified in the scene groups atlases
            sceneObj.classType.loadAndCacheSceneAssets(atlasNames: sceneObj.atlases) {
                
                /// Load additional assets that may be set by the user in the actual scene
                sceneObj.classType.loadSceneAssetsWithCompletionHandler() {
                    
                    /// Initia;ize the new scene
                    if let scene = sceneObj.classType.init(fileNamed: sceneObj.name) {
                        scene.userData = sceneObj.userData
                        scene.sbViewDelegate = self
                        self.currentScene = sceneObj
                        
                        /// Present the new scene after fake loading delay
                        Time.delay(delay: delay) {
                            self.presentScene(scene: scene, sceneObj: sceneObj)
                        }
                        
                        /// We actually do the preload of related scene assets here so that it doesn't happen in background while
                        /// main assets are loading. This happens after, which will prevent duplicate loading of atlases
                        /// NOTE: Commenting this out because there are no related scene groups in the game yet, and I don't want more async calls to break anything.
                        /**
                         if(delay > 0) {
                         self.preloadRelatedScenesInBackground(sceneObj: sceneObj)
                         }*/
                    }
                }
            }
        }

    }
    
    /// If the scene is cached, set it to current scene and present it
    /// This is specifically an entire scene cached, not just the textures
    /// NOTE: Scenes are only cached in their entirety if the user explicitly adds to the sceneCache array
    internal func presentCachedScene(sceneObj:SBSceneContainer) -> Bool {
        if let scene = self.sceneCache[sceneObj.name] {
            logged("Loading entire scene from cache", file:#file, level:.Debug)
            self.currentScene = sceneObj
            self.presentScene(scene: scene, sceneObj: sceneObj)
            return true
        }
        return false
    }
    
    /// Looks at the scene groupd and presents loading screen if required.
    internal func requiresLoadingScreen(sceneObj:SBSceneContainer) -> Bool {
        if(self.clearSceneCacheIfNecessary(sceneObj: sceneObj) && self.loadingScene != nil) {
            
            logged("Full wipe during scene transtion -- show loading screen", file:#file, level:.Debug)
            
            /// Show loading screen on every load except for inital game startup
            if self.currentScene != nil {
                
                self.presentScene(scene: self.loadingScene!, sceneObj: self.scenes["Loading"])
                return true
                
            }
            
        }
        return false
    }
    
    internal func presentScene(scene:SKScene, sceneObj:SBSceneContainer?) {

        if let skView = self.view {
            ///skView.showsFPS = true
            ///skView.showsNodeCount = true
            ///skView.showsPhysics = true
            skView.showsDrawCount = true
            
            /* Sprite Kit applies additional optimizations to improve rendering performance */
            skView.ignoresSiblingOrder = true
            
            /* Set the scale mode to scale to fit the window */
            scene.scaleMode = .aspectFill
            
            /* Remove gestures from last scene */
            self.removeGestureRecognizer()
            
            /// Cut the framerate down to 30 FPS
            skView.preferredFramesPerSecond = 30
                                
            if(sceneObj?.transition != nil) {
                let transition = sceneObj!.transition!
                transition.pausesIncomingScene = true
                transition.pausesOutgoingScene = false
                skView.presentScene(scene, transition:transition)
            }
            else {
                skView.presentScene(scene)
            }
        }
        else {
            logged("Lost handle on skView\n", file:#file, level:.Error, newline:true)
        }
    }

    // MARK: Cleanup
    
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
    
    /// This will keep atlases that are being used in the next scene, but get rid of everything else.
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
                logged("\(key) was already cached and the next scene needs it. Keep it -- don't delete it.", file: #file)
                SBCache.sharedInstance.setObject(value, forKey: key as AnyObject)
            }

            
            return true
        }
        /// If reloading the same scene, show loading scene so that the code can unrelease any references to previous scene
        else if sceneObj.name == self.currentScene?.name {
            return true
        }
        return false
    }
    
    /// If a scene group requires it, preload all related assets
    /// For example, when loading world map, camp will also be loaded
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
