//
//  AccountManager.swift
//  CrashReporter
//
//  Created by Katsuma Tanaka on 2014/08/30.
//  Copyright (c) 2014年 Katsuma Tanaka. All rights reserved.
//

import Cocoa
import Accounts
import Social

class AccountManager: NSObject {
    
    // MARK: - Properties
    
    let accountStore: ACAccountStore
    @objc(isAccessGranted) private(set) var accessGranted: Bool = false
    
    
    // MARK: - Initializers
    
    class var sharedManager: AccountManager {
    struct Static {
        static let instance = AccountManager()
        }
        return Static.instance
    }

    override init() {
        self.accountStore = ACAccountStore()
        
        super.init()
    }
    
    
    // MARK: - Managing Accounts
    
    func accounts(completion: ([ACAccount]?, NSError?) -> ()) {
        let accountType = self.accountStore.accountTypeWithAccountTypeIdentifier(ACAccountTypeIdentifierTwitter)
        
        if self.accessGranted {
            completion(self.accountStore.accountsWithAccountType(accountType) as [ACAccount]?, nil)
        } else {
            self.accountStore.requestAccessToAccountsWithType(accountType, options: nil) { (granted: Bool, error: NSError!) -> Void in
                self.accessGranted = granted
                
                if granted {
                    completion(self.accountStore.accountsWithAccountType(accountType) as [ACAccount]?, nil)
                } else {
                    completion(nil, error)
                }
            }
        }
    }
    
}
