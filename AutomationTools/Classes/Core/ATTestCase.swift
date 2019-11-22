//
//  ATTestCase.swift
//  JUSTEAT
//
//  Created by Alan Nichols on 2/13/17.
//  Copyright © 2019 Just Eat. All rights reserved.
//

import Foundation
import XCTest

open class ATTestCase: XCTestCase {
    
    public var app: XCUIApplication!
    
    override open func setUp() {
        app = XCUIApplication()
        continueAfterFailure = false
        super.setUp()
    }
    
    override open func tearDown() {
        super.tearDown()
        app.terminate()
    }
}
