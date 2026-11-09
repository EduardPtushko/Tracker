//
//  EmptyStateView.swift
//  Tracker
//
//  Created by Eduard Ptushko on 30.10.2026.
//

import UIKit

final class EmptyStateView: UIView {

    // MARK: - UI Elements

    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 8
        stackView.alignment = .center
        return stackView
    }()

    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    private let questionLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        label.textAlignment = .center
        label.textColor = UIColor(resource: .trackerBlack)
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        return label
    }()

    // MARK: - Initializers

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    required init?(coder: NSCoder) {
        // This view is not initialized via Storyboard
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Private Methods

    private func setupView() {
        addSubview(stackView)
        stackView.addArrangedSubview(imageView)
        stackView.addArrangedSubview(questionLabel)

        NSLayoutConstraint.activate([
            stackView.centerXAnchor.constraint(equalTo: centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: centerYAnchor),

            imageView.widthAnchor.constraint(equalToConstant: 80),
            imageView.heightAnchor.constraint(equalToConstant: 80),

            questionLabel.widthAnchor.constraint(
                lessThanOrEqualToConstant: 200
            ),
        ])
    }

    // MARK: - Public Methods

    func configure(image: UIImage, text: String) {
        imageView.image = image
        questionLabel.text = text
    }

}

// MARK: - Previews

#Preview("One line") {
    let emptyStateView = EmptyStateView()
    emptyStateView.configure(
        image: UIImage(resource: .emptyListPlaceholder),
        text: "Что будем отслеживать?"
    )

    return emptyStateView
}

#Preview("Two lines") {
    let emptyStateView = EmptyStateView()
    emptyStateView.configure(
        image: UIImage(resource: .emptyListPlaceholder),
        text: "Привычки и события можно объединить по смыслу"
    )

    return emptyStateView
}
