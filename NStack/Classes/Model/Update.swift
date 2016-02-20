//
//  Update.swift
//  NStack
//
//  Created by Kasper Welner on 09/09/15.
//  Copyright © 2015 Nodes. All rights reserved.
//

import Foundation
import Serializable

struct Update
{
    var newInThisVersion:Changelog?
    var newerVersion:Version?
    
    struct UpdateTranslations {
        var title       = ""
        var message     = ""
        var positiveBtn = ""
        var negativeBtn = ""
    }
    
    struct Update
    {
        var newInThisVersion:Changelog? //<-new_in_version
        var newerVersion:Version?
    }
    
    struct Changelog {
        var state = false
        var lastId = 0
        var version = ""
        var translate:UpdateTranslations?
    }
    
    struct Version {
        var state = State.Disabled
        var lastId = 0
        var version = ""
        var translations = UpdateTranslations() //<-translate
        var link:NSURL?
        
        enum State : String {
            case Disabled    = "no"
            case Remind      = "yes"
            case Force       = "force"
        }
    }
}

//Boilerplate code:

extension Update.UpdateTranslations:Serializable {
    init(dictionary: NSDictionary?) {
        title       = self.mapped(dictionary, key: "title") ?? title
        message     = self.mapped(dictionary, key: "message") ?? message
        positiveBtn = self.mapped(dictionary, key: "positive_btn") ?? positiveBtn
        negativeBtn = self.mapped(dictionary, key: "negative_btn") ?? negativeBtn
    }

    func encodableRepresentation() -> NSCoding {
        let dict = NSMutableDictionary()
        dict["title"]        = title
        dict["message"]      = message
        dict["positive_btn"] = positiveBtn
        dict["negative_btn"] = negativeBtn
        return dict
    }
}

extension Update.Changelog:Serializable {
    init(dictionary: NSDictionary?) {
        state     = self.mapped(dictionary, key: "state") ?? state
        lastId    = self.mapped(dictionary, key: "last_id") ?? lastId
        version   = self.mapped(dictionary, key: "version") ?? version
        translate = self.mapped(dictionary, key: "translate")
    }

    func encodableRepresentation() -> NSCoding {
        let dict = NSMutableDictionary()
        dict["state"]     = state
        dict["last_id"]   = lastId
        dict["version"]   = version
        dict["translate"] = translate?.encodableRepresentation()
        return dict
    }
}

extension Update:Serializable {
    init(dictionary: NSDictionary?) {
        newInThisVersion = self.mapped(dictionary, key: "new_in_version")
        newerVersion     = self.mapped(dictionary, key: "newer_version")
    }

    func encodableRepresentation() -> NSCoding {
        let dict = NSMutableDictionary()
        dict["new_in_version"] = newInThisVersion?.encodableRepresentation()
        dict["newer_version"]  = newerVersion?.encodableRepresentation()
        return dict
    }
}

extension Update.Version:Serializable {
    init(dictionary: NSDictionary?) {
        state        = self.mapped(dictionary, key: "state") ?? state
        lastId       = self.mapped(dictionary, key: "last_id") ?? lastId
        version      = self.mapped(dictionary, key: "version") ?? version
        translations = self.mapped(dictionary, key: "translate") ?? translations
        link         = self.mapped(dictionary, key: "link")
    }

    func encodableRepresentation() -> NSCoding {
        let dict = NSMutableDictionary()
        dict["state"]     = state.encodableRepresentation()
        dict["last_id"]   = lastId
        dict["version"]   = version
        dict["translate"] = translations.encodableRepresentation()
        dict["link"]      = link
        return dict
    }
}