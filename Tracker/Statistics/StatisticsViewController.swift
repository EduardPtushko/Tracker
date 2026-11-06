//
//  StatisticsViewController.swift
//  Tracker
//
//  Created by Eduard Ptushko on 23.10.2026.
//

import UIKit

class StatisticsViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Статистика"
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.largeTitleDisplayMode = .automatic
    }
}

#Preview {
    UINavigationController(
        rootViewController: StatisticsViewController()
    )
}
