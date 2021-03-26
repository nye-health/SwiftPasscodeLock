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
    let isCancellableAction = false
    var isTouchIDAllowed = false
    
    private var passcodeToConfirm: [String]
    
    init(passcode: [String]) {
        
        passcodeToConfirm = passcode
        title = localizedStringFor(key: "PasscodeLockConfirmTitle", comment: "Confirm passcode title")
        description = localizedStringFor(key: "PasscodeLockConfirmDescription", comment: "Confirm passcode description")
    }
    
    func acceptPasscode(passcode: [String], fromLock lock: PasscodeLockType) {

        if isPinComplex(passcode: passcode) == false
        {
            let insecureTitle = "Try again"
            let insecureDescription = "Your PIN is insecure"

            let nextState = SetPasscodeState(title: insecureTitle, description: insecureDescription)

            lock.changeStateTo(state: nextState)
            lock.delegate?.passcodeLockDidFail(lock: lock)

        } else if passcode == passcodeToConfirm {
            
            lock.repository.savePasscode(passcode: passcode)
            lock.delegate?.passcodeLockDidSucceed(lock: lock)
        
        } else {
            
            let mismatchTitle = localizedStringFor(key: "PasscodeLockMismatchTitle", comment: "Passcode mismatch title")
            let mismatchDescription = localizedStringFor(key: "PasscodeLockMismatchDescription", comment: "Passcode mismatch description")
            
            let nextState = SetPasscodeState(title: mismatchTitle, description: mismatchDescription)
            
            lock.changeStateTo(state: nextState)
            lock.delegate?.passcodeLockDidFail(lock: lock)
        }
    }

    func isPinComplex(passcode: [String]) -> Bool {

        var numericalPasscode: [Int] = []

        for code in passcode {
            numericalPasscode.append(Int(code) ?? 0)
        }

        // Are all items in the array the same?
        if numericalPasscode.dropFirst().allSatisfy({ $0 == numericalPasscode.first }) {
            return false
        }

        // Are all items sequential ascending?
        if numericalPasscode.map { $0 - 1 }.dropFirst() == numericalPasscode.dropLast() {
            return false
        }

        // Are all items sequential decending?
        if numericalPasscode.map { $0 + 1 }.dropFirst() == numericalPasscode.dropLast() {
            return false
        }

        return true
    }
}
