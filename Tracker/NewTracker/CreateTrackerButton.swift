//
//  CreateTrackerButton.swift
//  Tracker
//
//  Created by Eduard Ptushko on 03.11.2026.
//

import SwiftUI
import UIKit

final class CreateTrackerButton: UIButton {

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
            if style == .primary {
                backgroundColor = isEnabled ? .trackerBlack : .trackerGray
            }
        }
    }

    private func setupView(title: String) {
        translatesAutoresizingMaskIntoConstraints = false
        layer.cornerRadius = 16
        layer.masksToBounds = true
        titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        setTitle(title, for: .normal)

        switch style {
        case .primary:
            setTitleColor(.trackerWhite, for: .normal)
            setTitleColor(.trackerWhite, for: .disabled)
            backgroundColor = isEnabled ? .trackerBlack : .trackerGray

        case .cancel:
            backgroundColor = .clear
            layer.borderWidth = 1
            layer.borderColor = UIColor.trackerRed.cgColor
            setTitleColor(.trackerRed, for: .normal)
        }

    }
}

// MARK: - Preview

#Preview("Tracker Buttons") {
    VStack {
        ViewPreview {
            let containerStack = UIStackView()
            containerStack.axis = .vertical
            containerStack.spacing = 16

            containerStack.translatesAutoresizingMaskIntoConstraints = true

            let createButton = CreateTrackerButton(
                title: "Создать",
                style: .primary
            )
            let cancelButton = CreateTrackerButton(
                title: "Отменить",
                style: .cancel
            )
            let disabledButton = CreateTrackerButton(
                title: "Неактивная",
                style: .primary
            )
            disabledButton.isEnabled = false

            containerStack.addArrangedSubview(createButton)
            containerStack.addArrangedSubview(cancelButton)
            containerStack.addArrangedSubview(disabledButton)

            return containerStack
        }
    }
    .padding(.horizontal, 20)
    .frame(height: 212)
}
