//
//  N-Meta.swift
//  NStackSDK
//
//  Created by Chris Combs on 11/07/2019.
//  Copyright © 2019 Nodes ApS. All rights reserved.
//

import Foundation
#if os(iOS) || os(tvOS)
import UIKit
#elseif os(watchOS)
import WatchKit
#elseif os(macOS)
import AppKit
#endif

struct NMeta {
    private var environment: String
    init(environment: String?) {
        self.environment = environment ?? "production"
    }

    public var current: String {
        return userAgentString(environment: environment)
    }
}

private func userAgentString(environment: String) -> String {

    var appendString = "ios;"

    appendString += "\(environment);"
    appendString += "\(Bundle.main.releaseVersionNumber ?? "");"
    #if os(iOS) || os(tvOS)
    appendString += "\(UIDevice.current.systemVersion);"
    appendString += "\(UIDevice.current.modelName)"
    #elseif os(watchOS)
    appendString += "\(WKInterfaceDevice.current().systemVersion);"
    appendString += "\(WKInterfaceDevice.current().model)"
    #elseif os(macOS)

    #endif

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

#if os(iOS) || os(tvOS)
fileprivate extension UIDevice {

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
#endif
