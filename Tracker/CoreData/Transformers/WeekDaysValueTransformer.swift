//
//  WeekDaysValueTransformer.swift
//  Tracker
//
//  Created by Eduard Ptushko on 17.11.2026.
//


import Foundation

@objc(WeekDaysValueTransformer)
final class WeekDaysValueTransformer: ValueTransformer {
    
    // Specify that this transformer converts data into NSData
    override class func transformedValueClass() -> AnyClass {
        return NSData.self
    }
    
    // Allow reverse transformation (from NSData back to Set<WeekDay>)
    override class func allowsReverseTransformation() -> Bool {
        return true
    }
    
    // Convert Set<WeekDay> -> NSData when saving to Core Data
    override func transformedValue(_ value: Any?) -> Any? {
        guard let days = value as? Set<WeekDay> else { return nil }
        return try? JSONEncoder().encode(days)
    }
    
    // Convert NSData -> Set<WeekDay> when fetching from Core Data
    override func reverseTransformedValue(_ value: Any?) -> Any? {
        guard let data = value as? Data else { return nil }
        return try? JSONDecoder().decode(Set<WeekDay>.self, from: data)
    }
    
    // Helper method to register the transformer before loading NSPersistentContainer
    static func register() {
        let transformer = WeekDaysValueTransformer()
        ValueTransformer.setValueTransformer(
            transformer,
            forName: NSValueTransformerName("WeekDaysValueTransformer")
        )
    }
}
