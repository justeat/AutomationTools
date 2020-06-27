//
//  ExtensionXCTestCase.swift
//  JUSTEAT
//
//  Created by Alan Nichols on 2/9/17.
//  Copyright © 2019 Just Eat. All rights reserved.
//

import XCTest

/// This function immediately return if the initial condition is true and must wait is set to false. The idea is that usually we check for existence since testing non existence
/// is trickier.
func evaluate(condition: () -> Bool, shouldProceed proceedCondition: @autoclosure () -> Bool, mustWait: Bool) -> Bool {
    if !mustWait && proceedCondition() { return true }
    return condition()
}

func waitIfNeeded(_ block: () -> Void, shouldProceed proceedCondition: @autoclosure () -> Bool, mustWait: Bool) {
    if !mustWait && proceedCondition() { return }
    block()
}

extension XCTestCase {
    
    public func waitForElementToNotExist(element: XCUIElement, timeout: Double = 30, mustWait: Bool = true) {
        waitIfNeeded({
            expectation(for: NSPredicate(format: "exists == false"), evaluatedWith: element, handler: nil)
            waitForExpectations(timeout: timeout, handler: nil)
        },
                     shouldProceed: !element.exists,
                     mustWait: mustWait)
    }
    
    public func waitForElementToExist(element: XCUIElement, timeout: Double = 30, mustWait: Bool = true) {
        waitIfNeeded({
            expectation(for: NSPredicate(format: "exists == true"), evaluatedWith: element, handler: nil)
            waitForExpectations(timeout: timeout, handler: nil)
        },
                     shouldProceed: element.exists,
                     mustWait: mustWait)
    }
    
    public func waitForElementValueToExist(element: XCUIElement, valueString: String, timeout: Double = 30, mustWait: Bool = true) {
        let value = element.value as? String
        waitIfNeeded({
            expectation(for: NSPredicate(format: "value == \(valueString)"), evaluatedWith: element, handler: nil)
            waitForExpectations(timeout: timeout, handler: nil)
        },
                     shouldProceed: value == valueString,
                     mustWait: mustWait)
    }
    
    public func waitForElementToBeHittable(element: XCUIElement, timeout: Double = 30, mustWait: Bool = true) {
        waitIfNeeded({
            waitForElementToExist(element: element, timeout: timeout)
            expectation(for: NSPredicate(format: "isHittable == true"), evaluatedWith: element, handler: nil)
            waitForExpectations(timeout: timeout, handler: nil)
        },
                     shouldProceed: element.isHittable,
                     mustWait: mustWait)
    }
    
    public func waitForElementToBeEnabled(element: XCUIElement, timeout: Double = 30, mustWait: Bool = true) {
        waitIfNeeded({
            waitForElementToExist(element: element, timeout: timeout)
            expectation(for: NSPredicate(format: "isEnabled == true"), evaluatedWith: element, handler: nil)
            waitForExpectations(timeout: timeout, handler: nil)
        },
                     shouldProceed: element.isEnabled,
                     mustWait: mustWait)
    }
}
