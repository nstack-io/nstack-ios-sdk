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
public protocol NStackLocalizable where Self: UIView {
    //this function must call: NStackSDK.shared.translationsManager.localize(component: self, for: localizedValue)
    //later on we can make some sort of operator overload...or maybe a property wrapper
    func localize(for key: String)
    func setLocalizedValue(_ localizedValue: String)
    var translatableValue: String? { get set }
    var backgroundViewToColor: UIView? { get }
    var originalBackgroundColor: UIColor? { get set }
    var originalIsUserInteractionEnabled: Bool { get set }
    var section: String { get set }
    var key: String { get set }
}

public protocol LocalizationWrappable {
    func handleLocalizationModels(localizations: [LocalizationModel], acceptHeaderUsed: String?, completion: ((Error?) -> Void)?)
    func updateTranslations()
    func updateTranslations(_ completion: ((Error?) -> Void)?)
    
    func localize(component: NStackLocalizable, for key: String)
    func storeProposal(_ value: String, for key: String)
}

public class LocalizationWrapper {
    private(set) var translationsManager: TranslatableManager<Localizable, Language, Localization>?
    let originallyTranslatedComponents: NSMapTable<NSString, NStackLocalizable>
    var proposedTranslations: [String: String]
    
    init(translationsManager: TranslatableManager<Localizable, Language, Localization>) {
        self.translationsManager = translationsManager
        self.originallyTranslatedComponents = NSMapTable(keyOptions: NSMapTableStrongMemory, valueOptions: NSMapTableWeakMemory)
        self.proposedTranslations = [String: String]()
    }
    
}

extension LocalizationWrapper: LocalizationWrappable {
    public func handleLocalizationModels(localizations: [LocalizationModel], acceptHeaderUsed: String?, completion: ((Error?) -> Void)? = nil) {
        translationsManager?.handleLocalizationModels(localizations: localizations, acceptHeaderUsed: acceptHeaderUsed, completion: completion)
    }
    
    public func updateTranslations() {
        updateTranslations(nil)
    }
    
    public func updateTranslations(_ completion: ((Error?) -> Void)? = nil) {
        translationsManager?.updateTranslations(completion)
    }
    
    /**
     As a default, fetch a value from the `translationsManager` and use that on the `component`. If
     a proposed value exists, use that instead.
     */
    public func localize(component: NStackLocalizable, for sectionAndKey: String) {
        add(sectionAndKey, to: component)
        
        //Has the user proposed a translation earlier in this session?
        if let proposedTranslation = proposedTranslations[sectionAndKey] {
            component.setLocalizedValue(proposedTranslation)
        } else {
            originallyTranslatedComponents.setObject(component, forKey: sectionAndKey as NSString)
            do {
                if let localizedValue = try translationsManager?.translation(for: sectionAndKey) {
                    component.setLocalizedValue(localizedValue)
                }
            } catch {
                component.setLocalizedValue("")
            }
        }
    }
    
    /**
     stores proposed text value locally.
     
     *Note:* this method does not call the NStack API for saving of the proposal - we do that first and then
     come back here to store the proposal locally
     
     - Parameter value: proposed value
     - Parameter key: NStack key/identifier
    */
    public func storeProposal(_ value: String, for key: String) {
        //remove from originallyTranslatedComponents if it is already there (problably)
        originallyTranslatedComponents.removeObject(forKey: key as NSString)
        //And store
        proposedTranslations[key] = value
    }
    
    /// Adds the section and the key to the givent component
    ///
    /// - Parameters:
    ///   - sectionAndKey: "someSection.someKey"
    ///   - component: A NStackLocalizable component
    private func add(_ sectionAndKey: String, to component: NStackLocalizable) {
        guard let tuple = SectionKeyHelper().split(sectionAndKey) else { return }
        component.section = tuple.section
        component.key = tuple.key
    }
}
