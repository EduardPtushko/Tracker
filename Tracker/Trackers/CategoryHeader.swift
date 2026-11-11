//
//  CategoryHeader.swift
//  Tracker
//
//  Created by Eduard Ptushko on 02.11.2026.
//

import SwiftUI
import UIKit

final class CategoryHeader: UICollectionReusableView {

    static let reuseIdentifier = "CategoryHeader"

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 19, weight: .bold)
        label.textColor = .trackerBlack
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)

        addSubview(titleLabel)

        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(
                equalTo: leadingAnchor,
                constant: 28
            ),
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 16),
            titleLabel.bottomAnchor.constraint(
                equalTo: bottomAnchor,
                constant: -12
            ),
            titleLabel.trailingAnchor.constraint(
                equalTo: trailingAnchor,
                constant: -28
            ),
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        titleLabel.text = nil
    }

    func configure(with title: String) {
        titleLabel.text = title
    }
}

// MARK: - Preview

#Preview("Category Header") {
    ViewPreview {
        let header = CategoryHeader()
        header.configure(with: "Категории")
        header.backgroundColor = .systemGray6
        return header
    }
    .frame(height: 60)
    .frame(maxWidth: .infinity)
}
