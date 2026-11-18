//
//  Tracker+CoreData.swift
//  Tracker
//
//  Created by Eduard Ptushko on 17.11.2026.
//

import UIKit

extension Tracker {
    init?(
        from entity: TrackerEntity,
        colorMarshalling: UIColorMarshalling = UIColorMarshalling()
    ) {
        guard
            let trackerID = entity.trackerId,
            let name = entity.name,
            let emoji = entity.emoji,
            let color = entity.colorHex
        else {
            return nil
        }

        self.id = trackerID
        self.name = name
        self.color = colorMarshalling.color(from: color)
        self.emoji = emoji
        self.schedule = entity.schedule as? Set<WeekDay>
    }
}
