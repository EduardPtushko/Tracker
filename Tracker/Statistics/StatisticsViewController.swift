//
//  StatisticsViewController.swift
//  Tracker
//
//  Created by Eduard Ptushko on 23.10.2026.
//

import UIKit

final class StatisticsViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
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
