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
    func localize(for stringIdentifier: String)
    func setLocalizedValue(_ localizedValue: String)
    var translatableValue: String? { get set }
    var backgroundViewToColor: UIView? { get }
    var originalBackgroundColor: UIColor? { get set }
    var originalIsUserInteractionEnabled: Bool { get set }
    var translationIdentifier: TranslationIdentifier? { get set }
}

public protocol LocalizationWrappable {
    var bestFitLanguage: Language? { get }
    func handleLocalizationModels(localizations: [LocalizationModel], acceptHeaderUsed: String?, completion: ((Error?) -> Void)?)
    func updateTranslations(_ completion: ((Error?) -> Void)?)
    func updateTranslations()
    
    func localize(component: NStackLocalizable, for identifier: TranslationIdentifier)
    func containsComponent(for identifier: TranslationIdentifier) -> Bool
    func storeProposal(_ value: String, for identifier: TranslationIdentifier)
}

public class LocalizationWrapper {
    private(set) var translationsManager: TranslatableManager<Localizable, Language, Localization>?
    let originallyTranslatedComponents: NSMapTable<TranslationIdentifier, NStackLocalizable>
    var proposedTranslations: [TranslationIdentifier: String]
    
    init(translationsManager: TranslatableManager<Localizable, Language, Localization>) {
        self.translationsManager = translationsManager
        self.originallyTranslatedComponents = NSMapTable(keyOptions: NSMapTableStrongMemory, valueOptions: NSMapTableWeakMemory)
        self.proposedTranslations = [TranslationIdentifier: String]()
    }
    
}

extension LocalizationWrapper: LocalizationWrappable {
    
    public var bestFitLanguage: Language? {
        return translationsManager?.bestFitLanguage
    }
    
    
    public func handleLocalizationModels(localizations: [LocalizationModel], acceptHeaderUsed: String?, completion: ((Error?) -> Void)? = nil) {
        translationsManager?.handleLocalizationModels(localizations: localizations, acceptHeaderUsed: acceptHeaderUsed, completion: completion)
    }
    
    public func updateTranslations() {
        translationsManager?.updateTranslations()
    }
        
    public func updateTranslations(_ completion: ((Error?) -> Void)? = nil) {
        translationsManager?.updateTranslations(completion)
    }
    
    /**
     As a default, fetch a value from the `translationsManager` and use that on the `component`. If
     a proposed value exists, use that instead.
     */
    public func localize(component: NStackLocalizable, for identifier: TranslationIdentifier) {
        add(identifier, to: component)
        
        //Has the user proposed a translation earlier in this session?
        if let proposedTranslation = proposedTranslations[identifier] {
            component.setLocalizedValue(proposedTranslation)
        } else {
            originallyTranslatedComponents.setObject(component, forKey: identifier)
            do {
                // TODO: Change translationsManager?.translation to take the identifier as parameter instead of the string.
                if let localizedValue = try translationsManager?.translation(for: SectionKeyHelper.combine(section: identifier.section, key: identifier.key)) {
					originallyTranslatedComponents.setObject(component, forKey: identifier)
                    component.setLocalizedValue(localizedValue)
                }
            } catch {
                //in case we can't find a localized value, don't do anything. There is no need for us to
                //`component.setLocalizedValue("")` for instance, lets just leave the component as is                
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
    public func storeProposal(_ value: String, for identifier: TranslationIdentifier) {
        //remove from originallyTranslatedComponents if it is already there (problably)
        originallyTranslatedComponents.removeObject(forKey: identifier)
        //And store
        proposedTranslations[identifier] = value
    }
    
    /**
     - Return `true` if `component` has been localized, `false` if it has not
    */
    public func containsComponent(for identifier: TranslationIdentifier) -> Bool {
        if originallyTranslatedComponents.object(forKey: identifier) != nil {
            return true
        } else {
            return proposedTranslations[identifier] != nil
        }
    }
    
    /// Adds the section and the key to the givent component
    ///
    /// - Parameters:
    ///   - identifier: TranslationIdentifier-object containing section and key
    ///   - component: A NStackLocalizable component
    private func add(_ identifier: TranslationIdentifier, to component: NStackLocalizable) {
        component.translationIdentifier = identifier
    }
}
