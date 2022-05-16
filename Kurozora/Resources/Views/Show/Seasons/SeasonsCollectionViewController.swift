//
//  SeasonsCollectionViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 10/10/2018.
//  Copyright © 2018 Kurozora. All rights reserved.
//

import UIKit
import KurozoraKit
import Alamofire

class SeasonsCollectionViewController: KCollectionViewController {
	// MARK: - Properties
	var showIdentity: ShowIdentity? = nil
	var seasons: [IndexPath: Season] = [:]
	var seasonIdentities: [SeasonIdentity] = [] {
		didSet {
			self.updateDataSource()
			self._prefersActivityIndicatorHidden = true
			self.toggleEmptyDataView()
			#if DEBUG
			#if !targetEnvironment(macCatalyst)
			self.refreshControl?.endRefreshing()
			#endif
			#endif
		}
	}
	var dataSource: UICollectionViewDiffableDataSource<SectionLayoutKind, SeasonIdentity>! = nil
	var prefetchingIndexPathOperations: [IndexPath: DataRequest] = [:]

	/// The next page url of the pagination.
	var nextPageURL: String?

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
		return _prefersActivityIndicatorHidden
	}

	// MARK: - View
	override func viewDidLoad() {
        super.viewDidLoad()

		#if DEBUG
		self._prefersRefreshControlDisabled = false
		#else
		self._prefersRefreshControlDisabled = true
		#endif

		// Add Refresh Control to Collection View
		#if !targetEnvironment(macCatalyst)
		self.refreshControl?.attributedTitle = NSAttributedString(string: "Pull to refresh the seasons.")
		#endif

		self.configureDataSource()

		// Fetch seasons
		DispatchQueue.global(qos: .userInteractive).async {
			self.fetchSeasons()
		}
    }

	// MARK: - Functions
	override func handleRefreshControl() {
		self.nextPageURL = nil

		DispatchQueue.global(qos: .userInteractive).async {
			self.fetchSeasons()
		}
	}

	override func configureEmptyDataView() {
		emptyBackgroundView.configureImageView(image: R.image.empty.seasons()!)
		emptyBackgroundView.configureLabels(title: "No Seasons", detail: "This show doesn't have seasons yet. Please check back again later.")

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

	/// Fetch seasons for the current show.
	func fetchSeasons() {
		guard let showIdentity = showIdentity else {
			DispatchQueue.main.async { [weak self] in
				guard let self = self else { return }
			#if !targetEnvironment(macCatalyst)
				self.refreshControl?.endRefreshing()
			#endif
			}
			return
		}

		DispatchQueue.main.async { [weak self] in
			guard let self = self else { return }
			#if !targetEnvironment(macCatalyst)
			self.refreshControl?.attributedTitle = NSAttributedString(string: "Refreshing seasons...")
			#endif
		}

		KService.getSeasons(forShow: showIdentity, next: self.nextPageURL) { [weak self] result in
			guard let self = self else { return }
			switch result {
			case .success(let seasonIdentityResponse):
				// Reset data if necessary
				if self.nextPageURL == nil {
					self.seasonIdentities = []
				}

				// Save next page url and append new data
				self.nextPageURL = seasonIdentityResponse.next
				self.seasonIdentities.append(contentsOf: seasonIdentityResponse.data)

				// Reset refresh controller title
				#if !targetEnvironment(macCatalyst)
				self.refreshControl?.attributedTitle = NSAttributedString(string: "Pull to refresh the seasons.")
				#endif
			case .failure: break
			}
        }
    }

	// MARK: - Segue
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		switch segue.identifier {
		case R.segue.seasonsCollectionViewController.episodeSegue.identifier:
			guard let episodesCollectionViewController = segue.destination as? EpisodesCollectionViewController else { return }
			guard let lockupCollectionViewCell = sender as? SeasonLockupCollectionViewCell else { return }
			guard let indexPath = collectionView.indexPath(for: lockupCollectionViewCell) else { return }
			episodesCollectionViewController.seasonID = self.seasonIdentities[indexPath.item].id
		default: break
		}
	}
}

// MARK: - SectionLayoutKind
extension SeasonsCollectionViewController {
	/// List of season section layout kind.
	///
	/// ```
	/// case main = 0
	/// ```
	enum SectionLayoutKind: Int, CaseIterable {
		case main = 0
	}
}
