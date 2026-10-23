//
//  TrackersViewController.swift
//  Tracker
//
//  Created by Eduard Ptushko on 22.10.2026.
//

import UIKit

class TrackersViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Трекеры"
        configureNavBarButton()
    }
    
    private func configureNavBarButton() {
        let addButton = UIBarButtonItem(image: UIImage(resource: .addTracker), style: .plain, target: self, action: #selector(addTrackerButtonTapped))
        
        navigationItem.leftBarButtonItem = addButton
    }
    
   @objc private func addTrackerButtonTapped() {
        print("Add Tracker button tapped")
    }

}

