//
//  TrackerCustomizationCollectionViewCell.swift
//  Tracker
//
//  Created by Eduard Ptushko on 11.11.2026.
//

import SwiftUI
import UIKit

enum ConfigureTrackerCellItem {
    case emoji(String)
    case color(UIColor)
}

class TrackerCustomizationCollectionViewCell: UICollectionViewCell {

    static let identifier = String(
        describing: TrackerCustomizationCollectionViewCell.self
    )

    private enum Layout {
        static let emojiFontSize: CGFloat = 32
        static let emojiCornerRadius: CGFloat = 16
        static let colorCornerRadius: CGFloat = 8
        static let colorInset: CGFloat = 6
        static let selectionBorderWidth: CGFloat = 3
        static let selectionBorderAlpha: CGFloat = 0.3
    }

    // MARK: - UI Elements

    private lazy var emojiLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: Layout.emojiFontSize, weight: .bold)
        label.textAlignment = .center
        return label
    }()

    private lazy var colorView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = Layout.colorCornerRadius
        return view
    }()

    // MARK: - Init

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle

    override func prepareForReuse() {
        super.prepareForReuse()
        emojiLabel.text = nil
        emojiLabel.isHidden = true
        colorView.backgroundColor = nil
        colorView.isHidden = true
        contentView.backgroundColor = .clear
        contentView.layer.borderWidth = 0
        contentView.layer.borderColor = nil
    }

    // MARK: - Public Methods

    func configure(with item: ConfigureTrackerCellItem, isSelected: Bool) {
        switch item {
        case .emoji(let emoji):
            emojiLabel.isHidden = false
            colorView.isHidden = true
            emojiLabel.text = emoji
            contentView.layer.cornerRadius = Layout.emojiCornerRadius
            contentView.backgroundColor =
                isSelected ? .trackerLightGray : .clear
        case .color(let color):
            emojiLabel.isHidden = true
            colorView.isHidden = false
            colorView.backgroundColor = color
            contentView.layer.cornerRadius = Layout.colorCornerRadius
            contentView.layer.borderWidth =
                isSelected ? Layout.selectionBorderWidth : 0
            contentView.layer.borderColor =
                isSelected
                ? color.withAlphaComponent(Layout.selectionBorderAlpha).cgColor
                : nil
        }
    }

    // MARK: - Private Methos

    private func setupView() {
        contentView.addSubviews([emojiLabel, colorView])

        NSLayoutConstraint.activate([
            emojiLabel.centerXAnchor.constraint(
                equalTo: contentView.centerXAnchor
            ),
            emojiLabel.centerYAnchor.constraint(
                equalTo: colorView.centerYAnchor
            ),

            colorView.topAnchor.constraint(
                equalTo: contentView.topAnchor,
                constant: Layout.colorInset
            ),
            colorView.bottomAnchor.constraint(
                equalTo: contentView.bottomAnchor,
                constant: -Layout.colorInset
            ),
            colorView.leadingAnchor.constraint(
                equalTo: contentView.leadingAnchor,
                constant: Layout.colorInset
            ),
            colorView.trailingAnchor.constraint(
                equalTo: contentView.trailingAnchor,
                constant: -Layout.colorInset
            ),
        ])
    }
}

// MARK: - Preview

#Preview("Trackers Cell States") {
    Group {

        LazyVGrid(columns: [GridItem(.fixed(167))], spacing: 5) {

            ViewPreview {
                let cell = TrackerCustomizationCollectionViewCell()
                cell.configure(
                    with: .emoji("🙂"),
                    isSelected: false,
                )
                return cell
            }
            .frame(width: 52, height: 52)

            ViewPreview {
                let cell = TrackerCustomizationCollectionViewCell()
                cell.configure(
                    with: .emoji("🙂"),
                    isSelected: true,
                )
                return cell
            }
            .frame(width: 52, height: 52)

            ViewPreview {
                let cell = TrackerCustomizationCollectionViewCell()
                cell.configure(
                    with: .color(.selection1),
                    isSelected: false,
                )
                return cell
            }
            .frame(width: 52, height: 52)

            ViewPreview {
                let cell = TrackerCustomizationCollectionViewCell()
                cell.configure(
                    with: .color(.selection1),
                    isSelected: true,
                )
                return cell
            }
            .frame(width: 52, height: 52)
        }
    }
    .padding()

}
