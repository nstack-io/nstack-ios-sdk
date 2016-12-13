//
//  RateReminder.swift
//  NStack
//
//  Created by Kasper Welner on 09/09/15.
//  Copyright © 2015 Nodes. All rights reserved.
//

import Foundation
import Serpent

struct RateReminder {
    var id = 0
    var title = ""
    var body = ""
    var yesButtonTitle = ""     // <-yesBtn
    var laterButtonTitle = ""   // <-laterBtn
    var noButtonTitle = ""      // <-noBtn
    var link: URL?
}

extension RateReminder: Serializable {
    init(dictionary: NSDictionary?) {
        id               <== (self, dictionary, "id")
        title            <== (self, dictionary, "title")
        body             <== (self, dictionary, "body")
        yesButtonTitle   <== (self, dictionary, "yesBtn")
        laterButtonTitle <== (self, dictionary, "laterBtn")
        noButtonTitle    <== (self, dictionary, "noBtn")
        link             <== (self, dictionary, "link")
    }

    func encodableRepresentation() -> NSCoding {
        let dict = NSMutableDictionary()
        (dict, "id")       <== id
        (dict, "title")    <== title
        (dict, "body")     <== body
        (dict, "yesBtn")   <== yesButtonTitle
        (dict, "laterBtn") <== laterButtonTitle
        (dict, "noBtn")    <== noButtonTitle
        (dict, "link")     <== link
        return dict
    }
}
