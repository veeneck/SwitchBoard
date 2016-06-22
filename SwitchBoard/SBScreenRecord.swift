//
//  SBScreenRecord.swift
//  SwitchBoard
//
//  Created by Ryan Campbell on 12/19/15.
//  Copyright © 2015 Phalanx Studios. All rights reserved.
//

import ReplayKit

/**
 Extending SKScene to allow for screen erecording. A majority of the code is taken from Apple's DemoBots. See README for example usage
*/
extension SBGameScene: RPPreviewViewControllerDelegate, RPScreenRecorderDelegate {
    
    /*// MARK: Computed Properties
    
    var screenRecordingToggleEnabled: Bool {
        return true //NSUserDefaults.standardUserDefaults().boolForKey("AppConfiguration.Defaults.screenRecorderEnabledKey")
    }
    
    // MARK: Start/Stop Screen Recording
    
    public func startScreenRecording() {
        // Do nothing if screen recording hasn't been enabled.
        guard screenRecordingToggleEnabled else { return }
        
        let sharedRecorder = RPScreenRecorder.sharedRecorder()
        
        // Register as the recorder's delegate to handle errors.
        sharedRecorder.delegate = self
        
        sharedRecorder.startRecordingWithMicrophoneEnabled(true) { error in
            if let error = error {
                self.showScreenRecordingAlert(error.localizedDescription)
            }
        }
        
        self.recording = true
    }
    
    public func stopScreenRecordingWithHandler(handler:(() -> Void)) {
        let sharedRecorder = RPScreenRecorder.sharedRecorder()
        
        sharedRecorder.stopRecordingWithHandler { (previewViewController: RPPreviewViewController?, error: NSError?) in
            if let error = error {
                // If an error has occurred, display an alert to the user.
                self.showScreenRecordingAlert(error.localizedDescription)
                return
            }
            
            self.recording = false
            
            if let previewViewController = previewViewController {
                // Set delegate to handle view controller dismissal.
                previewViewController.previewControllerDelegate = self
                
                /*
                Keep a reference to the `previewViewController` to
                present when the user presses on preview button.
                */
                self.previewViewController = previewViewController
                self.previewViewController!.modalPresentationStyle = UIModalPresentationStyle.FullScreen
                
                self.view?.window?.rootViewController?.presentViewController(previewViewController, animated: true, completion: nil)
            }
            
            handler()
        }
    }
    
    func showScreenRecordingAlert(message: String) {
        // Pause the scene and un-pause after the alert returns.
        paused = true
        
        // Show an alert notifying the user that there was an issue with starting or stopping the recorder.
        let alertController = UIAlertController(title: "ReplayKit Error", message: message, preferredStyle: .Alert)
        
        let alertAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default) { _ in
            self.paused = false
        }
        alertController.addAction(alertAction)
        
        /*
        `ReplayKit` event handlers may be called on a background queue. Ensure
        this alert is presented on the main queue.
        */
        dispatch_async(dispatch_get_main_queue()) {
            self.view?.window?.rootViewController?.presentViewController(alertController, animated: true, completion: nil)
        }
    }
    
    func discardRecording() {
        // When we no longer need the `previewViewController`, tell `ReplayKit` to discard the recording and nil out our reference
        RPScreenRecorder.sharedRecorder().discardRecordingWithHandler {
            self.previewViewController = nil
        }
    }
    
    // MARK: RPScreenRecorderDelegate
    
    public func screenRecorder(screenRecorder: RPScreenRecorder, didStopRecordingWithError error: NSError, previewViewController: RPPreviewViewController?) {
        // Display the error the user to alert them that the recording failed.
        showScreenRecordingAlert(error.localizedDescription)
        
        /// Hold onto a reference of the `previewViewController` if not nil.
        if previewViewController != nil {
            self.previewViewController = previewViewController
        }
    }
    
    // MARK: RPPreviewViewControllerDelegate
    
    public func previewControllerDidFinish(previewController: RPPreviewViewController) {
        previewViewController?.dismissViewControllerAnimated(true, completion: nil)
    }*/
}

