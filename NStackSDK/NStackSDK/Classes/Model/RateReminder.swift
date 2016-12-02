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
    var id          = 0
    var title       = ""
    var body        = ""
    var rateBtn     = "" //<-yesBtn
    var laterBtn    = ""
    var neverBtn    = "" //<-noBtn
    var link:URL?
}

extension RateReminder: Serializable {
    init(dictionary: NSDictionary?) {
        id       <== (self, dictionary, "id")
        title    <== (self, dictionary, "title")
        body     <== (self, dictionary, "body")
        rateBtn  <== (self, dictionary, "yesBtn")
        laterBtn <== (self, dictionary, "laterBtn")
        neverBtn <== (self, dictionary, "noBtn")
        link     <== (self, dictionary, "link")
    }
    
    func encodableRepresentation() -> NSCoding {
        let dict = NSMutableDictionary()
        (dict, "id")        <== id
        (dict, "title")     <== title
        (dict, "body")      <== body
        (dict, "yesBtn")    <== rateBtn
        (dict, "laterBtn") <== laterBtn
        (dict, "noBtn")     <== neverBtn
        (dict, "link")      <== link
        return dict
    }
}
