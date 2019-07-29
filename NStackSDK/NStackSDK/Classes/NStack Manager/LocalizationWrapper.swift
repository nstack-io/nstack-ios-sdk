//
//  LocalizationWrapper.swift
//  NStackSDK
//
//  Created by Peter Bødskov on 29/07/2019.
//  Copyright © 2019 Nodes ApS. All rights reserved.
//

import Foundation
import TranslationManager

@objc
public protocol NStackLocalizable {
    func setLocalizedValue(_ localizedValue: String)
}

public class LocalizationWrapper {
    fileprivate(set) var translationsManager: TranslatableManager<Localizable, Language, Localization>?
    let translatedComponents: NSMapTable<NSString, NStackLocalizable>
    
    
    public init(translationsManager: TranslatableManager<Localizable, Language, Localization>) {
        self.translationsManager = translationsManager
        self.translatedComponents = NSMapTable(keyOptions: NSMapTableStrongMemory, valueOptions: NSMapTableWeakMemory)
    }
    
    public func localize(component: NStackLocalizable, for key: String) {
        translatedComponents.setObject(component, forKey: key as NSString)
        do {
            if let localizedValue = try translationsManager?.translation(for: key) {
                component.setLocalizedValue(localizedValue)                
            }
        } catch {
            component.setLocalizedValue("")
        }
    }
}
