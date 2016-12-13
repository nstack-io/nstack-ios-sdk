//
//  Update.swift
//  NStack
//
//  Created by Kasper Welner on 09/09/15.
//  Copyright © 2015 Nodes. All rights reserved.
//

import Foundation
import Serpent

enum UpdateState: String {
    case Disabled    = "no"
    case Remind      = "yes"
    case Force       = "force"
}

struct Update {
    var newInThisVersion:Changelog?
    var newerVersion:Version?
    
    struct UpdateTranslations {
        var title       = ""
        var message     = ""
        var positiveBtn = ""
        var negativeBtn = ""
    }
    
    struct Update {
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
        var state = UpdateState.Disabled
        var lastId = 0
        var version = ""
        var translations = UpdateTranslations() //<-translate
        var link:URL?
        

    }
}

//Boilerplate code:

extension Update: Serializable {
    init(dictionary: NSDictionary?) {
        newInThisVersion <== (self, dictionary, "new_in_version")
        newerVersion     <== (self, dictionary, "newer_version")
    }
    
    func encodableRepresentation() -> NSCoding {
        let dict = NSMutableDictionary()
        (dict, "new_in_version") <== newInThisVersion
        (dict, "newer_version")  <== newerVersion
        return dict
    }
}

extension Update.UpdateTranslations: Serializable {
    init(dictionary: NSDictionary?) {
        title       <== (self, dictionary, "title")
        message     <== (self, dictionary, "message")
        positiveBtn <== (self, dictionary, "positiveBtn")
        negativeBtn <== (self, dictionary, "negativeBtn")
    }
    
    func encodableRepresentation() -> NSCoding {
        let dict = NSMutableDictionary()
        (dict, "title")        <== title
        (dict, "message")      <== message
        (dict, "positiveBtn") <== positiveBtn
        (dict, "negativeBtn") <== negativeBtn
        return dict
    }
}

extension Update.Changelog: Serializable {
    init(dictionary: NSDictionary?) {
        state     <== (self, dictionary, "state")
        lastId    <== (self, dictionary, "last_id")
        version   <== (self, dictionary, "version")
        translate <== (self, dictionary, "translate")
    }
    
    func encodableRepresentation() -> NSCoding {
        let dict = NSMutableDictionary()
        (dict, "state")     <== state
        (dict, "last_id")   <== lastId
        (dict, "version")   <== version
        (dict, "translate") <== translate
        return dict
    }
}

extension Update.Version: Serializable {
    init(dictionary: NSDictionary?) {
        state        <== (self, dictionary, "state")
        lastId       <== (self, dictionary, "last_id")
        version      <== (self, dictionary, "version")
        translations <== (self, dictionary, "translate")
        link         <== (self, dictionary, "link")
    }
    
    func encodableRepresentation() -> NSCoding {
        let dict = NSMutableDictionary()
        (dict, "state")     <== state
        (dict, "last_id")   <== lastId
        (dict, "version")   <== version
        (dict, "translate") <== translations
        (dict, "link")      <== link
        return dict
    }
}
