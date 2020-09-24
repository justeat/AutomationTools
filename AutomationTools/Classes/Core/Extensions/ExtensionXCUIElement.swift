//
//  ExtensionXCUIElement.swift
//  AutomationTools-Core
//
//  Created by Sneha Swamy on 28/02/2019.
//

import Foundation
import XCTest

extension XCUIElement {
    /**
     Scrolls to a particular element until it is rendered in the visible rect
     - Parameter elememt: the element we want to scroll to
     */
    public func scrollToElement(element: XCUIElement) {
        while !element.isHittable {
            let startCoord = coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5))
            let endCoord = startCoord.withOffset(CGVector(dx: 0.0, dy: -262));
            startCoord.press(forDuration: 0.01, thenDragTo: endCoord)
        }
    }
    
    public func scrollDown() {
        let startCoord = coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5))
        let endCoord = startCoord.withOffset(CGVector(dx: 0.0, dy: -262));
        startCoord.press(forDuration: 0.01, thenDragTo: endCoord)
    }
    
    public func waitClearAndEnterText(text: String, timeout: TimeInterval = 30, mustWait: Bool = true) {
        waitIfNeeded({ _ = waitForExistence(timeout: timeout) },
                     shouldProceed: !exists || (exists && !isHittable),
                     mustWait: mustWait)
        tap()
        guard let string = value as? String else { return }
        let deleteString = string.map{ _ in XCUIKeyboardKey.delete.rawValue }.joined(separator: "")
        typeText(deleteString)
        typeText(text)
    }
    
    public func waitAndTap(timeout: TimeInterval = 30, mustWait: Bool = true) {
        waitIfNeeded({ _ = waitForExistence(timeout: timeout) },
                     shouldProceed: exists && isHittable,
                     mustWait: mustWait)
        tap()
    }
    
    public func waitForElementValueToExist(testCase: XCTestCase, valueString: String, timeout: Double = 30, mustWait: Bool = true) {
        let initialValue = value as? String
        waitIfNeeded({
            testCase.expectation(for: NSPredicate(format: "value == \(valueString)"), evaluatedWith: self, handler: nil)
            testCase.waitForExpectations(timeout: timeout, handler: nil)
        },
                     shouldProceed: initialValue == valueString,
                     mustWait: mustWait)
    }
    
    public func existsOrWaitForExistence(timeout: TimeInterval = 30, mustWait: Bool = true) -> Bool {
        if exists { return true }
        _ = waitForExistence(timeout: timeout)
        return exists
    }
}
