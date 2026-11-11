//
//  TrackerOptionsCardView.swift
//  Tracker
//
//  Created by Eduard Ptushko on 10.11.2026.
//

import UIKit

final class TrackerOptionsCardView: UIView {

    // MARK: - Callbacks

    var onCategoryTap: (() -> Void)?
    var onScheduleTap: (() -> Void)?

    // MARK: - Properties

    private let type: TrackerType

    // MARK: - UI Elements

    private lazy var categoryRow = TrackerOptionRowView(title: "Категория")
    private lazy var scheduleRow = TrackerOptionRowView(title: "Расписание")

    private lazy var optionsStack: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.distribution = .fillEqually
        return stack
    }()

    private lazy var separator: UIView = {
        let view = UIView()
        view.backgroundColor = .trackerGray
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    // MARK: - Init

    init(type: TrackerType) {
        self.type = type
        super.init(frame: .zero)
        setupView()
        setupConstraints()
        setupActions()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Public Methods

    func setCategorySubtitle(_ text: String?) {
        categoryRow.setSubtitle(text)
    }

    func setScheduleSubtitle(_ text: String?) {
        scheduleRow.setSubtitle(text)
    }

    // MARK: - Private Methods

    private func setupView() {
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = .trackerBackgroundDay
        layer.cornerRadius = 16
        layer.masksToBounds = true

        addSubview(optionsStack)
        optionsStack.addArrangedSubview(categoryRow)

        if type == .habit {
            optionsStack.addArrangedSubview(scheduleRow)
            addSubview(separator)
        }
    }

    private func setupConstraints() {
        var constraints = [
            optionsStack.topAnchor.constraint(equalTo: topAnchor),
            optionsStack.leadingAnchor.constraint(
                equalTo: leadingAnchor,
                constant: 16
            ),
            optionsStack.trailingAnchor.constraint(
                equalTo: trailingAnchor,
                constant: 16
            ),
            optionsStack.bottomAnchor.constraint(equalTo: bottomAnchor),
        ]

        if type == .habit {
            constraints.append(contentsOf: [
                separator.leadingAnchor.constraint(
                    equalTo: leadingAnchor,
                    constant: 16
                ),
                separator.trailingAnchor.constraint(
                    equalTo: trailingAnchor,
                    constant: -16
                ),
                separator.centerYAnchor.constraint(equalTo: centerYAnchor),
                separator.heightAnchor.constraint(equalToConstant: 0.5),
            ])
        }

        NSLayoutConstraint.activate(constraints)
    }

    private func setupActions() {
        categoryRow.addAction(
            UIAction { [weak self] _ in
                self?.onCategoryTap?()
            },
            for: .touchUpInside
        )

        if type == .habit {
            scheduleRow.addAction(
                UIAction { [weak self] _ in
                    self?.onScheduleTap?()
                },
                for: .touchUpInside
            )
        }
    }
}

// MARK: - Previews

#Preview("Habit Card (2 Rows)") {
    let vc = UIViewController()
    vc.view.backgroundColor = .systemBackground

    let cardView = TrackerOptionsCardView(type: .habit)
    cardView.setCategorySubtitle("Важное")
    cardView.setScheduleSubtitle("Пн, Ср, Пт")

    vc.view.addSubview(cardView)

    NSLayoutConstraint.activate([
        cardView.topAnchor.constraint(
            equalTo: vc.view.safeAreaLayoutGuide.topAnchor,
            constant: 24
        ),
        cardView.leadingAnchor.constraint(
            equalTo: vc.view.leadingAnchor,
            constant: 16
        ),
        cardView.trailingAnchor.constraint(
            equalTo: vc.view.trailingAnchor,
            constant: -16
        ),
    ])

    return vc
}

#Preview("Irregular Card (1 Row)") {
    let vc = UIViewController()
    vc.view.backgroundColor = .systemBackground

    let cardView = TrackerOptionsCardView(type: .irregular)
    cardView.setCategorySubtitle("Радостные мелочи")

    vc.view.addSubview(cardView)

    NSLayoutConstraint.activate([
        cardView.topAnchor.constraint(
            equalTo: vc.view.safeAreaLayoutGuide.topAnchor,
            constant: 24
        ),
        cardView.leadingAnchor.constraint(
            equalTo: vc.view.leadingAnchor,
            constant: 16
        ),
        cardView.trailingAnchor.constraint(
            equalTo: vc.view.trailingAnchor,
            constant: -16
        ),
    ])

    return vc
}
