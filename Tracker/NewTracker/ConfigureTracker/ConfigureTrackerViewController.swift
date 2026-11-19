//
//  ConfigureTrackerViewController.swift
//  Tracker
//
//  Created by Eduard Ptushko on 03.11.2026.
//

import UIKit

final class ConfigureTrackerViewController: UIViewController {

    private struct FormState {
        var name: String = ""
        var schedule: Set<WeekDay> = []
        var category: String?
        var emoji: String?
        var color: UIColor?

        var trimmedName: String {
            name.trimmingCharacters(in: .whitespacesAndNewlines)
        }

        func isValid(for type: TrackerType) -> Bool {
            let hasName = !trimmedName.isEmpty
            let hasBasics = category != nil && emoji != nil && color != nil
            let hasValidSchedule = type == .irregular || !schedule.isEmpty
            return hasName && hasBasics && hasValidSchedule
        }

        func makeTracker(for type: TrackerType) -> Tracker? {
            guard isValid(for: type), let color, let emoji else { return nil }

            return Tracker(
                id: UUID(),
                name: trimmedName,
                color: color,
                emoji: emoji,
                schedule: type == .habit ? schedule : nil
            )
        }
    }

    private enum Layout {
        static let contentSpacing: CGFloat = 24
        static let contentVerticalInset: CGFloat = 24
        static let buttonsSpacing: CGFloat = 8
        static let buttonsHeight: CGFloat = 60
        static let buttonsHorizontalInset: CGFloat = 20
        static let bottomPadding: CGFloat = 16
        static let scrollBottomSpacing: CGFloat = 16
    }

    // MARK: - Private Properties

    private let dataStore: any TrackerDataStoreProtocol
    private let type: TrackerType

    private var formState = FormState() {
        didSet {
            createButton.isEnabled = formState.isValid(for: type)
        }
    }

    // MARK: - UI Elements

    private let trackersCollectionView = TrackerCustomizationCollectionView()
    private let nameInputView = TrackerNameInputView()
    private lazy var optionsCardView = TrackerOptionsCardView(type: type)

    private let createButton = CreateTrackerButton(
        title: "Создать",
        style: .primary
    )
    private let cancelButton = CreateTrackerButton(
        title: "Отменить",
        style: .cancel
    )

    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.backgroundColor = .systemBackground
        scrollView.keyboardDismissMode = .onDrag
        return scrollView
    }()

    private lazy var contentStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [
            nameInputView, optionsCardView, trackersCollectionView,
        ])
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.spacing = Layout.contentSpacing
        stack.isLayoutMarginsRelativeArrangement = true
        stack.layoutMargins = UIEdgeInsets(
            top: Layout.contentVerticalInset,
            left: 0,
            bottom: Layout.contentVerticalInset,
            right: 0
        )
        return stack
    }()

    private lazy var buttonsStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [cancelButton, createButton])
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .horizontal
        stack.spacing = Layout.buttonsSpacing
        stack.distribution = .fillEqually
        return stack
    }()

    // MARK: - Init

    init(dataStore: any TrackerDataStoreProtocol, type: TrackerType) {
        self.dataStore = dataStore
        self.type = type
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        // This controller is not initialised via Storyboard
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupConstraints()
        setupBindings()
    }

    // MARK: - Private Methods

    private func setupView() {
        title = type == .habit ? "Новая привычка" : "Новое нерегулярное событие"
        view.backgroundColor = .systemBackground
        createButton.isEnabled = false

        view.addSubview(scrollView)
        view.addSubview(buttonsStack)
        scrollView.addSubview(contentStack)

        let defaultCategoryName = MockTrackerData.defaultCategory
        formState.category = defaultCategoryName
        optionsCardView.setCategorySubtitle(defaultCategoryName)
        trackersCollectionView.trackerDelegate = self
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            buttonsStack.bottomAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.bottomAnchor,
                constant: -Layout.bottomPadding
            ),
            buttonsStack.leadingAnchor.constraint(
                equalTo: view.leadingAnchor,
                constant: Layout.buttonsHorizontalInset
            ),
            buttonsStack.trailingAnchor.constraint(
                equalTo: view.trailingAnchor,
                constant: -Layout.buttonsHorizontalInset
            ),
            buttonsStack.heightAnchor.constraint(
                equalToConstant: Layout.buttonsHeight
            ),

            scrollView.topAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.topAnchor
            ),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(
                equalTo: buttonsStack.topAnchor,
                constant: -Layout.scrollBottomSpacing
            ),

            contentStack.topAnchor.constraint(
                equalTo: scrollView.contentLayoutGuide.topAnchor
            ),
            contentStack.leadingAnchor.constraint(
                equalTo: scrollView.contentLayoutGuide.leadingAnchor
            ),
            contentStack.trailingAnchor.constraint(
                equalTo: scrollView.contentLayoutGuide.trailingAnchor
            ),
            contentStack.bottomAnchor.constraint(
                equalTo: scrollView.contentLayoutGuide.bottomAnchor
            ),
            contentStack.widthAnchor.constraint(
                equalTo: scrollView.frameLayoutGuide.widthAnchor
            ),
        ])
    }

    private func setupBindings() {
        nameInputView.onTextChanged = { [weak self] text in
            self?.formState.name = text
        }

        optionsCardView.onCategoryTap = { [weak self] in
            self?.didTapCategory()
        }

        optionsCardView.onScheduleTap = { [weak self] in
            self?.didTapSchedule()
        }

        createButton.addAction(
            UIAction { [weak self] _ in
                self?.didTapCreateButton()
            },
            for: .touchUpInside
        )

        cancelButton.addAction(
            UIAction { [weak self] _ in
                self?.didTapCancelButton()
            },
            for: .touchUpInside
        )
    }

    private func updateScheduleRowSubtitle() {
        guard type == .habit else { return }

        if formState.schedule.count == WeekDay.allCases.count {
            optionsCardView.setScheduleSubtitle("Каждый день")
        } else if !formState.schedule.isEmpty {
            let sortedDays = formState.schedule.sorted {
                $0.rawValue < $1.rawValue
            }
            let daysText = sortedDays.map { $0.shortName }.joined(
                separator: ", "
            )
            optionsCardView.setScheduleSubtitle(daysText)
        } else {
            optionsCardView.setScheduleSubtitle(nil)
        }
    }

    // MARK: - Actions

    private func didTapSchedule() {
        let scheduleViewController = ScheduleViewController()
        scheduleViewController.delegate = self
        navigationController?.pushViewController(
            scheduleViewController,
            animated: true
        )
    }

    private func didTapCategory() {
        //TODO: Push CategoryViewController
    }

    private func didTapCreateButton() {
        guard let category = formState.category,
            let tracker = formState.makeTracker(for: type)
        else { return }

        do {
            try dataStore.addTracker(tracker, toCategoryWithTitle: category)
            view.window?.rootViewController?.dismiss(
                animated: true
            )
        } catch {
            assertionFailure("Failed to save tracker: \(error)")
        }
    }

    private func didTapCancelButton() {
        dismiss(animated: true)
    }
}
// MARK: - ScheduleViewControllerDelegate

extension ConfigureTrackerViewController: ScheduleViewControllerDelegate {
    func didSelectSchedule(schedule: Set<WeekDay>) {
        formState.schedule = schedule
        updateScheduleRowSubtitle()
    }
}

// MARK: - TrackerCustomizationCollectionViewDelegate

extension ConfigureTrackerViewController:
    TrackerCustomizationCollectionViewDelegate
{
    func selectView(
        _ view: TrackerCustomizationCollectionView,
        didSelectEmoji emoji: String
    ) {
        formState.emoji = emoji
    }

    func selectView(
        _ view: TrackerCustomizationCollectionView,
        didSelectColor color: UIColor
    ) {
        formState.color = color
    }
}

// MARK: - Preview

#Preview("Habit") {
    let store = TrackerDataStore(context: CoreDataStack.preview.viewContext)
    return UINavigationController(
        rootViewController:
            ConfigureTrackerViewController(dataStore: store, type: .habit)
    )
}

#Preview("Irregular") {
    let store = TrackerDataStore(context: CoreDataStack.preview.viewContext)
    return UINavigationController(
        rootViewController:
            ConfigureTrackerViewController(dataStore: store, type: .irregular)
    )
}
