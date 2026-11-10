//
//  TrackerTypeSelectionViewController.swift
//  Tracker
//
//  Created by Eduard Ptushko on 03.11.2026.
//

import UIKit

final class TrackerTypeSelectionViewController: UIViewController {

    private weak var delegate: ConfigureTrackerViewControllerDelegate?

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

    init(delegate: ConfigureTrackerViewControllerDelegate? = nil) {
        self.delegate = delegate
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

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
        let configureTrackerViewController = ConfigureTrackerViewController(
            type: .habit
        )
        configureTrackerViewController.delegate = self.delegate
        let navigationController = UINavigationController(
            rootViewController: configureTrackerViewController
        )
        present(navigationController, animated: true)
    }

    @objc private func didTapIrregularTracker() {
        let configureTrackerViewController = ConfigureTrackerViewController(
            type: .irregular
        )
        configureTrackerViewController.delegate = self.delegate
        let navigationController = UINavigationController(
            rootViewController: configureTrackerViewController
        )
        present(navigationController, animated: true)
    }

}

// MARK: - Preview

#Preview {
    UINavigationController(
        rootViewController: TrackerTypeSelectionViewController()
    )
}
