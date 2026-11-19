//
//  TrackersCollectionViewCell.swift
//  Tracker
//
//  Created by Eduard Ptushko on 30.10.2026.
//

import SwiftUI
import UIKit

struct TrackerCellViewModel {
    let id: UUID
    let title: String
    let emoji: String
    let color: UIColor
    let completedDaysText: String
    let isCompleted: Bool
    let isCompletionEnabled: Bool

    init(
        tracker: Tracker,
        isCompleted: Bool,
        completedDays: Int,
        isCompletionEnabled: Bool = true,
    ) {
        self.id = tracker.id
        self.title = tracker.name
        self.emoji = tracker.emoji
        self.color = tracker.color
        self.completedDaysText = Self.formatDaysString(for: completedDays)
        self.isCompleted = isCompleted
        self.isCompletionEnabled = isCompletionEnabled
    }

    private static func formatDaysString(for days: Int) -> String {
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
}

protocol TrackersCollectionViewCellDelegate: AnyObject {
    func didTapCompleteButton(for trackerId: UUID)
}

final class TrackersCollectionViewCell: UICollectionViewCell {
    
    private enum Layout {
        static let cardCornerRadius: CGFloat = 16
        static let cardHeightMultiplier: CGFloat = 3.0 / 5.0
        static let inset: CGFloat = 12
        static let emojiSize: CGFloat = 24
        static let emojiFontSize: CGFloat = 16
        static let titleFontSize: CGFloat = 12
        static let buttonSize: CGFloat = 34
        static let buttonSymbolPointSize: CGFloat = 12
        static let bottomStackTopSpacing: CGFloat = 8
        static let bottomInset: CGFloat = 16
    }
    
    // MARK: - Private Properties

        private var trackerID: UUID?

    // MARK: - Public Properties

    static let identifier = String(describing: TrackersCollectionViewCell.self)
    weak var delegate: TrackersCollectionViewCellDelegate?

    // MARK: - UI Elements

    private lazy var cardView: UIView = {
        let card = UIView()
        card.translatesAutoresizingMaskIntoConstraints = false
        card.layer.cornerRadius = Layout.cardCornerRadius
        card.layer.masksToBounds = true
        return card
    }()

    private lazy var emojiLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(
            ofSize: Layout.emojiFontSize,
            weight: .medium
        )
        label.textAlignment = .center
        label.backgroundColor = UIColor(resource: .trackerWhite)
            .withAlphaComponent(0.3)
        label.layer.cornerRadius = Layout.emojiSize / 2
        label.layer.masksToBounds = true
        return label
    }()

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: Layout.titleFontSize, weight: .medium)
        label.textColor = UIColor(resource: .trackerWhite)
        label.numberOfLines = 2
        return label
    }()

    private lazy var bottomStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [countLabel, plusButton])
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
        return label
    }()

    private lazy var plusButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(systemName: "plus"), for: .normal)
        button.setPreferredSymbolConfiguration(
            UIImage.SymbolConfiguration(
                pointSize: Layout.buttonSymbolPointSize,
                weight: .bold
            ),
            forImageIn: .normal
        )
        button.tintColor = UIColor(resource: .trackerWhite)
        button.layer.cornerRadius = Layout.buttonSize / 2
        button.clipsToBounds = true
        button.addAction(
            UIAction { [weak self] _ in
                guard let self, let trackerID = self.trackerID else { return }
                self.delegate?.didTapCompleteButton(for: trackerID)
            },
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

    // MARK: - Public Methods

    func configure(with viewModel: TrackerCellViewModel)
    {
        trackerID = viewModel.id
        cardView.backgroundColor = viewModel.color
        emojiLabel.text = viewModel.emoji
        titleLabel.text = viewModel.title
        plusButton.backgroundColor = viewModel.color
        countLabel.text = viewModel.completedDaysText

        let imageName = viewModel.isCompleted ? "checkmark" : "plus"
        plusButton.setImage(
            UIImage(systemName: imageName),
            for: .normal
        )
        plusButton.alpha = viewModel.isCompleted ? 0.5 : 1.0
        plusButton.isEnabled = viewModel.isCompletionEnabled
    }

    // MARK: - Private Methods

    private func setupView() {
        contentView.addSubviews([cardView, bottomStackView])
        cardView.addSubviews([emojiLabel, titleLabel])
    }

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
                multiplier: Layout.cardHeightMultiplier
            ),

            emojiLabel.topAnchor.constraint(
                equalTo: cardView.topAnchor,
                constant: Layout.inset
            ),
            emojiLabel.leadingAnchor.constraint(
                equalTo: cardView.leadingAnchor,
                constant: Layout.inset
            ),
            emojiLabel.widthAnchor.constraint(
                equalToConstant: Layout.emojiSize
            ),
            emojiLabel.heightAnchor.constraint(
                equalToConstant: Layout.emojiSize
            ),

            titleLabel.bottomAnchor.constraint(
                equalTo: cardView.bottomAnchor,
                constant: -Layout.inset
            ),
            titleLabel.leadingAnchor.constraint(
                equalTo: cardView.leadingAnchor,
                constant: Layout.inset
            ),
            titleLabel.trailingAnchor.constraint(
                equalTo: cardView.trailingAnchor,
                constant: -Layout.inset
            ),

            plusButton.widthAnchor.constraint(
                equalToConstant: Layout.buttonSize
            ),
            plusButton.heightAnchor.constraint(
                equalToConstant: Layout.buttonSize
            ),

            bottomStackView.topAnchor.constraint(
                equalTo: cardView.bottomAnchor,
                constant: Layout.bottomStackTopSpacing
            ),
            bottomStackView.leadingAnchor.constraint(
                equalTo: contentView.leadingAnchor,
                constant: Layout.inset
            ),
            bottomStackView.trailingAnchor.constraint(
                equalTo: contentView.trailingAnchor,
                constant: -Layout.inset
            ),
            bottomStackView.bottomAnchor.constraint(
                equalTo: contentView.bottomAnchor,
                constant: -Layout.bottomInset
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
                    with: TrackerCellViewModel( tracker: MockTrackerData.tracker,
                    isCompleted: false,
                    completedDays: 0)
                )
                return cell
            }
            .frame(width: 167, height: 148)

            ViewPreview {
                let cell = TrackersCollectionViewCell()
                cell.configure(
                    with: TrackerCellViewModel( tracker: MockTrackerData.tracker,
                    isCompleted: true,
                    completedDays: 4)
                )
                return cell
            }
            .frame(width: 167, height: 148)
        }
    }
    .padding()

}
