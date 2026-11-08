//
//  ScheduleViewController.swift
//  Tracker
//
//  Created by Eduard Ptushko on 03.11.2026.
//

import UIKit

final class ScheduleViewController: UIViewController {
    
    private let daysOfWeek = [
        "Понедельник", "Вторник", "Среда", "Четверг", "Пятница", "Суббота",
        "Воскресенье",
    ]

    private lazy var contentStack: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.spacing = 0
        stack.alignment = .fill
        stack.distribution = .fill
        stack.layer.cornerRadius = 10
        stack.layer.masksToBounds = true
        return stack
    }()
    
    private let readyButton = TrackerButton(title: "Готово")

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.hidesBackButton = true
        setupView()
    }

    private func setupView() {
        view.backgroundColor = .systemBackground
        title = "Расписание"
        view.addSubviews([contentStack, readyButton])

        setupDays()
        setupConstraints()
    }

    private func setupDays() {
        for (index, day) in daysOfWeek.enumerated() {
            contentStack.addArrangedSubview(makeSwitchView(title: day))
            
            if index < daysOfWeek.count - 1 {
                let separator = createSeparator()
                contentStack.addArrangedSubview(separator)
            }
        }
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            contentStack.topAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.topAnchor,
                constant: 24
            ),
            contentStack.leadingAnchor.constraint(
                equalTo: view.leadingAnchor,
                constant: 16
            ),
            contentStack.trailingAnchor.constraint(
                equalTo: view.trailingAnchor,
                constant: -16
            ),

            readyButton.leadingAnchor.constraint(
                equalTo: view.leadingAnchor,
                constant: 20
            ),
            readyButton.trailingAnchor.constraint(
                equalTo: view.trailingAnchor,
                constant: -20
            ),
            readyButton.bottomAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.bottomAnchor
            ),
            readyButton.heightAnchor.constraint(equalToConstant: 60),
        ])
    }

    private func makeSwitchView(title: String) -> UIStackView {
        let dayOfWeekLabel = UILabel()
        dayOfWeekLabel.text = title
        dayOfWeekLabel.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        dayOfWeekLabel.textColor = UIColor(resource: .trackerBlack)

        let trackerSwitch = UISwitch()
        trackerSwitch.isOn = false
        trackerSwitch.onTintColor = .trackerBlue

        var switchStack = UIStackView(arrangedSubviews: [
            dayOfWeekLabel, trackerSwitch,
        ])
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
        switchStack.heightAnchor.constraint(equalToConstant: 75).isActive = true

        return switchStack
    }
    
    private func createSeparator() -> UIView {
        let container = UIView()
        container.backgroundColor = .trackerBackgroundDay
        container.translatesAutoresizingMaskIntoConstraints = false
        container.heightAnchor.constraint(equalToConstant: 1).isActive = true
        
        let line = UIView()
        line.backgroundColor = .trackerGray
        line.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(line)
        
        NSLayoutConstraint.activate([
            line.heightAnchor.constraint(equalToConstant: 0.5),
            line.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16),
            line.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -16),
            line.centerYAnchor.constraint(equalTo: container.centerYAnchor)
        ])
        
        return container
    }

}

#Preview {
    UINavigationController(rootViewController: ScheduleViewController())
}
