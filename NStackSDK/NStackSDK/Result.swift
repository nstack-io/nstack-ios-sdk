//
//  Result.swift
//  NStackSDK
//
//  Created by Dominik Hadl on 25/09/2018.
//  Copyright © 2018 Nodes ApS. All rights reserved.
//

import Foundation

public enum Result<T> {
    case success(data: T)
    case failure(Error)
}
