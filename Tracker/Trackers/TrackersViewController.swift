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
            collectionView.reloadData()
            updateBackgroundState()
        }
    }
    var completedTrackers: [TrackerRecord] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Трекеры"
        configureNavBarButtons()
        setupUI()
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

    private func setupUI() {
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
        print("Add Tracker button tapped")
    }

    @objc private func datePickerValueChanged(_ sender: UIDatePicker) {
        let selectedDate = sender.date
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yyyy"
        let formattedDate = dateFormatter.string(from: selectedDate)
        print("Selected date: \(formattedDate)")
    }

}

extension TrackersViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        categories.count
    }

    func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {
        categories[section].trackers.count
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

        let trackers = categories[indexPath.section].trackers
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

extension TrackersViewController: UICollectionViewDelegate {

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
