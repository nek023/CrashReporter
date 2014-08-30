//
//  AppDelegate.swift
//  CrashReporter
//
//  Created by Katsuma Tanaka on 2014/08/30.
//  Copyright (c) 2014年 Katsuma Tanaka. All rights reserved.
//

import Cocoa
import Accounts
import Social

var NSVariableStatusItemLength: CGFloat = -1

class AppDelegate: NSObject, NSApplicationDelegate, CrashDetectorDelegate {
    
    // MARK: - Properies
    
    @IBOutlet weak var statusMenu: NSMenu!
    @IBOutlet weak var accountMenuItem: NSMenuItem!
    var statusItem: NSStatusItem!
    
    var detector: CrashDetector!
    
    var accounts: [ACAccount]?
    var selectedAccount: ACAccount?
    
    
    // MARK: - Application Lifecycle

    func applicationDidFinishLaunching(aNotification: NSNotification?) {
        setUpStatusItem()
        updateAcountList()
        
        // Start crash detection
        let detector = CrashDetector()
        detector.delegate = self
        detector.startWatching()
        
        self.detector = detector
    }
    
    func applicationWillTerminate(notification: NSNotification!) {
        // Stop crach detection
        self.detector.stopWatching()
    }
    
    
    // MARK: - Status Menu
    
    func setUpStatusItem() {
        let statusItem = NSStatusBar.systemStatusBar().statusItemWithLength(NSVariableStatusItemLength)
        statusItem.highlightMode = true
        statusItem.target = self
        statusItem.action = "showStatusMenu:"
        statusItem.image = NSImage(named: "status_icon")
        statusItem.alternateImage = NSImage(named: "status_icon_highlighted")
        
        self.statusItem = statusItem;
    }
    
    func showStatusMenu(sender: AnyObject) {
        self.statusItem.popUpStatusItemMenu(self.statusMenu)
    }
    
    func updateAcountList() {
        AccountManager.sharedManager.accounts { (accounts: [ACAccount]?, error: NSError?) -> () in
            self.accounts = accounts
            
            if accounts != nil {
                let submenu = NSMenu()
                
                for account: ACAccount in accounts! {
                    if self.selectedAccount == nil {
                        self.selectedAccount = account
                    }
                    
                    let menuItem = NSMenuItem(title: "@\(account.username)", action: "switchAccount:", keyEquivalent: "")
                    menuItem.state = (self.selectedAccount?.isEqual(account))! ? NSOnState : NSOffState
                    submenu.addItem(menuItem)
                }
                
                self.accountMenuItem.submenu = submenu
            }
        }
    }
    
    func switchAccount(menuItem: NSMenuItem) {
        let submenu = self.accountMenuItem.submenu
        let index = submenu.indexOfItem(menuItem)
        
        if index != -1 {
            self.selectedAccount = self.accounts?[index]
        }
    }
    
    
    // MARK: - Crash Counts
    
    func incrementCrashCountsWithBundleIdentfier(bundleIdentifier: String) -> Int {
        var countMap = UserDefaults.standardUserDefaults.countMap.mutableCopy() as NSMutableDictionary
        var newValue = (countMap[bundleIdentifier] != nil) ? (countMap[bundleIdentifier] as Int) + 1 : 1
        countMap[bundleIdentifier] = newValue
        UserDefaults.standardUserDefaults.countMap = countMap
        
        return newValue
    }
    
    @IBAction func resetCrashCounts(sender: AnyObject) {
        UserDefaults.standardUserDefaults.countMap = [:]
    }
    
    
    // MARK: - CrashDetectorDelegate
    
    func detector(detector: CrashDetector, didDetectCrashOfApplication application: NSRunningApplication) {
        if application.bundleIdentifier == nil { return }
        if application.bundleIdentifier != "com.apple.dt.Xcode" { return } // Xcode only
        
        // Count up
        let count = self.incrementCrashCountsWithBundleIdentfier(application.bundleIdentifier)
        
        // Status
        let status = "\(application.localizedName) がクラッシュしました (\(count)回目)"
        
        // Create request
        let request = SLRequest(
            forServiceType: SLServiceTypeTwitter,
            requestMethod: .POST,
            URL: NSURL.URLWithString("https://api.twitter.com/1.1/statuses/update.json"),
            parameters: [
                "status": status
            ])
        request.account = self.selectedAccount
        
        // Send request
        [request .performRequestWithHandler({ (data: NSData!, response: NSHTTPURLResponse!, error: NSError!) -> Void in
            var error: NSError?
            if var JSONObject = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers, error: &error) as? NSDictionary {
                NSLog("\(JSONObject)")
            }
        })]
    }
    
}

