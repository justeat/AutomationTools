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
    
    public func waitClearAndEnterText(text: String, timeout: TimeInterval = 10) {
        _ = self.waitForExistence(timeout: timeout)
        self.tap()
        guard let string = value as? String else { return }
        let deleteString = string.map{ _ in XCUIKeyboardKey.delete.rawValue }.joined(separator: "")
        self.typeText(deleteString)
        self.typeText(text)
    }
    
    public func waitAndTap(timeout: TimeInterval = 10) {
        _ = self.waitForExistence(timeout: timeout)
        self.tap()
    }
}
