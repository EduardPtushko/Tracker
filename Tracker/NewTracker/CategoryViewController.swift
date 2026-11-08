//
//  CategoryViewController.swift
//  Tracker
//
//  Created by Eduard Ptushko on 03.11.2026.
//

import UIKit

final class CategoryViewController: UIViewController {
    private let emptyStateView = EmptyStateView()

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.hidesBackButton = true
        setupView()
    }

    private func setupView() {
        view.backgroundColor = .systemBackground
        title = "Категория"

        view.addSubview(emptyStateView)
        emptyStateView.edgesToSuperview()
        emptyStateView.configure(
            image: UIImage(resource: .emptyListPlaceholder),
            text: "Привычки и события можно объединить по смыслу"
        )
    }
}

#Preview {
    UINavigationController(rootViewController: CategoryViewController())
}
