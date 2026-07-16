//
//  DigestCollectionViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 28/06/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import KurozoraKit
import UIKit

class DigestCollectionViewController: KCollectionViewController, SectionFetchable, TypedSegueHandling {
	// MARK: - Enums
	enum SegueIdentifiers: String, SegueIdentifier {
		case showDetailsSegue
		case gameDetailsSegue
		case episodeDetailsSegue
		case personDetailsSegue
		case episodesListSegue
		case reCapSegue
	}

	// MARK: - Properties
	/// The authenticated user's weekly digest.
	var digest: WeeklyDigest? {
		didSet {
			self._prefersActivityIndicatorHidden = true
			self.updateDataSource()

			#if DEBUG
			#if !targetEnvironment(macCatalyst)
			self.refreshControl?.endRefreshing()
			#endif
			#endif
		}
	}

	var cache: [IndexPath: KurozoraItem] = [:]
	var isFetchingSection: Set<SectionLayoutKind> = []

	/// The server-provided title and subtitle for each rendered section.
	var sectionHeaders: [SectionLayoutKind: (title: String?, subtitle: String?)] = [:]

	/// Observes Core Data mutations so visible cells reflect library changes made from other screens.
	private var libraryObserver: LocalLibraryEntryObserver?

	var dataSource: UICollectionViewDiffableDataSource<SectionLayoutKind, ItemKind>!
	var snapshot: NSDiffableDataSourceSnapshot<SectionLayoutKind, ItemKind>!

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

		self.title = L10n.digest

		self.configureDataSource()
		self.observeLibraryChanges()

		// Fetch the weekly digest.
		Task { [weak self] in
			guard let self = self else { return }
			await self.fetchDigest()
		}
	}

	// MARK: - Functions
	override func handleRefreshControl() {
		Task { [weak self] in
			guard let self = self else { return }
			await self.fetchDigest()
		}
	}

	func fetchDigest() async {
		do {
			self.digest = try await KService.weeklyDigest().response()
		} catch {
			print(error.localizedDescription)
		}
	}

	/// The week's momentum stats.
	var momentum: WeeklyDigest.Momentum? {
		return self.digest?.sections.first { $0.attributes.momentum != nil }?.attributes.momentum
	}

	/// Subscribes to local library mutations so visible cells reapply their library overlays surgically.
	private func observeLibraryChanges() {
		guard let slug = User.current?.attributes.slug else { return }
		self.libraryObserver = LocalLibraryEntryObserver(
			matching: LocalLibraryEntryObserver.matches(userSlug: slug),
			onChange: { [weak self] entry in
				self?.applyLibraryEntryChange(forTrackableID: entry.trackableID, userSlug: entry.userSlug, kind: entry.kind, isRemoval: false)
			},
			onRemove: { [weak self] removed in
				self?.applyLibraryEntryChange(forTrackableID: removed.trackableID, userSlug: removed.userSlug, kind: removed.kind, isRemoval: true)
			}
		)
	}

	/// Updates every cached show/game whose identity matches the given trackable identity.
	private func applyLibraryEntryChange(forTrackableID trackableID: String, userSlug: String, kind: LibraryKind, isRemoval: Bool) {
		var matchedItems: [ItemKind] = []
		let currentSnapshot = self.dataSource.snapshot()

		for item in currentSnapshot.itemIdentifiers {
			let matches: Bool
			switch (item, kind) {
			case (.showIdentity(let identity, _), .shows):
				matches = identity.id.rawValue == trackableID
			case (.gameIdentity(let identity, _), .games):
				matches = identity.id.rawValue == trackableID
			default:
				matches = false
			}
			guard matches else { continue }

			guard let indexPath = self.dataSource.indexPath(for: item) else { continue }
			switch kind {
			case .shows:
				guard let show = self.cache[indexPath] as? Show else { continue }
			case .games:
				guard let game = self.cache[indexPath] as? Game else { continue }
			case .literatures:
				continue
			}
			matchedItems.append(item)
		}

		guard !matchedItems.isEmpty else { return }
		var snapshot = currentSnapshot
		snapshot.reconfigureItems(matchedItems)
		self.dataSource.apply(snapshot, animatingDifferences: false)
	}

	// MARK: - SectionFetchable
	func extractIdentity<Element>(from item: ItemKind) -> Element? where Element: KurozoraItem {
		switch item {
		case .showIdentity(let id, _): return id as? Element
		case .gameIdentity(let id, _): return id as? Element
		case .episodeIdentity(let id, _): return id as? Element
		case .personIdentity(let id, _): return id as? Element
		default: return nil
		}
	}

	// MARK: - Segue
	override func makeDestination(for identifier: any SegueIdentifier) -> UIViewController? {
		guard let identifier = identifier as? SegueIdentifiers else { return nil }

		switch identifier {
		case .showDetailsSegue: return ShowDetailsCollectionViewController()
		case .gameDetailsSegue: return GameDetailsCollectionViewController()
		case .episodeDetailsSegue: return EpisodeDetailsCollectionViewController()
		case .personDetailsSegue: return PersonDetailsCollectionViewController()
		case .episodesListSegue: return EpisodesListCollectionViewController()
		case .reCapSegue: return ReCapCollectionViewController()
		}
	}

	override func prepare(for identifier: any SegueIdentifier, destination: UIViewController, sender: Any?) {
		guard let identifier = identifier as? SegueIdentifiers else { return }

		switch identifier {
		case .showDetailsSegue:
			guard let showDetailsCollectionViewController = destination as? ShowDetailsCollectionViewController else { return }
			if let show = sender as? Show {
				showDetailsCollectionViewController.show = show
			} else if let showIdentity = sender as? ShowIdentity {
				showDetailsCollectionViewController.showIdentity = showIdentity
			}
		case .gameDetailsSegue:
			guard let gameDetailsCollectionViewController = destination as? GameDetailsCollectionViewController else { return }
			guard let game = sender as? Game else { return }
			gameDetailsCollectionViewController.game = game
		case .episodeDetailsSegue:
			guard let episodeDetailsCollectionViewController = destination as? EpisodeDetailsCollectionViewController else { return }
			guard let episodeDict = (sender as? [IndexPath: Episode])?.first else { return }
			episodeDetailsCollectionViewController.indexPath = episodeDict.key
			episodeDetailsCollectionViewController.episode = episodeDict.value
		case .personDetailsSegue:
			guard let personDetailsCollectionViewController = destination as? PersonDetailsCollectionViewController else { return }
			guard let person = sender as? Person else { return }
			personDetailsCollectionViewController.person = person
		case .episodesListSegue:
			guard let episodesListCollectionViewController = destination as? EpisodesListCollectionViewController else { return }
			guard let seasonIdentity = sender as? SeasonIdentity else { return }
			episodesListCollectionViewController.seasonIdentity = seasonIdentity
			episodesListCollectionViewController.episodesListFetchType = .season
		case .reCapSegue:
			guard let reCapCollectionViewController = destination as? ReCapCollectionViewController else { return }
			reCapCollectionViewController.year = Calendar.current.component(.year, from: Date())
		}
	}

	/// Opens the user's Re:CAP for the current year.
	func openReCap() {
		self.show(.reCapSegue, sender: nil)
	}
}

// MARK: - BaseLockupCollectionViewCellDelegate
extension DigestCollectionViewController: BaseLockupCollectionViewCellDelegate {
	func baseLockupCollectionViewCell(_ cell: BaseLockupCollectionViewCell, didPressStatus button: UIButton) async {
		let signedIn = await WorkflowController.shared.isSignedIn(on: self)
		guard signedIn else { return }
		guard
			let indexPath = self.collectionView.indexPath(for: cell),
			let model = self.cache[indexPath]
		else { return }
		let modelID: KurozoraItemID = model.id

		let oldLibraryStatus = cell.libraryStatus
		let actionSheetAlertController = UIAlertController.actionSheetWithItems(items: LibraryStatus.alertControllerItems(for: cell.libraryKind), currentSelection: oldLibraryStatus, action: { title, value in
			Task {
				do {
					let libraryUpdateResponse = try await KService.addToLibrary(cell.libraryKind, status: value, itemIDs: [modelID]).response()

					switch cell.libraryKind {
					case .shows:
						guard let show = self.cache[indexPath] as? Show else { return }
					case .literatures:
						guard let literature = self.cache[indexPath] as? Literature else { return }
					case .games:
						guard let game = self.cache[indexPath] as? Game else { return }
					}

					if let slug = User.current?.attributes.slug {
						LibraryStore.shared.apply(libraryUpdateResponse.data.relationships.libraries, forUserSlug: slug, kind: cell.libraryKind)
					}

					// Update entry in library
					cell.libraryStatus = value
					button.setTitle("\(title) ▾", for: .normal)

					// Request review
					ReviewManager.shared.requestReview(for: .itemAddedToLibrary(status: value))
				} catch let error as APIError {
					self.presentAlertController(title: L10n.cantAddToLibraryTitle, message: error.message)
					print("----- Add to library failed", error.message)
				}
			}
		})

		if cell.libraryStatus != .none {
			actionSheetAlertController.addAction(UIAlertAction(title: L10n.removeFromLibrary, style: .destructive) { _ in
				Task {
					do {
						let libraryUpdateResponse = try await KService.removeFromLibrary(cell.libraryKind, itemIDs: [modelID]).response()

						switch cell.libraryKind {
						case .shows:
							guard let show = self.cache[indexPath] as? Show else { return }
						case .literatures:
							guard let literature = self.cache[indexPath] as? Literature else { return }
						case .games:
							guard let game = self.cache[indexPath] as? Game else { return }
						}

						if let slug = User.current?.attributes.slug {
							LibraryStore.shared.applyRemoved(forTrackableID: modelID.rawValue, userSlug: slug, kind: cell.libraryKind)
						}

						// Update entry in library
						cell.libraryStatus = .none
						button.setTitle(L10n.add.uppercased(with: Locale.current), for: .normal)

					} catch let error as APIError {
						self.presentAlertController(title: L10n.cantRemoveFromLibraryTitle, message: error.message)
						print("----- Remove from library failed", error.message)
					}
				}
			})
		}

		// Present the controller
		if let popoverController = actionSheetAlertController.popoverPresentationController {
			popoverController.sourceView = button
			popoverController.sourceRect = button.bounds
		}

		if (self.navigationController?.visibleViewController as? UIAlertController) == nil {
			self.present(actionSheetAlertController, animated: true, completion: nil)
		}
	}

	func baseLockupCollectionViewCell(_ cell: BaseLockupCollectionViewCell, didPressReminder button: UIButton) async {
		guard
			let indexPath = self.collectionView.indexPath(for: cell),
			let show = self.cache[indexPath] as? Show
		else { return }
		await show.toggleReminder(on: self)
		cell.configureReminderButton(for: show.libraryAttributes?.reminderStatus)
	}
}

// MARK: - EpisodeLockupCollectionViewCellDelegate
extension DigestCollectionViewController: EpisodeLockupCollectionViewCellDelegate {
	func episodeLockupCollectionViewCell(_ cell: EpisodeLockupCollectionViewCell, didPressWatchStatusButton button: UIButton) async {
		let isSignedIn = await WorkflowController.shared.isSignedIn()
		guard isSignedIn else { return }

		guard
			let indexPath = self.collectionView.indexPath(for: cell),
			let episode = self.cache[indexPath] as? Episode
		else { return }
		cell.watchStatusButton.isEnabled = false
		await episode.updateWatchStatus(userInfo: ["indexPath": indexPath])
		cell.watchStatusButton.isEnabled = true
	}

	func episodeLockupCollectionViewCell(_ cell: EpisodeLockupCollectionViewCell, didPressShowButton button: UIButton) {
		guard
			let indexPath = self.collectionView.indexPath(for: cell),
			let episode = self.cache[indexPath] as? Episode,
			let showIdentity = episode.relationships?.shows?.data.first
		else { return }

		self.show(.showDetailsSegue, sender: showIdentity)
	}

	func episodeLockupCollectionViewCell(_ cell: EpisodeLockupCollectionViewCell, didPressSeasonButton button: UIButton) {
		guard
			let indexPath = self.collectionView.indexPath(for: cell),
			let episode = self.cache[indexPath] as? Episode,
			let seasonIdentity = episode.relationships?.seasons?.data.first
		else { return }

		self.show(.episodesListSegue, sender: seasonIdentity)
	}
}

// MARK: - SectionLayoutKind
extension DigestCollectionViewController {
	/// List of available Section Layout Kind types.
	///
	/// The raw values match the `kind` the digest API returns for each section.
	enum SectionLayoutKind: String {
		/// The standout tracked anime of the week.
		case hero

		/// The regular episodes that aired for tracked anime this week.
		case newEpisodes

		/// The season finales that aired for tracked anime this week.
		case finales

		/// The tracked games that released this week.
		case newReleases

		/// The anime related to what the user watched most this week.
		case becauseYouWatched

		/// A highly-ranked anime in the user's favourite genre.
		case dropIn

		/// The on-hold anime worth picking back up.
		case rescueOnHold

		/// The plan-to-watch anime worth picking back up.
		case rescuePlanning

		/// The tracked anime premiering over the coming days.
		case premiering

		/// The tracked games releasing over the coming days.
		case releasing

		/// The most-watched episodes across the platform this week.
		case trending

		/// The people relevant to the user's library with an upcoming birthday.
		case birthdays

		/// The user's consumption stats for the week.
		case momentum

		/// The catalog growth summary for the week.
		case growth
	}
}

// MARK: - ItemKind
extension DigestCollectionViewController {
	/// List of available Item Kind types.
	enum ItemKind: Hashable {
		/// Indicates the item kind contains a `ShowIdentity` object.
		case showIdentity(_: ShowIdentity, section: SectionLayoutKind)

		/// Indicates the item kind contains a `GameIdentity` object.
		case gameIdentity(_: GameIdentity, section: SectionLayoutKind)

		/// Indicates the item kind contains an `EpisodeIdentity` object.
		case episodeIdentity(_: EpisodeIdentity, section: SectionLayoutKind)

		/// Indicates the item kind contains a `PersonIdentity` object.
		case personIdentity(_: PersonIdentity, section: SectionLayoutKind)

		/// Indicates the item kind contains a `String` object.
		case text(_: String, section: SectionLayoutKind)

		/// Indicates the item kind is the week's momentum stats card.
		case momentum
	}
}

// MARK: - Cell Configuration
extension DigestCollectionViewController {
	func getConfiguredBannerCell() -> UICollectionView.CellRegistration<BannerLockupCollectionViewCell, ItemKind> {
		return UICollectionView.CellRegistration<BannerLockupCollectionViewCell, ItemKind>(cellNib: BannerLockupCollectionViewCell.nib) { [weak self] cell, indexPath, itemKind in
			guard let self = self else { return }

			switch itemKind {
			case .showIdentity:
				let show: Show? = self.fetchModelOrTriggerSectionFetch(at: indexPath, itemKind: itemKind, response: ResourceCollection<Show>.self, identity: ShowIdentity.self)
				cell.delegate = self
				cell.configure(using: show)
			default:
				break
			}
		}
	}

	func getConfiguredMomentumCell() -> UICollectionView.CellRegistration<DigestMomentumCollectionViewCell, ItemKind> {
		return UICollectionView.CellRegistration<DigestMomentumCollectionViewCell, ItemKind> { [weak self] cell, _, _ in
			guard let self = self, let momentum = self.momentum else { return }
			cell.configure(stats: self.momentumStats(for: momentum), notes: self.momentumNotes(for: momentum))
			cell.seeReCapHandler = { [weak self] in
				self?.openReCap()
			}
		}
	}

	func getConfiguredShowCell() -> UICollectionView.CellRegistration<SmallLockupCollectionViewCell, ItemKind> {
		return UICollectionView.CellRegistration<SmallLockupCollectionViewCell, ItemKind>(cellNib: SmallLockupCollectionViewCell.nib) { [weak self] cell, indexPath, itemKind in
			guard let self = self, case .showIdentity = itemKind else { return }
			let show: Show? = self.fetchModelOrTriggerSectionFetch(at: indexPath, itemKind: itemKind, response: ResourceCollection<Show>.self, identity: ShowIdentity.self)
			cell.delegate = self
			cell.configure(using: show)
		}
	}

	func getConfiguredGameCell() -> UICollectionView.CellRegistration<GameLockupCollectionViewCell, ItemKind> {
		return UICollectionView.CellRegistration<GameLockupCollectionViewCell, ItemKind>(cellNib: GameLockupCollectionViewCell.nib) { [weak self] cell, indexPath, itemKind in
			guard let self = self, case .gameIdentity = itemKind else { return }
			let game: Game? = self.fetchModelOrTriggerSectionFetch(at: indexPath, itemKind: itemKind, response: ResourceCollection<Game>.self, identity: GameIdentity.self)
			cell.delegate = self
			cell.configure(using: game)
		}
	}

	func getConfiguredEpisodeCell() -> UICollectionView.CellRegistration<EpisodeLockupCollectionViewCell, ItemKind> {
		return UICollectionView.CellRegistration<EpisodeLockupCollectionViewCell, ItemKind>(cellNib: EpisodeLockupCollectionViewCell.nib) { [weak self] cell, indexPath, itemKind in
			guard let self = self, case .episodeIdentity = itemKind else { return }
			let episode: Episode? = self.fetchModelOrTriggerSectionFetch(at: indexPath, itemKind: itemKind, response: ResourceCollection<Episode>.self, identity: EpisodeIdentity.self)
			cell.delegate = self
			cell.configure(using: episode)
		}
	}

	func getConfiguredPersonCell() -> UICollectionView.CellRegistration<ProfileLockupCollectionViewCell, ItemKind> {
		return UICollectionView.CellRegistration<ProfileLockupCollectionViewCell, ItemKind>(cellNib: ProfileLockupCollectionViewCell.nib) { [weak self] cell, indexPath, itemKind in
			guard let self = self, case .personIdentity = itemKind else { return }
			let person: Person? = self.fetchModelOrTriggerSectionFetch(at: indexPath, itemKind: itemKind, response: ResourceCollection<Person>.self, identity: PersonIdentity.self)
			cell.configure(using: person)
		}
	}

	func getConfiguredTextCell() -> UICollectionView.CellRegistration<DigestTextCollectionViewCell, ItemKind> {
		return UICollectionView.CellRegistration<DigestTextCollectionViewCell, ItemKind> { cell, _, itemKind in
			switch itemKind {
			case let .text(text, section):
				cell.configure(using: text, alignment: section == .hero ? .natural : .center)
			default:
				break
			}
		}
	}
}
