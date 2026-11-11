//
//  ConfigureTrackerViewController.swift
//  Tracker
//
//  Created by Eduard Ptushko on 03.11.2026.
//

import UIKit

protocol ConfigureTrackerViewControllerDelegate: AnyObject {
    func didCreateTracker(_ tracker: Tracker, in categoryTitle: String)
}

final class ConfigureTrackerViewController: UIViewController {

    weak var delegate: ConfigureTrackerViewControllerDelegate?

    private let type: TrackerType
    private var trackerName: String = ""
    private var schedule: Set<WeekDay> = []
    private var category: String?
    private var selectedEmoji: String?
    private var selectedColor: UIColor?

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
        stack.spacing = 24
        stack.isLayoutMarginsRelativeArrangement = true
        stack.layoutMargins = UIEdgeInsets(
            top: 24,
            left: 0,
            bottom: 24,
            right: 0
        )
        return stack
    }()

    private lazy var buttonsStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [cancelButton, createButton])
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .horizontal
        stack.spacing = 8
        stack.distribution = .fillEqually
        return stack
    }()

    // MARK: - Init

    init(type: TrackerType) {
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
        self.category = defaultCategoryName
        optionsCardView.setCategorySubtitle(defaultCategoryName)
        trackersCollectionView.trackerDelegate = self
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            buttonsStack.bottomAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.bottomAnchor,
                constant: -16
            ),
            buttonsStack.leadingAnchor.constraint(
                equalTo: view.leadingAnchor,
                constant: 20
            ),
            buttonsStack.trailingAnchor.constraint(
                equalTo: view.trailingAnchor,
                constant: -20
            ),
            buttonsStack.heightAnchor.constraint(equalToConstant: 60),

            scrollView.topAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.topAnchor
            ),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(
                equalTo: buttonsStack.topAnchor,
                constant: -16
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
            self?.trackerName = text
            self?.updateCreateButtonState()
        }

        optionsCardView.onCategoryTap = { [weak self] in
            self?.didTapCategory()
        }

        optionsCardView.onScheduleTap = { [weak self] in
            self?.didTapSchedule()
        }

        createButton.addTarget(
            self,
            action: #selector(didTapCreateButton),
            for: .touchUpInside
        )
        cancelButton.addTarget(
            self,
            action: #selector(didTapCancelButton),
            for: .touchUpInside
        )
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

    @objc private func didTapCreateButton() {
        let trimmedName = trackerName.trimmingCharacters(
            in: .whitespacesAndNewlines
        )
        guard let category, let selectedColor, let selectedEmoji,
            !trimmedName.isEmpty
        else { return }
        let tracker = Tracker(
            id: UUID(),
            name: trimmedName,
            color: selectedColor,
            emoji: selectedEmoji,
            schedule: type == .habit ? schedule : nil
        )

        delegate?.didCreateTracker(tracker, in: category)
        view.window?.rootViewController?.dismiss(
            animated: true,
            completion: nil
        )
    }

    @objc private func didTapCancelButton() {
        dismiss(animated: true, completion: nil)
    }

    private func updateCreateButtonState() {
        let isNameValid = !trackerName.trimmingCharacters(
            in: .whitespacesAndNewlines
        ).isEmpty
        let isCategoryValid = category != nil
        let isSelectedEmojiValid = selectedEmoji != nil
        let isSelectedColorValid = selectedColor != nil
        let isScheduleValid = type == .habit ? !schedule.isEmpty : true

        createButton.isEnabled =
            isNameValid && isCategoryValid && isScheduleValid
            && isSelectedColorValid
            && isScheduleValid
    }
}
// MARK: - ScheduleViewControllerDelegate

extension ConfigureTrackerViewController: ScheduleViewControllerDelegate {
    func didSelectSchedule(schedule: Set<WeekDay>) {
        self.schedule = schedule
        updateScheduleRowSubtitle()
        updateCreateButtonState()
    }

    private func updateScheduleRowSubtitle() {
        guard type == .habit else { return }

        if schedule.count == 7 {
            optionsCardView.setScheduleSubtitle("Каждый день")
        } else if !schedule.isEmpty {
            let sortedDays = schedule.sorted { $0.rawValue < $1.rawValue }
            let daysText = sortedDays.map { $0.shortName }.joined(
                separator: ", "
            )
            optionsCardView.setScheduleSubtitle(daysText)
        } else {
            optionsCardView.setScheduleSubtitle(nil)
        }
    }
}

extension ConfigureTrackerViewController:
    TrackerCustomizationCollectionViewDelegate
{
    func selectView(
        _ view: TrackerCustomizationCollectionView,
        didSelectEmoji emoji: String
    ) {
        selectedEmoji = emoji
        updateCreateButtonState()
    }

    func selectView(
        _ view: TrackerCustomizationCollectionView,
        didSelectColor color: UIColor
    ) {
        selectedColor = color
        updateCreateButtonState()
    }

}

// MARK: - Preview

#Preview("Habit") {
    UINavigationController(
        rootViewController:
            ConfigureTrackerViewController(type: .habit)
    )
}

#Preview("Irregular") {
    UINavigationController(
        rootViewController:
            ConfigureTrackerViewController(type: .irregular)
    )
}
