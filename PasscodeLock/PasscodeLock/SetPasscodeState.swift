//
//  SetPasscodeState.swift
//  PasscodeLock
//
//  Created by Yanko Dimitrov on 8/28/15.
//  Copyright © 2015 Yanko Dimitrov. All rights reserved.
//

import Foundation

struct SetPasscodeState: PasscodeLockStateType {
    
    let title: String
    let description: String
    let isCancellableAction = false
    var isTouchIDAllowed = false
    
    init(title: String, description: String) {
        
        self.title = title
        self.description = description
    }
    
    init() {
        
        title = localizedStringFor(key: "PasscodeLockSetTitle", comment: "Set passcode title")
        description = localizedStringFor(key: "PasscodeLockSetDescription", comment: "Set passcode description")
    }
    
    func acceptPasscode(passcode: [String], fromLock lock: PasscodeLockType) {

        if isPinComplex(passcode: passcode) == false
        {
            let insecureTitle = localizedStringFor(key: "PasscodeLockInsecureTitle", comment: "Set passcode title")
            let insecureDescription = localizedStringFor(key: "PasscodeLockInsecureDescription", comment: "Set passcode description")

            let nextState = SetPasscodeState(title: insecureTitle, description: insecureDescription)

            lock.changeStateTo(state: nextState)
            lock.delegate?.passcodeLockDidFail(lock: lock)

        } else {
        
            let nextState = ConfirmPasscodeState(passcode: passcode)

            lock.changeStateTo(state: nextState)
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
