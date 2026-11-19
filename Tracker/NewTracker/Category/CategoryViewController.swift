//
//  CategoryViewController.swift
//  Tracker
//
//  Created by Eduard Ptushko on 03.11.2026.
//

import UIKit

final class CategoryViewController: UIViewController {
    private let emptyStateView = EmptyStateView()
    private let addCategoryButton = TrackerButton(title: "Добавить категорию")

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.hidesBackButton = true
        setupView()
    }

    private func setupView() {
        view.backgroundColor = .systemBackground
        title = "Категория"

        view.addSubviews([emptyStateView, addCategoryButton])
        emptyStateView.edgesToSuperview()
        emptyStateView.configure(
            image: UIImage(resource: .emptyListPlaceholder),
            text: "Привычки и события можно объединить по смыслу"
        )

        NSLayoutConstraint.activate([
            addCategoryButton.leadingAnchor.constraint(
                equalTo: view.leadingAnchor,
                constant: 20
            ),
            addCategoryButton.trailingAnchor.constraint(
                equalTo: view.trailingAnchor,
                constant: -20
            ),
            addCategoryButton.bottomAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.bottomAnchor,
                constant: -16
            ),
        ])
    }

}

#Preview {
    UINavigationController(rootViewController: CategoryViewController())
}
