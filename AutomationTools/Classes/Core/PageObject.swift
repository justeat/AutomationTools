//
//  PageObject.swift
//  Just Eat
//
//  Created by Alberto De Bortoli on 15/02/2017.
//  Copyright © 2019 Just Eat. All rights reserved.
//

import XCTest

open class PageObject {
    
    public let app: XCUIApplication
    public let tc: XCTestCase
    
    public init(application: XCUIApplication, testCaseInstance: XCTestCase) {
        app = application
        tc = testCaseInstance
    }
}
