//
//  TrackerTypeSelectionViewController.swift
//  Tracker
//
//  Created by Eduard Ptushko on 03.11.2026.
//

import UIKit

final class TrackerTypeSelectionViewController: UIViewController {

    private enum Layout {
        static let horizontalInset: CGFloat = 16
        static let stackSpacing: CGFloat = 16
    }

    // MARK: - Dependencies

    private let dataStore: any TrackerDataStoreProtocol

    // MARK: - UI Elements

    private let habitButton = TrackerButton(title: "Привычка")
    private let irregularEventButton = TrackerButton(
        title: "Нерегулярное событие"
    )

    private lazy var contentStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [
            habitButton, irregularEventButton,
        ])
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.spacing = Layout.stackSpacing
        return stack
    }()

    // MARK: - Init

    init(dataStore: any TrackerDataStoreProtocol) {
        self.dataStore = dataStore
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupActions()
        setupConstraints()
    }

    // MARK: - Private Methods

    private func setupView() {
        view.backgroundColor = .systemBackground
        title = "Создание трекера"
        view.addSubview(contentStack)
    }

    private func setupActions() {
        habitButton.addAction(
            UIAction { [weak self] _ in
                self?.presentConfigureScreen(type: .habit)
            },
            for: .touchUpInside
        )

        irregularEventButton.addAction(
            UIAction { [weak self] _ in
                self?.presentConfigureScreen(type: .irregular)
            },
            for: .touchUpInside
        )
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            contentStack.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            contentStack.leadingAnchor.constraint(
                equalTo: view.leadingAnchor,
                constant: Layout.horizontalInset
            ),
            contentStack.trailingAnchor.constraint(
                equalTo: view.trailingAnchor,
                constant: -Layout.horizontalInset
            ),
        ])
    }

    private func presentConfigureScreen(type: TrackerType) {
        let configureTrackerViewController = ConfigureTrackerViewController(
            dataStore: dataStore,
            type: type
        )

        let navigationController = UINavigationController(
            rootViewController: configureTrackerViewController
        )
        present(navigationController, animated: true)
    }
}

// MARK: - Preview

#Preview {
    let store = TrackerDataStore(context: CoreDataStack.preview.viewContext)
    return UINavigationController(
        rootViewController: TrackerTypeSelectionViewController(dataStore: store)
    )
}
