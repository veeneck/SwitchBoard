//
//  SBCache.swift
//  SwitchBoard
//
//  Created by Ryan Campbell on 1/6/16.
//  Copyright © 2016 Phalanx Studios. All rights reserved.
//


import SpriteKit
#if os(iOS)
    import Particleboard
#elseif os(OSX)
    import ParticleboardOS
#endif

/**
 Preloading texture atlases is often done on multiple threads, so it is tricky to pass around instances of variables. Global variables are messy and inconsistent. So, this singleton can serve as the consisten location of cache objects for this project, and will mainly be used to store a hard refernece to texture atlases.
*/
public class SBCache : NSCache<AnyObject, AnyObject> {
    
    public static let sharedInstance = SBCache()
    
    private var observer: NSObjectProtocol!
    
    override init() {
        super.init()
        
        #if os(iOS)
        observer = NotificationCenter.default.addObserver(forName: NSNotification.Name.UIApplicationDidReceiveMemoryWarning, object: nil, queue: nil) { [unowned self] notification in
            self.removeAllObjects()
        }
        #endif
    }
    
    override public func setObject(_ obj: AnyObject, forKey key: AnyObject) {
        super.setObject(obj, forKey: key)
        if let printable = key as? String {
            logged("Adding \(printable) to SBCache", file: #file, level: .Warning)

        }
    }
    
    override public func removeAllObjects() {
        super.removeAllObjects()
        logged("SBCache emptied", file: #file, level: .Warning)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(observer)
    }
    
}
