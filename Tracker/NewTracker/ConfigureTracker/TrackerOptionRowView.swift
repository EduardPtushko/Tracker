//
//  TrackerOptionRowView.swift
//  Tracker
//
//  Created by Eduard Ptushko on 10.11.2026.
//

import UIKit

final class TrackerOptionRowView: UIControl {

    private enum Layout {
        static let minHeight: CGFloat = 75
        static let horizontalInset: CGFloat = 16
        static let verticalInset: CGFloat = 12
        static let stackSpacing: CGFloat = 2
        static let fontSize: CGFloat = 17
        static let chevronPointSize: CGFloat = 14
    }

    private enum Constants {
        static let highlightDuration: TimeInterval = 0.15
        static let highlightedAlpha: CGFloat = 0.6
    }

    // MARK: - UI Elements

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .label
        label.font = .systemFont(ofSize: Layout.fontSize, weight: .regular)
        return label
    }()

    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .secondaryLabel
        label.font = .systemFont(ofSize: Layout.fontSize, weight: .regular)
        label.numberOfLines = 0
        label.isHidden = true
        return label
    }()

    private let chevronImageView: UIImageView = {
        let config = UIImage.SymbolConfiguration(
            pointSize: Layout.chevronPointSize,
            weight: .semibold
        )
        let image = UIImage(
            systemName: "chevron.right",
            withConfiguration: config
        )
        let imageView = UIImageView(image: image)
        imageView.tintColor = .systemGray3
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.isUserInteractionEnabled = false
        return imageView
    }()

    private lazy var labelStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [titleLabel, subtitleLabel])
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.alignment = .leading
        stack.spacing = Layout.stackSpacing
        stack.isUserInteractionEnabled = false
        return stack
    }()

    // MARK: - State

    override var isHighlighted: Bool {
        didSet {
            UIView.animate(withDuration: Constants.highlightDuration) {
                self.alpha =
                    self.isHighlighted ? Constants.highlightedAlpha : 1.0
            }
        }
    }

    // MARK: - Init

    init(title: String) {
        super.init(frame: .zero)
        titleLabel.text = title
        setupView()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Public Methods

    func setSubtitle(_ text: String?) {
        let isEmpty =
            text?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            ?? true
        subtitleLabel.text = isEmpty ? nil : text
        subtitleLabel.isHidden = isEmpty
    }

    // MARK: - Private Methods

    private func setupView() {
        translatesAutoresizingMaskIntoConstraints = false
        addSubview(labelStack)
        addSubview(chevronImageView)

        chevronImageView.setContentHuggingPriority(.required, for: .horizontal)
        chevronImageView.setContentCompressionResistancePriority(
            .required,
            for: .horizontal
        )

        NSLayoutConstraint.activate([
            heightAnchor.constraint(
                greaterThanOrEqualToConstant: Layout.minHeight
            ),

            labelStack.leadingAnchor.constraint(
                equalTo: leadingAnchor,
                constant: Layout.horizontalInset
            ),
            labelStack.trailingAnchor.constraint(
                equalTo: chevronImageView.leadingAnchor,
                constant: -Layout.horizontalInset
            ),
            labelStack.centerYAnchor.constraint(equalTo: centerYAnchor),
            labelStack.topAnchor.constraint(
                greaterThanOrEqualTo: topAnchor,
                constant: Layout.verticalInset
            ),
            labelStack.bottomAnchor.constraint(
                lessThanOrEqualTo: bottomAnchor,
                constant: -Layout.verticalInset
            ),

            chevronImageView.trailingAnchor.constraint(
                equalTo: trailingAnchor,
                constant: -Layout.horizontalInset
            ),
            chevronImageView.centerYAnchor.constraint(equalTo: centerYAnchor),
        ])
    }
}

// MARK: - Preview

#Preview {
    let row = TrackerOptionRowView(title: "Расписание")
    row.widthAnchor.constraint(equalToConstant: 375).isActive = true
    return row
}
