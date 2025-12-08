//
//  SeasonsListCollectionViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 10/10/2018.
//  Copyright © 2018 Kurozora. All rights reserved.
//

import KurozoraKit
import UIKit

class SeasonsListCollectionViewController: KCollectionViewController, SectionFetchable {
	// MARK: - Properties
	var showIdentity: ShowIdentity?
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

	var cache: [IndexPath: KurozoraItem] = [:]
	var isFetchingSection: Set<SectionLayoutKind> = []

	var dataSource: UICollectionViewDiffableDataSource<SectionLayoutKind, ItemKind>!
	var snapshot: NSDiffableDataSourceSnapshot<SectionLayoutKind, ItemKind>!

	/// The next page url of the pagination.
	var nextPageURL: String?

	/// Whether a fetch request is currently in progress.
	var isRequestInProgress: Bool = false

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
		if !self.seasonIdentities.isEmpty {
			self.endFetch()
		} else {
			Task { [weak self] in
				guard let self = self else { return }
				await self.fetchSeasons()
			}
		}
	}

	// MARK: - Functions
	override func handleRefreshControl() {
		if self.showIdentity != nil {
			self.nextPageURL = nil
			Task { [weak self] in
				guard let self = self else { return }
				await self.fetchSeasons()
			}
		}
	}

	override func configureEmptyDataView() {
		self.emptyBackgroundView.configureImageView(image: .Empty.seasons)
		self.emptyBackgroundView.configureLabels(title: "No Seasons", detail: "This show doesn't have seasons yet. Please check back again later.")

		self.collectionView.backgroundView?.alpha = 0
	}

	/// Fades in and out the empty data view according to the number of rows.
	func toggleEmptyDataView() {
		if self.collectionView.numberOfItems == 0 {
			self.collectionView.backgroundView?.animateFadeIn()
		} else {
			self.collectionView.backgroundView?.animateFadeOut()
		}
	}

	func endFetch() {
		self.isRequestInProgress = false
		self.updateDataSource()
		self._prefersActivityIndicatorHidden = true
		self.toggleEmptyDataView()
		#if DEBUG
		#if !targetEnvironment(macCatalyst)
		self.refreshControl?.endRefreshing()
		self.refreshControl?.attributedTitle = NSAttributedString(string: "Pull to refresh the seasons.")
		#endif
		#endif
	}

	/// Fetch seasons for the current show.
	func fetchSeasons() async {
		guard !self.isRequestInProgress else {
			return
		}

		// Set request in progress
		self.isRequestInProgress = true

		#if !targetEnvironment(macCatalyst)
		self.refreshControl?.attributedTitle = NSAttributedString(string: "Refreshing seasons...")
		#endif

		do {
			guard let showIdentity = self.showIdentity else { return }
			let seasonIdentityResponse = try await KService.getSeasons(forShow: showIdentity, next: self.nextPageURL).value

			// Reset data if necessary
			if self.nextPageURL == nil {
				self.seasonIdentities = []
			}

			// Save next page url and append new data
			self.nextPageURL = seasonIdentityResponse.next
			self.seasonIdentities.append(contentsOf: seasonIdentityResponse.data)
			self.seasonIdentities.removeDuplicates()
		} catch {
			print(error.localizedDescription)
		}

		self.endFetch()
	}

	// MARK: - SectionFetchable
	func extractIdentity<Element>(from item: ItemKind) -> Element? where Element: KurozoraItem {
		switch item {
		case .seasonIdentity(let id): return id as? Element
		}
	}

	// MARK: - Segue
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		switch segue.identifier {
		case R.segue.seasonsListCollectionViewController.episodeSegue.identifier:
			guard let episodesListCollectionViewController = segue.destination as? EpisodesListCollectionViewController else { return }
			guard let season = sender as? Season else { return }
			episodesListCollectionViewController.season = season
			episodesListCollectionViewController.episodesListFetchType = .season
		default: break
		}
	}
}

// MARK: - SectionLayoutKind
extension SeasonsListCollectionViewController {
	/// List of season section layout kind.
	///
	/// ```swift
	/// case main = 0
	/// ```
	enum SectionLayoutKind: Int, CaseIterable {
		case main = 0
	}
}

// MARK: - ItemKind
extension SeasonsListCollectionViewController {
	/// List of item layout kind.
	enum ItemKind: Hashable {
		// MARK: - Cases
		/// Indicates the item kind contains a `SeasonIdentity` object.
		case seasonIdentity(_: SeasonIdentity)

		// MARK: - Functions
		func hash(into hasher: inout Hasher) {
			switch self {
			case .seasonIdentity(let seasonIdentity):
				hasher.combine(seasonIdentity)
			}
		}

		static func == (lhs: ItemKind, rhs: ItemKind) -> Bool {
			switch (lhs, rhs) {
			case (.seasonIdentity(let seasonIdentity1), .seasonIdentity(let seasonIdentity2)):
				return seasonIdentity1 == seasonIdentity2
			}
		}
	}
}

// MARK: - Cell Configuration
extension SeasonsListCollectionViewController {
	func getConfiguredSeasonCell() -> UICollectionView.CellRegistration<SeasonLockupCollectionViewCell, ItemKind> {
		return UICollectionView.CellRegistration<SeasonLockupCollectionViewCell, ItemKind>(cellNib: SeasonLockupCollectionViewCell.nib) { [weak self] smallLockupCollectionViewCell, indexPath, itemKind in
			guard let self = self else { return }

			switch itemKind {
			case .seasonIdentity:
				let season: Season? = self.fetchModel(at: indexPath)

				if season == nil, let section = self.snapshot.sectionIdentifier(containingItem: itemKind), !self.isFetchingSection.contains(section) {
					Task {
						await self.fetchSectionIfNeeded(SeasonResponse.self, SeasonIdentity.self, at: indexPath, itemKind: itemKind)
					}
				}

				smallLockupCollectionViewCell.configure(using: season)
			}
		}
	}
}
