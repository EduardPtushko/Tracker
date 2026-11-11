//
//  TrackerOptionRowView.swift
//  Tracker
//
//  Created by Eduard Ptushko on 10.11.2026.
//

import UIKit

final class TrackerOptionRowView: UIControl {

    // MARK: - UI Elements

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .label
        label.font = .systemFont(ofSize: 17, weight: .regular)
        return label
    }()

    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .secondaryLabel
        label.font = .systemFont(ofSize: 17, weight: .regular)
        label.isHidden = true
        return label
    }()

    private let chevronImageView: UIImageView = {
        let config = UIImage.SymbolConfiguration(
            pointSize: 14,
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
        return imageView
    }()

    private lazy var labelStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [titleLabel, subtitleLabel])
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.alignment = .leading
        stack.spacing = 2
        stack.isUserInteractionEnabled = false
        return stack
    }()

    // MARK: - State

    override var isHighlighted: Bool {
        didSet {
            UIView.animate(withDuration: 0.15) {
                self.alpha = self.isHighlighted ? 0.6 : 1.0
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
        subtitleLabel.text = text
        subtitleLabel.isHidden = (text?.isEmpty ?? true)
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
            heightAnchor.constraint(greaterThanOrEqualToConstant: 75),

            labelStack.leadingAnchor.constraint(
                equalTo: leadingAnchor,
                constant: 16
            ),
            labelStack.trailingAnchor.constraint(
                equalTo: chevronImageView.leadingAnchor,
                constant: -16
            ),
            labelStack.centerYAnchor.constraint(equalTo: centerYAnchor),
            labelStack.topAnchor.constraint(
                greaterThanOrEqualTo: topAnchor,
                constant: 12
            ),
            labelStack.bottomAnchor.constraint(
                lessThanOrEqualTo: bottomAnchor,
                constant: -12
            ),

            chevronImageView.trailingAnchor.constraint(
                equalTo: trailingAnchor,
                constant: -16
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
