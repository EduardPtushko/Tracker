//
//  Tracker.swift
//  Tracker
//
//  Created by Eduard Ptushko on 29.10.2026.
//

import UIKit

struct Tracker {
    let id: UUID
    let name: String
    let color: UIColor
    let emoji: String
    let schedule: Set<WeekDay>?
}

