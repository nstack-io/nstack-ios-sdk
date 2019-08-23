//
//  LocalizationWrapper.swift
//  NStackSDK
//
//  Created by Peter Bødskov on 29/07/2019.
//  Copyright © 2019 Nodes ApS. All rights reserved.
//

import Foundation

#if os(iOS)
import UIKit
import TranslationManager
#elseif os(tvOS)
import TranslationManager_tvOS
#elseif os(watchOS)
import TranslationManager_watchOS
#elseif os(macOS)
import TranslationManager_macOS
#endif

#if os(iOS) || os(tvOS)
public typealias NStackLocalizableView = UIView
public typealias NStackLocalizableBackgroundColor = UIColor
#elseif os(watchOS)
public typealias NStackLocalizableView = WKInterfaceGroup
public typealias NStackLocalizableBackgroundColor = UIColor
#elseif os(macOS)
public typealias NStackLocalizableView = NSView
public typealias NStackLocalizableBackgroundColor = NSColor
#endif

@objc
public protocol NStackLocalizable where Self: NStackLocalizableView {
    //this function must call: NStackSDK.shared.translationsManager.localize(component: self, for: localizedValue)
    //later on we can make some sort of operator overload...or maybe a property wrapper
    func localize(for stringIdentifier: String)
    func setLocalizedValue(_ localizedValue: String)
    var translatableValue: String? { get set }
    var backgroundViewToColor: NStackLocalizableView? { get }
    var originalBackgroundColor: NStackLocalizableBackgroundColor? { get set }
    var originalIsUserInteractionEnabled: Bool { get set }
    var translationIdentifier: TranslationIdentifier? { get set }
}

public protocol LocalizationWrappable {
    var bestFitLanguage: Language? { get }
    func translations<L: LocalizableModel>() throws -> L
    func handleLocalizationModels(localizations: [LocalizationModel], acceptHeaderUsed: String?, completion: ((Error?) -> Void)?)
    func updateTranslations(_ completion: ((Error?) -> Void)?)
    func updateTranslations()
    func refreshTranslations()

    func localize(component: NStackLocalizable, for identifier: TranslationIdentifier)
    func containsComponent(for identifier: TranslationIdentifier) -> Bool
    func storeProposal(_ value: String, locale: Locale, for identifier: TranslationIdentifier)
}

public class LocalizationWrapper {
    private(set) var translationsManager: TranslatableManager<Language, Localization>?
    let originallyTranslatedComponents: NSMapTable<TranslationIdentifier, NStackLocalizable>
    var proposedTranslations: [TranslationIdentifier: LocalizationProposal]

    init(translationsManager: TranslatableManager<Language, Localization>) {
        self.translationsManager = translationsManager
        self.originallyTranslatedComponents = NSMapTable(keyOptions: NSMapTableStrongMemory, valueOptions: NSMapTableWeakMemory)
        self.proposedTranslations = [TranslationIdentifier: LocalizationProposal]()
    }
}

extension LocalizationWrapper: LocalizationWrappable {
    public func refreshTranslations() {
        for translation in originallyTranslatedComponents.keyEnumerator() {
            if let translationIdentifier = translation as? TranslationIdentifier {
                if let localizableComponent = originallyTranslatedComponents.object(forKey: translationIdentifier) {
                    DispatchQueue.main.async {
                        localizableComponent.localize(for: "\(translationIdentifier.section).\(translationIdentifier.key)")
                    }
                }
            }
        }
    }

    public func translations<L: LocalizableModel>() throws -> L {
        guard let manager = translationsManager else {
            fatalError("no translations manager initialized")
        }
        do {
            return try manager.translations()!
        } catch {
            fatalError("no translations found")
        }
    }

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
     Fetches a localized string value for the `identifier` and adds that to the `component`
     
     If a proposed value exists, use that, otherwise fetch a value from the `translationsManager`.
     */
    public func localize(component: NStackLocalizable, for identifier: TranslationIdentifier) {
        component.translationIdentifier = identifier

        //Has the user proposed a translation earlier in this session?
        if
            let proposedTranslation = proposedTranslations[identifier],
            let bestFitLocale = translationsManager?.bestFitLanguage?.locale
        {
            //for this locale?
            if proposedTranslation.locale == bestFitLocale {
                component.setLocalizedValue(proposedTranslation.value)
            } else {
                //OK, not for this locale, then just use the original value
                localizeFromOriginallyTranslated(component: component, for: identifier)
            }
        } else {
            localizeFromOriginallyTranslated(component: component, for: identifier)
        }
    }

    private func localizeFromOriginallyTranslated(component: NStackLocalizable, for identifier: TranslationIdentifier) {
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

    /**
     stores proposed text value locally.
     
     *Note:* this method does not call the NStack API for saving of the proposal - we do that first and then
     come back here to store the proposal locally
     
     - Parameter value: proposed value
     - Parameter key: NStack key/identifier
    */
    public func storeProposal(_ value: String, locale: Locale, for identifier: TranslationIdentifier) {
        //remove from originallyTranslatedComponents if it is already there (problably)
        originallyTranslatedComponents.removeObject(forKey: identifier)
        //And store
        proposedTranslations[identifier] = LocalizationProposal(value: value, locale: locale)
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
}
