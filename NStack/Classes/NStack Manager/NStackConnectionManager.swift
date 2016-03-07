//
//  NStackConnectionManager.swift
//  NStack
//
//  Created by Kasper Welner on 29/09/15.
//  Copyright © 2015 Nodes. All rights reserved.
//

import Foundation
import Alamofire
import Serializable
import Harbor
import Cashier

struct NStackConnectionManager {
    
    //MARK: - Setup
    
    internal static let kBaseURL = "https://nstack.io/api/v1/"
    
    static let manager:Manager = Manager(configuration: NStackConnectionManager.configuration())
    
    static func configuration() -> NSURLSessionConfiguration {
        let staticHeaders = [
            "X-Application-id"  : NStack.sharedInstance.configuration.appId,
            "X-Rest-Api-Key"    : NStack.sharedInstance.configuration.restAPIKey
        ]
        
        let configuration = Manager.sharedInstance.session.configuration
        configuration.HTTPAdditionalHeaders = staticHeaders as [NSObject : AnyObject]
        configuration.timeoutIntervalForRequest = 20.0
        return configuration
    }
    
    static func headers() -> [String : String] {
        return ["Accept-Language": TranslationManager.sharedInstance.acceptLanguageHeaderValueString()]
    }
    
    //MARK: - API Calls
    
    static func doAppOpenCall(completion: (ApiResult<[String : AnyObject]?>) -> Void) {
        let params:[String : AnyObject] = [
            "version"           : NStackVersionUtils.currentAppVersion(),
            "guid"              : Configuration.guid(),
            "platform"          : "ios",
            "last_updated"      : lastUpdatedString(),
            "old_version"       : NStackVersionUtils.previousAppVersion()
        ]
        
        var slugs = "open"
        if NStack.sharedInstance.configuration.flat {
            slugs += "?flat=true"
        }
        
        manager.request(.POST, kBaseURL + slugs, parameters:params, headers: headers()).JSONParse(completion) { (data) -> [String : AnyObject]?? in
            return data as? [String : AnyObject]
        }
    }
    
    static func fetchTranslations(completion: (ApiResult<[String : AnyObject]?>) -> Void) {
        let params:[String : AnyObject] = [
            "version"           : 1.0,
            "guid"              : Configuration.guid(),
            "last_updated"      : lastUpdatedString(),
        ]
        var slugs = "translate/mobile/keys"
        if NStack.sharedInstance.configuration.flat {
            slugs += "?flat=true"
        }
        manager.request(.GET, kBaseURL + slugs, parameters:params, headers: headers()).JSONParse(completion) { (data) -> [String : AnyObject]?? in
            return data as? [String : AnyObject]
        }
    }
    
    static func fetchCurrentLanguage(completion: (ApiResult<Language>) -> Void) {
        let params:[String : AnyObject] = [
            "version"           : 1.0,
            "guid"              : Configuration.guid(),
            "last_updated"      : lastUpdatedString(),
        ]
        var slugs = "translate/mobile/languages/best_fit?show_inactive_languages=true"
        if NStack.sharedInstance.configuration.flat {
            slugs += "?flat=true"
        }
        manager.request(.GET, kBaseURL + slugs, parameters:params, headers: headers()).JSONParse(completion)
    }
    
    static func fetchAvailableLanguages(completion: (ApiResult<[Language]>) -> Void) {
        let params:[String : AnyObject] = [
            "version"           : 1.0,
            "guid"              : Configuration.guid(),
        ]
        
        manager.request(.GET, kBaseURL + "translate/mobile/languages", parameters:params, headers: headers()).JSONParse(completion)
    }
    
    static func fetchUpdates(completion: (ApiResult<Update>) -> Void) {
        let params:[String : AnyObject] = [
            "current_version"   : NStackVersionUtils.currentAppVersion(),
            "guid"              : Configuration.guid(),
            "platform"          : "ios",
            "old_version"      : NStackVersionUtils.previousAppVersion(),
        ]
        
        manager.request(.GET, kBaseURL + "notify/updates", parameters:params, headers: headers()).JSONParse(completion)
    }
    
    static func markNewerVersionAsSeen(id: Int, appStoreButtonPressed:Bool) {
        let params:[String : AnyObject] = [
            "guid"              : Configuration.guid(),
            "update_id"         : id,
            "answer"            : appStoreButtonPressed ? "yes" : "no",
            "type"              : "newer_version"
        ]
        
        manager.request(.POST, kBaseURL + "notify/updates/views", parameters:params, headers: headers())
    }
    
    static func markWhatsNewAsSeen(id: Int) {
        let params:[String : AnyObject] = [
            "guid"              : Configuration.guid(),
            "update_id"         : id,
            "type"              : "new_in_version",
            "answer"            : "no",
        ]
        
        manager.request(.POST, kBaseURL + "notify/updates/views", parameters:params, headers: headers())
    }
    
    static func markMessageAsRead(id: String) {
        let params:[String : AnyObject] = [
            "guid"              : Configuration.guid(),
            "message_id"        : id
        ]
        
        manager.request(.POST, kBaseURL + "notify/messages/views", parameters:params, headers: headers())
    }
    
    static func markRateReminderAsSeen(answer:AlertManager.RateReminderResult) {
        let params:[String : AnyObject] = [
            "guid"              : Configuration.guid(),
            "platform"          : "ios",
            "answer"            : answer.rawValue
        ]
        
        manager.request(.POST, kBaseURL + "notify/rate_reminder/views", parameters:params, headers: headers())
    }
}

extension NStackConnectionManager {
    //MARK: - Utility functions
    
    internal static func lastUpdatedString() -> String {
        
        let currentAcceptLangString = TranslationManager.sharedInstance.acceptLanguageHeaderValueString()
        if let prevAcceptLangString:String? = NOPersistentStore(id: NStackConstants.persistentStoreID).objectForKey(NStackConstants.prevAcceptedLanguageKey) as? String where prevAcceptLangString != currentAcceptLangString {
            NOPersistentStore(id: NStackConstants.persistentStoreID).setObject(currentAcceptLangString, forKey: NStackConstants.prevAcceptedLanguageKey)
            self.setLastUpdatedToDistantPast()
        }
        
        let date:NSDate? = NOPersistentStore(id: NStackConstants.persistentStoreID).objectForKey(NStackConstants.lastUpdatedDateKey) as? NSDate
        
        let dateObject = Date(date: date ?? NSDate.distantPast())
        
        return dateObject?.stringRepresentation() ?? ""
    }
    
    internal static func setLastUpdatedToNow() {
        NOPersistentStore(id: NStackConstants.persistentStoreID).setObject(Date().value, forKey: NStackConstants.lastUpdatedDateKey)
    }
    
    internal static func setLastUpdatedToDistantPast() {
        NOPersistentStore(id: NStackConstants.persistentStoreID).setObject(NSDate.distantPast(), forKey: NStackConstants.lastUpdatedDateKey)
    }
}