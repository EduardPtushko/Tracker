//
//  TrackerButton.swift
//  Tracker
//
//  Created by Eduard Ptushko on 05.11.2026.
//

import SwiftUI
import UIKit

class TrackerButton: UIButton {

    init(title: String) {
        super.init(frame: .zero)
        setupView(title: title)
    }

    required init?(coder: NSCoder) {
        // This view is not initialized via Storyboard
        fatalError("init(coder:) has not been implemented")
    }

    override var intrinsicContentSize: CGSize {
        CGSize(width: UIView.noIntrinsicMetric, height: 60)
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
        setTitleColor(.trackerWhite, for: .normal)

        updateBackgroundColor()
    }

    func updateBackgroundColor() {
        backgroundColor = isEnabled ? .trackerBlack : .trackerGray
    }

}

// MARK: - Preview
#Preview("Tracker Button States") {
    let containerStack = UIStackView()
    containerStack.axis = .vertical
    containerStack.spacing = 16
    containerStack.translatesAutoresizingMaskIntoConstraints = false

    let activeButton = TrackerButton(title: "Добавить категорию")

    let disabledButton = TrackerButton(title: "Готово")
    disabledButton.isEnabled = false

    containerStack.addArrangedSubview(activeButton)
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
