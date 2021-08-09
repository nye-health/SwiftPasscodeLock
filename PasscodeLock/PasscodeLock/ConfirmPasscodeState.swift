//
//  ConfirmPasscodeState.swift
//  PasscodeLock
//
//  Created by Yanko Dimitrov on 8/28/15.
//  Copyright © 2015 Yanko Dimitrov. All rights reserved.
//

import Foundation

struct ConfirmPasscodeState: PasscodeLockStateType {
    
    let title: String
    let description: String
    let error: String?
    let isCancellableAction = false
    var isTouchIDAllowed = false
    
    private var passcodeToConfirm: [String]
    
    init(passcode: [String]) {
        
        passcodeToConfirm = passcode
        title = localizedStringFor(key: "PasscodeLockConfirmTitle", comment: "Confirm passcode title")
        description = localizedStringFor(key: "PasscodeLockConfirmDescription", comment: "Confirm passcode description")
        error = nil
    }
    
    func acceptPasscode(passcode: [String], fromLock lock: PasscodeLockType) {

        if passcode == passcodeToConfirm {
            
            lock.repository.savePasscode(passcode: passcode)
            lock.delegate?.passcodeLockDidSucceed(lock: lock)
        
        } else {
            let mismatchError = localizedStringFor(key: "PasscodeLockMismatchError", comment: "Passcode mismatch error")
            
            let nextState = SetPasscodeState(title: title, description: description, error: mismatchError)
            
            lock.changeStateTo(state: nextState)
            lock.delegate?.passcodeLockDidFail(lock: lock)
        }
    }
}
