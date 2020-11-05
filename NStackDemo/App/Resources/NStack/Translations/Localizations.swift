// ----------------------------------------------------------------------
// File generated by NStack Translations Generator v5.0.1.
//
// Copyright (c) 2019 Nodes ApS
//
// Permission is hereby granted, free of charge, to any person obtaining
// a copy of this software and associated documentation files (the
// "Software"), to deal in the Software without restriction, including
// without limitation the rights to use, copy, modify, merge, publish,
// distribute, sublicense, and/or sell copies of the Software, and to
// permit persons to whom the Software is furnished to do so, subject to
// the following conditions:
//
// The above copyright notice and this permission notice shall be
// included in all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
// EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
// MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
// IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
// CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
// TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
// SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
// ----------------------------------------------------------------------

import Foundation
import NStackSDK

#if canImport(NLocalizationManager)
import NLocalizationManager
#endif

#if canImport(LocalizationManager)
import LocalizationManager
#endif

public var lo: Localizations {
    guard let manager = NStack.sharedInstance.localizationManager else {
        return Localizations()
    }
    return try! manager.localization()
}

public var tr: Localizations { lo }

public final class Localizations: LocalizableModel {
    public var defaultSection = DefaultSection()
    public var error = Error()
    public var feedback = Feedback()
    public var languageSelection = LanguageSelection()

    enum CodingKeys: String, CodingKey {
        case defaultSection = "default"
        case error
        case feedback
        case languageSelection
    }

    public override init() { super.init() }

    public required init(from decoder: Decoder) throws {
        super.init()
        let container = try decoder.container(keyedBy: CodingKeys.self)
        defaultSection = try container.decodeIfPresent(DefaultSection.self, forKey: .defaultSection) ?? defaultSection
        error = try container.decodeIfPresent(Error.self, forKey: .error) ?? error
        feedback = try container.decodeIfPresent(Feedback.self, forKey: .feedback) ?? feedback
        languageSelection = try container.decodeIfPresent(LanguageSelection.self, forKey: .languageSelection) ?? languageSelection
    }

    public override subscript(key: String) -> LocalizableSection? {
        switch key {
        case CodingKeys.defaultSection.stringValue: return defaultSection
        case CodingKeys.error.stringValue: return error
        case CodingKeys.feedback.stringValue: return feedback
        case CodingKeys.languageSelection.stringValue: return languageSelection
        default: return nil
        }
    }

    public final class DefaultSection: LocalizableSection {
        public var back = ""
        public var cancel = ""
        public var edit = ""
        public var later = ""
        public var next = ""
        public var no = ""
        public var ok = ""
        public var previous = ""
        public var retry = ""
        public var save = ""
        public var settings = ""
        public var skip = ""
        public var submit = ""
        public var yes = ""

        enum CodingKeys: String, CodingKey {
            case back
            case cancel
            case edit
            case later
            case next
            case no
            case ok
            case previous
            case retry
            case save
            case settings
            case skip
            case submit
            case yes
        }

        public override init() { super.init() }

        public required init(from decoder: Decoder) throws {
            super.init()
            let container = try decoder.container(keyedBy: CodingKeys.self)
            back = try container.decodeIfPresent(String.self, forKey: .back) ?? "__back"
            cancel = try container.decodeIfPresent(String.self, forKey: .cancel) ?? "__cancel"
            edit = try container.decodeIfPresent(String.self, forKey: .edit) ?? "__edit"
            later = try container.decodeIfPresent(String.self, forKey: .later) ?? "__later"
            next = try container.decodeIfPresent(String.self, forKey: .next) ?? "__next"
            no = try container.decodeIfPresent(String.self, forKey: .no) ?? "__no"
            ok = try container.decodeIfPresent(String.self, forKey: .ok) ?? "__ok"
            previous = try container.decodeIfPresent(String.self, forKey: .previous) ?? "__previous"
            retry = try container.decodeIfPresent(String.self, forKey: .retry) ?? "__retry"
            save = try container.decodeIfPresent(String.self, forKey: .save) ?? "__save"
            settings = try container.decodeIfPresent(String.self, forKey: .settings) ?? "__settings"
            skip = try container.decodeIfPresent(String.self, forKey: .skip) ?? "__skip"
            submit = try container.decodeIfPresent(String.self, forKey: .submit) ?? "__submit"
            yes = try container.decodeIfPresent(String.self, forKey: .yes) ?? "__yes"
        }

        public override subscript(key: String) -> String? {
            switch key {
            case CodingKeys.back.stringValue: return back
            case CodingKeys.cancel.stringValue: return cancel
            case CodingKeys.edit.stringValue: return edit
            case CodingKeys.later.stringValue: return later
            case CodingKeys.next.stringValue: return next
            case CodingKeys.no.stringValue: return no
            case CodingKeys.ok.stringValue: return ok
            case CodingKeys.previous.stringValue: return previous
            case CodingKeys.retry.stringValue: return retry
            case CodingKeys.save.stringValue: return save
            case CodingKeys.settings.stringValue: return settings
            case CodingKeys.skip.stringValue: return skip
            case CodingKeys.submit.stringValue: return submit
            case CodingKeys.yes.stringValue: return yes
            default: return nil
            }
        }
    }

    public final class Error: LocalizableSection {
        public var authenticationError = ""
        public var connectionError = ""
        public var errorTitle = ""
        public var unknownError = ""

        enum CodingKeys: String, CodingKey {
            case authenticationError
            case connectionError
            case errorTitle
            case unknownError
        }

        public override init() { super.init() }

        public required init(from decoder: Decoder) throws {
            super.init()
            let container = try decoder.container(keyedBy: CodingKeys.self)
            authenticationError = try container.decodeIfPresent(String.self, forKey: .authenticationError) ?? "__authenticationError"
            connectionError = try container.decodeIfPresent(String.self, forKey: .connectionError) ?? "__connectionError"
            errorTitle = try container.decodeIfPresent(String.self, forKey: .errorTitle) ?? "__errorTitle"
            unknownError = try container.decodeIfPresent(String.self, forKey: .unknownError) ?? "__unknownError"
        }

        public override subscript(key: String) -> String? {
            switch key {
            case CodingKeys.authenticationError.stringValue: return authenticationError
            case CodingKeys.connectionError.stringValue: return connectionError
            case CodingKeys.errorTitle.stringValue: return errorTitle
            case CodingKeys.unknownError.stringValue: return unknownError
            default: return nil
            }
        }
    }

    public final class Feedback: LocalizableSection {
        public var enterEmail = ""
        public var enterName = ""
        public var feedbackTitle = ""
        public var selectImage = ""

        enum CodingKeys: String, CodingKey {
            case enterEmail
            case enterName
            case feedbackTitle
            case selectImage
        }

        public override init() { super.init() }

        public required init(from decoder: Decoder) throws {
            super.init()
            let container = try decoder.container(keyedBy: CodingKeys.self)
            enterEmail = try container.decodeIfPresent(String.self, forKey: .enterEmail) ?? "__enterEmail"
            enterName = try container.decodeIfPresent(String.self, forKey: .enterName) ?? "__enterName"
            feedbackTitle = try container.decodeIfPresent(String.self, forKey: .feedbackTitle) ?? "__feedbackTitle"
            selectImage = try container.decodeIfPresent(String.self, forKey: .selectImage) ?? "__selectImage"
        }

        public override subscript(key: String) -> String? {
            switch key {
            case CodingKeys.enterEmail.stringValue: return enterEmail
            case CodingKeys.enterName.stringValue: return enterName
            case CodingKeys.feedbackTitle.stringValue: return feedbackTitle
            case CodingKeys.selectImage.stringValue: return selectImage
            default: return nil
            }
        }
    }

    public final class LanguageSelection: LocalizableSection {
        public var selectLanguage = ""
        public var selectLanguageTitle = ""
        public var title = ""

        enum CodingKeys: String, CodingKey {
            case selectLanguage
            case selectLanguageTitle
            case title
        }

        public override init() { super.init() }

        public required init(from decoder: Decoder) throws {
            super.init()
            let container = try decoder.container(keyedBy: CodingKeys.self)
            selectLanguage = try container.decodeIfPresent(String.self, forKey: .selectLanguage) ?? "__selectLanguage"
            selectLanguageTitle = try container.decodeIfPresent(String.self, forKey: .selectLanguageTitle) ?? "__selectLanguageTitle"
            title = try container.decodeIfPresent(String.self, forKey: .title) ?? "__title"
        }

        public override subscript(key: String) -> String? {
            switch key {
            case CodingKeys.selectLanguage.stringValue: return selectLanguage
            case CodingKeys.selectLanguageTitle.stringValue: return selectLanguageTitle
            case CodingKeys.title.stringValue: return title
            default: return nil
            }
        }
    }
}

