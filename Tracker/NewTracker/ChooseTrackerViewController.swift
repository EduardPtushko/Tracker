//
//  ChooseTrackerViewController.swift
//  Tracker
//
//  Created by Eduard Ptushko on 03.11.2026.
//

import UIKit

final class ChooseTrackerViewController: UIViewController {

    // MARK: - UI Elements

    private lazy var contentStack: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.spacing = 16
        stack.alignment = .fill
        stack.distribution = .fill
        return stack
    }()

    private let regularTrackerButton = TrackerButton(title: "Привычка")
    private let irregularTrackerButton = TrackerButton(
        title: "Нерегулярное событие"
    )

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupConstraints()
    }

    // MARK: - Private Methods

    private func setupView() {
        view.backgroundColor = .systemBackground
        title = "Создание трекера"

        view.addSubview(contentStack)
        contentStack.addArrangedSubview(regularTrackerButton)
        contentStack.addArrangedSubview(irregularTrackerButton)

        regularTrackerButton.addTarget(
            self,
            action: #selector(didTapRegularTracker),
            for: .touchUpInside
        )
        irregularTrackerButton.addTarget(
            self,
            action: #selector(didTapIrregularTracker),
            for: .touchUpInside
        )
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            contentStack.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            contentStack.leadingAnchor.constraint(
                equalTo: view.leadingAnchor,
                constant: 16
            ),
            contentStack.trailingAnchor.constraint(
                equalTo: view.trailingAnchor,
                constant: -16
            ),
        ])
    }

    // MARK: - Actions

    @objc private func didTapRegularTracker() {
        let configureVC = ConfigureTrackerViewController(type: .habit)
        let navigationController = UINavigationController(
            rootViewController: configureVC
        )
        present(navigationController, animated: true)
    }

    @objc private func didTapIrregularTracker() {
        let configureVC = ConfigureTrackerViewController(type: .irregular)
        let navigationController = UINavigationController(
            rootViewController: configureVC
        )
        present(navigationController, animated: true)
    }

}

#Preview {
    UINavigationController(rootViewController: ChooseTrackerViewController())
}
