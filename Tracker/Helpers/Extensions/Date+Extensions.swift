//
//  Date+Extensions.swift
//  Tracker
//
//  Created by Eduard Ptushko on 02.11.2026.
//

import Foundation

extension Date {

    static func daysAgo(_ days: Int) -> Date {
        return Calendar.current.date(byAdding: .day, value: -days, to: Date())
            ?? Date()
    }
}
