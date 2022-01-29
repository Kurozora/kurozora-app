//
//  ShowsListCollectionViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 16/01/2020.
//  Copyright © 2020 Kurozora. All rights reserved.
//

import UIKit
import KurozoraKit

class ShowsListCollectionViewController: KCollectionViewController {
	// MARK: - Properties
	var personID: Int! {
		didSet {
			self.fetchShows()
		}
	}
	var characterID: Int! {
		didSet {
			self.fetchShows()
		}
	}
	var showID: Int! {
		didSet {
			self.fetchShows()
		}
	}
	var studioID: Int! {
		didSet {
			self.fetchShows()
		}
	}
	var shows: [Show] = [] {
		didSet {
			self.configureDataSource()
			self._prefersActivityIndicatorHidden = true
			self.toggleEmptyDataView()
			#if DEBUG
			#if !targetEnvironment(macCatalyst)
			self.refreshControl?.endRefreshing()
			#endif
			#endif
		}
	}
	var relatedShows: [RelatedShow] = []
	var nextPageURL: String?
	var dataSource: UICollectionViewDiffableDataSource<SectionLayoutKind, ItemKind>! = nil

	// Refresh control
	var _prefersRefreshControlDisabled = false {
		didSet {
			self.setNeedsRefreshControlAppearanceUpdate()
		}
	}
	override var prefersRefreshControlDisabled: Bool {
		return self._prefersRefreshControlDisabled
	}

	// Activity indicator
	var _prefersActivityIndicatorHidden = false {
		didSet {
			self.setNeedsActivityIndicatorAppearanceUpdate()
		}
	}
	override var prefersActivityIndicatorHidden: Bool {
		return self._prefersActivityIndicatorHidden
	}

	// MARK: - View
	override func viewWillReload() {
		super.viewWillReload()

		self.handleRefreshControl()
	}

	override func viewDidLoad() {
		super.viewDidLoad()

		// Add refresh control
		#if DEBUG
		self._prefersRefreshControlDisabled = false
		#else
		self._prefersRefreshControlDisabled = true
		#endif
	}

	// MARK: - Functions
	override func handleRefreshControl() {
		self.nextPageURL = nil

		if let showID = self.showID {
			self.showID = showID
		} else if let personID = self.personID {
			self.personID = personID
		} else if let characterID = self.characterID {
			self.characterID = characterID
		} else if let studioID = self.studioID {
			self.studioID = studioID
		}
	}

	override func configureEmptyDataView() {
		emptyBackgroundView.configureImageView(image: R.image.empty.library()!)
		emptyBackgroundView.configureLabels(title: "No Shows", detail: "Can't get shows list. Please refresh the page or restart the app and check your WiFi connection.")

		collectionView.backgroundView?.alpha = 0
	}

	/// Fades in and out the empty data view according to the number of rows.
	func toggleEmptyDataView() {
		if self.collectionView.numberOfItems() == 0 {
			self.collectionView.backgroundView?.animateFadeIn()
		} else {
			self.collectionView.backgroundView?.animateFadeOut()
		}
	}

	/// Fetches the characters.
	func fetchShows() {
		if self.showID != nil {
			KService.getRelatedShows(forShowID: self.showID, next: self.nextPageURL) { [weak self] result in
				guard let self = self else { return }
				switch result {
				case .success(let relatedShowsResponse):
					// Reset data if necessary
					if self.nextPageURL == nil {
						self.relatedShows = []
						self.shows = []
					}

					// Append new data and save next page url
					self.relatedShows.append(contentsOf: relatedShowsResponse.data)
					self.shows.append(contentsOf: relatedShowsResponse.data.compactMap({ relatedShow -> Show? in
						return relatedShow.show
					}))
					self.nextPageURL = relatedShowsResponse.next
				case .failure: break
				}
			}
		} else if self.personID != nil {
			KService.getShows(forPersonID: self.personID, next: self.nextPageURL) { [weak self] result in
				guard let self = self else { return }
				switch result {
				case .success(let showResponse):
					// Reset data if necessary
					if self.nextPageURL == nil {
						self.shows = []
					}

					// Append new data and save next page url
					self.shows.append(contentsOf: showResponse.data)
					self.nextPageURL = showResponse.next
				case .failure: break
				}
			}
		} else if self.characterID != nil {
			KService.getShows(forCharacterID: self.characterID, next: self.nextPageURL) { [weak self] result in
				guard let self = self else { return }
				switch result {
				case .success(let showResponse):
					// Reset data if necessary
					if self.nextPageURL == nil {
						self.shows = []
					}

					// Append new data and save next page url
					self.shows.append(contentsOf: showResponse.data)
					self.nextPageURL = showResponse.next
				case .failure: break
				}
			}
		} else if self.studioID != nil {
			KService.getShows(forStudioID: self.studioID, next: self.nextPageURL) { [weak self] result in
				guard let self = self else { return }
				switch result {
				case .success(let showResponse):
					// Reset data if necessary
					if self.nextPageURL == nil {
						self.shows = []
					}

					// Append new data and save next page url
					self.shows.append(contentsOf: showResponse.data)
					self.nextPageURL = showResponse.next
				case .failure: break
				}
			}
		}
	}

	// MARK: - Segue
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		switch segue.identifier {
		case R.segue.showsListCollectionViewController.showDetailsSegue.identifier:
			guard let showDetailCollectionViewController = segue.destination as? ShowDetailsCollectionViewController else { return }
			guard let show = sender as? Show else { return }
			showDetailCollectionViewController.showID = show.id
		default: break
		}
	}
}

// MARK: - KCollectionViewDataSource
extension ShowsListCollectionViewController {
	override func registerCells(for collectionView: UICollectionView) -> [UICollectionViewCell.Type] {
		return [SmallLockupCollectionViewCell.self]
	}

	override func configureDataSource() {
		dataSource = UICollectionViewDiffableDataSource<SectionLayoutKind, ItemKind>(collectionView: collectionView) { (collectionView: UICollectionView, indexPath: IndexPath, item: ItemKind) -> UICollectionViewCell? in
			let smallLockupCollectionViewCell = collectionView.dequeueReusableCell(withClass: SmallLockupCollectionViewCell.self, for: indexPath)

			// Populate the cell with our item description
			switch item {
			case .show(let show, _):
				smallLockupCollectionViewCell.configureCell(with: show)
			case .relatedShow(let relatedShow, _):
				smallLockupCollectionViewCell.configureCell(with: relatedShow)
			}

			// Return the cell
			return smallLockupCollectionViewCell
		}

		self.updateDataSource()
	}

	override func updateDataSource() {
		var snapshot = NSDiffableDataSourceSnapshot<SectionLayoutKind, ItemKind>()
		snapshot.appendSections([.main])

		// Append items
		if self.relatedShows.isEmpty {
			let showItems: [ItemKind] = self.shows.map { show in
				return .show(show)
			}
			snapshot.appendItems(showItems)
		} else {
			let relatedShowItems: [ItemKind] = relatedShows.map { relatedShow in
				return .relatedShow(relatedShow)
			}
			snapshot.appendItems(relatedShowItems)
		}

		dataSource.apply(snapshot)
	}
}

// MARK: - KCollectionViewDelegateLayout
extension ShowsListCollectionViewController {
	override func columnCount(forSection section: Int, layout layoutEnvironment: NSCollectionLayoutEnvironment) -> Int {
		let width = layoutEnvironment.container.effectiveContentSize.width
		let columnCount = width >= 414 ? (width / 384).rounded().int : (width / 284).rounded().int
		return columnCount > 0 ? columnCount : 1
	}

	override func contentInset(forSection section: Int, layout collectionViewLayout: NSCollectionLayoutEnvironment) -> NSDirectionalEdgeInsets {
		return NSDirectionalEdgeInsets(top: 10, leading: 10, bottom: 20, trailing: 10)
	}

	override func createLayout() -> UICollectionViewLayout? {
		let layout = UICollectionViewCompositionalLayout { (section: Int, layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? in
			let columns = self.columnCount(forSection: section, layout: layoutEnvironment)
			let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
			let item = NSCollectionLayoutItem(layoutSize: itemSize)

			let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(150.0))
			let layoutGroup = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: columns)
			layoutGroup.interItemSpacing = .fixed(10.0)

			let layoutSection = NSCollectionLayoutSection(group: layoutGroup)
			layoutSection.interGroupSpacing = 10.0
			layoutSection.contentInsets = self.contentInset(forSection: section, layout: layoutEnvironment)
			return layoutSection
		}
		return layout
	}
}

// MARK: - SectionLayoutKind
extension ShowsListCollectionViewController {
	/**
		List of section layout kind.

		```
		case main = 0
		```
	*/
	enum SectionLayoutKind: Int, CaseIterable {
		// MARK: - Cases
		/// The main section.
		case main = 0
	}
}

// MARK: - ItemKind
extension ShowsListCollectionViewController {
	/**
		List of item layout kind.
	*/
	enum ItemKind: Hashable {
		// MARK: - Cases
		/// Indicates the item kind contains a Show object.
		case show(_: Show, id: UUID = UUID())

		/// Indicates the item kind contains a RelatedShow object.
		case relatedShow(_: RelatedShow, id: UUID = UUID())

		// MARK: - Functions
		func hash(into hasher: inout Hasher) {
			switch self {
			case .show(let show, let id):
				hasher.combine(show)
				hasher.combine(id)
			case .relatedShow(let relatedShow, let id):
				hasher.combine(relatedShow)
				hasher.combine(id)
			}
		}

		static func == (lhs: ItemKind, rhs: ItemKind) -> Bool {
			switch (lhs, rhs) {
			case (.show(let show1, let id1), .show(let show2, let id2)):
				return show1.id == show2.id && id1 == id2
			case (.relatedShow(let relatedShow1, let id1), .relatedShow(let relatedShow2, let id2)):
				return relatedShow1.id == relatedShow2.id && id1 == id2
			default:
				return false
			}
		}
	}
}
