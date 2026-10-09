//
//  LiteratureDetailsCollectionViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 01/02/2023.
//  Copyright © 2023 Kurozora. All rights reserved.
//

import AVFoundation
import Intents
import IntentsUI
import KurozoraKit
import UIKit

class LiteratureDetailsCollectionViewController: DetailsCollectionViewController, SectionFetchable, TypedSegueHandling {
	// MARK: - Properties
	var literatureIdentity: LiteratureIdentity?

	/// The authenticated user's library state for the literature.
	var libraryAttributes: LibraryAttributes?

	/// The cached library entry the screen presents while the literature can't be fetched.
	var libraryEntry: LocalLibraryEntry?

	override var headerLibraryTarget: (any Libraryable)? {
		return self.literature ?? self.libraryEntry
	}

	/// Returns the cached library entry for the given literature.
	///
	/// - Parameter trackableID: The identifier of the literature.
	///
	/// - Returns: The matching `LocalLibraryEntry`.
	private func cachedLibraryEntry(forTrackableID trackableID: String) -> LocalLibraryEntry? {
		guard let userSlug = User.current?.attributes.slug else { return nil }

		return LibraryStore.shared.entry(forTrackableID: trackableID, userSlug: userSlug, kind: .literatures)
	}

	var literature: Literature! {
		didSet {
			self.title = self.literature.attributes.title
			if #available(iOS 26.0, macOS 26.0, tvOS 26.0, visionOS 26.0, watchOS 26.0, *) {
				self.navigationItem.largeTitle = ""
			}
			self.navigationTitleLabel.text = self.literature.attributes.title
			self.literatureIdentity = LiteratureIdentity(id: self.literature.id)
			AiringStatusStore.shared.record(name: self.literature.attributes.status.name, colorHex: self.literature.attributes.status.color)

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

	var relatedLiteratures: [RelatedLiterature] = []
	var relatedShows: [RelatedShow] = []
	var relatedGames: [RelatedGame] = []
	var castIdentities: [CastIdentity] = []
	var studioIdentities: [StudioIdentity] = []
	var studioLiteratureIdentities: [LiteratureIdentity] = []

	/// The literature's editorial endorsement, fetched from its dedicated endpoint. `nil` until
	/// the fetch resolves, or when the literature has none.
	var editorial: Editorial?

	var cache: [ItemKind: KurozoraItem] = [:]
	var isFetchingSection: Set<SectionLayoutKind> = []

	/// Observes local library mutations to refresh the header.
	private var libraryObserver: LocalLibraryEntryObserver?

	var dataSource: UICollectionViewDiffableDataSource<SectionLayoutKind, ItemKind>!
	var snapshot: NSDiffableDataSourceSnapshot<SectionLayoutKind, ItemKind>!

	// MARK: - Overridden Properties
	override var favoriteTarget: (any Libraryable)? { self.literature }

	// TODO: Enable once reminders are supported for Literature.
//	override var reminderTarget: (any Libraryable)? { self.literature }

	override var emptyStateImage: UIImage? { .Empty.libraryManga }
	override var emptyStateDetail: String { L10n.noDetailsYet(L10n.literature.lowercased(with: .current)) }

	override var reviewDetailsSegueIdentifier: (any SegueIdentifier)? { SegueIdentifiers.reviewDetailsSegue }

	override var mediaItems: [MediaItem] {
		guard let literature = self.literature else { return self.cachedMediaItems }

		var items: [MediaItem] = []
		if let posterURL = URL(string: literature.attributes.poster?.url ?? "") {
			items.append(MediaItem(url: posterURL, type: .image, title: literature.attributes.title, description: nil, author: nil, provider: nil, embedHTML: nil, extraInfo: nil))
		}
		if let bannerURL = URL(string: literature.attributes.banner?.url ?? "") {
			items.append(MediaItem(url: bannerURL, type: .image, title: literature.attributes.title, description: nil, author: nil, provider: nil, embedHTML: nil, extraInfo: nil))
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
	func callAsFunction(with literatureID: KurozoraItemID) -> LiteratureDetailsCollectionViewController {
		let literatureDetailsCollectionViewController = LiteratureDetailsCollectionViewController()
		literatureDetailsCollectionViewController.literatureIdentity = LiteratureIdentity(id: literatureID)
		return literatureDetailsCollectionViewController
	}

	func callAsFunction(with literature: Literature) -> LiteratureDetailsCollectionViewController {
		let literatureDetailsCollectionViewController = LiteratureDetailsCollectionViewController()
		literatureDetailsCollectionViewController.literature = literature
		return literatureDetailsCollectionViewController
	}

	// MARK: - View Lifecycle
	override func viewDidLoad() {
		super.viewDidLoad()
		self.configureDataSource()
		self.configureNavigationItems()
		self.observeLibraryChanges()

		Task { [weak self] in
			guard let self = self else { return }
			await self.fetchDetails()
		}
	}

	/// Subscribes to local library mutations targeting this literature and its related items.
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

	/// Reapplies the header's overlay when the change targets this literature, then reconfigures
	/// every item bound to the changed trackable identity.
	private func handleLibraryEntryChange(trackableID: String, kind: LibraryKind, isRemoval: Bool) {
		if kind == .literatures, trackableID == (self.literatureIdentity?.id.rawValue ?? self.literature?.id.rawValue) {
			if isRemoval {
				self.libraryAttributes = nil
			} else {
				self.applyLocalLibraryOverlay()
			}
			self.refreshTouchBarLibraryState()
		}
		self.reconfigureLiteratureItems(forTrackableID: trackableID, kind: kind)
	}

	/// Reconfigures every item in the current snapshot — header and related literatures/shows/games —
	/// whose underlying model matches the given trackable identity.
	///
	/// No-ops if `updateDataSource()` hasn't produced a snapshot yet, or if the trackable
	/// identity isn't in it — reconfiguring an item that isn't present would trip a precondition.
	private func reconfigureLiteratureItems(forTrackableID trackableID: String, kind: LibraryKind) {
		guard let dataSource = self.dataSource, var snapshot = self.snapshot else { return }
		let matchedItems = snapshot.itemIdentifiers.filter { item in
			switch (item, kind) {
			case (.literature(let literature), .literatures):
				return literature.id.rawValue == trackableID
			case (.rateAndReview, .literatures):
				return self.literature?.id.rawValue == trackableID
			case (.relatedLiterature(let relatedLiterature), .literatures):
				return relatedLiterature.literature.id.rawValue == trackableID
			case (.relatedShow(let relatedShow), .shows):
				return relatedShow.show.id.rawValue == trackableID
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
		guard let literatureIdentity = self.literatureIdentity else { return }

		let reviewIdentityRequest = KService.reviews(for: literatureIdentity).cursor(nil).limit(10)
		let editorialRequest = KService.editorial(for: literatureIdentity)
		let castIdentityRequest = KService.cast(for: literatureIdentity).limit(10)
		let studioIdentityRequest = KService.studios(for: literatureIdentity).limit(10)
		let moreByStudioRequest = KService.moreByStudio(for: literatureIdentity).limit(10)
		let relatedLiteratureRequest = KService.relatedLiteratures(for: literatureIdentity).limit(10)
		let relatedShowRequest = KService.relatedShows(for: literatureIdentity).limit(10)
		let relatedGameRequest = KService.relatedGames(for: literatureIdentity).limit(10)

		async let reviewIdentityResponse = reviewIdentityRequest.response()
		async let editorialResponse = editorialRequest.response()
		async let castIdentityResponse = castIdentityRequest.response()
		async let studioIdentityResponse = studioIdentityRequest.response()
		async let moreByStudioResponse = moreByStudioRequest.response()
		async let relatedLiteratureResponse = relatedLiteratureRequest.response()
		async let relatedShowResponse = relatedShowRequest.response()
		async let relatedGameResponse = relatedGameRequest.response()

		if self.literature == nil {
			do {
				// Catalog-only — per-user state comes from the local store and overlays.
				let literatureResponse = try await KService.detail(literatureIdentity).embedded(false).response()
				self.literature = literatureResponse.data.first

				// Donate suggestion to Siri.
				self.userActivity = self.literature.openDetailUserActivity
			} catch {
				print(error.localizedDescription)
				self.libraryEntry = self.cachedLibraryEntry(forTrackableID: literatureIdentity.id.rawValue)
				self.title = self.libraryEntry?.trackable?.title
				self.navigationTitleLabel.text = self.libraryEntry?.trackable?.title
				self._prefersActivityIndicatorHidden = true
				self.updateDataSource()
			}

			self.applyLocalLibraryOverlay()
			self.configureNavBarButtons()
		} else {
			// Donate suggestion to Siri.
			self.userActivity = self.literature.openDetailUserActivity

			self.applyLocalLibraryOverlay()
			self.updateDataSource()
			self.configureNavBarButtons()
		}

		guard self.literature != nil else { return }

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
			self.castIdentities = try await castIdentityResponse.data
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
			self.studioLiteratureIdentities = try await moreByStudioResponse.data
			self.updateDataSource()
		} catch {
			print(error.localizedDescription)
		}

		do {
			self.relatedLiteratures = try await relatedLiteratureResponse.data
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
			self.relatedGames = try await relatedGameResponse.data
			self.updateDataSource()
		} catch {
			print(error.localizedDescription)
		}
	}

	/// Mirrors the local-store library state for this literature into `libraryAttributes`.
	private func applyLocalLibraryOverlay() {
		guard let literature = self.literature,
		      let slug = User.current?.attributes.slug
		else { return }

		self.libraryAttributes = LibraryStore.shared.overlay(forTrackableID: literature.id.rawValue, userSlug: slug, kind: .literatures)
	}

	override func makeMoreMenu() -> UIMenu? {
		if let literature = self.literature {
			return literature.makeContextMenu(in: self, userInfo: [:], sourceView: nil, barButtonItem: self.moreBarButtonItem)
		}

		return self.libraryEntry?.makeContextMenu(in: self, userInfo: [:], sourceView: nil, barButtonItem: self.moreBarButtonItem)
	}

	override func rateItem(using rating: Double, description: String?) async throws(APIError) -> Double? {
		guard let literature = self.literature else { return nil }
		return try await literature.rate(using: rating, description: description)
	}

	override func writeAReviewContext() -> ReviewEditorContext? {
		guard let literature = self.literature else { return nil }
		return ReviewEditorContext(kind: .literature(literature), rating: self.libraryAttributes?.rating, review: self.libraryAttributes?.review, note: self.libraryAttributes?.note, isSpoiler: self.libraryAttributes?.isSpoiler ?? false, recommendation: self.libraryAttributes?.recommendation)
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
			return self.relatedShows[safe: indexPath.item]?.show
		case .literatures:
			switch self.dataSource.sectionIdentifier(for: indexPath.section) {
			case .moreByStudio: return self.cachedItem(at: indexPath) as? Literature
			case .relatedLiteratures: return self.relatedLiteratures[safe: indexPath.item]?.literature
			default: return nil
			}
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
extension LiteratureDetailsCollectionViewController {
	func measuredItemWidth(for section: SectionLayoutKind, containerWidth: CGFloat) -> CGFloat? {
		switch section {
		case .reviews, .cast, .studios, .moreByStudio, .relatedLiteratures, .relatedShows, .relatedGames:
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
		case .castIdentity:
			return self.castMeasurableItem(for: itemKind)
		case .studioIdentity:
			return self.studioMeasurableItem(for: itemKind)
		case .literatureIdentity:
			return self.studioLiteratureMeasurableItem(for: itemKind)
		case .relatedLiterature(let relatedLiterature):
			return SmallLockupCollectionViewCell.measurableItem(for: relatedLiterature)
		case .relatedShow(let relatedShow):
			return SmallLockupCollectionViewCell.measurableItem(for: relatedShow)
		case .relatedGame(let relatedGame):
			return GameLockupCollectionViewCell.measurableItem(for: relatedGame)
		default:
			return nil
		}
	}

	/// Returns the item that measures the given item's cast cell.
	///
	/// - Parameter itemKind: The item whose cell is measured.
	///
	/// - Returns: The item that measures the cell.
	private func castMeasurableItem(for itemKind: ItemKind) -> CellHeightMeasurer.Item {
		let cast: Cast? = self.fetchModel(for: itemKind)

		guard let cast = cast else {
			return CellHeightMeasurer.Item(cellType: ProfileLockupCollectionViewCell.self, isSkeleton: true) { cell in
				cell.configure(using: nil as Character?)
			}
		}

		return ProfileLockupCollectionViewCell.measurableItem(for: cast)
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
	private func studioLiteratureMeasurableItem(for itemKind: ItemKind) -> CellHeightMeasurer.Item {
		let literature: Literature? = self.fetchModel(for: itemKind)

		guard let literature = literature else {
			return CellHeightMeasurer.Item(cellType: SmallLockupCollectionViewCell.self, isSkeleton: true) { cell in
				cell.configure(using: nil as Literature?)
			}
		}

		return SmallLockupCollectionViewCell.measurableItem(for: literature)
	}
}

// MARK: - CastCollectionViewCellDelegate
extension LiteratureDetailsCollectionViewController: CastCollectionViewCellDelegate {
	func castCollectionViewCell(_ cell: CastCollectionViewCell, didPressPersonButton button: UIButton) {
		self.show(.personDetailsSegue, sender: cell)
	}

	func castCollectionViewCell(_ cell: CastCollectionViewCell, didPressCharacterButton button: UIButton) {
		self.show(.characterDetailsSegue, sender: cell)
	}
}

// MARK: - TextViewCollectionViewCellDelegate
extension LiteratureDetailsCollectionViewController: TextViewCollectionViewCellDelegate {
	func textViewCollectionViewCell(_ cell: TextViewCollectionViewCell, didPressButton button: UIButton) {
		let synopsisViewController = SynopsisViewController()
		synopsisViewController.title = cell.textViewCollectionViewCellType.stringValue
		synopsisViewController.synopsis = self.literature.attributes.synopsis

		let kNavigationController = KNavigationController(rootViewController: synopsisViewController)
		kNavigationController.modalPresentationStyle = .formSheet

		self.present(kNavigationController, animated: true)
	}
}

// MARK: - Cell Configuration
extension LiteratureDetailsCollectionViewController {
	func getConfiguredCastCell() -> UICollectionView.CellRegistration<ProfileLockupCollectionViewCell, ItemKind> {
		return UICollectionView.CellRegistration<ProfileLockupCollectionViewCell, ItemKind>(cellNib: ProfileLockupCollectionViewCell.nib) { [weak self] characterLockupCollectionViewCell, indexPath, itemKind in
			guard let self = self else { return }

			switch itemKind {
			case .castIdentity:
				let cast: Cast? = self.fetchModel(at: indexPath)

				if cast == nil, let section = self.snapshot.sectionIdentifier(containingItem: itemKind), !self.isFetchingSection.contains(section) {
					Task {
						await self.fetchSectionIfNeeded(ResourceCollection<Cast>.self, CastIdentity.self, for: itemKind)
					}
				}

				characterLockupCollectionViewCell.configure(using: cast?.relationships.characters.data.first, role: cast?.attributes.role)
			default: return
			}
		}
	}

	func getConfiguredStudioLiteratureCell() -> UICollectionView.CellRegistration<SmallLockupCollectionViewCell, ItemKind> {
		return UICollectionView.CellRegistration<SmallLockupCollectionViewCell, ItemKind>(cellNib: SmallLockupCollectionViewCell.nib) { [weak self] smallLockupCollectionViewCell, indexPath, itemKind in
			guard let self = self else { return }

			switch itemKind {
			case .literatureIdentity:
				let literature: Literature? = self.fetchModel(at: indexPath)

				if literature == nil, let section = self.snapshot.sectionIdentifier(containingItem: itemKind), !self.isFetchingSection.contains(section) {
					Task {
						await self.fetchSectionIfNeeded(ResourceCollection<Literature>.self, LiteratureIdentity.self, for: itemKind)
					}
				}

				smallLockupCollectionViewCell.delegate = self
				smallLockupCollectionViewCell.configure(using: literature)
			default: return
			}
		}
	}

	func getConfiguredStudioCell() -> UICollectionView.CellRegistration<StudioLockupCollectionViewCell, ItemKind> {
		return UICollectionView.CellRegistration<StudioLockupCollectionViewCell, ItemKind>(cellNib: StudioLockupCollectionViewCell.nib) { [weak self] studioLockupCollectionViewCell, indexPath, itemKind in
			guard let self = self else { return }

			switch itemKind {
			case .studioIdentity:
				let studio: Studio? = self.fetchModel(at: indexPath)

				if studio == nil, let section = self.snapshot.sectionIdentifier(containingItem: itemKind), !self.isFetchingSection.contains(section) {
					Task {
						await self.fetchSectionIfNeeded(ResourceCollection<Studio>.self, StudioIdentity.self, for: itemKind)
					}
				}

				studioLockupCollectionViewCell.configure(using: studio)
			default: break
			}
		}
	}

	func getConfiguredRelatedLiteratureCell() -> UICollectionView.CellRegistration<SmallLockupCollectionViewCell, ItemKind> {
		return UICollectionView.CellRegistration<SmallLockupCollectionViewCell, ItemKind>(cellNib: SmallLockupCollectionViewCell.nib) { smallLockupCollectionViewCell, _, itemKind in
			smallLockupCollectionViewCell.delegate = self

			switch itemKind {
			case .relatedLiterature(let relatedLiterature):
				smallLockupCollectionViewCell.configure(using: relatedLiterature)
			case .relatedShow(let relatedShow):
				smallLockupCollectionViewCell.configure(using: relatedShow)
			default: return
			}
		}
	}

	func getConfiguredRelatedGameCell() -> UICollectionView.CellRegistration<GameLockupCollectionViewCell, ItemKind> {
		return UICollectionView.CellRegistration<GameLockupCollectionViewCell, ItemKind>(cellNib: GameLockupCollectionViewCell.nib) { gameLockupCollectionViewCell, _, itemKind in
			gameLockupCollectionViewCell.delegate = self

			switch itemKind {
			case .relatedGame(let relatedGame):
				gameLockupCollectionViewCell.configure(using: relatedGame)
			default: return
			}
		}
	}
}
