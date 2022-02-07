//
//  SeasonsCollectionViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 10/10/2018.
//  Copyright © 2018 Kurozora. All rights reserved.
//

import UIKit
import KurozoraKit

class SeasonsCollectionViewController: KCollectionViewController {
	// MARK: - Properties
	var showID: Int = 0
	var seasons: [Season] = [] {
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
	var nextPageURL: String?
	var dataSource: UICollectionViewDiffableDataSource<SectionLayoutKind, Season>! = nil

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

		self.configureDataSource()

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
		KService.getSeasons(forShowID: self.showID, next: self.nextPageURL) { [weak self] result in
			guard let self = self else { return }
			switch result {
			case .success(let seasonsResponse):
				// Reset data if necessary
				if self.nextPageURL == nil {
					self.seasons = []
				}

				// Save next page url and append new data
				DispatchQueue.main.async {
					self.nextPageURL = seasonsResponse.next
					self.seasons.append(contentsOf: seasonsResponse.data)
				}
			case .failure: break
			}
        }
    }

	// MARK: - Segue
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if segue.identifier == R.segue.seasonsCollectionViewController.episodeSegue.identifier, let lockupCollectionViewCell = sender as? PosterLockupCollectionViewCell {
			if let episodesCollectionViewController = segue.destination as? EpisodesCollectionViewController, let indexPath = collectionView.indexPath(for: lockupCollectionViewCell) {
				episodesCollectionViewController.seasonID = seasons[indexPath.item].id
			}
		}
	}
}

// MARK: - SectionLayoutKind
extension SeasonsCollectionViewController {
	/**
		List of season section layout kind.

		```
		case main = 0
		```
	*/
	enum SectionLayoutKind: Int, CaseIterable {
		case main = 0
	}
}
