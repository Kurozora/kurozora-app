//
//  TopChartsCollectionViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 02/08/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import Combine
import KurozoraKit
import UIKit

class TopChartsCollectionViewController: KCollectionViewController, SectionFetchable, TypedSegueHandling {
	// MARK: - Enums
	enum SegueIdentifiers: String, SegueIdentifier {
		case showsListSegue
		case charactersListSegue
		case episodesListSegue
		case gamesListSegue
		case literaturesListSegue
		case peopleListSegue
		case songsListSegue
		case studiosListSegue
		case showDetailsSegue
		case characterDetailsSegue
		case episodeDetailsSegue
		case gameDetailsSegue
		case literatureDetailsSegue
		case personDetailsSegue
		case songDetailsSegue
		case studioDetailsSegue
	}

	// MARK: - Properties
	/// The number of entries shown in a chart's row.
	static let entryLimit = 15

	var showIdentities: [ShowIdentity] = []
	var characterIdentities: [CharacterIdentity] = []
	var episodeIdentities: [EpisodeIdentity] = []
	var gameIdentities: [GameIdentity] = []
	var literatureIdentities: [LiteratureIdentity] = []
	var personIdentities: [PersonIdentity] = []
	var songIdentities: [SongIdentity] = []
	var studioIdentities: [StudioIdentity] = []

	/// The chart kinds whose request has settled.
	var settledChartKinds: Set<ChartKind> = []

	/// The resolved Apple Music songs keyed by Apple Music identifier.
	var resolvedSongs: [Int: MKSong] = [:]

	/// Observes local library mutations to refresh visible cells.
	private var libraryObserver: LocalLibraryEntryObserver?

	/// Observes playback changes so visible song cells reflect the currently playing song.
	private var playbackObserver: AnyCancellable?

	// MARK: - SectionFetchable
	var cache: [IndexPath: KurozoraItem] = [:]
	var isFetchingSection: Set<SectionLayoutKind> = []

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

		#if DEBUG
		self._prefersRefreshControlDisabled = false
		#else
		self._prefersRefreshControlDisabled = true
		#endif

		self.title = L10n.topCharts

		self.configureDataSource()
		self.observeLibraryChanges()
		self.observePlaybackChanges()

		self.fetchCharts()
	}

	// MARK: - Functions
	override func handleRefreshControl() {
		self.settledChartKinds = []
		self.cache = [:]

		self.fetchCharts()
	}

	override func configureEmptyDataView() {
		self.emptyBackgroundView.configureImageView(image: .Empty.libraryAnime)
		self.emptyBackgroundView.configureLabels(title: L10n.noItemsTitle(L10n.topCharts), detail: L10n.cantGetListRefresh(L10n.topCharts.lowercased(with: .current)))

		self.collectionView.backgroundView?.alpha = 0
	}

	/// Fades in and out the empty data view according to the number of items.
	func toggleEmptyDataView() {
		if self.snapshot.itemIdentifiers.isEmpty {
			self.collectionView.backgroundView?.animateFadeIn()
		} else {
			self.collectionView.backgroundView?.animateFadeOut()
		}
	}

	/// Requests every chart's highest ranked entries.
	private func fetchCharts() {
		for chartKind in ChartKind.allCases {
			Task { [weak self] in
				guard let self = self else { return }
				await self.fetchChart(for: chartKind)
			}
		}
	}

	/// Requests a single chart's highest ranked entries.
	///
	/// - Parameter chartKind: The chart to request.
	private func fetchChart(for chartKind: ChartKind) async {
		defer {
			self.settledChartKinds.insert(chartKind)
			self._prefersActivityIndicatorHidden = true
			self.updateDataSource()

			#if DEBUG
			#if !targetEnvironment(macCatalyst)
			if self.settledChartKinds.count == ChartKind.allCases.count {
				self.refreshControl?.endRefreshing()
			}
			#endif
			#endif
		}

		do {
			switch chartKind {
			case .shows:
				let response = try await KService.topShows().limit(Self.entryLimit).response()
				self.showIdentities = response.data
			case .characters:
				let response = try await KService.topCharacters().limit(Self.entryLimit).response()
				self.characterIdentities = response.data
			case .episodes:
				let response = try await KService.topEpisodes().limit(Self.entryLimit).response()
				self.episodeIdentities = response.data
			case .games:
				let response = try await KService.topGames().limit(Self.entryLimit).response()
				self.gameIdentities = response.data
			case .literatures:
				let response = try await KService.topLiteratures().limit(Self.entryLimit).response()
				self.literatureIdentities = response.data
			case .people:
				let response = try await KService.topPeople().limit(Self.entryLimit).response()
				self.personIdentities = response.data
			case .songs:
				let response = try await KService.topSongs().limit(Self.entryLimit).response()
				self.songIdentities = response.data
			case .studios:
				let response = try await KService.topStudios().limit(Self.entryLimit).response()
				self.studioIdentities = response.data
			}
		} catch {
			print(error.localizedDescription)
		}
	}

	/// The localized noun naming the given chart's resource.
	///
	/// - Parameter chartKind: The chart whose resource is named.
	///
	/// - Returns: The localized plural noun of the charted resource.
	func name(for chartKind: ChartKind) -> String {
		switch chartKind {
		case .shows: return L10n.shows
		case .characters: return L10n.characters
		case .episodes: return L10n.episodes
		case .games: return L10n.games
		case .literatures: return L10n.literatures
		case .people: return L10n.people
		case .songs: return L10n.songs
		case .studios: return L10n.studios
		}
	}

	/// The segue that opens the given chart's ranked list.
	///
	/// - Parameter chartKind: The chart whose list is opened.
	///
	/// - Returns: The identifier of the segue to perform.
	func listSegueIdentifier(for chartKind: ChartKind) -> SegueIdentifiers {
		switch chartKind {
		case .shows: return .showsListSegue
		case .characters: return .charactersListSegue
		case .episodes: return .episodesListSegue
		case .games: return .gamesListSegue
		case .literatures: return .literaturesListSegue
		case .people: return .peopleListSegue
		case .songs: return .songsListSegue
		case .studios: return .studiosListSegue
		}
	}

	/// Subscribes to local library mutations affecting the visible cells.
	private func observeLibraryChanges() {
		guard let slug = User.current?.attributes.slug else { return }
		self.libraryObserver = LocalLibraryEntryObserver(
			matching: LocalLibraryEntryObserver.matches(userSlug: slug),
			onChange: { [weak self] entry in
				self?.applyLibraryEntryChange(forTrackableID: entry.trackableID, kind: entry.kind)
			},
			onRemove: { [weak self] removed in
				self?.applyLibraryEntryChange(forTrackableID: removed.trackableID, kind: removed.kind)
			}
		)
	}

	/// Updates every cached show, literature and game whose identity matches the given trackable identity.
	///
	/// - Parameters:
	///    - trackableID: The trackable identity of the mutated entry.
	///    - kind: The library kind of the mutated entry.
	private func applyLibraryEntryChange(forTrackableID trackableID: String, kind: LibraryKind) {
		var matchedItems: [ItemKind] = []
		let currentSnapshot = self.dataSource.snapshot()

		for item in currentSnapshot.itemIdentifiers {
			let matches: Bool

			switch (item, kind) {
			case (.showIdentity(let identity), .shows):
				matches = identity.id.rawValue == trackableID
			case (.literatureIdentity(let identity), .literatures):
				matches = identity.id.rawValue == trackableID
			case (.gameIdentity(let identity), .games):
				matches = identity.id.rawValue == trackableID
			default:
				matches = false
			}

			guard matches, let indexPath = self.dataSource.indexPath(for: item), self.cache[indexPath] != nil else { continue }
			matchedItems.append(item)
		}

		guard !matchedItems.isEmpty else { return }
		var snapshot = currentSnapshot
		snapshot.reconfigureItems(matchedItems)
		self.dataSource.apply(snapshot, animatingDifferences: false)
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
	func refreshVisibleMusicCells() {
		for case let cell as MusicLockupCollectionViewCell in self.collectionView.visibleCells {
			guard
				let indexPath = self.collectionView.indexPath(for: cell),
				let song = self.cache[indexPath] as? Song
			else { continue }
			cell.updatePlayButton(for: song)
			cell.updateArtwork(for: song, resolvedSong: song.attributes.amID.flatMap { self.resolvedSongs[$0] })
		}
	}

	// MARK: - SectionFetchable
	func extractIdentity<Element>(from item: ItemKind) -> Element? where Element: KurozoraItem {
		switch item {
		case .showIdentity(let id): return id as? Element
		case .characterIdentity(let id): return id as? Element
		case .episodeIdentity(let id): return id as? Element
		case .gameIdentity(let id): return id as? Element
		case .literatureIdentity(let id): return id as? Element
		case .personIdentity(let id): return id as? Element
		case .songIdentity(let id): return id as? Element
		case .studioIdentity(let id): return id as? Element
		case .pending: return nil
		}
	}

	// MARK: - Segue
	override func makeDestination(for identifier: any SegueIdentifier) -> UIViewController? {
		guard let identifier = identifier as? SegueIdentifiers else { return nil }

		switch identifier {
		case .showsListSegue: return ShowsListCollectionViewController()
		case .charactersListSegue: return CharactersListCollectionViewController()
		case .episodesListSegue: return EpisodesListCollectionViewController()
		case .gamesListSegue: return GamesListCollectionViewController()
		case .literaturesListSegue: return LiteraturesListCollectionViewController()
		case .peopleListSegue: return PeopleListCollectionViewController()
		case .songsListSegue: return ShowSongsListCollectionViewController()
		case .studiosListSegue: return StudiosListCollectionViewController()
		case .showDetailsSegue: return ShowDetailsCollectionViewController()
		case .characterDetailsSegue: return CharacterDetailsCollectionViewController()
		case .episodeDetailsSegue: return EpisodeDetailsCollectionViewController()
		case .gameDetailsSegue: return GameDetailsCollectionViewController()
		case .literatureDetailsSegue: return LiteratureDetailsCollectionViewController()
		case .personDetailsSegue: return PersonDetailsCollectionViewController()
		case .songDetailsSegue: return SongDetailsCollectionViewController()
		case .studioDetailsSegue: return StudioDetailsCollectionViewController()
		}
	}

	override func prepare(for identifier: any SegueIdentifier, destination: UIViewController, sender: Any?) {
		guard let identifier = identifier as? SegueIdentifiers else { return }

		switch identifier {
		case .showsListSegue:
			guard let showsListCollectionViewController = destination as? ShowsListCollectionViewController else { return }
			showsListCollectionViewController.showsListFetchType = .charts
		case .charactersListSegue:
			guard let charactersListCollectionViewController = destination as? CharactersListCollectionViewController else { return }
			charactersListCollectionViewController.charactersListFetchType = .charts
		case .episodesListSegue:
			guard let episodesListCollectionViewController = destination as? EpisodesListCollectionViewController else { return }
			if let seasonIdentity = sender as? SeasonIdentity {
				episodesListCollectionViewController.seasonIdentity = seasonIdentity
				episodesListCollectionViewController.episodesListFetchType = .season
			} else {
				episodesListCollectionViewController.episodesListFetchType = .charts
			}
		case .gamesListSegue:
			guard let gamesListCollectionViewController = destination as? GamesListCollectionViewController else { return }
			gamesListCollectionViewController.gamesListFetchType = .charts
		case .literaturesListSegue:
			guard let literaturesListCollectionViewController = destination as? LiteraturesListCollectionViewController else { return }
			literaturesListCollectionViewController.literaturesListFetchType = .charts
		case .peopleListSegue:
			guard let peopleListCollectionViewController = destination as? PeopleListCollectionViewController else { return }
			peopleListCollectionViewController.peopleListFetchType = .charts
		case .songsListSegue:
			guard let showSongsListCollectionViewController = destination as? ShowSongsListCollectionViewController else { return }
			showSongsListCollectionViewController.songsListFetchType = .charts
		case .studiosListSegue:
			guard let studiosListCollectionViewController = destination as? StudiosListCollectionViewController else { return }
			studiosListCollectionViewController.studiosListFetchType = .charts
		case .showDetailsSegue:
			guard let showDetailsCollectionViewController = destination as? ShowDetailsCollectionViewController else { return }
			if let show = sender as? Show {
				showDetailsCollectionViewController.show = show
			} else if let showIdentity = sender as? ShowIdentity {
				showDetailsCollectionViewController.showIdentity = showIdentity
			}
		case .characterDetailsSegue:
			guard let characterDetailsCollectionViewController = destination as? CharacterDetailsCollectionViewController else { return }
			guard let character = sender as? Character else { return }
			characterDetailsCollectionViewController.character = character
		case .episodeDetailsSegue:
			guard let episodeDetailsCollectionViewController = destination as? EpisodeDetailsCollectionViewController else { return }
			guard let episodeDictionary = (sender as? [IndexPath: Episode])?.first else { return }
			episodeDetailsCollectionViewController.indexPath = episodeDictionary.key
			episodeDetailsCollectionViewController.episode = episodeDictionary.value
		case .gameDetailsSegue:
			guard let gameDetailsCollectionViewController = destination as? GameDetailsCollectionViewController else { return }
			guard let game = sender as? Game else { return }
			gameDetailsCollectionViewController.game = game
		case .literatureDetailsSegue:
			guard let literatureDetailsCollectionViewController = destination as? LiteratureDetailsCollectionViewController else { return }
			guard let literature = sender as? Literature else { return }
			literatureDetailsCollectionViewController.literature = literature
		case .personDetailsSegue:
			guard let personDetailsCollectionViewController = destination as? PersonDetailsCollectionViewController else { return }
			guard let person = sender as? Person else { return }
			personDetailsCollectionViewController.person = person
		case .songDetailsSegue:
			guard let songDetailsCollectionViewController = destination as? SongDetailsCollectionViewController else { return }
			guard let song = sender as? Song else { return }
			songDetailsCollectionViewController.song = song
		case .studioDetailsSegue:
			guard let studioDetailsCollectionViewController = destination as? StudioDetailsCollectionViewController else { return }
			guard let studio = sender as? Studio else { return }
			studioDetailsCollectionViewController.studio = studio
		}
	}
}

// MARK: - SectionLayoutKind
extension TopChartsCollectionViewController {
	/// List of available Section Layout Kind types.
	enum SectionLayoutKind: Hashable {
		// MARK: - Cases
		/// Indicates a chart section layout type.
		case chart(_: ChartKind)
	}
}

// MARK: - ItemKind
extension TopChartsCollectionViewController {
	/// List of available Item Kind types.
	enum ItemKind: Hashable {
		// MARK: - Cases
		/// Indicates the item kind contains a `ShowIdentity` object.
		case showIdentity(_: ShowIdentity)

		/// Indicates the item kind contains a `CharacterIdentity` object.
		case characterIdentity(_: CharacterIdentity)

		/// Indicates the item kind contains an `EpisodeIdentity` object.
		case episodeIdentity(_: EpisodeIdentity)

		/// Indicates the item kind contains a `GameIdentity` object.
		case gameIdentity(_: GameIdentity)

		/// Indicates the item kind contains a `LiteratureIdentity` object.
		case literatureIdentity(_: LiteratureIdentity)

		/// Indicates the item kind contains a `PersonIdentity` object.
		case personIdentity(_: PersonIdentity)

		/// Indicates the item kind contains a `SongIdentity` object.
		case songIdentity(_: SongIdentity)

		/// Indicates the item kind contains a `StudioIdentity` object.
		case studioIdentity(_: StudioIdentity)

		/// Indicates the item kind is a skeleton awaiting the chart's entries.
		case pending(chartKind: ChartKind, index: Int)
	}
}

// MARK: - TitleHeaderCollectionReusableViewDelegate
extension TopChartsCollectionViewController: TitleHeaderCollectionReusableViewDelegate {
	func titleHeaderCollectionReusableView(_ reusableView: TitleHeaderCollectionReusableView, didPress button: UIButton) {
		guard let segueID = reusableView.segueID as? SegueIdentifiers else { return }
		self.show(segueID, sender: nil)
	}
}

// MARK: - BaseLockupCollectionViewCellDelegate
extension TopChartsCollectionViewController: BaseLockupCollectionViewCellDelegate {
	func baseLockupCollectionViewCell(_ cell: BaseLockupCollectionViewCell, didPressStatus button: UIButton) async {
		let signedIn = await WorkflowController.shared.isSignedIn(on: self)
		guard signedIn else { return }
		guard
			let indexPath = self.collectionView.indexPath(for: cell),
			let target = self.cache[indexPath] as? Libraryable
		else { return }

		let oldLibraryStatus = cell.libraryStatus
		let actionSheetAlertController = UIAlertController.actionSheetWithItems(items: LibraryStatus.alertControllerItems(for: cell.libraryKind), currentSelection: oldLibraryStatus, action: { title, value in
			Task {
				await target.addToLibrary(status: value)
				cell.libraryStatus = value
				button.setTitle("\(title) ▾", for: .normal)
			}
		})

		if cell.libraryStatus != .none {
			actionSheetAlertController.addAction(UIAlertAction(title: L10n.removeFromLibrary, style: .destructive) { _ in
				Task {
					await target.removeFromLibrary()
					cell.libraryStatus = .none
					button.setTitle(L10n.add.uppercased(with: Locale.current), for: .normal)
				}
			})
		}

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
extension TopChartsCollectionViewController: EpisodeLockupCollectionViewCellDelegate {
	func episodeLockupCollectionViewCell(_ cell: EpisodeLockupCollectionViewCell, didPressWatchStatusButton button: UIButton) async {
		let signedIn = await WorkflowController.shared.isSignedIn(on: self)
		guard
			signedIn,
			let indexPath = self.collectionView.indexPath(for: cell),
			let episode = self.cache[indexPath] as? Episode
		else { return }

		cell.watchStatusButton.isEnabled = false
		await episode.updateWatchStatus(userInfo: ["indexPath": indexPath])
		cell.watchStatusButton.isEnabled = true
	}

	func episodeLockupCollectionViewCell(_ cell: EpisodeLockupCollectionViewCell, didPressShowButton button: UIButton) async {
		guard
			let indexPath = self.collectionView.indexPath(for: cell),
			let episode = self.cache[indexPath] as? Episode,
			let showIdentity = episode.relationships?.shows?.data.first
		else { return }

		self.show(.showDetailsSegue, sender: showIdentity)
	}

	func episodeLockupCollectionViewCell(_ cell: EpisodeLockupCollectionViewCell, didPressSeasonButton button: UIButton) async {
		guard
			let indexPath = self.collectionView.indexPath(for: cell),
			let episode = self.cache[indexPath] as? Episode,
			let seasonIdentity = episode.relationships?.seasons?.data.first
		else { return }

		self.show(.episodesListSegue, sender: seasonIdentity)
	}
}

// MARK: - MusicLockupCollectionViewCellDelegate
extension TopChartsCollectionViewController: MusicLockupCollectionViewCellDelegate {
	func showButtonPressed(_ sender: UIButton, indexPath: IndexPath) {}

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

	func musicLockupCollectionViewCell(_ cell: MusicLockupCollectionViewCell, didTapPlayButtonAt indexPath: IndexPath) {
		let itemCount = self.collectionView.numberOfItems(inSection: indexPath.section)
		let kkSongs: [KKSong?] = (0 ..< itemCount).map { item in
			self.cache[IndexPath(item: item, section: indexPath.section)] as? Song
		}

		MusicManager.shared.play(kkSongs: kkSongs, startingAt: indexPath.item)
	}
}
