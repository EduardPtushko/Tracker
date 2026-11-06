//
//  TrackersViewController.swift
//  Tracker
//
//  Created by Eduard Ptushko on 22.10.2026.
//

import UIKit

class TrackersViewController: UIViewController {

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
        let minDate = calendar.date(byAdding: .year, value: -10, to: currentDate)
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

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "Трекеры"
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.largeTitleDisplayMode = .automatic
        
        configureNavBarButtons()
        setupView()
        updateBackgroundState()
        setupSearchController()
        configureFilterButton()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        datePicker.clearCompactBackground()
    }

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

    private func updateBackgroundState() {
        if categories.isEmpty {
            emptyStateView.configure(
                image: UIImage(resource: .emptyListPlaceholder),
                text: "Что будем отслеживать?"
            )

            collectionView.backgroundView = emptyStateView
            filtersButton.isHidden = true
        } else {
            collectionView.backgroundView = nil
            configureNavBarButtons()
        }
    }

    private func configureNavBarButtons() {
        let addButton = UIBarButtonItem(
            image: UIImage(resource: .addTracker),
            style: .plain,
            target: self,
            action: #selector(addTrackerButtonTapped)
        )

        navigationItem.leftBarButtonItem = addButton
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            customView: datePicker
        )
    }

    @objc private func addTrackerButtonTapped() {
        let newTrackerViewController = UINavigationController(rootViewController:  ChooseTrackerViewController())
        present(newTrackerViewController, animated: true)
    }

    @objc private func datePickerValueChanged(_ sender: UIDatePicker) {
        self.currentDate = sender.date
        
        updateVisibleTrackers()
    }
    
    private func updateVisibleTrackers() {
        let currentDay = Calendar.current.component(.weekday, from: currentDate)
        guard let weekDay = WeekDay(rawValue: currentDay) else { return }
        
        visibleCategories = categories.compactMap({ category in
            
            let filteredTrackers = category.trackers.filter { tracker in
                if let schedule = tracker.schedule {
                    return schedule.contains(weekDay)
                }
                
                return false
            }
            
            return TrackerCategory(title: category.title, trackers: filteredTrackers)
        })
    }

}

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
        cell.delegate = self
        let trackers = visibleCategories[indexPath.section].trackers
        cell.configure(with: trackers[indexPath.row])
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

            let categoryTitle = categories[indexPath.section]
                .title
            header.titleLabel.text = categoryTitle

            return header
        }
        return UICollectionReusableView()
    }
}

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
    }
}

extension TrackersViewController: TrackersCollectionViewCellDelegate {
    func didTapCompleteButton(of cell: TrackersCollectionViewCell) {
        guard let indexPath = collectionView.indexPath(for: cell) else { return }
        
        let tracker = visibleCategories[indexPath.section].trackers[indexPath.row]
        let button = cell.plusButton
        let countLabel = cell.countLabel
        let currentBackground = button.backgroundColor ?? .systemBlue
        
        if self.completedTrackers.contains(where: { $0.id == tracker.id && $0.date == currentDate}) {
            self.completedTrackers.removeAll(where: { $0.id == tracker.id && $0.date == currentDate})
            button.setImage(UIImage(systemName: "plus"), for: .normal)
            button.backgroundColor = currentBackground.withAlphaComponent(1)
            countLabel.text = "0 дней"
        } else {
            let trackerRecord = TrackerRecord(id: tracker.id, date: currentDate)
            self.completedTrackers.append(trackerRecord)
            button.setImage(UIImage(systemName: "checkmark"), for: .normal)
            button.backgroundColor = currentBackground.withAlphaComponent(0.5)
            countLabel.text = "1 день"
        }
    }
    
}

#Preview("Empty categories") {
    let navController = UINavigationController(
        rootViewController:
            TrackersViewController()
    )
    navController.navigationBar.prefersLargeTitles = true
    return navController
}

#Preview("Categories") {
    let trackerController = TrackersViewController()
    let navController = UINavigationController(
        rootViewController: trackerController
    )
    navController.navigationBar.prefersLargeTitles = true
    trackerController.categories = MockTrackerData.categories

    return navController
}
