//
//  ExtensionXCUIApplication.swift
//  JUSTEAT
//
//  Created by Alan Nichols on 2/10/17.
//  Copyright © 2019 Just Eat. All rights reserved.
//

import Foundation
import XCTest
import JustTweak

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
            switch value {
            case is TweakValue:
                ephemeralConfiguration.set(value as! TweakValue, feature: "", variable: key)
            default: ()
            }
        }
        
        let automationConfiguration = NSMutableDictionary()
        
        for flag in automationFlags {
            let key = flag.key
            let value = flag.value
            switch value {
            case is TweakValue:
                automationConfiguration[key] = value as! TweakValue
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
