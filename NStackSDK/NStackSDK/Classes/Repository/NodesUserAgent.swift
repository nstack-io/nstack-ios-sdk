//
//  NodesUserAgent.swift
//  Nodes
//
//  Created by Jakob Mygind on 05/08/16.
//  Copyright © 2016 Nodes. All rights reserved.
//

import Foundation
import UIKit
import Alamofire

public enum AppEnvironment: String {
    case development = "development"
    case staging = "staging"
    case production = "production"
}

public func userAgentString(environment: AppEnvironment) -> String {
    
    var appendString = "ios;"
    
    appendString += "\(environment.rawValue);"
    appendString += "\(Bundle.main.releaseVersionNumber ?? "");"
    appendString += "\(UIDevice.current.systemVersion);"
    appendString += "\(UIDevice().modelName)"
    
    return appendString
}

extension Bundle {
    
    var releaseVersionNumber: String? {
        return self.infoDictionary?["CFBundleShortVersionString"] as? String
    }
    
    var buildVersionNumber: String? {
        return self.infoDictionary?["CFBundleVersion"] as? String
    }
}

public extension UIDevice {
    
    var modelName: String {
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        let identifier = machineMirror.children.reduce("") { identifier, element in

            guard let value = element.value as? Int8, value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }
        return identifier
    }
}
