//
//  TabBarController.swift
//  Tracker
//
//  Created by Eduard Ptushko on 23.10.2026.
//

import UIKit

class TabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        setUpTabs()
    }
    
    private func setUpTabs() {
        let trackersViewController = TrackersViewController()
        trackersViewController.navigationItem.largeTitleDisplayMode = .automatic
        
        let navTrackers = UINavigationController(rootViewController: trackersViewController)
        navTrackers.tabBarItem = UITabBarItem(
            title: "Трекеры",
            image: UIImage(resource: .tabTrackers), selectedImage: nil
        )
        navTrackers.navigationBar.prefersLargeTitles = true
        
        let statisticsViewController = StatisticsViewController()
        statisticsViewController.navigationItem.largeTitleDisplayMode = .automatic
        
        let navStatistics = UINavigationController(rootViewController: statisticsViewController)
        navStatistics.tabBarItem = UITabBarItem(
            title: "Статистика",
            image: UIImage(resource: .tabStatistics),
            selectedImage: nil
        )
        navStatistics.navigationBar.prefersLargeTitles = true
      
        self.viewControllers = [
            navTrackers,
            navStatistics
        ]
    }

}

#Preview {
    TabBarController()
}
