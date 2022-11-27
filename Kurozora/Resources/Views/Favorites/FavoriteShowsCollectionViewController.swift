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

		Task { [weak self] in
			guard let self = self else { return }
			await self.fetchFavoritesList()
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
		Task { [weak self] in
			guard let self = self else { return }
			await self.fetchFavoritesList()
		}
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
	@objc func fetchFavoritesList() async {
		DispatchQueue.main.async { [weak self] in
			guard let self = self else { return }
			#if !targetEnvironment(macCatalyst)
			self.refreshControl?.attributedTitle = NSAttributedString(string: "Refreshing favorites list...")
			#endif
		}

		guard let userID = self.user?.id else { return }
		let userIdentity = UserIdentity(id: userID)

		do {
			let showResponse = try await KService.getFavoriteShows(forUser: userIdentity, next: self.nextPageURL).value

			// Reset data if necessary
			if self.nextPageURL == nil {
				self.shows = []
			}

			// Save next page url and append new data
			self.nextPageURL = showResponse.next
			self.shows.append(contentsOf: showResponse.data)
		} catch {
			print("-----", error.localizedDescription)
		}

		self.updateDataSource()
	}

	// MARK: - Segue
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		guard let showDetailCollectionViewController = segue.destination as? ShowDetailsCollectionViewController else { return }
		guard let show = sender as? Show else { return }
		showDetailCollectionViewController.show = show
	}
}

// MARK: - SectionLayoutKind
extension FavoriteShowsCollectionViewController {
	/// List of  favorites section layout kind.
	///
	/// ```
	/// case main = 0
	/// ```
	enum SectionLayoutKind: Int, CaseIterable {
		case main = 0
	}
}
