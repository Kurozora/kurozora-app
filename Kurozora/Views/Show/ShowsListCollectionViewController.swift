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
	var nextPageURL: String?
	var dataSource: UICollectionViewDiffableDataSource<SectionLayoutKind, Show>! = nil

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
						self.shows = []
					}

					// Append new data and save next page url
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
		if segue.identifier == R.segue.showsListCollectionViewController.showDetailsSegue.identifier {
			if let showDetailCollectionViewController = segue.destination as? ShowDetailsCollectionViewController {
				if let showID = sender as? Int {
					showDetailCollectionViewController.showID = showID
				}
			}
		}
	}
}

// MARK: - KCollectionViewDataSource
extension ShowsListCollectionViewController {
	override func registerCells(for collectionView: UICollectionView) -> [UICollectionViewCell.Type] {
		return [SmallLockupCollectionViewCell.self]
	}

	override func configureDataSource() {
		dataSource = UICollectionViewDiffableDataSource<SectionLayoutKind, Show>(collectionView: collectionView) { (collectionView: UICollectionView, indexPath: IndexPath, item: Show) -> UICollectionViewCell? in
			let smallLockupCollectionViewCell = collectionView.dequeueReusableCell(withClass: SmallLockupCollectionViewCell.self, for: indexPath)
			smallLockupCollectionViewCell.show = item
			return smallLockupCollectionViewCell
		}

		self.updateDataSource()
	}

	override func updateDataSource() {
		var snapshot = NSDiffableDataSourceSnapshot<SectionLayoutKind, Show>()
		snapshot.appendSections([.main])
		snapshot.appendItems(self.shows)
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
		case main = 0
	}
}
