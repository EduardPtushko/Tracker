//
//  TrackerNameInputView.swift
//  Tracker
//
//  Created by Eduard Ptushko on 10.11.2026.
//

import UIKit

final class TrackerNameInputView: UIView {

    private enum Constants {
        static let characterLimit = 38
        static let horizontalInset: CGFloat = 16
        static let fieldHeight: CGFloat = 75
        static let cornerRadius: CGFloat = 16
        static let stackSpacing: CGFloat = 8
        static let errorFontSize: CGFloat = 17
        static let animationDuration: TimeInterval = 0.2
    }

    // MARK: - Callbacks

    var onTextChanged: ((String) -> Void)?

    // MARK: - UI Elements

    private lazy var textFieldContainer: UIView = {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        container.backgroundColor = .trackerBackgroundDay
        container.layer.cornerRadius = Constants.cornerRadius
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
        textField.delegate = self
        textField.addAction(UIAction { [weak self] _ in
            self?.onTextChanged?(self?.textField.text ?? "")
            
        }, for: .editingChanged)
        return textField
    }()

    private lazy var errorLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Ограничение \(Constants.characterLimit) символов"
        label.textColor = .trackerRed
        label.font = .systemFont(ofSize: Constants.errorFontSize, weight: .regular)
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
        stack.spacing = Constants.stackSpacing
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
                constant: Constants.horizontalInset
            ),
            containerStack.trailingAnchor.constraint(
                equalTo: trailingAnchor,
                constant: -Constants.horizontalInset
            ),
            containerStack.bottomAnchor.constraint(equalTo: bottomAnchor),

            textFieldContainer.heightAnchor.constraint(equalToConstant: Constants.fieldHeight),

            textField.topAnchor.constraint(
                equalTo: textFieldContainer.topAnchor
            ),
            textField.leadingAnchor.constraint(
                equalTo: textFieldContainer.leadingAnchor,
                constant: Constants.horizontalInset
            ),
            textField.trailingAnchor.constraint(
                equalTo: textFieldContainer.trailingAnchor,
                constant: -Constants.horizontalInset
            ),
            textField.bottomAnchor.constraint(
                equalTo: textFieldContainer.bottomAnchor
            ),
        ])
    }


    private func setErrorVisible(_ isVisible: Bool) {
        guard errorLabel.isHidden == isVisible else { return }

        UIView.animate(withDuration: Constants.animationDuration) {
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
        if updatedText.count > Constants.characterLimit {
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
