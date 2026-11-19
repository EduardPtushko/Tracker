//
//  WeekDaysValueTransformer.swift
//  Tracker
//
//  Created by Eduard Ptushko on 17.11.2026.
//

import Foundation

@objc(WeekDaysValueTransformer)
final class WeekDaysValueTransformer: ValueTransformer {

    override class func transformedValueClass() -> AnyClass {
        return NSData.self
    }

    override class func allowsReverseTransformation() -> Bool {
        return true
    }

    override func transformedValue(_ value: Any?) -> Any? {
        guard let days = value as? Set<WeekDay> else { return nil }
        return try? JSONEncoder().encode(days)
    }

    override func reverseTransformedValue(_ value: Any?) -> Any? {
        guard let data = value as? Data else { return nil }
        return try? JSONDecoder().decode(Set<WeekDay>.self, from: data)
    }

    static func register() {
        let transformer = WeekDaysValueTransformer()
        ValueTransformer.setValueTransformer(
            transformer,
            forName: NSValueTransformerName("WeekDaysValueTransformer")
        )
    }
}
