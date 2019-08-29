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
import LocalizationManager
#elseif os(tvOS)
import LocalizationManager_tvOS
#elseif os(watchOS)
import LocalizationManager_watchOS
#elseif os(macOS)
import LocalizationManager_macOS
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
    //this function must call: NStackSDK.shared.localizationsManager.localize(component: self, for: localizedValue)
    //later on we can make some sort of operator overload...or maybe a property wrapper
    func localize(for stringIdentifier: String)
    func setLocalizedValue(_ localizedValue: String)
    var localizableValue: String? { get set }
    var backgroundViewToColor: NStackLocalizableView? { get }
    var originalBackgroundColor: NStackLocalizableBackgroundColor? { get set }
    var originalIsUserInteractionEnabled: Bool { get set }
    var localizationIdentifier: LocalizationIdentifier? { get set }
}

public protocol LocalizationWrappable {

    var bestFitLanguage: Language? { get }
    var languageOverride: Locale? { get }

    func localizations<L: LocalizableModel>() throws -> L
    func fetchAvailableLanguages(completion: @escaping (([Language]) -> Void))

    func handleLocalizationModels(localizations: [LocalizationModel], acceptHeaderUsed: String?, completion: ((Error?) -> Void)?)
    func updateLocalizations(_ completion: ((Error?) -> Void)?)
    func updateLocalizations()
    func refreshLocalizations()

    func setOverrideLocale(locale: Locale)
    func clearOverrideLocale()

    func localize(component: NStackLocalizable, for identifier: LocalizationIdentifier)
    func containsComponent(for identifier: LocalizationIdentifier) -> Bool
    func storeProposal(_ value: String, locale: Locale, for identifier: LocalizationIdentifier)
}

public class LocalizationWrapper {
    private(set) var localizationManager: LocalizationManager<Language, Localization>?
    let originallyLocalizedComponents: NSMapTable<LocalizationIdentifier, NStackLocalizable>
    var proposedLocalizations: [LocalizationIdentifier: LocalizationProposal]

    init(localizationManager: LocalizationManager<Language, Localization>) {
        self.localizationManager = localizationManager
        self.originallyLocalizedComponents = NSMapTable(keyOptions: NSMapTableStrongMemory, valueOptions: NSMapTableWeakMemory)
        self.proposedLocalizations = [LocalizationIdentifier: LocalizationProposal]()
    }
}

extension LocalizationWrapper: LocalizationWrappable {

    public var languageOverride: Locale? {
        return localizationManager?.languageOverride?.locale
    }

    public var bestFitLanguage: Language? {
        return localizationManager?.bestFitLanguage
    }

    public func fetchAvailableLanguages(completion: @escaping (([Language]) -> Void)) {
        localizationManager?.fetchAvailableLanguages(completion: completion)
    }

    public func refreshLocalizations() {
        for localization in originallyLocalizedComponents.keyEnumerator() {
            if let localizationIdentifier = localization as? LocalizationIdentifier {
                if let localizableComponent = originallyLocalizedComponents.object(forKey: localizationIdentifier) {
                    DispatchQueue.main.async {
                        localizableComponent.localize(for: "\(localizationIdentifier.section).\(localizationIdentifier.key)")
                    }
                }
            }
        }
    }

    public func localizations<L: LocalizableModel>() throws -> L {
        guard let manager = localizationManager else {
            fatalError("no localizations manager initialized")
        }
        do {
            return try manager.localizations()
        } catch {
            fatalError("no localizations found")
        }
    }

    public func handleLocalizationModels(localizations: [LocalizationModel], acceptHeaderUsed: String?, completion: ((Error?) -> Void)? = nil) {
        localizationManager?.handleLocalizationModels(localizations: localizations, acceptHeaderUsed: acceptHeaderUsed, completion: completion)
    }

    public func updateLocalizations() {
        localizationManager?.updateLocalizations()
    }

    public func updateLocalizations(_ completion: ((Error?) -> Void)? = nil) {
        localizationManager?.updateLocalizations(completion)
    }

    public func setOverrideLocale(locale: Locale) {
        let language = Language(id: 1, name: "",
                                direction: "", acceptLanguage: locale.identifier,
                                isDefault: false, isBestFit: false)
        self.localizationManager?.languageOverride = language
    }

    public func clearOverrideLocale() {
        self.localizationManager?.languageOverride = nil
    }

    /**
     Fetches a localized string value for the `identifier` and adds that to the `component`
     
     If a proposed value exists, use that, otherwise fetch a value from the `localizationsManager`.
     */
    public func localize(component: NStackLocalizable, for identifier: LocalizationIdentifier) {
        component.localizationIdentifier = identifier

        //Has the user proposed a localization earlier in this session?
        if
            let proposedLocalization = proposedLocalizations[identifier],
            let bestFitLocale = localizationManager?.bestFitLanguage?.locale
        {
            //for this locale?
            if proposedLocalization.locale == bestFitLocale {
                component.setLocalizedValue(proposedLocalization.value)
            } else {
                //OK, not for this locale, then just use the original value
                localizeFromOriginallyTranslated(component: component, for: identifier)
            }
        } else {
            localizeFromOriginallyTranslated(component: component, for: identifier)
        }
    }

    private func localizeFromOriginallyTranslated(component: NStackLocalizable, for identifier: LocalizationIdentifier) {
        //clear old component if we are resetting a localization to a component that was previously stored in the map
        var identifierToRemove: LocalizationIdentifier?
        for localization in originallyLocalizedComponents.keyEnumerator() {
            if let localizationIdentifier = localization as? LocalizationIdentifier {
                if localizationIdentifier.section == identifier.section && localizationIdentifier.key == identifier.key {
                    identifierToRemove = localizationIdentifier
                }
            }
        }
        if let idToClean = identifierToRemove {
            originallyLocalizedComponents.removeObject(forKey: idToClean)
        }

        originallyLocalizedComponents.setObject(component, forKey: identifier)
        do {
            // TODO: Change localizationsManager?.localization to take the identifier as parameter instead of the string.
            if let localizedValue = try localizationManager?.localization(for: SectionKeyHelper.combine(section: identifier.section, key: identifier.key)) {
                originallyLocalizedComponents.setObject(component, forKey: identifier)
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
    public func storeProposal(_ value: String, locale: Locale, for identifier: LocalizationIdentifier) {
        //remove from originallyTranslatedComponents if it is already there (problably)
        originallyLocalizedComponents.removeObject(forKey: identifier)
        //And store
        proposedLocalizations[identifier] = LocalizationProposal(value: value, locale: locale)
    }

    /**
     - Return `true` if `component` has been localized, `false` if it has not
    */
    public func containsComponent(for identifier: LocalizationIdentifier) -> Bool {
        if originallyLocalizedComponents.object(forKey: identifier) != nil {
            return true
        } else {
            return proposedLocalizations[identifier] != nil
        }
    }
}
