//
//  TrackersCollectionViewCell.swift
//  Tracker
//
//  Created by Eduard Ptushko on 30.10.2026.
//

import SwiftUI
import UIKit

protocol TrackersCollectionViewCellDelegate: AnyObject {
    func didTapCompleteButton(of cell: TrackersCollectionViewCell)
}

final class TrackersCollectionViewCell: UICollectionViewCell {

    // MARK: - Public Properties

    static let identifier = "TrackersCollectionViewCell"
    weak var delegate: TrackersCollectionViewCellDelegate?

    // MARK: - UI Elements

    private lazy var cardView: UIView = {
        let card = UIView()
        card.translatesAutoresizingMaskIntoConstraints = false
        card.layer.cornerRadius = 16
        return card
    }()

    private lazy var emojiLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        return label
    }()

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        label.textColor = UIColor(resource: .trackerWhite)
        return label
    }()

    private lazy var bottomStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.distribution = .fill
        stackView.alignment = .center
        return stackView
    }()

    private lazy var countLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        label.textColor = UIColor(resource: .trackerBlack)
        label.text = "0 дней"
        return label
    }()

    private lazy var plusButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(systemName: "plus"), for: .normal)
        button.tintColor = UIColor(resource: .trackerWhite)
        button.layer.cornerRadius = 17
        button.clipsToBounds = true
        button.addTarget(
            self,
            action: #selector(completeButtonTapped),
            for: .touchUpInside
        )
        return button
    }()

    // MARK: - Init

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
        setupConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        delegate = nil
        titleLabel.text = nil
        emojiLabel.text = nil
        countLabel.text = nil
        plusButton.setImage(UIImage(systemName: "plus"), for: .normal)
        plusButton.alpha = 1.0
        plusButton.backgroundColor = nil
        cardView.backgroundColor = nil
    }

    // MARK: - Private Methods

    private func setupView() {
        contentView.addSubviews([cardView, bottomStackView])
        cardView.addSubviews([emojiLabel, titleLabel])
        bottomStackView.addArrangedSubview(countLabel)
        bottomStackView.addArrangedSubview(plusButton)
    }

    @objc private func completeButtonTapped() {
        delegate?.didTapCompleteButton(of: self)
    }

    private func formatDaysString(for days: Int) -> String {
        let remainder10 = days % 10
        let remainder100 = days % 100

        if remainder100 >= 11 && remainder100 <= 19 {
            return "\(days) дней"
        }

        switch remainder10 {
        case 1:
            return "\(days) день"
        case 2, 3, 4:
            return "\(days) дня"
        default:
            return "\(days) дней"
        }
    }

    func configure(with tracker: Tracker, isCompleted: Bool, completedDays: Int)
    {
        cardView.backgroundColor = tracker.color
        emojiLabel.text = tracker.emoji
        titleLabel.text = tracker.name
        plusButton.backgroundColor = tracker.color
        countLabel.text = formatDaysString(for: completedDays)

        let config = UIImage.SymbolConfiguration(pointSize: 12, weight: .bold)
        let imageName = isCompleted ? "checkmark" : "plus"

        plusButton.setImage(
            UIImage(systemName: imageName)?.withConfiguration(config),
            for: .normal
        )
        plusButton.alpha = isCompleted ? 0.5 : 1.0

    }

}

extension TrackersCollectionViewCell {
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            cardView.topAnchor.constraint(equalTo: contentView.topAnchor),
            cardView.leadingAnchor.constraint(
                equalTo: contentView.leadingAnchor
            ),
            cardView.trailingAnchor.constraint(
                equalTo: contentView.trailingAnchor
            ),
            cardView.heightAnchor.constraint(
                equalTo: contentView.heightAnchor,
                multiplier: 3.0 / 5.0
            ),

            emojiLabel.topAnchor.constraint(
                equalTo: cardView.topAnchor,
                constant: 12
            ),
            emojiLabel.leadingAnchor.constraint(
                equalTo: cardView.leadingAnchor,
                constant: 12
            ),
            emojiLabel.widthAnchor.constraint(equalToConstant: 24),
            emojiLabel.heightAnchor.constraint(equalToConstant: 24),

            titleLabel.bottomAnchor.constraint(
                equalTo: cardView.bottomAnchor,
                constant: -12
            ),
            titleLabel.leadingAnchor.constraint(
                equalTo: cardView.leadingAnchor,
                constant: 12
            ),
            titleLabel.trailingAnchor.constraint(
                equalTo: cardView.trailingAnchor,
                constant: -12
            ),

            plusButton.widthAnchor.constraint(equalToConstant: 34),
            plusButton.heightAnchor.constraint(equalToConstant: 34),

            bottomStackView.topAnchor.constraint(
                equalTo: cardView.bottomAnchor,
                constant: 8
            ),
            bottomStackView.leadingAnchor.constraint(
                equalTo: contentView.leadingAnchor,
                constant: 12
            ),
            bottomStackView.trailingAnchor.constraint(
                equalTo: contentView.trailingAnchor,
                constant: -12
            ),
            bottomStackView.bottomAnchor.constraint(
                equalTo: contentView.bottomAnchor,
                constant: -16
            ),
        ])
    }
}

// MARK: - Preview

#Preview("Trackers Cell States") {
    Group {

        LazyVGrid(columns: [GridItem(.fixed(167))]) {

            ViewPreview {
                let cell = TrackersCollectionViewCell()
                cell.configure(
                    with: MockTrackerData.tracker,
                    isCompleted: false,
                    completedDays: 0
                )
                return cell
            }
            .frame(width: 167, height: 148)

            ViewPreview {
                let cell = TrackersCollectionViewCell()
                cell.configure(
                    with: MockTrackerData.tracker,
                    isCompleted: true,
                    completedDays: 4
                )
                return cell
            }
            .frame(width: 167, height: 148)
        }
    }
    .padding()

}
