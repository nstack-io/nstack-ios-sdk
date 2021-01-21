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
    public var alert = Alert()
    public var content = Content()
    public var defaultSection = DefaultSection()
    public var error = Error()
    public var featureList = FeatureList()
    public var feedback = Feedback()
    public var geography = Geography()
    public var languageSelection = LanguageSelection()

    enum CodingKeys: String, CodingKey {
        case alert
        case content
        case defaultSection = "default"
        case error
        case featureList
        case feedback
        case geography
        case languageSelection
    }

    public override init() { super.init() }

    public required init(from decoder: Decoder) throws {
        super.init()
        let container = try decoder.container(keyedBy: CodingKeys.self)
        alert = try container.decodeIfPresent(Alert.self, forKey: .alert) ?? alert
        content = try container.decodeIfPresent(Content.self, forKey: .content) ?? content
        defaultSection = try container.decodeIfPresent(DefaultSection.self, forKey: .defaultSection) ?? defaultSection
        error = try container.decodeIfPresent(Error.self, forKey: .error) ?? error
        featureList = try container.decodeIfPresent(FeatureList.self, forKey: .featureList) ?? featureList
        feedback = try container.decodeIfPresent(Feedback.self, forKey: .feedback) ?? feedback
        geography = try container.decodeIfPresent(Geography.self, forKey: .geography) ?? geography
        languageSelection = try container.decodeIfPresent(LanguageSelection.self, forKey: .languageSelection) ?? languageSelection
    }

    public override subscript(key: String) -> LocalizableSection? {
        switch key {
        case CodingKeys.alert.stringValue: return alert
        case CodingKeys.content.stringValue: return content
        case CodingKeys.defaultSection.stringValue: return defaultSection
        case CodingKeys.error.stringValue: return error
        case CodingKeys.featureList.stringValue: return featureList
        case CodingKeys.feedback.stringValue: return feedback
        case CodingKeys.geography.stringValue: return geography
        case CodingKeys.languageSelection.stringValue: return languageSelection
        default: return nil
        }
    }

    public final class Alert: LocalizableSection {
        public var alertSubtitle = ""
        public var alertTitle = ""
        public var alertTypesTitle = ""
        public var defaultAlert = ""
        public var hideAlert = ""
        public var hideAlertSubtitle = ""
        public var infoAlert = ""
        public var openUrl = ""
        public var openUrlAlert = ""
        public var ratingPromptAlert = ""
        public var url = ""

        enum CodingKeys: String, CodingKey {
            case alertSubtitle
            case alertTitle
            case alertTypesTitle
            case defaultAlert
            case hideAlert
            case hideAlertSubtitle
            case infoAlert
            case openUrl
            case openUrlAlert
            case ratingPromptAlert
            case url
        }

        public override init() { super.init() }

        public required init(from decoder: Decoder) throws {
            super.init()
            let container = try decoder.container(keyedBy: CodingKeys.self)
            alertSubtitle = try container.decodeIfPresent(String.self, forKey: .alertSubtitle) ?? "__alertSubtitle"
            alertTitle = try container.decodeIfPresent(String.self, forKey: .alertTitle) ?? "__alertTitle"
            alertTypesTitle = try container.decodeIfPresent(String.self, forKey: .alertTypesTitle) ?? "__alertTypesTitle"
            defaultAlert = try container.decodeIfPresent(String.self, forKey: .defaultAlert) ?? "__defaultAlert"
            hideAlert = try container.decodeIfPresent(String.self, forKey: .hideAlert) ?? "__hideAlert"
            hideAlertSubtitle = try container.decodeIfPresent(String.self, forKey: .hideAlertSubtitle) ?? "__hideAlertSubtitle"
            infoAlert = try container.decodeIfPresent(String.self, forKey: .infoAlert) ?? "__infoAlert"
            openUrl = try container.decodeIfPresent(String.self, forKey: .openUrl) ?? "__openUrl"
            openUrlAlert = try container.decodeIfPresent(String.self, forKey: .openUrlAlert) ?? "__openUrlAlert"
            ratingPromptAlert = try container.decodeIfPresent(String.self, forKey: .ratingPromptAlert) ?? "__ratingPromptAlert"
            url = try container.decodeIfPresent(String.self, forKey: .url) ?? "__url"
        }

        public override subscript(key: String) -> String? {
            switch key {
            case CodingKeys.alertSubtitle.stringValue: return alertSubtitle
            case CodingKeys.alertTitle.stringValue: return alertTitle
            case CodingKeys.alertTypesTitle.stringValue: return alertTypesTitle
            case CodingKeys.defaultAlert.stringValue: return defaultAlert
            case CodingKeys.hideAlert.stringValue: return hideAlert
            case CodingKeys.hideAlertSubtitle.stringValue: return hideAlertSubtitle
            case CodingKeys.infoAlert.stringValue: return infoAlert
            case CodingKeys.openUrl.stringValue: return openUrl
            case CodingKeys.openUrlAlert.stringValue: return openUrlAlert
            case CodingKeys.ratingPromptAlert.stringValue: return ratingPromptAlert
            case CodingKeys.url.stringValue: return url
            default: return nil
            }
        }
    }

    public final class Content: LocalizableSection {
        public var availableProducts = ""
        public var collectionResponseButtonTitle = ""
        public var contentResponseButtonTitle = ""

        enum CodingKeys: String, CodingKey {
            case availableProducts
            case collectionResponseButtonTitle
            case contentResponseButtonTitle
        }

        public override init() { super.init() }

        public required init(from decoder: Decoder) throws {
            super.init()
            let container = try decoder.container(keyedBy: CodingKeys.self)
            availableProducts = try container.decodeIfPresent(String.self, forKey: .availableProducts) ?? "__availableProducts"
            collectionResponseButtonTitle = try container.decodeIfPresent(String.self, forKey: .collectionResponseButtonTitle) ?? "__collectionResponseButtonTitle"
            contentResponseButtonTitle = try container.decodeIfPresent(String.self, forKey: .contentResponseButtonTitle) ?? "__contentResponseButtonTitle"
        }

        public override subscript(key: String) -> String? {
            switch key {
            case CodingKeys.availableProducts.stringValue: return availableProducts
            case CodingKeys.collectionResponseButtonTitle.stringValue: return collectionResponseButtonTitle
            case CodingKeys.contentResponseButtonTitle.stringValue: return contentResponseButtonTitle
            default: return nil
            }
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

    public final class FeatureList: LocalizableSection {
        public var alertTypes = ""
        public var content = ""
        public var feedback = ""
        public var geography = ""
        public var languagePicker = ""
        public var title = ""

        enum CodingKeys: String, CodingKey {
            case alertTypes
            case content
            case feedback
            case geography
            case languagePicker
            case title
        }

        public override init() { super.init() }

        public required init(from decoder: Decoder) throws {
            super.init()
            let container = try decoder.container(keyedBy: CodingKeys.self)
            alertTypes = try container.decodeIfPresent(String.self, forKey: .alertTypes) ?? "__alertTypes"
            content = try container.decodeIfPresent(String.self, forKey: .content) ?? "__content"
            feedback = try container.decodeIfPresent(String.self, forKey: .feedback) ?? "__feedback"
            geography = try container.decodeIfPresent(String.self, forKey: .geography) ?? "__geography"
            languagePicker = try container.decodeIfPresent(String.self, forKey: .languagePicker) ?? "__languagePicker"
            title = try container.decodeIfPresent(String.self, forKey: .title) ?? "__title"
        }

        public override subscript(key: String) -> String? {
            switch key {
            case CodingKeys.alertTypes.stringValue: return alertTypes
            case CodingKeys.content.stringValue: return content
            case CodingKeys.feedback.stringValue: return feedback
            case CodingKeys.geography.stringValue: return geography
            case CodingKeys.languagePicker.stringValue: return languagePicker
            case CodingKeys.title.stringValue: return title
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

    public final class Geography: LocalizableSection {
        public var enterLatLng = ""
        public var enterLatitude = ""
        public var enterLongitude = ""
        public var geographyTitle = ""
        public var getTimezone = ""
        public var selectCountry = ""
        public var selectTimezone = ""

        enum CodingKeys: String, CodingKey {
            case enterLatLng
            case enterLatitude
            case enterLongitude
            case geographyTitle
            case getTimezone
            case selectCountry
            case selectTimezone
        }

        public override init() { super.init() }

        public required init(from decoder: Decoder) throws {
            super.init()
            let container = try decoder.container(keyedBy: CodingKeys.self)
            enterLatLng = try container.decodeIfPresent(String.self, forKey: .enterLatLng) ?? "__enterLatLng"
            enterLatitude = try container.decodeIfPresent(String.self, forKey: .enterLatitude) ?? "__enterLatitude"
            enterLongitude = try container.decodeIfPresent(String.self, forKey: .enterLongitude) ?? "__enterLongitude"
            geographyTitle = try container.decodeIfPresent(String.self, forKey: .geographyTitle) ?? "__geographyTitle"
            getTimezone = try container.decodeIfPresent(String.self, forKey: .getTimezone) ?? "__getTimezone"
            selectCountry = try container.decodeIfPresent(String.self, forKey: .selectCountry) ?? "__selectCountry"
            selectTimezone = try container.decodeIfPresent(String.self, forKey: .selectTimezone) ?? "__selectTimezone"
        }

        public override subscript(key: String) -> String? {
            switch key {
            case CodingKeys.enterLatLng.stringValue: return enterLatLng
            case CodingKeys.enterLatitude.stringValue: return enterLatitude
            case CodingKeys.enterLongitude.stringValue: return enterLongitude
            case CodingKeys.geographyTitle.stringValue: return geographyTitle
            case CodingKeys.getTimezone.stringValue: return getTimezone
            case CodingKeys.selectCountry.stringValue: return selectCountry
            case CodingKeys.selectTimezone.stringValue: return selectTimezone
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
