//
//  PropertyWrapper.swift
//  NStackSDK
//
//  Created by Bob De Kort on 02/08/2019.
//  Copyright © 2019 Nodes ApS. All rights reserved.
//

import Foundation

#if swift(>=5.1)
@propertyWrapper public struct NSLocalizable<T: NStackLocalizable> {
    private var _component: NStackLocalizable?
    var translation: String

    public init(_ translationKey: String) {
        self.translation = translationKey
    }

    // Has to be 'value' for the @propertyWrapper to work.
    // 'value' refers to the NStackLocalizable component that will use the translation
    public var wrappedValue: T? {
        get { return _component as? T }
        set {
            _component = newValue
            _component?.localize(for: translation)
        }
    }
}
#endif
