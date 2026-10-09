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

class ShowDetailsCollectionViewController: DetailsCollectionViewController, SectionFetchable, MusicResolving, TypedSegueHandling {
	// MARK: - Properties
	var showIdentity: ShowIdentity?

	/// The authenticated user's library state for the show.
	var libraryAttributes: LibraryAttributes?

	/// The cached library entry the screen presents while the show can't be fetched.
	var libraryEntry: LocalLibraryEntry?

	/// Returns the cached library entry for the given show.
	///
	/// - Parameter trackableID: The identifier of the show.
	///
	/// - Returns: The matching `LocalLibraryEntry`.
	private func cachedLibraryEntry(forTrackableID trackableID: String) -> LocalLibraryEntry? {
		guard let userSlug = User.current?.attributes.slug else { return nil }

		return LibraryStore.shared.entry(forTrackableID: trackableID, userSlug: userSlug, kind: .shows)
	}

	override var headerLibraryTarget: (any Libraryable)? {
		return self.show ?? self.libraryEntry
	}

	override func baseDetailHeaderCollectionViewCell(_ cell: BaseDetailHeaderCollectionViewCell, didPressShare sourceView: UIView?) {
		self.show?.openShareSheet(sourceView: sourceView, barButtonItem: nil)
	}

	var show: Show! {
		didSet {
			self.title = self.show.attributes.title
			if #available(iOS 26.0, macOS 26.0, tvOS 26.0, visionOS 26.0, watchOS 26.0, *) {
				self.navigationItem.largeTitle = ""
			}
			self.navigationTitleLabel.text = self.show.attributes.title
			self.showIdentity = ShowIdentity(id: self.show.id)
			AiringStatusStore.shared.record(name: self.show.attributes.status.name, colorHex: self.show.attributes.status.color)

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

	/// The show's editorial endorsement, fetched from its dedicated endpoint. `nil` until the
	/// fetch resolves, or when the show has none.
	var editorial: Editorial?

	/// The player that controls song playback.
	var player: AVPlayer?

	/// The index path of the song that is currently playing.
	var currentPlayerIndexPath: IndexPath?

	var cache: [ItemKind: KurozoraItem] = [:]
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
		guard let show = self.show else { return self.cachedMediaItems }

		var items: [MediaItem] = []
		if let posterURL = URL(string: show.attributes.poster?.url ?? "") {
			items.append(MediaItem(url: posterURL, type: .image, title: show.attributes.title, description: nil, author: nil, provider: nil, embedHTML: nil, extraInfo: nil))
		}
		if let bannerURL = URL(string: show.attributes.banner?.url ?? "") {
			items.append(MediaItem(url: bannerURL, type: .image, title: show.attributes.title, description: nil, author: nil, provider: nil, embedHTML: nil, extraInfo: nil))
		}
		return items
	}

	/// The poster and banner of the cached library entry.
	private var cachedMediaItems: [MediaItem] {
		guard let libraryEntry = self.libraryEntry else { return [] }

		let title = libraryEntry.trackable?.title
		var items: [MediaItem] = []

		if let posterURL = URL(string: libraryEntry.trackable?.posterURL ?? "") {
			items.append(MediaItem(url: posterURL, type: .image, title: title, description: nil, author: nil, provider: nil, embedHTML: nil, extraInfo: nil))
		}
		if let bannerURL = URL(string: libraryEntry.trackable?.bannerURL ?? "") {
			items.append(MediaItem(url: bannerURL, type: .image, title: title, description: nil, author: nil, provider: nil, embedHTML: nil, extraInfo: nil))
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
			case (.show(let show), .shows):
				return show.id.rawValue == trackableID
			case (.rateAndReview, .shows):
				return self.show?.id.rawValue == trackableID
			case (.showIdentity(let showIdentity), .shows):
				return showIdentity.id.rawValue == trackableID
			case (.relatedShow(let relatedShow), .shows):
				return relatedShow.show.id.rawValue == trackableID
			case (.relatedLiterature(let relatedLiterature), .literatures):
				return relatedLiterature.literature.id.rawValue == trackableID
			case (.relatedGame(let relatedGame), .games):
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
	func song(at indexPath: IndexPath) -> KKSong? {
		return self.showSongs[safe: indexPath.item]?.song
	}

	override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
		if motion == .motionShake, self.show?.attributes.title.lowercased().contains("log horizon") == true {
			if let url = URL.livingInTheDatabase {
				UIApplication.shared.kOpen(url)
			}
		}
	}

	// MARK: - Functions
	override func layoutContainerWidthDidChange() {
		self.remeasureCellHeightsNearViewport()
	}

	override func collectionViewWillLayout() {
		self.measureStaleCellHeightsNearViewport()
	}

	override func cellHeightEnvironmentDidChange() {
		self.remeasureAllCellHeights()
	}

	#if DEBUG
	override func measuredItemWidth(forSectionAt section: Int) -> CGFloat? {
		guard let sectionIdentifier = self.snapshot?.sectionIdentifiers[safe: section] else { return nil }

		return self.measuredItemWidth(forSection: sectionIdentifier)
	}
	#endif

	override func fetchDetails() async {
		guard let showIdentity = self.showIdentity else { return }

		let reviewIdentityRequest = KService.reviews(for: showIdentity).cursor(nil).limit(10)
		let editorialRequest = KService.editorial(for: showIdentity)
		let seasonIdentityRequest = KService.seasons(for: showIdentity).reversed(true).cursor(nil).limit(10)
		let castIdentityRequest = KService.cast(for: showIdentity).limit(10)
		let showSongRequest = KService.songs(for: showIdentity).limit(10)
		let studioIdentityRequest = KService.studios(for: showIdentity).limit(10)
		let moreByStudioRequest = KService.moreByStudio(for: showIdentity).limit(10)
		let relatedShowRequest = KService.relatedShows(for: showIdentity).limit(10)
		let relatedLiteraturesRequest = KService.relatedLiteratures(for: showIdentity).limit(10)
		let relatedGamesRequest = KService.relatedGames(for: showIdentity).limit(10)

		async let reviewIdentityResponse = reviewIdentityRequest.response()
		async let editorialResponse = editorialRequest.response()
		async let seasonIdentityResponse = seasonIdentityRequest.response()
		async let castIdentityResponse = castIdentityRequest.response()
		async let showSongResponse = showSongRequest.response()
		async let studioIdentityResponse = studioIdentityRequest.response()
		async let moreByStudioResponse = moreByStudioRequest.response()
		async let relatedShowResponse = relatedShowRequest.response()
		async let relatedLiteraturesResponse = relatedLiteraturesRequest.response()
		async let relatedGamesResponse = relatedGamesRequest.response()

		if self.show == nil {
			do {
				// Catalog-only — per-user state comes from the local store and overlays.
				let showResponse = try await KService.detail(showIdentity).embedded(false).response()
				self.show = showResponse.data.first

				// Donate suggestion to Siri.
				self.userActivity = self.show.openDetailUserActivity
			} catch {
				print(error.localizedDescription)
				self.libraryEntry = self.cachedLibraryEntry(forTrackableID: showIdentity.id.rawValue)
				self.title = self.libraryEntry?.trackable?.title
				self.navigationTitleLabel.text = self.libraryEntry?.trackable?.title
				self._prefersActivityIndicatorHidden = true
				self.updateDataSource()
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

		guard self.show != nil else { return }

		do {
			self.reviews = try await reviewIdentityResponse.data
			self.updateDataSource()
		} catch {
			print(error.localizedDescription)
		}

		do {
			self.editorial = try await editorialResponse.data.first
			self.updateDataSource()
		} catch {
			print(error.localizedDescription)
		}

		do {
			self.seasonIdentities = try await seasonIdentityResponse.data
			self.updateDataSource()
		} catch {
			print(error.localizedDescription)
		}

		do {
			self.castIdentities = try await castIdentityResponse.data
			self.updateDataSource()
		} catch {
			print(error.localizedDescription)
		}

		do {
			self.showSongs = try await showSongResponse.data

			let appleMusicIDs = self.showSongs.compactMap { $0.song.attributes.amID }
			_ = await MusicManager.shared.getSongs(for: appleMusicIDs)

			self.updateDataSource()
		} catch {
			print(error.localizedDescription)
		}

		do {
			self.studioIdentities = try await studioIdentityResponse.data
			self.updateDataSource()
		} catch {
			print(error.localizedDescription)
		}

		do {
			self.studioShowIdentities = try await moreByStudioResponse.data
			self.updateDataSource()
		} catch {
			print(error.localizedDescription)
		}

		do {
			self.relatedShows = try await relatedShowResponse.data
			self.updateDataSource()
		} catch {
			print(error.localizedDescription)
		}

		do {
			self.relatedLiteratures = try await relatedLiteraturesResponse.data
			self.updateDataSource()
		} catch {
			print(error.localizedDescription)
		}

		do {
			self.relatedGames = try await relatedGamesResponse.data
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
		if let show = self.show {
			return show.makeContextMenu(in: self, userInfo: [:], sourceView: nil, barButtonItem: self.moreBarButtonItem)
		}

		return self.libraryEntry?.makeContextMenu(in: self, userInfo: [:], sourceView: nil, barButtonItem: self.moreBarButtonItem)
	}

	override func rateItem(using rating: Double, description: String?) async throws(APIError) -> Double? {
		guard let show = self.show else { return nil }
		return try await show.rate(using: rating, description: description)
	}

	override func writeAReviewContext() -> ReviewEditorContext? {
		guard let show = self.show else { return nil }
		return ReviewEditorContext(kind: .show(show), rating: self.libraryAttributes?.rating, review: self.libraryAttributes?.review, note: self.libraryAttributes?.note, isSpoiler: self.libraryAttributes?.isSpoiler ?? false, recommendation: self.libraryAttributes?.recommendation)
	}

	/// Resolves the review backing a review cell, accounting for the editorial row that
	/// precedes the reviews in this controller's reviews section.
	override func review(at indexPath: IndexPath) -> Review? {
		guard let itemKind = self.dataSource.itemIdentifier(for: indexPath) else { return nil }

		switch itemKind {
		case .review(let review):
			return self.reviews.first { $0.id == review.id } ?? review
		default:
			return nil
		}
	}

	override func libraryStatusTarget(at indexPath: IndexPath, kind: LibraryKind) -> (any Libraryable)? {
		switch kind {
		case .shows:
			switch self.dataSource.sectionIdentifier(for: indexPath.section) {
			case .moreByStudio: return self.cachedItem(at: indexPath) as? Show
			case .relatedShows: return self.relatedShows[safe: indexPath.item]?.show
			default: return nil
			}
		case .literatures:
			return self.relatedLiteratures[safe: indexPath.item]?.literature
		case .games:
			return self.relatedGames[safe: indexPath.item]?.game
		}
	}

	override func didDeleteReview() {
		self.libraryAttributes?.rating = nil
		self.libraryAttributes?.review = nil
	}

	override func applyReviewRow(_ review: Review?, for reviewID: KurozoraItemID) {
		guard self.snapshot != nil else { return }

		let staleItem = self.snapshot.itemIdentifiers.first { item in
			switch item {
			case .review(let candidate):
				return candidate.id == reviewID
			default:
				return false
			}
		}

		guard let staleItem = staleItem else { return }

		if let review = review {
			if let index = self.reviews.firstIndex(where: { $0.id == reviewID }) {
				self.reviews[index] = review
			}

			self.snapshot.reconfigureItems([staleItem])
		} else {
			self.reviews.removeAll { $0.id == reviewID }

			let section = self.snapshot.sectionIdentifier(containingItem: staleItem)
			self.snapshot.deleteItems([staleItem])

			// An emptied section leaves with its row.
			if let section = section, self.snapshot.numberOfItems(inSection: section) == 0 {
				self.snapshot.deleteSections([section])
			}
		}

		if self.snapshot.indexOfSection(.reviews) != nil {
			self.setMeasuredItems(self.snapshot.itemIdentifiers(inSection: .reviews), for: .reviews)
		} else {
			self.removeMeasuredSections(notIn: self.snapshot.sectionIdentifiers)
		}

		if review != nil {
			self.measureCellHeights(of: [staleItem])
		}

		self.dataSource.apply(self.snapshot, animatingDifferences: review == nil)
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

// MARK: - Measurement
extension ShowDetailsCollectionViewController {
	func measuredItemWidth(for section: SectionLayoutKind, containerWidth: CGFloat) -> CGFloat? {
		switch section {
		case .reviews, .seasons, .cast, .songs, .studios, .moreByStudio, .relatedShows, .relatedLiteratures, .relatedGames:
			let columns = self.columnCount(forSection: section, width: containerWidth)

			return Layouts.itemWidth(columns: columns, containerWidth: containerWidth, isHorizontal: true)
		default:
			return nil
		}
	}

	func measurableItem(for itemKind: ItemKind, in _: SectionLayoutKind) -> CellHeightMeasurer.Item? {
		switch itemKind {
		case .review(let review):
			return ReviewCollectionViewCell.measurableItem(for: self.reviews.first { $0.id == review.id } ?? review)
		case .editorial(let editorial):
			return EditorialCollectionViewCell.measurableItem(for: editorial)
		case .seasonIdentity:
			return self.seasonMeasurableItem(for: itemKind)
		case .castIdentity:
			return self.castMeasurableItem(for: itemKind)
		case .showSong(let showSong):
			return MusicLockupCollectionViewCell.measurableItem(for: showSong)
		case .studioIdentity:
			return self.studioMeasurableItem(for: itemKind)
		case .showIdentity:
			return self.studioShowMeasurableItem(for: itemKind)
		case .relatedShow(let relatedShow):
			return SmallLockupCollectionViewCell.measurableItem(for: relatedShow)
		case .relatedLiterature(let relatedLiterature):
			return SmallLockupCollectionViewCell.measurableItem(for: relatedLiterature)
		case .relatedGame(let relatedGame):
			return GameLockupCollectionViewCell.measurableItem(for: relatedGame)
		default:
			return nil
		}
	}

	/// Returns the item that measures the given item's season cell.
	///
	/// - Parameter itemKind: The item whose cell is measured.
	///
	/// - Returns: The item that measures the cell.
	private func seasonMeasurableItem(for itemKind: ItemKind) -> CellHeightMeasurer.Item {
		let season: Season? = self.fetchModel(for: itemKind)

		guard let season = season else {
			return CellHeightMeasurer.Item(cellType: SeasonLockupCollectionViewCell.self, isSkeleton: true) { cell in
				cell.configure(using: nil as Season?)
			}
		}

		return SeasonLockupCollectionViewCell.measurableItem(for: season)
	}

	/// Returns the item that measures the given item's cast cell.
	///
	/// - Parameter itemKind: The item whose cell is measured.
	///
	/// - Returns: The item that measures the cell.
	private func castMeasurableItem(for itemKind: ItemKind) -> CellHeightMeasurer.Item {
		let cast: Cast? = self.fetchModel(for: itemKind)

		guard let cast = cast else {
			return CellHeightMeasurer.Item(cellType: CastCollectionViewCell.self, isSkeleton: true) { cell in
				cell.configure(using: nil as Cast?)
			}
		}

		return CastCollectionViewCell.measurableItem(for: cast)
	}

	/// Returns the item that measures the given item's studio cell.
	///
	/// - Parameter itemKind: The item whose cell is measured.
	///
	/// - Returns: The item that measures the cell.
	private func studioMeasurableItem(for itemKind: ItemKind) -> CellHeightMeasurer.Item {
		let studio: Studio? = self.fetchModel(for: itemKind)

		guard let studio = studio else {
			return CellHeightMeasurer.Item(cellType: StudioLockupCollectionViewCell.self, isSkeleton: true) { cell in
				cell.configure(using: nil as Studio?)
			}
		}

		return StudioLockupCollectionViewCell.measurableItem(for: studio)
	}

	/// Returns the item that measures the given item's more by studio cell.
	///
	/// - Parameter itemKind: The item whose cell is measured.
	///
	/// - Returns: The item that measures the cell.
	private func studioShowMeasurableItem(for itemKind: ItemKind) -> CellHeightMeasurer.Item {
		let show: Show? = self.fetchModel(for: itemKind)

		guard let show = show else {
			return CellHeightMeasurer.Item(cellType: SmallLockupCollectionViewCell.self, isSkeleton: true) { cell in
				cell.configure(using: nil as Show?)
			}
		}

		return SmallLockupCollectionViewCell.measurableItem(for: show)
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
}
