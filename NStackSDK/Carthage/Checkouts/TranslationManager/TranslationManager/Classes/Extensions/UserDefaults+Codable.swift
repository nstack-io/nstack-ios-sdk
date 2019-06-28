//
//  UserDefaults+Codable.swift
//  TranslationManager
//
//  Created by Dominik Hadl on 18/10/2018.
//  Copyright © 2018 Nodes. All rights reserved.
//

import Foundation

public extension UserDefaults {
    func setCodable<T: Codable>(_ codable: T, forKey key: String) {
        if let data = try? JSONEncoder().encode(codable) {
            set(data, forKey: key)
        }
    }

    func codable<T: Codable>(forKey key: String) -> T? {
        guard let data = object(forKey: key) as? Data else {
            return nil
        }

        guard let model: T = try? JSONDecoder().decode(T.self, from: data) else {
            return nil
        }

        return model
    }
}
