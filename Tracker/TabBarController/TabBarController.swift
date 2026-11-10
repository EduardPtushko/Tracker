//
//  TabBarController.swift
//  Tracker
//
//  Created by Eduard Ptushko on 23.10.2026.
//

import UIKit

final class TabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTabBarAppearance()
        setUpTabs()
    }

    private func setupTabBarAppearance() {
        tabBar.tintColor = .trackerBlue
        tabBar.unselectedItemTintColor = .gray

        let appearance = UITabBarAppearance()
        appearance.configureWithDefaultBackground()
        appearance.backgroundColor = .systemBackground

        tabBar.standardAppearance = appearance
        if #available(iOS 15.0, *) {
            tabBar.scrollEdgeAppearance = appearance
        }
    }

    private func setUpTabs() {
        let trackersViewController = TrackersViewController()
        let navTrackers = UINavigationController(
            rootViewController: trackersViewController
        )
        navTrackers.tabBarItem = UITabBarItem(
            title: "Трекеры",
            image: UIImage(resource: .tabTrackers),
            selectedImage: nil
        )
       
        let statisticsViewController = StatisticsViewController()
        let navStatistics = UINavigationController(
            rootViewController: statisticsViewController
        )
        navStatistics.tabBarItem = UITabBarItem(
            title: "Статистика",
            image: UIImage(resource: .tabStatistics),
            selectedImage: nil
        )

        self.viewControllers = [
            navTrackers,
            navStatistics,
        ]
    }
}

#Preview {
    TabBarController()
}
