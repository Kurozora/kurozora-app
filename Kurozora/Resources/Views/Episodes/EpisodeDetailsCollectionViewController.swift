//
//  EpisodeDetailsCollectionViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 26/04/2019.
//  Copyright © 2019 Kurozora. All rights reserved.
//

import KurozoraKit
import UIKit

class EpisodeDetailsCollectionViewController: DetailsCollectionViewController {
	// MARK: Enums
	enum SegueIdentifiers: String, SegueIdentifier {
		case castListSegue
		case reviewsListSegue
		case showDetailsSegue
		case seasonsListSegue
		case episodeDetailsSegue
		case episodesListSegue
		case personDetailsSegue
		case characterDetailsSegue
		case reviewDetailsSegue
	}

	// MARK: - Properties
	var episodeIdentity: EpisodeIdentity?
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
	override var emptyStateImage: UIImage { .Empty.episodes }

	override var emptyStateDetail: String { "This episode doesn't have details yet. Please check back again later." }

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
	}

	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		NotificationCenter.default.removeObserver(self, name: .KEpisodeWatchStatusDidUpdate, object: nil)
	}

	// MARK: - Functions
	override func fetchDetails() async {
		guard let episodeIdentity = self.episodeIdentity else { return }

		if self.episode == nil {
			do {
				let episodeResponse = try await KService.getDetails(forEpisode: episodeIdentity)
				self.episode = episodeResponse.data.first
			} catch {
				print("-----", error.localizedDescription)
			}

			self.configureNavBarButtons()
		} else {
			self.updateDataSource()
			self.configureNavBarButtons()
		}

		do {
			let reviewIdentityResponse = try await KService.getReviews(forEpisode: episodeIdentity, next: nil, limit: 10)
			self.reviews = reviewIdentityResponse.data
			self.updateDataSource()
		} catch {
			print("-----", error.localizedDescription)
		}

		do {
			let episodeResponse = try await KService.getSuggestions(forEpisode: episodeIdentity)
			self.suggestedEpisodes = episodeResponse.data
			self.updateDataSource()
		} catch {
			print("-----", error.localizedDescription)
		}
	}

	override func makeMoreMenu() -> UIMenu? {
		return self.episode?.makeContextMenu(in: self, userInfo: [:], sourceView: nil, barButtonItem: self.moreBarButtonItem)
	}

	override func rateItem(using rating: Double, description: String?) async throws(KKAPIError) -> Double? {
		guard let episode = self.episode else { return nil }
		return try await episode.rate(using: rating, description: description)
	}

	override func writeAReviewContext() -> (kind: ReviewTextEditor.Kind, rating: Double?, review: String?)? {
		guard let episode = self.episode else { return nil }
		return (.episode(episode), episode.attributes.givenRating, nil)
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

	override func didDeleteReview(at indexPath: IndexPath?) {
		self.episode?.attributes.givenRating = nil
		self.episode?.attributes.givenReview = nil
	}

	// MARK: - Segue
	override func makeDestination(for identifier: any SegueIdentifier) -> UIViewController? {
		guard let identifier = identifier as? SegueIdentifiers else { return nil }

		switch identifier {
		case .reviewsListSegue: return ReviewsListCollectionViewController()
		case .showDetailsSegue: return ShowDetailsCollectionViewController()
		case .seasonsListSegue: return SeasonsListCollectionViewController()
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
		case .showDetailsSegue:
			guard let showDetailsCollectionViewController = destination as? ShowDetailsCollectionViewController else { return }
			if let showIdentity = sender as? ShowIdentity {
				showDetailsCollectionViewController.showIdentity = showIdentity
			} else if let show = sender as? Show {
				showDetailsCollectionViewController.show = show
			}
		case .seasonsListSegue:
			guard let seasonsListCollectionViewController = destination as? SeasonsListCollectionViewController else { return }
			guard let show = sender as? Show else { return }
			seasonsListCollectionViewController.showIdentity = ShowIdentity(id: show.id)
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
		self.show(SegueIdentifiers.personDetailsSegue, sender: cell)
	}

	func castCollectionViewCell(_ cell: CastCollectionViewCell, didPressCharacterButton button: UIButton) {
		self.show(SegueIdentifiers.characterDetailsSegue, sender: cell)
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

		self.show(SegueIdentifiers.showDetailsSegue, sender: showIdentity)
	}

	func episodeLockupCollectionViewCell(_ cell: EpisodeLockupCollectionViewCell, didPressSeasonButton button: UIButton) async {
		guard let indexPath = self.collectionView.indexPath(for: cell) else { return }
		guard let seasonIdentity = self.suggestedEpisodes[indexPath.item].relationships?.seasons?.data.first else { return }

		self.show(SegueIdentifiers.episodesListSegue, sender: seasonIdentity)
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
