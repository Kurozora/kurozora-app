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
	var dataSource: UICollectionViewDiffableDataSource<SectionLayoutKind, Show>! = nil
	var snapshot: NSDiffableDataSourceSnapshot<SectionLayoutKind, Show>! = nil

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
