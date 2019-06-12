//
//  ExtensionXCTestCase.swift
//  JUSTEAT
//
//  Created by Alan Nichols on 2/9/17.
//  Copyright © 2019 Just Eat. All rights reserved.
//

import XCTest

extension XCTestCase {
    
    public func waitForElementToNotExist(element: XCUIElement, timeout: Double = 10) {
        expectation(for: NSPredicate(format: "exists == false"), evaluatedWith: element, handler: nil)
        waitForExpectations(timeout: timeout, handler: nil)
    }
    
    public func waitForElementToExist(element: XCUIElement, timeout: Double = 10) {
        expectation(for: NSPredicate(format: "exists == true"), evaluatedWith: element, handler: nil)
        waitForExpectations(timeout: timeout, handler: nil)
    }
    
    public func waitForElementValueToExist(element: XCUIElement, valueString: String, timeout: Double = 10) {
        expectation(for: NSPredicate(format: "value == \(valueString)"), evaluatedWith: element, handler: nil)
        waitForExpectations(timeout: timeout, handler: nil)
    }
    
    public func waitForElementToBeHittable(element: XCUIElement, timeout: Double = 10) {
        waitForElementToExist(element: element, timeout: timeout)
        expectation(for: NSPredicate(format: "isHittable == true"), evaluatedWith: element, handler: nil)
        waitForExpectations(timeout: 2, handler: nil)
    }
    
    public func waitForElementToBeEnabled(element: XCUIElement, timeout: Double = 10) {
        waitForElementToExist(element: element, timeout: timeout)
        expectation(for: NSPredicate(format: "isEnabled == true"), evaluatedWith: element, handler: nil)
        waitForExpectations(timeout: 20, handler: nil)
    }
}
