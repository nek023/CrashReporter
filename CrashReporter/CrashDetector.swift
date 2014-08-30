//
//  CrashDetector.swift
//  CrashReporter
//
//  Created by Katsuma Tanaka on 2014/08/30.
//  Copyright (c) 2014年 Katsuma Tanaka. All rights reserved.
//

import Cocoa

@objc
protocol CrashDetectorDelegate {
    
    optional func detector(detector: CrashDetector, didDetectCrashOfApplication application: NSRunningApplication)
    
}

class CrashDetector: NSObject {
    
    var delegate: CrashDetectorDelegate?
    var watching: Bool = false
    
    override init() {
        super.init()
    }
    
    deinit {
        self.stopWatching()
    }
    
    func startWatching() {
        if self.watching { return }
        self.watching = true
        
        NSWorkspace.sharedWorkspace().notificationCenter.addObserver(
            self,
            selector: "workspaceDidTerminateApplication:",
            name: NSWorkspaceDidTerminateApplicationNotification,
            object: nil
        )
    }
    
    func stopWatching() {
        if !self.watching { return }
        self.watching = false
        
        NSWorkspace.sharedWorkspace().notificationCenter.removeObserver(
            self,
            name: NSWorkspaceDidTerminateApplicationNotification,
            object: nil
        )
    }
    
    func workspaceDidTerminateApplication(notification: NSNotification) {
        if let statusCode: Int = notification.userInfo?["NSWorkspaceExitStatusKey"]?.integerValue {
            if statusCode != 0 {
                if let application = notification.userInfo?["NSWorkspaceApplicationKey"] as? NSRunningApplication {
                    // Delegate
                    self.delegate?.detector?(self, didDetectCrashOfApplication: application)
                }
            }
        }
    }

}
