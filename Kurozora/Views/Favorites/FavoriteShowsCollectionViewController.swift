//
//  FavoriteShowsCollectionViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 08/05/2018.
//  Copyright © 2018 Kurozora. All rights reserved.
//

import UIKit
import KurozoraKit

class FavoriteShowsCollectionViewController: KCollectionViewController {
	// MARK: - Properties
	var shows: [Show] = [] {
		didSet {
			self._prefersActivityIndicatorHidden = true

			#if !targetEnvironment(macCatalyst)
			self.refreshControl?.endRefreshing()
			self.refreshControl?.attributedTitle = NSAttributedString(string: "Pull to refresh favorites list!")
			#endif
		}
	}
	var nextPageURL: String?
	var _user: User? = User.current
	var user: User? {
		get {
			return self._user
		}
		set {
			self._user = newValue
		}
	}
	var dismissButtonIsEnabled: Bool = false {
		didSet {
			if dismissButtonIsEnabled {
				enableDismissButton()
			}
		}
	}
	var dataSource: UICollectionViewDiffableDataSource<SectionLayoutKind, Int>! = nil
	var snapshot: NSDiffableDataSourceSnapshot<SectionLayoutKind, Int>! = nil

	// Activity indicator
	var _prefersActivityIndicatorHidden = false {
		didSet {
			self.setNeedsActivityIndicatorAppearanceUpdate()
		}
	}
	override var prefersActivityIndicatorHidden: Bool {
		return self._prefersActivityIndicatorHidden
	}

	// MARK: - Views
	override func viewDidLoad() {
		super.viewDidLoad()
		// Observe NotificationCenter for an update.
		if self.user?.id == User.current?.id {
			NotificationCenter.default.addObserver(self, selector: #selector(self.fetchFavoritesList), name: .KFavoriteShowsListDidChange, object: nil)
		}

		self.configureDataSource()

		DispatchQueue.global(qos: .background).async {
			self.fetchFavoritesList()
		}

		// Setup refresh control
		#if !targetEnvironment(macCatalyst)
		self.refreshControl?.attributedTitle = NSAttributedString(string: "Pull to refresh favorites list!")
		#endif
	}

	// MARK: - Functions
	/// Enable and show the dismiss button.
	func enableDismissButton() {
		let leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .stop, target: self, action: #selector(dismissButtonPressed))
		self.navigationItem.setLeftBarButton(leftBarButtonItem, animated: true)
	}

	/// Dismiss the view. Used by the dismiss button when viewing other users' profile.
	@objc fileprivate func dismissButtonPressed() {
		dismiss(animated: true, completion: nil)
	}

	override func handleRefreshControl() {
		self.fetchFavoritesList()
	}

	override func configureEmptyDataView() {
		var detailString: String

		if self.user?.id == User.current?.id {
			detailString = "Favorited shows will show up on this page!"
		} else {
			detailString = "\(self.user?.attributes.username ?? "This user") hasn't favorited shows yet."
		}

		emptyBackgroundView.configureImageView(image: R.image.empty.favorites()!)
		emptyBackgroundView.configureLabels(title: "No Favorites", detail: detailString)

		collectionView.backgroundView?.alpha = 0
	}

	/// Fades in and out the empty data view according to the number of sections.
	func toggleEmptyDataView() {
		if self.snapshot.itemIdentifiers.isEmpty {
			self.collectionView.backgroundView?.animateFadeIn()
		} else {
			self.collectionView.backgroundView?.animateFadeOut()
		}
	}

	/// Fetches the user's favorite list.
	@objc fileprivate func fetchFavoritesList() {
		DispatchQueue.main.async {
			#if !targetEnvironment(macCatalyst)
			self.refreshControl?.attributedTitle = NSAttributedString(string: "Refreshing favorites list...")
			#endif
		}

		guard let userID = self.user?.id else { return }
		KService.getFavoriteShows(forUserID: userID, next: self.nextPageURL) { [weak self] result in
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
				self.updateDataSource()
			case .failure: break
			}
		}
	}

	// MARK: - Segue
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if let show = (sender as? SmallLockupCollectionViewCell)?.show, let showDetailCollectionViewController = segue.destination as? ShowDetailsCollectionViewController {
			showDetailCollectionViewController.showID = show.id
		}
	}
}

// MARK: - UICollectionViewDelegate
extension FavoriteShowsCollectionViewController {
	override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		let smallLockupCollectionViewCell = collectionView.cellForItem(at: indexPath) as? SmallLockupCollectionViewCell
		performSegue(withIdentifier: R.segue.favoriteShowsCollectionViewController.showDetailsSegue, sender: smallLockupCollectionViewCell)
	}

	override func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
		let numberOfItems = collectionView.numberOfItems()

		if indexPath.item == numberOfItems - 5 {
			if self.nextPageURL != nil {
				self.fetchFavoritesList()
			}
		}
	}
}

// MARK: - KCollectionViewDataSource
extension FavoriteShowsCollectionViewController {
	override func registerCells(for collectionView: UICollectionView) -> [UICollectionViewCell.Type] {
		return [SmallLockupCollectionViewCell.self]
	}

	override func configureDataSource() {
		self.dataSource = UICollectionViewDiffableDataSource<SectionLayoutKind, Int>(collectionView: collectionView) { [weak self] (collectionView: UICollectionView, indexPath: IndexPath, _) -> UICollectionViewCell? in
			guard let self = self else { return nil }
			let smallLockupCollectionViewCell = collectionView.dequeueReusableCell(withClass: SmallLockupCollectionViewCell.self, for: indexPath)
			smallLockupCollectionViewCell.show = self.shows[indexPath.item]
			return smallLockupCollectionViewCell
		}
	}

	override func updateDataSource() {
		var snapshot = NSDiffableDataSourceSnapshot<SectionLayoutKind, Int>()
		SectionLayoutKind.allCases.forEach {
			let itemsPerSection = shows.count
			snapshot.appendSections([$0])
			snapshot.appendItems(Array(0..<itemsPerSection))
		}
		self.snapshot = snapshot
		self.dataSource.apply(snapshot) {
			self.toggleEmptyDataView()
		}
	}
}

// MARK: - KCollectionViewDelegateLayout
extension FavoriteShowsCollectionViewController {
	override func columnCount(forSection section: Int, layout layoutEnvironment: NSCollectionLayoutEnvironment) -> Int {
		let width = layoutEnvironment.container.effectiveContentSize.width
		var columnCount = (width / 374).rounded().int
		if columnCount < 0 {
			columnCount = 1
		} else if columnCount > 5 {
			columnCount = 5
		}
		return columnCount
	}

	func heightDimension(forSection section: Int, with columnsCount: Int) -> NSCollectionLayoutDimension {
		let heightFraction = (0.60 / columnsCount.double).cgFloat
		return .fractionalWidth(heightFraction)
	}

	override func contentInset(forItemInSection section: Int, layout collectionViewLayout: NSCollectionLayoutEnvironment) -> NSDirectionalEdgeInsets {
		return NSDirectionalEdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10)
	}

	override func contentInset(forSection section: Int, layout collectionViewLayout: NSCollectionLayoutEnvironment) -> NSDirectionalEdgeInsets {
		return NSDirectionalEdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10)
	}

	override func createLayout() -> UICollectionViewLayout {
		let layout = UICollectionViewCompositionalLayout { (section: Int, layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? in
			let columns = self.columnCount(forSection: section, layout: layoutEnvironment)
			let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
												  heightDimension: .fractionalHeight(1.0))
			let item = NSCollectionLayoutItem(layoutSize: itemSize)
			item.contentInsets = self.contentInset(forItemInSection: section, layout: layoutEnvironment)

			let heightDimension = self.heightDimension(forSection: section, with: columns)
			let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
												   heightDimension: heightDimension)
			let layoutGroup = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: columns)

			let layoutSection = NSCollectionLayoutSection(group: layoutGroup)
			layoutSection.contentInsets = self.contentInset(forSection: section, layout: layoutEnvironment)

			return layoutSection
		}
		return layout
	}
}

// MARK: - SectionLayoutKind
extension FavoriteShowsCollectionViewController {
	/**
		List of  favorites section layout kind.

		```
		case main = 0
		```
	*/
	enum SectionLayoutKind: Int, CaseIterable {
		case main = 0
	}
}
