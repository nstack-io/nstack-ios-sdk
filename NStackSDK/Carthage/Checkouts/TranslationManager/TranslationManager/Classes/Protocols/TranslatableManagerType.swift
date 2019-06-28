//
//  TranslatableManagerType.swift
//  TranslationManager
//
//  Created by Dominik Hadl on 18/10/2018.
//  Copyright © 2018 Nodes. All rights reserved.
//

import Foundation

public protocol TranslatableManagerType: class {
    var updateMode: UpdateMode { get }

    var decoder: JSONDecoder { get }
    var encoder: JSONEncoder { get }

    var bestFitLanguage: Language? { get }
    var acceptLanguage: String { get }
    var languageOverride: Locale? { get set }

    func translation(for keyPath: String) throws -> String?
    func translations<T: Translatable>(localeId: String) throws -> T?

    func updateTranslations(_ completion: ((_ error: Error?) -> Void)?)
    func fetchAvailableLanguages<L>(_ completion: @escaping (Result<[L]>) -> Void) where L: LanguageModel

    func set<L>(response: TranslationResponse<L>, type: PersistedTranslationType) throws where L: LanguageModel
    func set<L>(languageOverride language: L?) throws where L: LanguageModel
    func clearTranslations(includingPersisted: Bool) throws
}
