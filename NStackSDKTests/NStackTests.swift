//
//  NStackTests.swift
//  NStackTests
//
//  Created by Kasper Welner on 07/09/15.
//  Copyright © 2015 Nodes. All rights reserved.
//

import UIKit
import XCTest
import Serializable
import Alamofire
@testable import NStackSDK

let testConfiguration: () -> Configuration = {
    var conf = Configuration(plistName: "NStack", translationsClass: Translations.self)
    conf.verboseMode = true
    conf.updateAutomaticallyOnStart = false
    return conf
}

class NStackTests: XCTestCase {

    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }

    func testStart() {
        //NStack.start(configuration: conf, launchOptions: nil)
    }

    func testUpdate() {

    }
}
