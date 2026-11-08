//
//  ConfigureTrackerViewController.swift
//  Tracker
//
//  Created by Eduard Ptushko on 03.11.2026.
//

import UIKit

enum TrackerType {
    case habit
    case irregular
}

final class ConfigureTrackerViewController: UIViewController {

    private let type: TrackerType

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

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupConstraints()
        setupActions()
    }

    private func setupView() {
        title = type == .habit ? "Новая привычка" : "Новое нерегулярное событие"
        view.backgroundColor = .systemBackground
        textField.delegate = self
        createButton.isEnabled = false

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
        var constraints = [
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
        button.contentEdgeInsets = UIEdgeInsets(
            top: 16,
            left: 0,
            bottom: 16,
            right: 0
        )
        button.backgroundColor = .clear

        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = title
        titleLabel.textColor = .label
        titleLabel.font = .systemFont(ofSize: 17, weight: .regular)

        let chevron = UIImageView(image: UIImage(systemName: "chevron.right"))
        chevron.tintColor = .systemGray3
        chevron.translatesAutoresizingMaskIntoConstraints = false

        button.addSubview(titleLabel)
        button.addSubview(chevron)

        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(
                equalTo: button.leadingAnchor,
                constant: 16
            ),
            titleLabel.centerYAnchor.constraint(equalTo: button.centerYAnchor),
            chevron.trailingAnchor.constraint(
                equalTo: button.trailingAnchor,
                constant: -16
            ),
            chevron.centerYAnchor.constraint(equalTo: button.centerYAnchor),
            button.heightAnchor.constraint(greaterThanOrEqualToConstant: 56),
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
    }
    @objc private func didTapCategory() {
        let categoryViewController = CategoryViewController()
        navigationController?.pushViewController(
            categoryViewController,
            animated: true
        )
    }

    @objc private func didTapCreateButton() {
        dismiss(animated: true, completion: nil)
    }

    @objc private func didTapCancelButton() {
        dismiss(animated: true, completion: nil)
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

#Preview {
    UINavigationController(
        rootViewController:
            ConfigureTrackerViewController(type: .habit)
    )
}
