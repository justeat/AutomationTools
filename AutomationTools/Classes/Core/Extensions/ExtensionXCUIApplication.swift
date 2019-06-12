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

extension XCUIApplication {
    
    public func launchApp(featureFlags: [Flag] = [], automationFlags: [Flag] = [], envVariables: [String : String] = [:], otherArgs: [String] = []) {
        let ephemeralConfiguration = NSMutableDictionary()
        
        for flag in featureFlags {
            let key = flag.key
            let value = flag.value
            // this check on the class is 'unfortunately' necessary to do here if
            // we want to allow a nicer way to pass flags from the UI Tests
            switch value {
            case is Bool:
                ephemeralConfiguration.set(value as! Bool, feature: "", variable: key)
            case is String:
                ephemeralConfiguration.set(value as! String, feature: "", variable: key)
            case is NSNumber:
                ephemeralConfiguration.set(value as! NSNumber, feature: "", variable: key)
            default: ()
            }
        }
        
        let automationConfiguration = NSMutableDictionary()
        
        for flag in automationFlags {
            let key = flag.key
            let value = flag.value
            // this check on the class is 'unfortunately' necessary to do here if
            // we want to allow a nicer way to pass flags from the UI Tests
            switch value {
            case is Bool:
                automationConfiguration[key] = NSNumber(value: value as! Bool)
            case is Int:
                automationConfiguration[key] = NSNumber(value: value as! Int)
            case is String:
                automationConfiguration[key] = value
            case is NSNumber:
                automationConfiguration[key] = value
            default: ()
            }
        }
        
        var args: [String] = ["UI_TEST_MODE"]
        
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
        
        self.launchArguments = args
        self.launchEnvironment = envVariables
        self.launch()
    }
}
