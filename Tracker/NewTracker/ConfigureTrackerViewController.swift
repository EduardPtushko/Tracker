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

    enum TrackerType {
        case habit
        case irregular
    }

    weak var delegate: ConfigureTrackerViewControllerDelegate?

    var schedule: Set<WeekDay> = []
    var category: String?

    private let type: TrackerType

    // MARK: - UI Elements

    private let createButton = CreateTrackerButton(
        title: "Создать",
        style: .primary
    )
    private let cancelButton = CreateTrackerButton(
        title: "Отменить",
        style: .cancel
    )

    private lazy var categoryRow = makeOptionRow(title: "Категория")
    private lazy var scheduleRow = makeOptionRow(title: "Расписание")

    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.backgroundColor = .systemBackground
        return scrollView
    }()

    private lazy var contentStack: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.spacing = 24
        stack.alignment = .fill
        stack.distribution = .fill
        stack.isLayoutMarginsRelativeArrangement = true
        stack.layoutMargins = UIEdgeInsets(
            top: 24,
            left: 16,
            bottom: 24,
            right: 16
        )
        return stack
    }()

    private lazy var inputStack: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.spacing = 8
        stack.alignment = .fill
        return stack
    }()

    private lazy var textFieldContainer: UIView = {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        container.backgroundColor = .trackerBackgroundDay
        container.layer.cornerRadius = 16
        container.layer.masksToBounds = true
        container.heightAnchor.constraint(equalToConstant: 75).isActive = true
        return container
    }()

    private lazy var textField: UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.placeholder = "Введите название трекера"
        textField.backgroundColor = .clear
        textField.layer.cornerRadius = 16
        textField.clipsToBounds = true
        textField.heightAnchor.constraint(equalToConstant: 75).isActive = true
        textField.leftView = UIView(
            frame: CGRect(x: 0, y: 0, width: 16, height: 1)
        )
        textField.leftViewMode = .always
        textField.rightView = UIView(
            frame: CGRect(x: 0, y: 0, width: 16, height: 1)
        )
        textField.rightViewMode = .always
        textField.addTarget(
            self,
            action: #selector(textFieldDidChange),
            for: .editingChanged
        )
        return textField
    }()

    private lazy var errorLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Ограничение 38 символов"
        label.textColor = .trackerRed
        label.font = .systemFont(ofSize: 17, weight: .regular)
        label.textAlignment = .center
        label.isHidden = true
        return label
    }()

    private lazy var optionsContainer: UIView = {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        container.backgroundColor = .trackerBackgroundDay
        container.layer.cornerRadius = 16
        container.layer.masksToBounds = true
        return container
    }()

    private lazy var optionsStack: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.distribution = .fillEqually
        stack.alignment = .fill
        return stack
    }()

    private lazy var separator: UIView = {
        let view = UIView()
        view.backgroundColor = .trackerGray
        view.translatesAutoresizingMaskIntoConstraints = false
        view.heightAnchor.constraint(equalToConstant: 0.5).isActive = true
        return view
    }()

    private lazy var buttonsStack: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .horizontal
        stack.spacing = 8
        stack.distribution = .fillEqually
        return stack
    }()

    // MARK: - Initialisers

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
        setupActions()
    }

    // MARK: - Private Methods

    private func setupView() {
        title = type == .habit ? "Новая привычка" : "Новое нерегулярное событие"
        view.backgroundColor = .systemBackground
        textField.delegate = self
        createButton.isEnabled = false

        let defaultCategoryName = MockTrackerData.defaultCategory
        self.category = defaultCategoryName

        updateSubtitle(for: categoryRow, text: defaultCategoryName)

        embedSubviews()
    }

    private func embedSubviews() {
        view.addSubview(scrollView)
        view.addSubview(buttonsStack)
        scrollView.addSubview(contentStack)

        textFieldContainer.addSubview(textField)
        inputStack.addArrangedSubview(textFieldContainer)
        inputStack.addArrangedSubview(errorLabel)
        contentStack.addArrangedSubview(inputStack)

        optionsContainer.addSubview(optionsStack)
        contentStack.addArrangedSubview(optionsContainer)
        optionsStack.addArrangedSubview(categoryRow)

        if type == .habit {
            optionsStack.addArrangedSubview(scheduleRow)
        }

        buttonsStack.addArrangedSubview(cancelButton)
        buttonsStack.addArrangedSubview(createButton)
    }

    private func setupConstraints() {
        let constraints = [
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

            textField.topAnchor.constraint(
                equalTo: textFieldContainer.topAnchor
            ),
            textField.leadingAnchor.constraint(
                equalTo: textFieldContainer.leadingAnchor
            ),
            textField.trailingAnchor.constraint(
                equalTo: textFieldContainer.trailingAnchor
            ),
            textField.bottomAnchor.constraint(
                equalTo: textFieldContainer.bottomAnchor
            ),

            optionsStack.topAnchor.constraint(
                equalTo: optionsContainer.topAnchor
            ),
            optionsStack.leadingAnchor.constraint(
                equalTo: optionsContainer.leadingAnchor
            ),
            optionsStack.trailingAnchor.constraint(
                equalTo: optionsContainer.trailingAnchor
            ),
            optionsStack.bottomAnchor.constraint(
                equalTo: optionsContainer.bottomAnchor
            ),
        ]

        configureOptionsContainer()
        NSLayoutConstraint.activate(constraints)
    }

    private func configureOptionsContainer() {
        let height: CGFloat = type == .habit ? 150 : 75
        optionsContainer.heightAnchor.constraint(equalToConstant: height)
            .isActive = true

        if type == .habit {
            optionsContainer.addSubview(separator)
            NSLayoutConstraint.activate([
                separator.leadingAnchor.constraint(
                    equalTo: optionsContainer.leadingAnchor,
                    constant: 16
                ),
                separator.trailingAnchor.constraint(
                    equalTo: optionsContainer.trailingAnchor,
                    constant: -16
                ),
                separator.centerYAnchor.constraint(
                    equalTo: optionsContainer.centerYAnchor
                ),
            ])
        }
    }

    private func createContainer(height: CGFloat) -> UIView {
        let container = UIView()
        container.backgroundColor = .trackerBackgroundDay
        container.layer.cornerRadius = 16
        container.layer.masksToBounds = true
        container.heightAnchor.constraint(equalToConstant: height).isActive =
            true
        return container
    }

    private func setupActions() {
        categoryRow.addTarget(
            self,
            action: #selector(didTapCategory),
            for: .touchUpInside
        )

        if type == .habit {
            scheduleRow.addTarget(
                self,
                action: #selector(didTapSchedule),
                for: .touchUpInside
            )
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

    private func makeOptionRow(title: String) -> UIButton {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .clear

        let labelStack = UIStackView()
        labelStack.translatesAutoresizingMaskIntoConstraints = false
        labelStack.axis = .vertical
        labelStack.alignment = .leading
        labelStack.spacing = 2
        labelStack.isUserInteractionEnabled = false

        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.textColor = .label
        titleLabel.font = .systemFont(ofSize: 17, weight: .regular)

        let subtitleLabel = UILabel()
        subtitleLabel.textColor = .systemGray
        subtitleLabel.font = .systemFont(ofSize: 17, weight: .regular)
        subtitleLabel.isHidden = true

        labelStack.addArrangedSubview(titleLabel)
        labelStack.addArrangedSubview(subtitleLabel)

        let chevron = UIImageView(image: UIImage(systemName: "chevron.right"))
        chevron.tintColor = .systemGray3
        chevron.translatesAutoresizingMaskIntoConstraints = false

        button.addSubview(labelStack)
        button.addSubview(chevron)

        NSLayoutConstraint.activate([
            labelStack.leadingAnchor.constraint(
                equalTo: button.leadingAnchor,
                constant: 16
            ),
            labelStack.trailingAnchor.constraint(
                equalTo: chevron.leadingAnchor,
                constant: -16
            ),
            labelStack.centerYAnchor.constraint(equalTo: button.centerYAnchor),

            chevron.trailingAnchor.constraint(
                equalTo: button.trailingAnchor,
                constant: -16
            ),
            chevron.centerYAnchor.constraint(equalTo: button.centerYAnchor),
            chevron.widthAnchor.constraint(equalToConstant: 11),
            chevron.heightAnchor.constraint(equalToConstant: 18),

            button.heightAnchor.constraint(equalToConstant: 75),
        ])

        return button
    }

    // MARK: - Actions

    @objc private func didTapSchedule() {
        let scheduleViewController = ScheduleViewController()
        navigationController?.pushViewController(
            scheduleViewController,
            animated: true
        )
        scheduleViewController.delegate = self
    }

    @objc private func didTapCategory() {
        //        let categoryViewController = CategoryViewController()
        //        navigationController?.pushViewController(
        //            categoryViewController,
        //            animated: true
        //        )
    }

    @objc private func didTapCreateButton() {
        guard let category, let text = textField.text else { return }
        let tracker = Tracker(
            id: UUID(),
            name: text,
            color: UIColor.red,
            emoji: "😀",
            schedule: type == .habit ? schedule : nil
        )

        delegate?.didCreateTracker(tracker, in: category)

        view.window?.rootViewController?.dismiss(
            animated: true,
            completion: nil
        )
    }

    @objc private func didTapCancelButton() {
        clearData()
        dismiss(animated: true, completion: nil)
    }

    @objc private func textFieldDidChange(_ textField: UITextField) {
        updateCreateButtonState()
    }

    private func updateCreateButtonState() {
        createButton.isEnabled = isEnabled()
    }
}

extension ConfigureTrackerViewController {
    private func updateSubtitle(for button: UIButton, text: String?) {
        guard
            let labelStack = button.subviews.compactMap({ $0 as? UIStackView })
                .first,
            let subtitleLabel = labelStack.arrangedSubviews.last as? UILabel
        else {
            return
        }

        if let text {
            subtitleLabel.text = text
            subtitleLabel.isHidden = false
        } else {
            subtitleLabel.isHidden = true
        }

        UIView.animate(withDuration: 0.2) {
            self.view.layoutIfNeeded()
        }
    }

    private func isEnabled() -> Bool {
        let text = textField.text ?? ""
        let isFilled = !text.trimmingCharacters(in: .whitespacesAndNewlines)
            .isEmpty

        return type == .habit
            ? !schedule.isEmpty && category != nil && isFilled
            : category != nil && isFilled
    }

    private func clearData() {
        category = nil
        schedule = []
        textField.text = ""
    }
}

extension ConfigureTrackerViewController: UITextFieldDelegate {
    func textField(
        _ textField: UITextField,
        shouldChangeCharactersIn range: NSRange,
        replacementString string: String
    ) -> Bool {
        let currentText = textField.text ?? ""
        guard let stringRange = Range(range, in: currentText) else {
            return false
        }
        let updatedText = currentText.replacingCharacters(
            in: stringRange,
            with: string
        )
        if updatedText.count > 38 {
            self.errorLabel.isHidden = false
            UIView.animate(withDuration: 0.2) { [weak self] in
                self?.view.layoutIfNeeded()
            }

        } else {
            self.errorLabel.isHidden = true
            UIView.animate(withDuration: 0.2) { [weak self] in
                self?.view.layoutIfNeeded()
            }

        }
        return updatedText.count <= 38
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

extension ConfigureTrackerViewController: ScheduleViewControllerDelegate {
    func didSelectSchedule(schedule: Set<WeekDay>) {
        self.schedule = schedule

        updateScheduleRowSubtitle()
        updateCreateButtonState()
    }

    private func updateScheduleRowSubtitle() {
        guard type == .habit else { return }

        if schedule.count == 7 {
            updateSubtitle(for: scheduleRow, text: "Каждый день")
        } else if !schedule.isEmpty {
            let sortedDays = schedule.sorted { $0.rawValue < $1.rawValue }
            let daysText = sortedDays.map { $0.shortName }.joined(
                separator: ", "
            )
            updateSubtitle(for: scheduleRow, text: daysText)
        } else {
            updateSubtitle(for: scheduleRow, text: nil)
        }
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
