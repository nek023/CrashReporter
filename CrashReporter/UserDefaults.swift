//
//  UserDefaults.swift
//  CrashReporter
//
//  Created by Katsuma Tanaka on 2014/08/30.
//  Copyright (c) 2014年 Katsuma Tanaka. All rights reserved.
//

import Cocoa

class UserDefaults: NSObject {
    
    // MARK: - Constants
    
    private let kCountMapKey = "countMap"
    
    
    // MARK: - Initializers
    
    class var standardUserDefaults: UserDefaults {
        struct Static {
            static let instance = UserDefaults()
        }
        return Static.instance
    }
    
    override init() {
        super.init()
        
        let userDefaults = NSUserDefaults.standardUserDefaults()
        userDefaults.registerDefaults([
            kCountMapKey: [:]
            ])
        userDefaults.synchronize()
    }
    
    
    // MARK: - Accessors
    
    var countMap: NSDictionary {
        get {
            let userDefaults = NSUserDefaults.standardUserDefaults()
            return userDefaults.objectForKey(kCountMapKey) as NSDictionary
        }
        
        set {
            let userDefaults = NSUserDefaults.standardUserDefaults()
            userDefaults.setObject(newValue.copy(), forKey: kCountMapKey)
            userDefaults.synchronize()
        }
    }
    
}
