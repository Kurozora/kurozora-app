//
//  ShowDetailsCollectionViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 09/08/2018.
//  Copyright © 2018 Kurozora. All rights reserved.
//

import AVFoundation
import Combine
import Intents
import IntentsUI
import KurozoraKit
import UIKit

class ShowDetailsCollectionViewController: DetailsCollectionViewController, SectionFetchable, TypedSegueHandling {
	// MARK: - Properties
	var showIdentity: ShowIdentity?

	/// The authenticated user's library state for the show.
	var libraryAttributes: LibraryAttributes?

	var show: Show! {
		didSet {
			self.title = self.show.attributes.title
			if #available(iOS 26.0, macOS 26.0, tvOS 26.0, visionOS 26.0, watchOS 26.0, *) {
				self.navigationItem.largeTitle = ""
			}
			self.navigationTitleLabel.text = self.show.attributes.title
			self.showIdentity = ShowIdentity(id: self.show.id)

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

	var seasonIdentities: [SeasonIdentity] = []
	var relatedShows: [RelatedShow] = []
	var relatedLiteratures: [RelatedLiterature] = []
	var relatedGames: [RelatedGame] = []
	var castIdentities: [CastIdentity] = []
	var studioIdentities: [StudioIdentity] = []
	var studioShowIdentities: [ShowIdentity] = []
	var showSongs: [ShowSong] = []

	/// The player that controls song playback.
	var player: AVPlayer?

	/// The index path of the song that is currently playing.
	var currentPlayerIndexPath: IndexPath?

	private var firstCellSize: CGSize = .zero

	var cache: [IndexPath: KurozoraItem] = [:]
	var isFetchingSection: Set<SectionLayoutKind> = []

	/// The resolved Apple Music songs keyed by Apple Music identifier.
	var resolvedSongs: [Int: MKSong] = [:]

	/// Observes local library mutations to refresh the header.
	private var libraryObserver: LocalLibraryEntryObserver?

	/// Observes playback changes so visible song cells reflect the currently-playing song.
	private var playbackObserver: AnyCancellable?

	var dataSource: UICollectionViewDiffableDataSource<SectionLayoutKind, ItemKind>!
	var snapshot: NSDiffableDataSourceSnapshot<SectionLayoutKind, ItemKind>!

	// MARK: - Overridden Properties
	override var favoriteTarget: (any Libraryable)? { self.show }

	override var reminderTarget: (any Libraryable)? { self.show }

	override var emptyStateImage: UIImage? { .Empty.libraryAnime }
	override var emptyStateDetail: String { L10n.noDetailsYet(L10n.show.lowercased(with: .current)) }

	override var reviewDetailsSegueIdentifier: (any SegueIdentifier)? { SegueIdentifiers.reviewDetailsSegue }

	override var mediaItems: [MediaItem] {
		guard let show = self.show else { return [] }
		var items: [MediaItem] = []
		if let posterURL = URL(string: show.attributes.poster?.url ?? "") {
			items.append(MediaItem(url: posterURL, type: .image, title: show.attributes.title, description: nil, author: nil, provider: nil, embedHTML: nil, extraInfo: nil))
		}
		if let bannerURL = URL(string: show.attributes.banner?.url ?? "") {
			items.append(MediaItem(url: bannerURL, type: .image, title: show.attributes.title, description: nil, author: nil, provider: nil, embedHTML: nil, extraInfo: nil))
		}
		return items
	}

	// MARK: - Initializers
	func callAsFunction(with showID: KurozoraItemID) -> ShowDetailsCollectionViewController {
		let showDetailsCollectionViewController = ShowDetailsCollectionViewController()
		showDetailsCollectionViewController.showIdentity = ShowIdentity(id: showID)
		return showDetailsCollectionViewController
	}

	func callAsFunction(with show: Show) -> ShowDetailsCollectionViewController {
		let showDetailsCollectionViewController = ShowDetailsCollectionViewController()
		showDetailsCollectionViewController.show = show
		return showDetailsCollectionViewController
	}

	// MARK: - View Lifecycle
	override func viewDidLoad() {
		super.viewDidLoad()
		self.configureDataSource()
		self.configureNavigationItems()
		self.observeLibraryChanges()
		self.observePlaybackChanges()

		Task { [weak self] in
			guard let self = self else { return }
			await self.fetchDetails()
		}
	}

	/// Subscribes to local library mutations targeting this show and its related/more-by-studio items.
	private func observeLibraryChanges() {
		guard let slug = User.current?.attributes.slug else { return }

		self.libraryObserver = LocalLibraryEntryObserver(
			matching: LocalLibraryEntryObserver.matches(userSlug: slug),
			onChange: { [weak self] entry in
				guard let self = self else { return }
				self.handleLibraryEntryChange(trackableID: entry.trackableID, kind: entry.kind, isRemoval: false)
			},
			onRemove: { [weak self] removed in
				guard let self = self else { return }
				self.handleLibraryEntryChange(trackableID: removed.trackableID, kind: removed.kind, isRemoval: true)
			}
		)
	}

	/// Reapplies the header's overlay when the change targets this show, then reconfigures
	/// every item bound to the changed trackable identity.
	private func handleLibraryEntryChange(trackableID: String, kind: LibraryKind, isRemoval: Bool) {
		if kind == .shows, trackableID == (self.showIdentity?.id.rawValue ?? self.show?.id.rawValue) {
			if isRemoval {
				self.libraryAttributes = nil
			} else {
				self.applyLocalLibraryOverlay()
			}
			self.refreshTouchBarLibraryState()
		}
		self.reconfigureShowItems(forTrackableID: trackableID, kind: kind)
	}

	/// Reconfigures every item in the current snapshot — header, related shows/literatures/games,
	/// and studio shows — whose underlying model matches the given trackable identity.
	///
	/// No-ops if `updateDataSource()` hasn't produced a snapshot yet, or if the trackable
	/// identity isn't in it — reconfiguring an item that isn't present would trip a precondition.
	private func reconfigureShowItems(forTrackableID trackableID: String, kind: LibraryKind) {
		guard let dataSource = self.dataSource, var snapshot = self.snapshot else { return }
		let matchedItems = snapshot.itemIdentifiers.filter { item in
			switch (item, kind) {
			case (.show(let show, _), .shows):
				return show.id.rawValue == trackableID
			case (.showIdentity(let showIdentity, _), .shows):
				return showIdentity.id.rawValue == trackableID
			case (.relatedShow(let relatedShow, _), .shows):
				return relatedShow.show.id.rawValue == trackableID
			case (.relatedLiterature(let relatedLiterature, _), .literatures):
				return relatedLiterature.literature.id.rawValue == trackableID
			case (.relatedGame(let relatedGame, _), .games):
				return relatedGame.game.id.rawValue == trackableID
			default:
				return false
			}
		}
		guard !matchedItems.isEmpty else { return }
		snapshot.reconfigureItems(matchedItems)
		self.snapshot = snapshot
		dataSource.apply(snapshot, animatingDifferences: false)
	}

	/// Subscribes to playback changes so visible song cells reflect the currently playing song.
	private func observePlaybackChanges() {
		self.playbackObserver = Publishers.CombineLatest(MusicManager.shared.currentKKSongPublisher, MusicManager.shared.isPlayingPublisher)
			.receive(on: RunLoop.main)
			.sink { [weak self] _, _ in
				self?.refreshVisibleMusicCells()
			}
	}

	/// Refreshes the play button glyph and artwork of every visible song cell.
	private func refreshVisibleMusicCells() {
		for case let cell as MusicLockupCollectionViewCell in self.collectionView.visibleCells {
			guard
				let indexPath = self.collectionView.indexPath(for: cell),
				let song = self.showSongs[safe: indexPath.item]?.song
			else { continue }
			cell.updatePlayButton(for: song)
			cell.updateArtwork(for: song, resolvedSong: song.attributes.amID.flatMap { self.resolvedSongs[$0] })
		}
	}

	override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
		if motion == .motionShake, self.show?.attributes.title.lowercased().contains("log horizon") == true {
			if let url = URL.livingInTheDatabase {
				UIApplication.shared.kOpen(url)
			}
		}
	}

	// MARK: - Functions
	override func fetchDetails() async {
		guard let showIdentity = self.showIdentity else { return }

		if self.show == nil {
			do {
				// Catalog-only — per-user state comes from the local store and overlays.
				let showResponse = try await KService.detail(showIdentity).embedded(false).response()
				self.show = showResponse.data.first

				// Donate suggestion to Siri.
				self.userActivity = self.show.openDetailUserActivity
			} catch {
				print(error.localizedDescription)
			}

			self.applyLocalLibraryOverlay()
			self.configureNavBarButtons()
		} else {
			// Donate suggestion to Siri.
			self.userActivity = self.show.openDetailUserActivity

			self.applyLocalLibraryOverlay()
			self.updateDataSource()
			self.configureNavBarButtons()
		}

		do {
			let reviewIdentityResponse = try await KService.reviews(for: showIdentity).cursor(nil).limit(10).response()
			self.reviews = reviewIdentityResponse.data
			self.updateDataSource()
		} catch {
			print(error.localizedDescription)
		}

		do {
			let seasonIdentityResponse = try await KService.seasons(for: showIdentity).reversed(true).cursor(nil).limit(10).response()
			self.seasonIdentities = seasonIdentityResponse.data
			self.updateDataSource()
		} catch {
			print(error.localizedDescription)
		}

		do {
			let castIdentityResponse = try await KService.cast(for: showIdentity).limit(10).response()
			self.castIdentities = castIdentityResponse.data
			self.updateDataSource()
		} catch {
			print(error.localizedDescription)
		}

		do {
			let showSongResponse = try await KService.songs(for: showIdentity).limit(10).response()
			self.showSongs = showSongResponse.data

			let appleMusicIDs = self.showSongs.compactMap { $0.song.attributes.amID }
			_ = await MusicManager.shared.getSongs(for: appleMusicIDs)

			self.updateDataSource()
		} catch {
			print(error.localizedDescription)
		}

		do {
			let studioIdentityResponse = try await KService.studios(for: showIdentity).limit(10).response()
			self.studioIdentities = studioIdentityResponse.data
			self.updateDataSource()
		} catch {
			print(error.localizedDescription)
		}

		do {
			let showIdentityResponse = try await KService.moreByStudio(for: showIdentity).limit(10).response()
			self.studioShowIdentities = showIdentityResponse.data
			self.updateDataSource()
		} catch {
			print(error.localizedDescription)
		}

		do {
			let relatedShowResponse = try await KService.relatedShows(for: showIdentity).limit(10).response()
			self.relatedShows = relatedShowResponse.data
			self.updateDataSource()
		} catch {
			print(error.localizedDescription)
		}

		do {
			let relatedLiteraturesResponse = try await KService.relatedLiteratures(for: showIdentity).limit(10).response()
			self.relatedLiteratures = relatedLiteraturesResponse.data
			self.updateDataSource()
		} catch {
			print(error.localizedDescription)
		}

		do {
			let relatedGamesResponse = try await KService.relatedGames(for: showIdentity).limit(10).response()
			self.relatedGames = relatedGamesResponse.data
			self.updateDataSource()
		} catch {
			print(error.localizedDescription)
		}
	}

	/// Mirrors the local-store library state for this show into `libraryAttributes`.
	private func applyLocalLibraryOverlay() {
		guard let show = self.show,
		      let slug = User.current?.attributes.slug
		else { return }

		self.libraryAttributes = LibraryStore.shared.overlay(forTrackableID: show.id.rawValue, userSlug: slug, kind: .shows)
	}

	override func makeMoreMenu() -> UIMenu? {
		return self.show?.makeContextMenu(in: self, userInfo: [:], sourceView: nil, barButtonItem: self.moreBarButtonItem)
	}

	override func rateItem(using rating: Double, description: String?) async throws(APIError) -> Double? {
		guard let show = self.show else { return nil }
		return try await show.rate(using: rating, description: description)
	}

	override func writeAReviewContext() -> (kind: ReviewKind, rating: Double?, review: String?)? {
		guard let show = self.show else { return nil }
		return (.show(show), self.libraryAttributes?.rating, self.libraryAttributes?.review)
	}

	override func libraryStatusTarget(at indexPath: IndexPath, kind: LibraryKind) -> (any Libraryable)? {
		switch kind {
		case .shows:
			switch self.dataSource.sectionIdentifier(for: indexPath.section) {
			case .moreByStudio: return self.cache[indexPath] as? Show
			case .relatedShows: return self.relatedShows[safe: indexPath.item]?.show
			default: return nil
			}
		case .literatures:
			return self.relatedLiteratures[safe: indexPath.item]?.literature
		case .games:
			return self.relatedGames[safe: indexPath.item]?.game
		}
	}

	override func didDeleteReview(at indexPath: IndexPath?) {
		self.libraryAttributes?.rating = nil
		self.libraryAttributes?.review = nil
	}

	// MARK: - Segue
	override func makeDestination(for identifier: any SegueIdentifier) -> UIViewController? {
		guard let identifier = identifier as? SegueIdentifiers else { return nil }
		return self.makeDestinationVC(for: identifier)
	}

	override func prepare(for identifier: any SegueIdentifier, destination: UIViewController, sender: Any?) {
		guard let identifier = identifier as? SegueIdentifiers else { return }
		self.prepareDestination(for: identifier, destination: destination, sender: sender)
	}
}

// MARK: - CastCollectionViewCellDelegate
extension ShowDetailsCollectionViewController: CastCollectionViewCellDelegate {
	func castCollectionViewCell(_ cell: CastCollectionViewCell, didPressPersonButton button: UIButton) {
		self.show(.personDetailsSegue, sender: cell)
	}

	func castCollectionViewCell(_ cell: CastCollectionViewCell, didPressCharacterButton button: UIButton) {
		self.show(.characterDetailsSegue, sender: cell)
	}
}

// MARK: - TextViewCollectionViewCellDelegate
extension ShowDetailsCollectionViewController: TextViewCollectionViewCellDelegate {
	func textViewCollectionViewCell(_ cell: TextViewCollectionViewCell, didPressButton button: UIButton) {
		let synopsisViewController = SynopsisViewController()
		synopsisViewController.title = cell.textViewCollectionViewCellType.stringValue
		synopsisViewController.synopsis = self.show.attributes.synopsis

		let kNavigationController = KNavigationController(rootViewController: synopsisViewController)
		kNavigationController.modalPresentationStyle = .formSheet

		self.present(kNavigationController, animated: true)
	}
}

// MARK: - MusicLockupCollectionViewCellDelegate
extension ShowDetailsCollectionViewController: MusicLockupCollectionViewCellDelegate {
	func showButtonPressed(_ sender: UIButton, indexPath: IndexPath) {}

	func musicLockupCollectionViewCell(_ cell: MusicLockupCollectionViewCell, didTapPlayButtonAt indexPath: IndexPath) {
		MusicManager.shared.play(kkSongs: self.showSongs.map { $0.song }, startingAt: indexPath.item)
	}

	/// Resolves and caches the Apple Music song for the given Kurozora song.
	///
	/// - Parameter song: The Kurozora song to resolve.
	func resolveMusicSong(_ song: KKSong) {
		guard let appleMusicID = song.attributes.amID, self.resolvedSongs[appleMusicID] == nil else { return }

		Task { [weak self] in
			self?.resolvedSongs[appleMusicID] = await MusicManager.shared.getSong(for: appleMusicID)
			self?.refreshVisibleMusicCells()
		}
	}
}
