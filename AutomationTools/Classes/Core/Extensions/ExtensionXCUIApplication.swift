//
//  ExtensionXCUIApplication.swift
//  JUSTEAT
//
//  Created by Alan Nichols on 2/10/17.
//  Copyright © 2019 Just Eat. All rights reserved.
//

import Foundation
import XCTest

public struct Flag {
    public let key: String
    public let value: Any
    
    public init(key: String, value: Any) {
        self.key = key
        self.value = value
    }
}
