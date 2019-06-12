//
//  UITestConstants.swift
//  Just Eat
//
//  Created by Alberto De Bortoli on 21/06/2018.
//  Copyright © 2019 Just Eat. All rights reserved.
//

import Foundation

struct LaunchArgumentsBuilder {
    
    static public func launchArgumentForEphemeralConfiguration(_ ephemeralConfiguration: NSMutableDictionary) -> String {
        return launchArgumentForConfiguration(ephemeralConfiguration, prefix: "EPHEMERAL")
    }
    
    static public func launchArgumentForAutomationConfiguration(_ automationConfiguration: NSMutableDictionary) -> String {
        return launchArgumentForConfiguration(automationConfiguration, prefix: "AUTOMATION")
    }
    
    static private func launchArgumentForConfiguration(_ configuration: NSMutableDictionary, prefix: String) -> String {
        guard JSONSerialization.isValidJSONObject(configuration) else { return "" }
        let jsonData = try! JSONSerialization.data(withJSONObject: configuration, options: [])
        let jsonString = String(data: jsonData, encoding: .utf8)!
        return "\(prefix)_" + jsonString
    }
}
