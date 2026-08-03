//
//  UserReviewsListCollectionViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 19/03/2024.
//  Copyright © 2024 Kurozora. All rights reserved.
//

import UIKit
import KurozoraKit
import AVFoundation

class UserReviewsListCollectionViewController: KCollectionViewController, SectionFetchable, TypedSegueHandling {
	// MARK: - Enums
	enum SegueIdentifiers: String, SegueIdentifier {
		case characterDetailsSegue
		case episodeDetailsSegue
		case gameDetailsSegue
		case literatureDetailsSegue
		case personDetailsSegue
		case showDetailsSegue
		case songDetailsSegue
		case studioDetailsSegue
	}

	// MARK: - Properties
	var user: User?
	var reviews: [Review] = []

	var cache: [IndexPath: KurozoraItem] = [:]
	var isFetchingSection: Set<SectionLayoutKind> = []
	var isFetchingType: Set<String> = []
	var fetchGeneration: Int = 0

	var dataSource: UICollectionViewDiffableDataSource<SectionLayoutKind, ItemKind>! = nil
	var snapshot: NSDiffableDataSourceSnapshot<SectionLayoutKind, ItemKind>! = nil

	/// The object that provides the interface to control the player’s transport behavior.
	var player: AVPlayer?

	/// The index path of the song that's currently playing.
	var currentPlayerIndexPath: IndexPath?

	/// The next page url of the pagination.
	var nextPageCursor: PageCursor?

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
		return _prefersActivityIndicatorHidden
	}

	// MARK: - Views
	override func viewWillReload() {
		super.viewWillReload()

		self.handleRefreshControl()
	}

	override func viewDidLoad() {
		super.viewDidLoad()

		self.title = L10n.ratingsAndReviews

		#if DEBUG
		self._prefersRefreshControlDisabled = false
		#else
		self._prefersRefreshControlDisabled = true
		#endif

		// Add Refresh Control to Collection View
		#if !targetEnvironment(macCatalyst)
		self.refreshControl?.attributedTitle = NSAttributedString(string: L10n.pullToRefreshItems(L10n.reviews.lowercased(with: Locale.current)))
		#endif

		self.configureDataSource()

		// Fetch follow list.
		if !self.reviews.isEmpty {
			self.endFetch()
		} else {
			Task { [weak self] in
				guard let self = self else { return }
				await self.fetchReviews()
			}
		}
	}

	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)

		self.player?.pause()
	}

	// MARK: - Functions
	override func handleRefreshControl() {
		if self.user != nil {
			self.nextPageCursor = nil
			self.cache.removeAll()
			self.isFetchingType.removeAll()
			self.fetchGeneration += 1

			Task { [weak self] in
				guard let self = self else { return }
				await self.fetchReviews()
			}
		}
	}

	override func configureEmptyDataView() {
		let username = self.user?.attributes.username
		let titleString: String = L10n.noItemsTitle(L10n.reviews)
		let detailString: String = if self.user?.id == User.current?.id {
			L10n.reviewsEmptySelfDetail
		} else {
			L10n.reviewsEmptyOtherDetail(username ?? "")
		}

		self.emptyBackgroundView.configureImageView(image: .Empty.person3)
		self.emptyBackgroundView.configureLabels(title: titleString, detail: detailString)

		self.collectionView.backgroundView?.alpha = 0
	}

	/// Fades in and out the empty data view according to the number of sections.
	func toggleEmptyDataView() {
		if self.collectionView.numberOfSections == 0 {
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
		#endif
		#endif
	}

	/// Fetch the reviews list for the currently viewed profile.
	func fetchReviews() async {
		guard !self.isRequestInProgress else {
			return
		}

		// Set request in progress
		self.isRequestInProgress = true

		#if !targetEnvironment(macCatalyst)
		self.refreshControl?.attributedTitle = NSAttributedString(string: L10n.refreshingItems(L10n.reviews.lowercased(with: Locale.current)))
		#endif

		guard let user = self.user else { return }
		let userIdentity = UserIdentity(id: user.id)

		do {
			let reviewResponse = try await KService.reviews(forUser: userIdentity).cursor(self.nextPageCursor).limit(self.nextPageCursor != nil ? 100 : 25).response()

			// Reset data if necessary
			if self.nextPageCursor == nil {
				self.reviews = []
			}

			// Save next page url and append new data
			self.nextPageCursor = reviewResponse.nextCursor
			self.reviews.append(contentsOf: reviewResponse.data)
			self.reviews.removeDuplicates()
		} catch {
			print(error.localizedDescription)
		}

		self.endFetch()

		// Reset refresh controller title
		#if !targetEnvironment(macCatalyst)
		self.refreshControl?.attributedTitle = NSAttributedString(string: L10n.pullToRefreshItems(L10n.reviews.lowercased(with: Locale.current)))
		#endif
	}

	// MARK: - Segue
	override func makeDestination(for identifier: any SegueIdentifier) -> UIViewController? {
		guard let identifier = identifier as? SegueIdentifiers else { return nil }

		switch identifier {
		case .characterDetailsSegue: return CharacterDetailsCollectionViewController()
		case .gameDetailsSegue: return GameDetailsCollectionViewController()
		case .episodeDetailsSegue: return EpisodeDetailsCollectionViewController()
		case .literatureDetailsSegue: return LiteratureDetailsCollectionViewController()
		case .personDetailsSegue: return PersonDetailsCollectionViewController()
		case .showDetailsSegue: return ShowDetailsCollectionViewController()
		case .songDetailsSegue: return SongDetailsCollectionViewController()
		case .studioDetailsSegue: return StudioDetailsCollectionViewController()
		}
	}

	override func prepare(for identifier: any SegueIdentifier, destination: UIViewController, sender: Any?) {
		guard let identifier = identifier as? SegueIdentifiers else { return }

		switch identifier {
		case .characterDetailsSegue:
			guard let characterDetailsCollectionViewController = destination as? CharacterDetailsCollectionViewController else { return }
			guard let character = sender as? Character else { return }
			characterDetailsCollectionViewController.character = character
		case .gameDetailsSegue:
			guard let gameDetailCollectionViewController = destination as? GameDetailsCollectionViewController else { return }
			guard let game = sender as? Game else { return }
			gameDetailCollectionViewController.game = game
		case .episodeDetailsSegue:
			guard let episodeDetailsCollectionViewController = destination as? EpisodeDetailsCollectionViewController else { return }
			guard let episode = sender as? Episode else { return }
			episodeDetailsCollectionViewController.episode = episode
		case .literatureDetailsSegue:
			guard let literatureDetailCollectionViewController = destination as? LiteratureDetailsCollectionViewController else { return }
			guard let literature = sender as? Literature else { return }
			literatureDetailCollectionViewController.literature = literature
		case .personDetailsSegue:
			guard let personDetailsCollectionViewController = destination as? PersonDetailsCollectionViewController else { return }
			guard let person = sender as? Person else { return }
			personDetailsCollectionViewController.person = person
		case .showDetailsSegue:
			guard let showDetailsCollectionViewController = destination as? ShowDetailsCollectionViewController else { return }
			guard let show = sender as? Show else { return }
			showDetailsCollectionViewController.show = show
		case .songDetailsSegue:
			// Segue to song details
			guard let songDetailsCollectionViewController = destination as? SongDetailsCollectionViewController else { return }
			guard let song = sender as? Song else { return }
			songDetailsCollectionViewController.song = song
		case .studioDetailsSegue:
			// Segue to studio details
			guard let studioDetailsCollectionViewController = destination as? StudioDetailsCollectionViewController else { return }
			guard let studio = sender as? Studio else { return }
			studioDetailsCollectionViewController.studio = studio
		}
	}
}

// MARK: - SectionFetchable
extension UserReviewsListCollectionViewController {
	func extractIdentity<Element>(from item: ItemKind) -> Element? where Element: KurozoraItem {
		switch item {
		case .review(let review):
			if let identity = review.relationships?.shows?.data.first { return identity as? Element }
			if let identity = review.relationships?.games?.data.first { return identity as? Element }
			if let identity = review.relationships?.literatures?.data.first { return identity as? Element }
			if let identity = review.relationships?.episodes?.data.first { return identity as? Element }
			if let identity = review.relationships?.songs?.data.first { return identity as? Element }
			if let identity = review.relationships?.characters?.data.first { return identity as? Element }
			if let identity = review.relationships?.people?.data.first { return identity as? Element }
			if let identity = review.relationships?.studios?.data.first { return identity as? Element }
			return nil
		}
	}

	/// Fetches details for all uncached identities of a specific type across the section.
	///
	/// Unlike `fetchSectionIfNeeded`, this method preserves global index paths for
	/// heterogeneous sections where items reference different identity types.
	/// Uses `isFetchingType` (per-type) instead of `isFetchingSection` (per-section).
	func fetchReviewSectionIfNeeded<I: KurozoraRequestable, Identity: Fetchable>(_ response: I.Type, _ identityType: Identity.Type, at indexPath: IndexPath, itemKind: ItemKind) async where Identity.Response == I {
		guard self.cache[indexPath] == nil else { return }

		let typeKey = String(describing: Identity.self)
		guard !self.isFetchingType.contains(typeKey) else { return }
		self.isFetchingType.insert(typeKey)
		defer { self.isFetchingType.remove(typeKey) }

		let generation = self.fetchGeneration

		// Enumerate all items preserving global index
		let allItems = self.snapshot.itemIdentifiers(inSection: .main)
		let uncached: [(globalIndex: Int, identity: Identity)] = allItems
			.enumerated()
			.compactMap { globalIndex, item -> (Int, Identity)? in
				guard let identity: Identity = self.extractIdentity(from: item) else { return nil }
				let ip = IndexPath(item: globalIndex, section: indexPath.section)
				guard self.cache[ip] == nil else { return nil }
				return (globalIndex, identity)
			}

		guard !uncached.isEmpty else { return }

		let chunkSize = 25
		let chunks = uncached.chunked(into: chunkSize)

		do {
			for chunk in chunks {
				let identitiesToFetch = chunk.map { $0.identity }
				let fetchedResponse: I = try await KService.details(identitiesToFetch).response()

				// Bail if the snapshot was rebuilt
				guard generation == self.fetchGeneration else { return }

				let orderLookup = Dictionary(
					identitiesToFetch.enumerated().map { ($1.id, $0) },
					uniquingKeysWith: { first, _ in first }
				)
				let sorted = fetchedResponse.data.sorted {
					guard let l = orderLookup[$0.id], let r = orderLookup[$1.id] else { return false }
					return l < r
				}

				// Build lookup mapping identity ID to all global indexes (handles
				// duplicate reviews for the same model)
				var chunkLookup: [KurozoraItemID: [Int]] = [:]
				for entry in chunk {
					chunkLookup[entry.identity.id, default: []].append(entry.globalIndex)
				}
				for model in sorted {
					if let globalIndexes = chunkLookup[model.id] {
						for globalIndex in globalIndexes {
							self.cache[IndexPath(item: globalIndex, section: indexPath.section)] = model
						}
					}
				}

				let appleMusicIDs = sorted.compactMap { ($0 as? Song)?.attributes.amID }
				if !appleMusicIDs.isEmpty {
					_ = await MusicManager.shared.getSongs(for: appleMusicIDs)
				}

				self.setSectionNeedsUpdate(.main)
			}
		} catch {
			print("----- Fetch error for \(typeKey): \(error)")
		}
	}
}

// MARK: - SectionLayoutKind
extension UserReviewsListCollectionViewController {
	/// List of section layout kind.
	///
	/// ```swift
	/// case main = 0
	/// ```
	enum SectionLayoutKind: Int, CaseIterable {
		case main = 0
	}
}

// MARK: - ItemKind
extension UserReviewsListCollectionViewController {
	/// List of item layout kind.
	enum ItemKind: Hashable {
		// MARK: - Cases
		/// Indicates the item kind contains a `Review` object.
		case review(_: Review)

		// MARK: - Properties
		/// The associated review.
		var review: Review? {
			switch self {
			case .review(let review):
				return review
			}
		}

		// MARK: - Functions
		func hash(into hasher: inout Hasher) {
			switch self {
			case .review(let review):
				hasher.combine(review)
			}
		}

		static func == (lhs: ItemKind, rhs: ItemKind) -> Bool {
			switch (lhs, rhs) {
			case (.review(let review1), .review(let review2)):
				return review1 == review2
			}
		}
	}
}
