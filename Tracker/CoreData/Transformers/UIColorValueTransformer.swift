//
//  UIColorValueTransformer.swift
//  Tracker
//
//  Created by Eduard Ptushko on 12.11.2026.
//

import UIKit

@objc(UIColorValueTransformer)
final class UIColorValueTransformer: NSSecureUnarchiveFromDataTransformer {

    override static var allowedTopLevelClasses: [AnyClass] {
        return [UIColor.self]
    }

    static func register() {
        let transformer = UIColorValueTransformer()
        ValueTransformer.setValueTransformer(
            transformer,
            forName: NSValueTransformerName("UIColorValueTransformer")
        )
    }
}
