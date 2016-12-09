//
//  FileManagerMock.swift
//  NStackSDK
//
//  Created by Dominik Hádl on 09/12/2016.
//  Copyright © 2016 Nodes ApS. All rights reserved.
//

import Foundation

class FileManagerMock: FileManager {
    var searchPathUrlsOverride: [URL]?

    override func urls(for directory: FileManager.SearchPathDirectory,
                       in domainMask: FileManager.SearchPathDomainMask) -> [URL] {
        return searchPathUrlsOverride ?? super.urls(for: directory, in: domainMask)
    }
}
