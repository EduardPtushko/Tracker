//
//  TrackersViewController.swift
//  Tracker
//
//  Created by Eduard Ptushko on 22.10.2026.
//

import UIKit

final class TrackersViewController: UIViewController {

    // MARK: - UI Elements

    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let collectionView = UICollectionView(
            frame: .zero,
            collectionViewLayout: layout
        )
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()

    private lazy var datePicker: UIDatePicker = {
        let datePicker = UIDatePicker()
        datePicker.translatesAutoresizingMaskIntoConstraints = false
        datePicker.preferredDatePickerStyle = .compact
        datePicker.datePickerMode = .date
        datePicker.addTarget(
            self,
            action: #selector(datePickerValueChanged),
            for: .valueChanged
        )
        let currentDate = Date()
        let calendar = Calendar.current
        let minDate = calendar.date(
            byAdding: .year,
            value: -10,
            to: currentDate
        )
        let maxDate = calendar.date(byAdding: .year, value: 10, to: currentDate)
        datePicker.minimumDate = minDate
        datePicker.maximumDate = maxDate
        return datePicker
    }()

    private lazy var searchController: UISearchController = {
        let searchController = UISearchController(searchResultsController: nil)

        return searchController
    }()

    private lazy var filtersButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Фильтры", for: .normal)
        button.layer.cornerRadius = 16
        button.clipsToBounds = true
        button.backgroundColor = UIColor(resource: .trackerBlue)
        button.tintColor = UIColor(resource: .trackerWhite)
        return button
    }()

    private let emptyStateView = EmptyStateView()

    // MARK: - Public Properties

    var categories: [TrackerCategory] = [] {
        didSet {
            updateVisibleTrackers()
        }
    }

    var visibleCategories: [TrackerCategory] = [] {
        didSet {
            collectionView.reloadData()
            updateBackgroundState()
        }
    }

    var completedTrackers: [TrackerRecord] = []
    var currentDate: Date = Date.now

    // MARK: - Init

    init(categories: [TrackerCategory] = MockTrackerData.categories) {
        self.categories = categories
        self.completedTrackers = MockTrackerData.completedTrackers
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycles

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "Трекеры"
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.largeTitleDisplayMode = .automatic

        setupView()
        setupSearchController()
        configureFilterButton()
        configureNavBarButtons()

        updateVisibleTrackers()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        datePicker.clearCompactBackground()
    }

    // MARK: - Private Methods

    private func setupSearchController() {
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Поиск"
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        definesPresentationContext = true
    }

    private func setupView() {
        view.addSubview(collectionView)
        collectionView.edgesToSuperview()

        collectionView.register(
            TrackersCollectionViewCell.self,
            forCellWithReuseIdentifier: TrackersCollectionViewCell.identifier
        )
        collectionView.register(
            CategoryHeader.self,
            forSupplementaryViewOfKind: UICollectionView
                .elementKindSectionHeader,
            withReuseIdentifier: CategoryHeader.reuseIdentifier
        )

        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.contentInset = UIEdgeInsets(
            top: 0,
            left: 0,
            bottom: 82,
            right: 0
        )

        collectionView.scrollIndicatorInsets = UIEdgeInsets(
            top: 0,
            left: 0,
            bottom: 82,
            right: 0
        )
    }

    private func configureFilterButton() {
        view.addSubview(filtersButton)
        NSLayoutConstraint.activate([
            filtersButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            filtersButton.bottomAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.bottomAnchor,
                constant: -16
            ),

            filtersButton.widthAnchor.constraint(equalToConstant: 114),
            filtersButton.heightAnchor.constraint(equalToConstant: 50),
        ])
    }

    private func configureNavBarButtons() {
        let addButton = UIBarButtonItem(
            image: UIImage(resource: .addTracker),
            style: .plain,
            target: self,
            action: #selector(addTrackerButtonTapped)
        )
        addButton.tintColor = .trackerBlack

        navigationItem.leftBarButtonItem = addButton
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            customView: datePicker
        )
    }

    private func updateBackgroundState() {
        if visibleCategories.isEmpty {
            let isSearching =
                !(searchController.searchBar.text?.isEmpty ?? true)
            emptyStateView.configure(
                image: UIImage(resource: .emptyListPlaceholder),
                text: isSearching
                    ? "Ничего не найдено" : "Что будем отслеживать?"
            )

            collectionView.backgroundView = emptyStateView
            filtersButton.isHidden = true
        } else {
            collectionView.backgroundView = nil
            configureNavBarButtons()
        }
    }

    private func updateVisibleTrackers() {
        let currentDay = Calendar.current.component(.weekday, from: currentDate)
        guard let weekDay = WeekDay(rawValue: currentDay) else { return }

        let searchText = searchController.searchBar.text?.lowercased() ?? ""

        visibleCategories = categories.compactMap({ category in
            let filteredTrackers = category.trackers.filter { tracker in
                let matchesDate: Bool
                let matchesSearch =
                    searchText.isEmpty
                    || tracker.name.lowercased().contains(searchText)

                if let schedule = tracker.schedule {
                    matchesDate = schedule.contains(weekDay)
                } else {
                    matchesDate = true
                }
                return matchesDate && matchesSearch
            }

            return filteredTrackers.isEmpty
                ? nil
                : TrackerCategory(
                    title: category.title,
                    trackers: filteredTrackers
                )
        })
    }

    @objc private func addTrackerButtonTapped() {
        let chooseTrackerViewController = TrackerTypeSelectionViewController(
            delegate: self
        )

        let newTrackerViewController = UINavigationController(
            rootViewController: chooseTrackerViewController
        )

        present(newTrackerViewController, animated: true)
    }

    @objc private func datePickerValueChanged(_ sender: UIDatePicker) {
        self.currentDate = sender.date

        updateVisibleTrackers()
    }

}

// MARK: - UICollectionViewDataSource

extension TrackersViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        visibleCategories.count
    }

    func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {
        visibleCategories[section].trackers.count
    }

    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        guard
            let cell =
                collectionView.dequeueReusableCell(
                    withReuseIdentifier: TrackersCollectionViewCell.identifier,
                    for: indexPath
                ) as? TrackersCollectionViewCell
        else {
            return UICollectionViewCell()
        }
        let tracker = visibleCategories[indexPath.section].trackers[
            indexPath.row
        ]
        cell.delegate = self

        let isCompletedToday = completedTrackers.contains {
            $0.id == tracker.id
                && Calendar.current.isDate($0.date, inSameDayAs: currentDate)
        }
        let completedDaysCount = completedTrackers.filter {
            $0.id == tracker.id
        }.count

        cell.configure(
            with: tracker,
            isCompleted: isCompletedToday,
            completedDays: completedDaysCount
        )

        return cell
    }

    func collectionView(
        _ collectionView: UICollectionView,
        viewForSupplementaryElementOfKind kind: String,
        at indexPath: IndexPath
    ) -> UICollectionReusableView {
        if kind == UICollectionView.elementKindSectionHeader {
            guard
                let header = collectionView.dequeueReusableSupplementaryView(
                    ofKind: kind,
                    withReuseIdentifier: CategoryHeader.reuseIdentifier,
                    for: indexPath
                ) as? CategoryHeader
            else {
                return UICollectionReusableView()
            }

            let categoryTitle = visibleCategories[indexPath.section]
                .title
            header.titleLabel.text = categoryTitle

            return header
        }
        return UICollectionReusableView()
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension TrackersViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {

        let params = 16 * 3
        let availableWidth = collectionView.frame.width - CGFloat(params)
        let cellWidth = availableWidth / CGFloat(2)
        return CGSize(width: cellWidth, height: cellWidth * 4 / 4.5)
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        minimumInteritemSpacingForSectionAt section: Int
    ) -> CGFloat {
        return 0
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        insetForSectionAt section: Int
    ) -> UIEdgeInsets {
        UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        referenceSizeForHeaderInSection section: Int
    ) -> CGSize {
        CGSize(width: collectionView.frame.width, height: 48)
    }

}

extension TrackersViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        updateVisibleTrackers()
    }
}

// MARK: - TrackersCollectionViewCellDelegate

extension TrackersViewController: TrackersCollectionViewCellDelegate {
    func didTapCompleteButton(of cell: TrackersCollectionViewCell) {
        guard let indexPath = collectionView.indexPath(for: cell) else {
            return
        }

        let tracker = visibleCategories[indexPath.section].trackers[
            indexPath.row
        ]
        if currentDate > Date() && !Calendar.current.isDateInToday(currentDate)
        {
            return
        }

        let index = completedTrackers.firstIndex { record in
            record.id == tracker.id
                && Calendar.current.isDate(
                    record.date,
                    inSameDayAs: currentDate
                )
        }

        if let index {
            completedTrackers.remove(at: index)
        } else {
            let trackerRecord = TrackerRecord(id: tracker.id, date: currentDate)
            completedTrackers.append(trackerRecord)
        }
        collectionView.reloadItems(at: [indexPath])
    }

}

// MARK: - ConfigureTrackerViewControllerDelegate

extension TrackersViewController: ConfigureTrackerViewControllerDelegate {
    func didCreateTracker(_ tracker: Tracker, in categoryTitle: String) {
        if let index = categories.firstIndex(where: {
            $0.title == categoryTitle
        }) {
            var updatedTrackers = categories[index].trackers
            updatedTrackers.append(tracker)

            categories[index] = TrackerCategory(
                title: categoryTitle,
                trackers: updatedTrackers
            )
        } else {
            let newCategory = TrackerCategory(
                title: categoryTitle,
                trackers: [tracker]
            )
            categories.append(newCategory)
        }

    }

}

// MARK: - Previews

#Preview("Categories") {
    let navController = UINavigationController(
        rootViewController:
            TrackersViewController()
    )
    navController.navigationBar.prefersLargeTitles = true

    return navController
}

#Preview("Empty categories") {
    let trackerController = TrackersViewController()
    let navController = UINavigationController(
        rootViewController: trackerController
    )
    navController.navigationBar.prefersLargeTitles = true
    trackerController.categories = []
    trackerController.completedTrackers = []

    return navController
}
