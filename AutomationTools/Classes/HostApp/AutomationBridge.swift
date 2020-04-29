//
//  AutomationBridge.swift
//  Just Eat
//
//  Created by Alberto De Bortoli on 23/05/2018.
//  Copyright © 2019 Just Eat. All rights reserved.
//

import Foundation

@objcMembers public class AutomationBridge: NSObject {
    
    // MARK: Public
    let runningAutomationTests = "UI_TEST_MODE"
    
    public var isRunningAutomationTests: Bool {
        return launchArgumentsContain(runningAutomationTests)
    }
    
    public var ephemeralConfiguration: NSDictionary? {
        return configuration(withPrefix: "EPHEMERAL")
    }
    
    public var automationConfiguration: NSDictionary? {
        return configuration(withPrefix: "AUTOMATION")
    }
    
    public func launchArgumentsContain(_ launchArgument: String) -> Bool {
        return ProcessInfo.processInfo.arguments.contains(launchArgument)
    }
    
    // MARK: Private
    
    private func configuration(withPrefix prefix: String) -> NSMutableDictionary? {
        let prefixToRemove = "\(prefix)_"
        let arguments = ProcessInfo.processInfo.arguments.filter { $0.hasPrefix(prefixToRemove) }
        if let argument = arguments.first {
            let index = argument.index(argument.startIndex, offsetBy: prefixToRemove.count)
            let stringRepresentation = argument.suffix(from: index)
            if let data = stringRepresentation.data(using: .utf8) {
                do {
                    let configuration = try JSONSerialization.jsonObject(with: data, options: []) as! [String : Any]
                    return NSMutableDictionary(dictionary: configuration)
                } catch {
                    return nil
                }
            }
        }
        return nil
    }
    
}
