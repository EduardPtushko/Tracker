//
//  ScheduleTableViewCell.swift
//  Tracker
//
//  Created by Eduard Ptushko on 09.11.2026.
//

import SwiftUI
import UIKit

protocol ScheduleTableViewCellDelegate: AnyObject {
    func didToggleSwitch(for day: WeekDay, isOn: Bool)
}

final class ScheduleTableViewCell: UITableViewCell {
    static let reuseIdentifier = "ScheduleTableViewCell"

    weak var delegate: ScheduleTableViewCellDelegate?
    private var currentDay: WeekDay?

    // MARK: - UI Elements
    
    private lazy var dayOfWeekLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        label.textColor = UIColor(resource: .trackerBlack)
        return label
    }()

    private lazy var trackerSwitch: UISwitch = {
        let trackerSwitch = UISwitch()
        trackerSwitch.translatesAutoresizingMaskIntoConstraints = false
        trackerSwitch.isOn = false
        trackerSwitch.onTintColor = .trackerBlue
        trackerSwitch.addTarget(
            self,
            action: #selector(switchStateChanged),
            for: .valueChanged
        )
        return trackerSwitch
    }()

    private lazy var switchStack: UIStackView = {
        let switchStack = UIStackView()
        switchStack.translatesAutoresizingMaskIntoConstraints = false
        switchStack.axis = .horizontal
        switchStack.alignment = .center
        switchStack.distribution = .fill
        switchStack.backgroundColor = .trackerBackgroundDay
        switchStack.isLayoutMarginsRelativeArrangement = true
        switchStack.layoutMargins = UIEdgeInsets(
            top: 0,
            left: 16,
            bottom: 0,
            right: 16
        )
        return switchStack
    }()

    private let separatorView: UIView = {
        let view = UIView()

        view.backgroundColor = .trackerGray
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    // MARK: - Init

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupView()
        setupConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Private Methods

    private func setupView() {
        selectionStyle = .none
        contentView.addSubviews([switchStack, separatorView])
        switchStack.addArrangedSubview(dayOfWeekLabel)
        switchStack.addArrangedSubview(trackerSwitch)
        backgroundColor = .clear
        contentView.backgroundColor = .trackerBackgroundDay
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            switchStack.topAnchor.constraint(equalTo: contentView.topAnchor),
            switchStack.leadingAnchor.constraint(
                equalTo: contentView.leadingAnchor
            ),
            switchStack.trailingAnchor.constraint(
                equalTo: contentView.trailingAnchor
            ),
            switchStack.bottomAnchor.constraint(
                equalTo: contentView.bottomAnchor
            ),
            contentView.heightAnchor.constraint(equalToConstant: 75),

            separatorView.leadingAnchor.constraint(
                equalTo: contentView.leadingAnchor,
                constant: 16
            ),
            separatorView.trailingAnchor.constraint(
                equalTo: contentView.trailingAnchor,
                constant: -16
            ),
            separatorView.bottomAnchor.constraint(
                equalTo: contentView.bottomAnchor
            ),
            separatorView.heightAnchor.constraint(equalToConstant: 0.5),
        ])
    }
    
    // MARK: - Public Methods

    func showSeparator(_ isVisible: Bool) {
        separatorView.isHidden = !isVisible
    }
    
    func configure(with day: WeekDay) {
        dayOfWeekLabel.text = day.getLongName
        currentDay = day
    }
    
    // MARK: - Actions

    @objc private func switchStateChanged(_ sender: UISwitch) {
        guard let currentDay else { return }
        delegate?.didToggleSwitch(for: currentDay, isOn: true)

    }
}

// MARK: - Preview

#Preview {
    ViewControllerPreview {
        let controller = UIViewController()
        let cell = ScheduleTableViewCell(
            style: .default,
            reuseIdentifier: ScheduleTableViewCell.reuseIdentifier
        )
        cell.configure(with: .friday)

        controller.view.addSubview(cell)
        cell.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            cell.centerYAnchor.constraint(
                equalTo: controller.view.centerYAnchor
            ),
            cell.leadingAnchor.constraint(
                equalTo: controller.view.leadingAnchor
            ),
            cell.trailingAnchor.constraint(
                equalTo: controller.view.trailingAnchor
            ),
            cell.heightAnchor.constraint(equalToConstant: 75),
        ])

        controller.view.backgroundColor = .systemGroupedBackground

        return controller
    }
}
