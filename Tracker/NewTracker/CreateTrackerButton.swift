//
//  CreateTrackerButton.swift
//  Tracker
//
//  Created by Eduard Ptushko on 03.11.2026.
//

import SwiftUI
import UIKit

class CreateTrackerButton: UIButton {

    enum Style {
        case primary
        case cancel
    }

    private let style: Style

    init(title: String, style: Style) {
        self.style = style
        super.init(frame: .zero)
        setupView(title: title)
    }

    required init?(coder: NSCoder) {
        // This view is not initialized via Storyboard
        fatalError("init(coder:) has not been implemented")
    }

    override var intrinsicContentSize: CGSize {
        return CGSize(width: UIView.noIntrinsicMetric, height: 60)
    }

    override var isEnabled: Bool {
        didSet {
            updateBackgroundColor()
        }
    }

    private func setupView(title: String) {
        translatesAutoresizingMaskIntoConstraints = false
        setTitle(title, for: .normal)
        layer.cornerRadius = 16

        titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        titleLabel?.adjustsFontSizeToFitWidth = false

        switch style {
        case .primary:
            backgroundColor = .trackerBlack
            setTitleColor(.trackerWhite, for: .normal)
        case .cancel:
            backgroundColor = .clear
            setTitleColor(.trackerRed, for: .normal)
            layer.borderWidth = 1
            layer.borderColor = UIColor.trackerRed.cgColor
        }
        updateBackgroundColor()
    }

    private func updateBackgroundColor() {
        switch style {
        case .primary:
            backgroundColor = isEnabled ? .trackerBlack : .trackerGray
        case .cancel:
            backgroundColor = .clear
        }
    }
}

#Preview("Tracker Buttons") {
    let containerStack = UIStackView()
    containerStack.axis = .vertical
    containerStack.spacing = 16
    containerStack.translatesAutoresizingMaskIntoConstraints = false

    let createButton = CreateTrackerButton(title: "Создать", style: .primary)
    let cancelButton = CreateTrackerButton(title: "Отменить", style: .cancel)

    let disabledButton = CreateTrackerButton(
        title: "Неактивная",
        style: .primary
    )
    disabledButton.isEnabled = false

    containerStack.addArrangedSubview(createButton)
    containerStack.addArrangedSubview(cancelButton)
    containerStack.addArrangedSubview(disabledButton)

    let viewController = UIViewController()
    viewController.view.backgroundColor = .systemBackground
    viewController.view.addSubview(containerStack)

    NSLayoutConstraint.activate([
        containerStack.centerXAnchor.constraint(
            equalTo: viewController.view.centerXAnchor
        ),
        containerStack.centerYAnchor.constraint(
            equalTo: viewController.view.centerYAnchor
        ),
        containerStack.leadingAnchor.constraint(
            equalTo: viewController.view.leadingAnchor,
            constant: 20
        ),
        containerStack.trailingAnchor.constraint(
            equalTo: viewController.view.trailingAnchor,
            constant: -20
        ),
    ])

    return viewController
}

#Preview("Tracker Buttons - Dark") {
    let containerStack = UIStackView()
    containerStack.axis = .vertical
    containerStack.spacing = 16
    containerStack.translatesAutoresizingMaskIntoConstraints = false

    let createButton = CreateTrackerButton(title: "Создать", style: .primary)
    let cancelButton = CreateTrackerButton(title: "Отменить", style: .cancel)

    containerStack.addArrangedSubview(createButton)
    containerStack.addArrangedSubview(cancelButton)

    let viewController = UIViewController()
    
    viewController.overrideUserInterfaceStyle = .dark
    viewController.view.backgroundColor = .systemBackground
    viewController.view.addSubview(containerStack)

    NSLayoutConstraint.activate([
        containerStack.centerXAnchor.constraint(equalTo: viewController.view.centerXAnchor),
        containerStack.centerYAnchor.constraint(equalTo: viewController.view.centerYAnchor),
        containerStack.leadingAnchor.constraint(equalTo: viewController.view.leadingAnchor, constant: 20),
        containerStack.trailingAnchor.constraint(equalTo: viewController.view.trailingAnchor, constant: -20),
    ])

    return viewController
}
