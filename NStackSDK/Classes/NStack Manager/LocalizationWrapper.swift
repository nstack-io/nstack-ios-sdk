//
//  LocalizationWrapper.swift
//  NStackSDK
//
//  Created by Peter Bødskov on 29/07/2019.
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
#if canImport(LocalizationManager)
import LocalizationManager
#endif
#if canImport(NLocalizationManager)
import NLocalizationManager
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
    var localizationItemIdentifier: LocalizationItemIdentifier? { get set }
}

public protocol LocalizationWrappable {

    var bestFitLanguage: DefaultLanguage? { get }
    var languageOverride: Locale? { get }

    func localization<L: LocalizableModel>() throws -> L
    func fetchAvailableLanguages(completion: @escaping (([DefaultLanguage]) -> Void))

    func handleLocalizationModels(configs: [LocalizationConfig], acceptHeaderUsed: String?, completion: ((Error?) -> Void)?)
    func updateLocalizations(_ completion: ((Error?) -> Void)?)
    func updateLocalizations()
    func refreshLocalization()

    func setOverrideLocale(locale: Locale)
    func clearOverrideLocale()

    func localize(component: NStackLocalizable, for identifier: LocalizationItemIdentifier)
    func containsComponent(for identifier: LocalizationItemIdentifier) -> Bool
    func storeProposal(_ value: String, locale: Locale, for identifier: LocalizationItemIdentifier)
}

public class LocalizationWrapper {
    private(set) var localizationManager: LocalizationManager<DefaultLanguage, LocalizationConfig>?
    let originallyLocalizedComponents: NSMapTable<LocalizationItemIdentifier, NStackLocalizable>
    var proposedChanges: [LocalizationItemIdentifier: LocalizationItemProposal]

    init(localizationManager: LocalizationManager<DefaultLanguage, LocalizationConfig>) {
        self.localizationManager = localizationManager
        self.originallyLocalizedComponents = NSMapTable(keyOptions: NSMapTableStrongMemory, valueOptions: NSMapTableWeakMemory)
        self.proposedChanges = [LocalizationItemIdentifier: LocalizationItemProposal]()
    }
}

extension LocalizationWrapper: LocalizationWrappable {

    public var languageOverride: Locale? {
        return localizationManager?.languageOverride?.locale
    }

    public var bestFitLanguage: DefaultLanguage? {
        return localizationManager?.bestFitLanguage
    }

    public func fetchAvailableLanguages(completion: @escaping (([DefaultLanguage]) -> Void)) {
        localizationManager?.fetchAvailableLanguages(completion: completion)
    }

    public func refreshLocalization() {
        var localizations = [(LocalizationItemIdentifier, NStackLocalizable)]()

        for localization in originallyLocalizedComponents.keyEnumerator() {
            if let localizationItemIdentifier = localization as? LocalizationItemIdentifier {
                if let localizableComponent = originallyLocalizedComponents.object(forKey: localizationItemIdentifier) {
                    localizations.append((localizationItemIdentifier, localizableComponent))
                }
            }
        }

        DispatchQueue.main.async {
            localizations.forEach { localizationItemIdentifier, localizableComponent in
                // .localize mutates the originallyLocalizedComponents
                // triggering it here so we do not update originallyLocalizedComponents while enumarating it
                localizableComponent.localize(for: "\(localizationItemIdentifier.section).\(localizationItemIdentifier.key)")
            }
        }
    }

    public func localization<L: LocalizableModel>() throws -> L {
        guard let manager = localizationManager else {
            fatalError("no localization manager initialized")
        }
        do {
            return try manager.localization()
        } catch {
            fatalError("no localization found")
        }
    }

    public func handleLocalizationModels(configs: [LocalizationConfig], acceptHeaderUsed: String?, completion: ((Error?) -> Void)? = nil) {
        localizationManager?.handleLocalizationModels(descriptors: configs, acceptHeaderUsed: acceptHeaderUsed, completion: completion)
    }

    public func updateLocalizations() {
        localizationManager?.updateLocalizations()
    }

    public func updateLocalizations(_ completion: ((Error?) -> Void)? = nil) {
        localizationManager?.updateLocalizations(completion)
    }

    public func setOverrideLocale(locale: Locale) {
        let language = DefaultLanguage(id: 1, name: "",
                                direction: "", locale: locale,
                                isDefault: false, isBestFit: false)
        self.localizationManager?.languageOverride = language
    }

    public func clearOverrideLocale() {
        self.localizationManager?.languageOverride = nil
    }

    /**
     Fetches a localized string value for the `identifier` and adds that to the `component`

     If a proposed value exists, use that, otherwise fetch a value from the `localizationManager`.
     */
    public func localize(component: NStackLocalizable, for identifier: LocalizationItemIdentifier) {
        component.localizationItemIdentifier = identifier

        //Has the user proposed a translation earlier in this session?
        if
            let proposedLocalization = proposedChanges[identifier],
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

    private func localizeFromOriginallyTranslated(component: NStackLocalizable, for identifier: LocalizationItemIdentifier) {
        //clear old component if we are resetting a localization to a component that was previously stored in the map
        var identifierToRemove: LocalizationItemIdentifier?
        for localization in originallyLocalizedComponents.keyEnumerator() {
            if let localizationItemIdentifier = localization as? LocalizationItemIdentifier {
                if localizationItemIdentifier.section == identifier.section && localizationItemIdentifier.key == identifier.key {
                    identifierToRemove = localizationItemIdentifier
                }
            }
        }
        if let idToClean = identifierToRemove {
            originallyLocalizedComponents.removeObject(forKey: idToClean)
        }

        originallyLocalizedComponents.setObject(component, forKey: identifier)
        do {
            // TODO: Change localizationManager?.translation to take the identifier as parameter instead of the string.
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
    public func storeProposal(_ value: String, locale: Locale, for identifier: LocalizationItemIdentifier) {
        //remove from originallyLocalizedComponents if it is already there (problably)
        originallyLocalizedComponents.removeObject(forKey: identifier)
        //And store
        proposedChanges[identifier] = LocalizationItemProposal(value: value, locale: locale)
    }

    /**
     - Return `true` if `component` has been localized, `false` if it has not
    */
    public func containsComponent(for identifier: LocalizationItemIdentifier) -> Bool {
        if originallyLocalizedComponents.object(forKey: identifier) != nil {
            return true
        } else {
            return proposedChanges[identifier] != nil
        }
    }
}
