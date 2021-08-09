//
//  EnterPasscodeState.swift
//  PasscodeLock
//
//  Created by Yanko Dimitrov on 8/28/15.
//  Copyright © 2015 Yanko Dimitrov. All rights reserved.
//

import Foundation

public let PasscodeLockIncorrectPasscodeNotification = "passcode.lock.incorrect.passcode.notification"

struct EnterPasscodeState: PasscodeLockStateType {
    
    let title: String
    let description: String
    let error: String?
    let isCancellableAction: Bool
    var isTouchIDAllowed = true
    
    private var inccorectPasscodeAttempts: Int
    private var isNotificationSent: Bool
    
    init(error: String? = nil, allowCancellation: Bool = false, inccorectPasscodeAttempts: Int = 0, isNotificationSent: Bool = false) {
        
        isCancellableAction = allowCancellation
        title = localizedStringFor(key: "PasscodeLockEnterTitle", comment: "Enter passcode title")
        description = localizedStringFor(key: "PasscodeLockEnterDescription", comment: "Enter passcode description")
        self.error = error
        
        self.inccorectPasscodeAttempts = inccorectPasscodeAttempts
        self.isNotificationSent = isNotificationSent
    }
    
    mutating func acceptPasscode(passcode: [String], fromLock lock: PasscodeLockType) {
        
        guard let currentPasscode = lock.repository.passcode else {
            return
        }
        
        if passcode == currentPasscode {
            
            lock.delegate?.passcodeLockDidSucceed(lock: lock)
            
        } else {
            
            inccorectPasscodeAttempts += 1
            
            if inccorectPasscodeAttempts >= lock.configuration.maximumInccorectPasscodeAttempts {
                
                postNotification()
            }
            
            let mismatchError = localizedStringFor(key: "PasscodeLockMismatchError", comment: "Set passcode error")
            let nextState = EnterPasscodeState(error: mismatchError, allowCancellation: isCancellableAction, inccorectPasscodeAttempts: self.inccorectPasscodeAttempts, isNotificationSent: self.isNotificationSent)

            lock.changeStateTo(state: nextState)
            lock.delegate?.passcodeLockDidFail(lock: lock)
        }
    }
    
    private mutating func postNotification() {
        
        guard !isNotificationSent else { return }
            
        let center = NotificationCenter.default
        
        center.post(name: NSNotification.Name(rawValue: PasscodeLockIncorrectPasscodeNotification), object: nil)
        
        isNotificationSent = true
    }
}
