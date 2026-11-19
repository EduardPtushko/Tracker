//
//  TrackerCustomizationCollectionView.swift
//  Tracker
//
//  Created by Eduard Ptushko on 11.11.2026.
//

import SwiftUI
import UIKit

protocol TrackerCustomizationCollectionViewDelegate: AnyObject {
    func selectView(
        _ view: TrackerCustomizationCollectionView,
        didSelectEmoji emoji: String
    )
    func selectView(
        _ view: TrackerCustomizationCollectionView,
        didSelectColor color: UIColor
    )
}

final class TrackerCustomizationCollectionView: UICollectionView {
    private enum Layout {
        static let itemsPerRow: CGFloat = 6
        static let horizontalInset: CGFloat = 18
        static let verticalInset: CGFloat = 24
        static let interItemSpacing: CGFloat = 5
        static let lineSpacing: CGFloat = 0
        static let headerHeight: CGFloat = 48
    }

    private enum Section: Int, CaseIterable {
        case emoji
        case colors

        var title: String {
            switch self {
            case .emoji: "Emoji"
            case .colors: "Цвет"
            }
        }
    }

    // MARK: - Properties

    weak var trackerDelegate: TrackerCustomizationCollectionViewDelegate?

    private let emojis: [String]
    private let colors: [UIColor]
    private var selectedEmojiIndex: Int?
    private var selectedColorIndex: Int?
    private var lastKnownContentHeight: CGFloat = 0
    // MARK: - Init

    init(
        emojis: [String] = TrackerDesignConstants.emojis,
        colors: [UIColor] = TrackerDesignConstants.colors
    ) {
        self.emojis = emojis
        self.colors = colors
        let layout = UICollectionViewFlowLayout()
        super.init(frame: .zero, collectionViewLayout: layout)
        setupCollection()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycles

    override var intrinsicContentSize: CGSize {
        return CGSize(
            width: UIView.noIntrinsicMetric,
            height: collectionViewLayout.collectionViewContentSize.height
        )
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        let currentHeight = collectionViewLayout.collectionViewContentSize
            .height
        if currentHeight != lastKnownContentHeight {
            lastKnownContentHeight = currentHeight
            invalidateIntrinsicContentSize()
        }
    }

    private func setupCollection() {
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = .clear
        isScrollEnabled = false

        register(
            TrackerCustomizationCollectionViewCell.self,
            forCellWithReuseIdentifier: TrackerCustomizationCollectionViewCell
                .identifier
        )
        register(
            CategoryHeader.self,
            forSupplementaryViewOfKind: UICollectionView
                .elementKindSectionHeader,
            withReuseIdentifier: CategoryHeader.reuseIdentifier
        )
        delegate = self
        dataSource = self
    }

}

// MARK: - UICollectionViewDataSource

extension TrackerCustomizationCollectionView: UICollectionViewDataSource {

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        Section.allCases.count
    }

    func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {
        guard let sectionType = Section(rawValue: section) else { return 0 }
        return sectionType == .emoji ? emojis.count : colors.count
    }

    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        guard
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: TrackerCustomizationCollectionViewCell
                    .identifier,
                for: indexPath
            ) as? TrackerCustomizationCollectionViewCell,
            let sectionType = Section(rawValue: indexPath.section)
        else {
            return UICollectionViewCell()
        }

        switch sectionType {
        case .emoji:
            let isSelected = selectedEmojiIndex == indexPath.row
            cell.configure(
                with: .emoji(emojis[indexPath.row]),
                isSelected: isSelected
            )
        case .colors:
            let isSelected = selectedColorIndex == indexPath.row
            cell.configure(
                with: .color(colors[indexPath.row]),
                isSelected: isSelected
            )
        }

        return cell
    }

    func collectionView(
        _ collectionView: UICollectionView,
        viewForSupplementaryElementOfKind kind: String,
        at indexPath: IndexPath
    ) -> UICollectionReusableView {
        guard kind == UICollectionView.elementKindSectionHeader,
            let sectionType = Section(rawValue: indexPath.section),
            let header = collectionView.dequeueReusableSupplementaryView(
                ofKind: kind,
                withReuseIdentifier: CategoryHeader.reuseIdentifier,
                for: indexPath
            ) as? CategoryHeader
        else {
            return UICollectionReusableView()
        }

        header.configure(with: sectionType.title)
        return header
    }

}

// MARK: - UICollectionViewDelegate

extension TrackerCustomizationCollectionView: UICollectionViewDelegate {
    func collectionView(
        _ collectionView: UICollectionView,
        didSelectItemAt indexPath: IndexPath
    ) {
        guard let sectionType = Section(rawValue: indexPath.section) else {
            return
        }
        var indexPathsToReload: [IndexPath] = [indexPath]

        switch sectionType {
        case .emoji:
            if let previousIndex = selectedEmojiIndex,
                previousIndex != indexPath.row
            {
                indexPathsToReload.append(
                    IndexPath(row: previousIndex, section: indexPath.section)
                )
            }
            selectedEmojiIndex = indexPath.row
            trackerDelegate?.selectView(
                self,
                didSelectEmoji: emojis[indexPath.row]
            )
        case .colors:
            if let previousIndex = selectedColorIndex,
                previousIndex != indexPath.row
            {
                indexPathsToReload.append(
                    IndexPath(row: previousIndex, section: indexPath.section)
                )
            }
            selectedColorIndex = indexPath.row
            trackerDelegate?.selectView(
                self,
                didSelectColor: colors[indexPath.row]
            )
        }

        UIView.performWithoutAnimation {
            reloadItems(at: indexPathsToReload)
        }
    }
}
// MARK: - UICollectionViewDelegateFlowLayout

extension TrackerCustomizationCollectionView: UICollectionViewDelegateFlowLayout
{
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        guard collectionView.bounds.width > 0 else { return .zero }

        let totalHorizontalPadding = Layout.horizontalInset * 2
        let totalInterItemSpacing =
            Layout.interItemSpacing * (Layout.itemsPerRow - 1)
        let availableWidth =
            collectionView.bounds.width - totalHorizontalPadding
            - totalInterItemSpacing
        let side = floor(availableWidth / Layout.itemsPerRow)

        return CGSize(width: side, height: side)
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        insetForSectionAt section: Int
    ) -> UIEdgeInsets {
        UIEdgeInsets(top: Layout.verticalInset, left: Layout.horizontalInset, bottom: Layout.verticalInset, right: Layout.horizontalInset)
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        minimumInteritemSpacingForSectionAt section: Int
    ) -> CGFloat {
        Layout.interItemSpacing
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        minimumLineSpacingForSectionAt section: Int
    ) -> CGFloat {
        Layout.lineSpacing
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        referenceSizeForHeaderInSection section: Int
    ) -> CGSize {
        CGSize(width: collectionView.bounds.width, height: Layout.headerHeight)
    }
}

// MARK: - Preview

#Preview("Customization Grid") {

    ViewPreview {
        let grid = TrackerCustomizationCollectionView()
        return grid
    }
    .frame(height: 660)
}
