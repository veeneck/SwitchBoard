//
//  SBSceneManager.swift
//  SwitchBoard
//
//  Created by Ryan Campbell on 1/5/16.
//  Copyright © 2016 Phalanx Studios. All rights reserved.
//

import SpriteKit

public class SBSceneManager : SBViewDelegate {
    
    let view : SKView
    
    let loadingScene : SKScene
    
    /// Manually called by individual scenes when they want to maintain state the next time they are displayed.
    var sceneCache = Dictionary<String, SBGameScene>()
    
    var currentScene : SBSceneContainer?
    
    public var scenes = Dictionary<String, SBSceneContainer>()
    
    public init(view:SKView) {
        self.view = view
        self.loadingScene = SBGameScene(fileNamed:"Loading")!
    }
    
    public func registerScene(key:String, scene:SBSceneContainer) {
        self.scenes[key] = scene
    }
    
    /// The standard method to load a scene and then present it
    func loadAndPresentScene(sceneObj:SBSceneContainer) {
        
        // If the scene is cached, set it to current scene and present it
        // This is specifically an entire scene cached, not just the textures
        if let scene = self.sceneCache[sceneObj.name] {
            self.currentScene = sceneObj
            self.presentScene(scene, sceneObj: sceneObj)
        }
            // else show loading screen and fully load scene. clear cache if needed
        else {
            // Change cache if major scene change, in whcih case preload all related assets
            if(self.clearSceneCacheIfNecessary(sceneObj)) {
                self.presentScene(self.loadingScene, sceneObj: nil)
                self.preloadRelatedScenesInBackground(sceneObj)
            }
            // Load assets for this scene, and present it
            sceneObj.classType.loadSceneAssetsWithCompletionHandler() {
                if let scene = sceneObj.classType.init(fileNamed: sceneObj.name) {
                    scene.userData = sceneObj.userData
                    scene.sbViewDelegate = self
                    self.currentScene = sceneObj
                    self.presentScene(scene, sceneObj: sceneObj)
                }
            }
        }
        
    }
    
    func presentScene(scene:SKScene, sceneObj:SBSceneContainer?) {
        // Configure the view.
        let skView = self.view
        //skView.showsFPS = true
        //skView.showsNodeCount = true
        //skView.showsPhysics = true
        //skView.showsDrawCount = true
        
        /* Sprite Kit applies additional optimizations to improve rendering performance */
        skView.ignoresSiblingOrder = true
        
        /* Set the scale mode to scale to fit the window */
        scene.scaleMode = .AspectFill
        
        /// Cut the framerate down to 30 FPS
        skView.frameInterval = 1
        
        
        if(sceneObj?.transition != nil) {
            let transition = sceneObj!.transition!
            transition.pausesIncomingScene = false
            transition.pausesOutgoingScene = false
            skView.presentScene(scene, transition:transition)
        }
        else {
            skView.presentScene(scene)
        }
    }
    
    public func sceneDidFinish(nextScene:SBSceneContainer) {
        self.loadAndPresentScene(nextScene)
    }
    
    
    // MARK: CACHING TEXTURES AND SCENES
    
    func clearSceneCacheIfNecessary(sceneObj:SBSceneContainer) -> Bool {
        // If major scene change, clear cache, or if first scene to be shown
        if((sceneObj.category != self.currentScene?.category && sceneObj.category != SBSceneContainer.SceneGroup.Misc) || self.currentScene == nil) {
            self.sceneCache.removeAll(keepCapacity: false)
            globalTextureCache.removeAll(keepCapacity: false)
            return true
        }
        return false
    }
    
    // If a scene group requires it, preload all related assets
    // For example, when loading world map, camp will also be loaded
    func preloadRelatedScenesInBackground(sceneObj:SBSceneContainer) {
        if(sceneObj.category.loadGroup) {
            for (_, scene) in self.scenes {
                if(scene.name != sceneObj.name && scene.category == sceneObj.category) {
                    scene.classType.loadSceneAssetsWithCompletionHandler({})
                }
            }
        }
    }
    
}
