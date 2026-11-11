//
//  TrackerNameInputView.swift
//  Tracker
//
//  Created by Eduard Ptushko on 10.11.2026.
//

import UIKit

final class TrackerNameInputView: UIView {

    // MARK: - Callbacks

    var onTextChanged: ((String) -> Void)?

    private let characterLimit = 38

    // MARK: - UI Elements

    private lazy var textFieldContainer: UIView = {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        container.backgroundColor = .trackerBackgroundDay
        container.layer.cornerRadius = 16
        container.layer.masksToBounds = true
        return container
    }()

    private lazy var textField: UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.placeholder = "Введите название трекера"
        textField.backgroundColor = .clear
        textField.clearButtonMode = .whileEditing
        textField.returnKeyType = .done
        textField.addTarget(
            self,
            action: #selector(textFieldDidChange),
            for: .editingChanged
        )
        textField.delegate = self
        return textField
    }()

    private lazy var errorLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Ограничение \(characterLimit) символов"
        label.textColor = .trackerRed
        label.font = .systemFont(ofSize: 17, weight: .regular)
        label.textAlignment = .center
        label.isHidden = true
        return label
    }()

    private lazy var containerStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [
            textFieldContainer, errorLabel,
        ])
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.spacing = 8
        return stack
    }()

    // MARK: - Init

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Public Methods

    func clear() {
        textField.text = ""
        setErrorVisible(false)
        onTextChanged?("")
    }

    // MARK: - Private Methods

    private func setupView() {
        translatesAutoresizingMaskIntoConstraints = false

        addSubview(containerStack)
        textFieldContainer.addSubview(textField)

        NSLayoutConstraint.activate([
            containerStack.topAnchor.constraint(equalTo: topAnchor),
            containerStack.leadingAnchor.constraint(
                equalTo: leadingAnchor,
                constant: 16
            ),
            containerStack.trailingAnchor.constraint(
                equalTo: trailingAnchor,
                constant: 16
            ),
            containerStack.bottomAnchor.constraint(equalTo: bottomAnchor),

            textFieldContainer.heightAnchor.constraint(equalToConstant: 75),

            textField.topAnchor.constraint(
                equalTo: textFieldContainer.topAnchor
            ),
            textField.leadingAnchor.constraint(
                equalTo: textFieldContainer.leadingAnchor,
                constant: 16
            ),
            textField.trailingAnchor.constraint(
                equalTo: textFieldContainer.trailingAnchor,
                constant: -16
            ),
            textField.bottomAnchor.constraint(
                equalTo: textFieldContainer.bottomAnchor
            ),
        ])
    }

    @objc private func textFieldDidChange(_ textField: UITextField) {
        onTextChanged?(textField.text ?? "")
    }

    private func setErrorVisible(_ isVisible: Bool) {
        guard errorLabel.isHidden == isVisible else { return }

        UIView.animate(withDuration: 0.2) {
            self.errorLabel.isHidden = !isVisible
            self.superview?.layoutIfNeeded()
        }
    }
}

// MARK: - UITextFieldDelegate

extension TrackerNameInputView: UITextFieldDelegate {
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
        if updatedText.count > characterLimit {
            setErrorVisible(true)
            return false
        } else {
            setErrorVisible(false)
            return true
        }
    }

    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        setErrorVisible(false)
        return true
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

#Preview {
    let vc = UIViewController()
    vc.view.backgroundColor = .systemBackground

    let inputView = TrackerNameInputView()
    inputView.translatesAutoresizingMaskIntoConstraints = false
    vc.view.addSubview(inputView)

    NSLayoutConstraint.activate([
        inputView.topAnchor.constraint(
            equalTo: vc.view.safeAreaLayoutGuide.topAnchor,
            constant: 50
        ),
        inputView.leadingAnchor.constraint(
            equalTo: vc.view.leadingAnchor,
            constant: 16
        ),
        inputView.trailingAnchor.constraint(
            equalTo: vc.view.trailingAnchor,
            constant: -16
        ),
    ])

    return vc
}
