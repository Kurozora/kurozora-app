//
//  EpisodeDetailsCollectionViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 26/04/2019.
//  Copyright © 2019 Kurozora. All rights reserved.
//

import KurozoraKit
import UIKit

class EpisodeDetailsCollectionViewController: DetailsCollectionViewController, TypedSegueHandling {
	// MARK: Enums
	enum SegueIdentifiers: String, SegueIdentifier {
		case castListSegue
		case reviewsListSegue
		case showDetailsSegue
		case seasonsListSegue
		case topChartsSegue
		case episodeDetailsSegue
		case episodesListSegue
		case personDetailsSegue
		case characterDetailsSegue
		case reviewDetailsSegue
	}

	// MARK: - Properties
	var episodeIdentity: EpisodeIdentity?

	/// The authenticated user's rating state for the episode.
	var libraryAttributes: LibraryAttributes?

	/// The entity tag of the last applied reviews overlay.
	var reviewsOverlayETag: String?

	var episode: Episode! {
		didSet {
			self.title = self.episode.attributes.title
			if #available(iOS 26.0, macOS 26.0, tvOS 26.0, visionOS 26.0, watchOS 26.0, *) {
				self.navigationItem.largeTitle = ""
			}
			self.navigationTitleLabel.text = self.episode.attributes.title
			self.episodeIdentity = EpisodeIdentity(id: self.episode.id)

			self._prefersActivityIndicatorHidden = true
			#if targetEnvironment(macCatalyst)
			self.touchBar = nil
			#endif

			#if DEBUG
			#if !targetEnvironment(macCatalyst)
			self.refreshControl?.endRefreshing()
			#endif
			#endif
		}
	}

	var indexPath = IndexPath()

	var cast: [IndexPath: Cast] = [:]
	var castIdentities: [CastIdentity] = []

	var suggestedEpisodes: [Episode] = []

	var dataSource: UICollectionViewDiffableDataSource<SectionLayoutKind, ItemKind>!
	var snapshot: NSDiffableDataSourceSnapshot<SectionLayoutKind, ItemKind>!

	// MARK: - Overridden Properties
	override var emptyStateImage: UIImage? { .Empty.tvPhoto }
	override var emptyStateDetail: String { L10n.noDetailsYet(L10n.episode.lowercased(with: .current)) }

	override var reviewDetailsSegueIdentifier: (any SegueIdentifier)? { SegueIdentifiers.reviewDetailsSegue }

	override var mediaItems: [MediaItem] {
		guard let episode = self.episode else { return [] }
		var items: [MediaItem] = []
		if let posterURL = URL(string: episode.attributes.poster?.url ?? "") {
			items.append(MediaItem(url: posterURL, type: .image, title: episode.attributes.title, description: nil, author: nil, provider: nil, embedHTML: nil, extraInfo: nil))
		}
		if let bannerURL = URL(string: episode.attributes.banner?.url ?? "") {
			items.append(MediaItem(url: bannerURL, type: .image, title: episode.attributes.title, description: nil, author: nil, provider: nil, embedHTML: nil, extraInfo: nil))
		}
		return items
	}

	// MARK: - Initializers
	func callAsFunction(with episodeID: KurozoraItemID) -> EpisodeDetailsCollectionViewController {
		let episodeDetailsCollectionViewController = EpisodeDetailsCollectionViewController()
		episodeDetailsCollectionViewController.episodeIdentity = EpisodeIdentity(id: episodeID)
		return episodeDetailsCollectionViewController
	}

	func callAsFunction(with episode: Episode) -> EpisodeDetailsCollectionViewController {
		let episodeDetailsCollectionViewController = EpisodeDetailsCollectionViewController()
		episodeDetailsCollectionViewController.episode = episode
		return episodeDetailsCollectionViewController
	}

	// MARK: - View Lifecycle
	override func viewDidLoad() {
		super.viewDidLoad()

		self.configureDataSource()
		self.configureNavigationItems()

		Task { [weak self] in
			guard let self = self else { return }
			await self.fetchDetails()
		}
	}

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		NotificationCenter.default.addObserver(self, selector: #selector(self.handleEpisodeWatchStatusDidUpdate(_:)), name: .KEpisodeWatchStatusDidUpdate, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(self.handleUserStateDidChangeRemotely(_:)), name: .KUserStateDidChangeRemotely, object: nil)
	}

	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		NotificationCenter.default.removeObserver(self, name: .KEpisodeWatchStatusDidUpdate, object: nil)
		NotificationCenter.default.removeObserver(self, name: .KUserStateDidChangeRemotely, object: nil)
	}

	/// Re-fetches the user overlays when another device or the website changes the user's state.
	@objc func handleUserStateDidChangeRemotely(_ notification: NSNotification) {
		Task { @MainActor [weak self] in
			guard let self = self else { return }
			await self.fetchUserOverlays()
			self.configureNavBarButtons()
		}
	}

	// MARK: - Functions
	override func fetchDetails() async {
		guard let episodeIdentity = self.episodeIdentity else { return }

		if self.episode == nil {
			do {
				let episodeResponse = try await KService.detail(episodeIdentity).response()
				self.episode = episodeResponse.data.first
			} catch {
				print("-----", error.localizedDescription)
			}

			self.configureNavBarButtons()
		} else {
			self.updateDataSource()
			self.configureNavBarButtons()
		}

		await self.fetchUserOverlays()

		do {
			let reviewIdentityResponse = try await KService.reviews(for: episodeIdentity).cursor(nil).limit(10).response()
			self.reviews = reviewIdentityResponse.data
			self.updateDataSource()
		} catch {
			print("-----", error.localizedDescription)
		}

		do {
			let episodeResponse = try await KService.suggestions(for: episodeIdentity).response()
			let suggestedIdentities = episodeResponse.data
			let detailedResponse = try await KService.details(suggestedIdentities).response()
			self.suggestedEpisodes = detailedResponse.data
			self.updateDataSource()
		} catch {
			print("-----", error.localizedDescription)
		}
	}

	/// Fetches the auth user's watched and review overlays for the current episode.
	private func fetchUserOverlays() async {
		guard
			let episodeID = self.episode?.id,
			let userID = User.current?.id
		else { return }
		let userIdentity = UserIdentity(id: userID)

		do {
			let requestedIDs = [episodeID.rawValue]
			let cachedETag = await WatchedStore.shared.etag(forRequestedIDs: requestedIDs)
			let overlayResult = try await KService
				.watchedOverlay(forUser: userIdentity, episodes: [episodeID])
				.response(ifNoneMatch: cachedETag)

			if case .modified(let watchedResponse, let etag) = overlayResult {
				await WatchedStore.shared.apply(watchedResponse.data, requestedIDs: requestedIDs)
				await WatchedStore.shared.setETag(etag, forRequestedIDs: requestedIDs)
			}
		} catch {
			print("watchedOverlay fetch failed: \(error.localizedDescription)")
		}

		do {
			let overlayResult = try await KService
				.reviewsOverlay(forUser: userIdentity, kind: .episodes, itemIDs: [episodeID])
				.response(ifNoneMatch: self.reviewsOverlayETag)

			if case .modified(let response, let etag) = overlayResult {
				let reviewEntry = response.data.first?.attributes
				var libraryAttributes = self.libraryAttributes ?? LibraryAttributes()
				libraryAttributes.rating = reviewEntry?.score
				libraryAttributes.review = reviewEntry?.description
				libraryAttributes.note = try? await KService
					.notesOverlay(forUser: userIdentity, kind: .episodes, itemIDs: [episodeID])
					.response().data.first?.attributes.body
				libraryAttributes.isSpoiler = reviewEntry?.isSpoiler
				libraryAttributes.recommendation = reviewEntry?.recommendation
				self.libraryAttributes = libraryAttributes
				self.reviewsOverlayETag = etag
			}
		} catch {
			print("reviewsOverlay fetch failed: \(error.localizedDescription)")
		}

		await MainActor.run { [weak self] in
			self?.updateDataSource()
		}
	}

	override func makeMoreMenu() -> UIMenu? {
		return self.episode?.makeContextMenu(in: self, userInfo: [:], sourceView: nil, barButtonItem: self.moreBarButtonItem)
	}

	override func rateItem(using rating: Double, description: String?) async throws(APIError) -> Double? {
		guard let episode = self.episode else { return nil }
		return try await episode.rate(using: rating, description: description)
	}

	override func writeAReviewContext() -> ReviewEditorContext? {
		guard let episode = self.episode else { return nil }
		return ReviewEditorContext(kind: .episode(episode), rating: self.libraryAttributes?.rating, review: self.libraryAttributes?.review, note: self.libraryAttributes?.note, isSpoiler: self.libraryAttributes?.isSpoiler ?? false, recommendation: self.libraryAttributes?.recommendation)
	}

	override func baseDetailHeaderCollectionViewCell(_ cell: BaseDetailHeaderCollectionViewCell, didPressStatus button: UIButton) async {
		guard await WorkflowController.shared.isSignedIn() else { return }

		button.isEnabled = false
		await self.episode?.updateWatchStatus(userInfo: ["indexPath": self.indexPath])
		button.isEnabled = true
	}

	@objc func handleEpisodeWatchStatusDidUpdate(_ notification: NSNotification) {
		DispatchQueue.main.async { [weak self] in
			guard let self = self else { return }

			if let indexPath = notification.userInfo?["indexPath"] as? IndexPath, let selectedEpisode = self.dataSource.itemIdentifier(for: indexPath) {
				var newSnapshot = self.dataSource.snapshot()
				newSnapshot.reloadItems([selectedEpisode])
				self.dataSource.apply(newSnapshot)
			} else {
				self.snapshot.reloadSections([.header])
			}

			self.configureNavBarButtons()
		}
	}

	override func didDeleteReview() {
		self.libraryAttributes?.rating = nil
		self.libraryAttributes?.review = nil
	}

	// MARK: - Segue
	override func makeDestination(for identifier: any SegueIdentifier) -> UIViewController? {
		guard let identifier = identifier as? SegueIdentifiers else { return nil }

		switch identifier {
		case .reviewsListSegue: return ReviewsListCollectionViewController()
		case .showDetailsSegue: return ShowDetailsCollectionViewController()
		case .seasonsListSegue: return SeasonsListCollectionViewController()
		case .topChartsSegue: return EpisodesListCollectionViewController()
		case .episodeDetailsSegue: return EpisodeDetailsCollectionViewController()
		case .episodesListSegue: return EpisodesListCollectionViewController()
		case .castListSegue: return CastListCollectionViewController()
		case .characterDetailsSegue: return CharacterDetailsCollectionViewController()
		case .personDetailsSegue: return PersonDetailsCollectionViewController()
		case .reviewDetailsSegue: return KNavigationController(rootViewController: ReviewDetailsCollectionViewController())
		}
	}

	override func prepare(for identifier: any SegueIdentifier, destination: UIViewController, sender: Any?) {
		guard let identifier = identifier as? SegueIdentifiers else { return }

		switch identifier {
		case .reviewsListSegue:
			guard let reviewsCollectionViewController = destination as? ReviewsListCollectionViewController else { return }
			reviewsCollectionViewController.listType = .episode(self.episode)
			reviewsCollectionViewController.givenRating = self.libraryAttributes?.rating
			reviewsCollectionViewController.givenReview = self.libraryAttributes?.review
			reviewsCollectionViewController.givenNote = self.libraryAttributes?.note
			reviewsCollectionViewController.givenIsSpoiler = self.libraryAttributes?.isSpoiler ?? false
			reviewsCollectionViewController.givenRecommendation = self.libraryAttributes?.recommendation
		case .showDetailsSegue:
			guard let showDetailsCollectionViewController = destination as? ShowDetailsCollectionViewController else { return }
			if let showIdentity = sender as? ShowIdentity {
				showDetailsCollectionViewController.showIdentity = showIdentity
			} else if let show = sender as? Show {
				showDetailsCollectionViewController.show = show
			}
		case .seasonsListSegue:
			guard let seasonsListCollectionViewController = destination as? SeasonsListCollectionViewController else { return }
			guard let showIdentity = sender as? ShowIdentity else { return }
			seasonsListCollectionViewController.showIdentity = showIdentity
		case .topChartsSegue:
			guard let episodesListCollectionViewController = destination as? EpisodesListCollectionViewController else { return }
			episodesListCollectionViewController.episodesListFetchType = .charts
		case .episodeDetailsSegue:
			guard let episodeDetailsCollectionViewController = destination as? EpisodeDetailsCollectionViewController else { return }
			episodeDetailsCollectionViewController.episode = sender as? Episode
		case .episodesListSegue:
			guard let episodesListCollectionViewController = destination as? EpisodesListCollectionViewController else { return }
			guard let seasonIdentity = sender as? SeasonIdentity else { return }
			episodesListCollectionViewController.seasonIdentity = seasonIdentity
			episodesListCollectionViewController.episodesListFetchType = .season
		case .castListSegue: break
		case .characterDetailsSegue: break
		case .personDetailsSegue: break
		case .reviewDetailsSegue:
			guard
				let navigationController = destination as? KNavigationController,
				let reviewDetailsCollectionViewController = navigationController.viewControllers.first as? ReviewDetailsCollectionViewController,
				let review = sender as? Review
			else { return }
			navigationController.modalPresentationStyle = .formSheet
			reviewDetailsCollectionViewController.review = review
		}
	}
}

// MARK: - CastCollectionViewCellDelegate
extension EpisodeDetailsCollectionViewController: CastCollectionViewCellDelegate {
	func castCollectionViewCell(_ cell: CastCollectionViewCell, didPressPersonButton button: UIButton) {
		self.show(.personDetailsSegue, sender: cell)
	}

	func castCollectionViewCell(_ cell: CastCollectionViewCell, didPressCharacterButton button: UIButton) {
		self.show(.characterDetailsSegue, sender: cell)
	}
}

// MARK: - EpisodeLockupCollectionViewCellDelegate
extension EpisodeDetailsCollectionViewController: EpisodeLockupCollectionViewCellDelegate {
	func episodeLockupCollectionViewCell(_ cell: EpisodeLockupCollectionViewCell, didPressWatchStatusButton button: UIButton) async {
		let signedIn = await WorkflowController.shared.isSignedIn(on: self)
		guard signedIn else { return }
		guard let indexPath = self.collectionView.indexPath(for: cell) else { return }

		cell.watchStatusButton.isEnabled = false
		let suggestedEpisode = self.suggestedEpisodes[indexPath.item]
		await suggestedEpisode.updateWatchStatus(userInfo: ["indexPath": indexPath])
		cell.watchStatusButton.isEnabled = true

		if suggestedEpisode.id == self.episode.id {
			self.configureNavBarButtons()
		}
	}

	func episodeLockupCollectionViewCell(_ cell: EpisodeLockupCollectionViewCell, didPressShowButton button: UIButton) async {
		guard let indexPath = self.collectionView.indexPath(for: cell) else { return }
		guard let showIdentity = self.suggestedEpisodes[indexPath.item].relationships?.shows?.data.first else { return }

		self.show(.showDetailsSegue, sender: showIdentity)
	}

	func episodeLockupCollectionViewCell(_ cell: EpisodeLockupCollectionViewCell, didPressSeasonButton button: UIButton) async {
		guard let indexPath = self.collectionView.indexPath(for: cell) else { return }
		guard let seasonIdentity = self.suggestedEpisodes[indexPath.item].relationships?.seasons?.data.first else { return }

		self.show(.episodesListSegue, sender: seasonIdentity)
	}
}

// MARK: - TextViewCollectionViewCellDelegate
extension EpisodeDetailsCollectionViewController: TextViewCollectionViewCellDelegate {
	func textViewCollectionViewCell(_ cell: TextViewCollectionViewCell, didPressButton button: UIButton) {
		let synopsisViewController = SynopsisViewController()
		synopsisViewController.title = cell.textViewCollectionViewCellType.stringValue
		synopsisViewController.synopsis = self.episode.attributes.synopsis

		let kNavigationController = KNavigationController(rootViewController: synopsisViewController)
		kNavigationController.modalPresentationStyle = .formSheet

		self.present(kNavigationController, animated: true)
	}
}

extension EpisodeDetailsCollectionViewController {
	enum SectionLayoutKind: Int, CaseIterable {
		// MARK: - Cases
		case header = 0
		case badge
		case synopsis
		case rating
		case rateAndReview
		case reviews
		case information
		case cast
		case suggestedEpisodes
		case sosumi

		// MARK: - Properties
		/// The string value of a section type.
		var stringValue: String {
			switch self {
			case .header:
				return L10n.header
			case .badge:
				return L10n.badges
			case .synopsis:
				return L10n.synopsis
			case .rating:
				return L10n.ratingsAndReviews
			case .rateAndReview:
				return ""
			case .reviews:
				return ""
			case .information:
				return L10n.information
			case .cast:
				return L10n.cast
			case .suggestedEpisodes:
				return L10n.seeAlso
			case .sosumi:
				return L10n.copyright
			}
		}

		/// The string value of a section type segue identifier.
		var segueIdentifier: SegueIdentifiers? {
			switch self {
			case .header, .badge, .synopsis, .rateAndReview, .reviews, .information, .suggestedEpisodes, .sosumi:
				return nil
			case .rating:
				return .reviewsListSegue
			case .cast:
				return .castListSegue
			}
		}
	}

	/// List of available item kind types.
	enum ItemKind: Hashable {
		// MARK: - Cases
		/// An item kind that contains an `Episode` object.
		case episode(_: Episode, id: UUID = UUID())

		/// An item kind that contains a `Review` object.
		case review(_: Review, id: UUID = UUID())

		/// An item kind that contains a `CastIdentity` object.
		case castIdentity(_: CastIdentity, id: UUID = UUID())

		// MARK: - Functions
		func hash(into hasher: inout Hasher) {
			switch self {
			case .episode(let episode, let id):
				hasher.combine(episode)
				hasher.combine(id)
			case .review(let review, let id):
				hasher.combine(review)
				hasher.combine(id)
			case .castIdentity(let castIdentity, let id):
				hasher.combine(castIdentity)
				hasher.combine(id)
			}
		}

		static func == (lhs: ItemKind, rhs: ItemKind) -> Bool {
			switch (lhs, rhs) {
			case (.episode(let episode1, let id1), .episode(let episode2, let id2)):
				return episode1 == episode2 && id1 == id2
			case (.review(let review1, let id1), .review(let review2, let id2)):
				return review1 == review2 && id1 == id2
			case (.castIdentity(let castIdentity1, let id1), .castIdentity(let castIdentity2, let id2)):
				return castIdentity1 == castIdentity2 && id1 == id2
			default:
				return false
			}
		}
	}
}
