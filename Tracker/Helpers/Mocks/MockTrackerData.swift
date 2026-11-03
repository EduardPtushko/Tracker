//
//  MockTrackerData.swift
//  Tracker
//
//  Created by Eduard Ptushko on 02.11.2026.
//

import UIKit

#if DEBUG
    struct MockTrackerData {

        private static let waterTrackerId = UUID()
        private static let runTrackerId = UUID()
        private static let swiftTrackerId = UUID()
        private static let bookTrackerId = UUID()

        static let mockTracker = Tracker(
            id: UUID(),
            name: "Learn iOS Architecture",
            color: .systemBlue,
            emoji: "🚀",
            schedule: [WeekDay.friday]
        )

        static let categories: [TrackerCategory] = [
            TrackerCategory(
                title: "Спорт и здоровье",
                trackers: [
                    Tracker(
                        id: runTrackerId,
                        name: "Утренняя пробежка",
                        color: UIColor(
                            red: 0.27,
                            green: 0.51,
                            blue: 0.71,
                            alpha: 1.0
                        ),  // #4682B4
                        emoji: "🏃‍♂️",
                        schedule: [.monday, .wednesday, .friday]
                    ),
                    Tracker(
                        id: waterTrackerId,
                        name: "Выпить 2л воды",
                        color: UIColor(
                            red: 0.0,
                            green: 0.75,
                            blue: 1.0,
                            alpha: 1.0
                        ),  // #00BFFF
                        emoji: "💧",
                        schedule: Set(WeekDay.allCases)
                    ),
                ]
            ),

            TrackerCategory(
                title: "Обучение",
                trackers: [
                    Tracker(
                        id: swiftTrackerId,
                        name: "Учить Swift",
                        color: UIColor(
                            red: 0.98,
                            green: 0.5,
                            blue: 0.45,
                            alpha: 1.0
                        ),  // #FA8072
                        emoji: "💻",
                        schedule: [
                            .monday, .tuesday, .wednesday, .thursday, .friday,
                        ]
                    ),
                    Tracker(
                        id: bookTrackerId,
                        name: "Чтение книги",
                        color: UIColor(
                            red: 0.55,
                            green: 0.27,
                            blue: 0.07,
                            alpha: 1.0
                        ),  // #8B4513
                        emoji: "📚",
                        schedule: Set(WeekDay.allCases)
                    ),
                ]
            ),
        ]

        static let completedTrackers: [TrackerRecord] = [
            TrackerRecord(id: waterTrackerId, date: Date()),
            TrackerRecord(id: bookTrackerId, date: Date()),
            TrackerRecord(id: runTrackerId, date: Date.daysAgo(1)),
        ]
    }
#endif
