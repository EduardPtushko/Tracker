//
//  ScheduleViewController.swift
//  Tracker
//
//  Created by Eduard Ptushko on 03.11.2026.
//

import UIKit

protocol ScheduleViewControllerDelegate: AnyObject {
    func didSelectSchedule(schedule: Set<WeekDay>)
}

final class ScheduleViewController: UIViewController {

    private let daysOfWeek: [WeekDay] = [
        .monday, .tuesday, .wednesday, .thursday, .friday, .saturday, .sunday,
    ]
    var scheduledDays: Set<WeekDay> = []
    weak var delegate: ScheduleViewControllerDelegate?

    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = UIColor(resource: .trackerWhite)
        tableView.separatorStyle = .none
        tableView.isScrollEnabled = false
        tableView.layer.cornerRadius = 16
        tableView.clipsToBounds = true

        return tableView
    }()

    private let readyButton = TrackerButton(title: "Готово")

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.hidesBackButton = true
        setupView()
        setupConstraints()
    }

    // MARK: - Private Methods

    private func setupView() {
        view.backgroundColor = .systemBackground
        title = "Расписание"
        view.addSubviews([tableView, readyButton])

        tableView.dataSource = self
        tableView.register(
            ScheduleTableViewCell.self,
            forCellReuseIdentifier: ScheduleTableViewCell.reuseIdentifier
        )
        tableView.rowHeight = 75

        readyButton.addTarget(
            self,
            action: #selector(didTapReadyButton),
            for: .touchUpInside
        )
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.topAnchor,
                constant: 24
            ),
            tableView.leadingAnchor.constraint(
                equalTo: view.leadingAnchor,
                constant: 16
            ),
            tableView.trailingAnchor.constraint(
                equalTo: view.trailingAnchor,
                constant: -16
            ),
            tableView.heightAnchor.constraint(equalToConstant: 525),

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

    @objc private func didTapReadyButton() {
        delegate?.didSelectSchedule(schedule: scheduledDays)
        navigationController?.popViewController(animated: true)
    }
}

// MARK: - UITableViewDataSource

extension ScheduleViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int)
        -> Int
    {
        daysOfWeek.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath)
        -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: ScheduleTableViewCell.reuseIdentifier,
            for: indexPath
        )

        guard let scheduleCell = cell as? ScheduleTableViewCell else {
            return UITableViewCell()
        }
        scheduleCell.delegate = self

        let day = daysOfWeek[indexPath.row]
        scheduleCell.configure(with: day)

        if indexPath.row == daysOfWeek.count - 1 {
            scheduleCell.showSeparator(false)
        }
        return scheduleCell
    }
}

// MARK: - ScheduleTableViewCellDelegate

extension ScheduleViewController: ScheduleTableViewCellDelegate {
    func didToggleSwitch(for day: WeekDay, isOn: Bool) {
        if isOn {
            scheduledDays.insert(day)
        } else {
            scheduledDays.remove(day)
        }
    }

}

// MARK: - Preview

#Preview {
    UINavigationController(rootViewController: ScheduleViewController())
}
