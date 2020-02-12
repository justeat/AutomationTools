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
    
    open func launchApp(featureFlags: [Flag] = [], automationFlags: [Flag] = [], envVariables: [String : String] = [:], otherArgs: [String] = []) {
        let ephemeralConfiguration = NSMutableDictionary()
        
        for flag in featureFlags {
            let key = flag.key
            let value = flag.value
            switch value {
            case is Bool, is Int, is Double, is Float, is String:
                ephemeralConfiguration[key] = value
            default: ()
            }
        }
        
        let automationConfiguration = NSMutableDictionary()
        
        for flag in automationFlags {
            let key = flag.key
            let value = flag.value
            switch value {
            case is Bool, is Int, is Double, is Float, is String:
                automationConfiguration[key] = value
            default: ()
            }
        }
        
        var args: [String] = []
        
        // Epehmeral
        if ephemeralConfiguration.count > 0 {
            args.append(LaunchArgumentsBuilder.launchArgumentForEphemeralConfiguration(ephemeralConfiguration))
        }
        
        // Automation
        if automationConfiguration.count > 0 {
            args.append(LaunchArgumentsBuilder.launchArgumentForAutomationConfiguration(automationConfiguration))
        }
        
        // APIStubs, Deeplinks or other launch arguments
        args = args + otherArgs
        
        app.launchArguments = args
        app.launchEnvironment = envVariables
        app.launch()
    }
}
