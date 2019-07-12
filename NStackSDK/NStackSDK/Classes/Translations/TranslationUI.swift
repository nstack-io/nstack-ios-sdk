//
//  NOLabel.swift
//  Borsen
//
//  Created by Kasper Welner on 20/11/14.
//  Copyright (c) 2014 Nodes All rights reserved.
//

#if !os(macOS)
import UIKit
import Serpent
import Alamofire

internal func translationString(keyPath: String) -> String? {
	if keyPath.characters.isEmpty {
		return nil
	}

    let langDict = TranslationManager.sharedInstance.savedTranslationsDict() as NSDictionary
	return langDict.valueForKeyPath(keyPath) as? String
}

@IBDesignable public class NOTextView: UITextView {
    @IBInspectable public var translationsKeyPath: NSString = ""

	override public func awakeFromNib() {
		updateFromLang()
	}

	func updateFromLang() {
		let oldSelectable = self.selectable
        let string = translationString(translationsKeyPath as String)
		if string != nil {
			self.selectable = true
			self.text = string
			self.selectable = oldSelectable
		}
	}
}

@IBDesignable public class NOTextField: UITextField {

	@IBInspectable public var placeholderTranslationsKeyPath: NSString = ""

	override public func awakeFromNib() {
		updateFromLang()
	}

	func updateFromLang() {
		let string = translationString(placeholderTranslationsKeyPath as String)
		if string != nil {
			self.placeholder = string
		}
	}
}

@IBDesignable public class NOButton: UIButton {
	@IBInspectable public var translationsKeyPath: NSString = ""

	override public func awakeFromNib() {
		updateFromLang()
	}

	func updateFromLang() {
		let string = translationString(translationsKeyPath as String)
		if string != nil {
			self.setTitle(string, forState: .Normal)
		}
	}
}

@IBDesignable public class NOSegmentControl: UISegmentedControl {
	@IBInspectable public var translationKeyPath1 = ""
	@IBInspectable public var translationKeyPath2 = ""
	@IBInspectable public var translationKeyPath3 = ""
	@IBInspectable public var translationKeyPath4 = ""

	override public func awakeFromNib() {
		updateFromLang()
	}

	func updateFromLang() {
		if self.numberOfSegments > 0 {
			let string1 = translationString(translationKeyPath1)
			if let string1 = string1 {
				self.setTitle(string1, forSegmentAtIndex: 0)
			}
		}

		if self.numberOfSegments > 1 {
			let string2 = translationString(translationKeyPath2)
			if string2 != nil {
				self.setTitle(string2, forSegmentAtIndex: 1)
			}
		}

		if self.numberOfSegments > 2 {
			let string3 = translationString(translationKeyPath3)
			if string3 != nil {
				self.setTitle(string3, forSegmentAtIndex: 2)
			}
		}

		if self.numberOfSegments > 3 {
			let string4 = translationString(translationKeyPath4)
			if string4 != nil {
				self.setTitle(string4, forSegmentAtIndex: 3)
			}
		}
	}
}
#endif
