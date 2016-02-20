//
//  Language.swift
//
//  Created by Chris Combs on 07/09/15.
//  Copyright (c) 2014 Nodes. All rights reserved.
//

import Foundation
import Serializable
import NStack

public var tr:Translations {
    get {
        return TranslationManager.sharedInstance.translations()
    }
}

public struct Translations: Translatable {

	struct Default {
		var successKey = ""
	}


	var defaultSection = Default()

	public func inputKeyMappings() -> [String : String] {
		return ["defaultSection" : "default"]
	}
}

extension Translations:Serializable {
    public init(dictionary: [String : AnyObject]?) {
        defaultSection = self.mapped(dictionary, key: "defaultSection") ?? defaultSection
    }

    public func encodableRepresentation() -> NSCoding {
        var dict = [String : AnyObject]()
        dict["defaultSection"] = defaultSection.encodableRepresentation()
		return dict
    }
}
extension Translations.Default:Serializable {
    init(dictionary: [String : AnyObject]?) {
        successKey = self.mapped(dictionary, key: "successKey") ?? successKey
    }

    func encodableRepresentation() -> NSCoding {
        var dict = [String : AnyObject]()
        dict["successKey"] = successKey
		return dict
    }
}

