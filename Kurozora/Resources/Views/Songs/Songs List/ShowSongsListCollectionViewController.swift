//
//  ShowSongsListCollectionViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 20/08/2020.
//  Copyright © 2020 Kurozora. All rights reserved.
//

import AVFoundation
import Combine
import KurozoraKit
import UIKit

/// A display mode for ``ShowSongsListCollectionViewController``.
enum SongsListViewType: Int {
	case songs = 0
	case showSongs
}

/// A source of songs for ``ShowSongsListCollectionViewController``.
enum SongsListFetchType {
	case show
	case charts
}

/// A list of songs for a show, grouped by song type.
class ShowSongsListCollectionViewController: ListCollectionViewController, SectionFetchable, TypedSegueHandling {
	// MARK: - Enums
	enum SegueIdentifiers: String, SegueIdentifier {
		case showDetailsSegue
		case songDetailsSegue
	}

	/// A section layout.
	enum SectionLayoutKind: Hashable {
		case main
		case header(id: UUID = UUID())
	}

	/// An item displayed in the list.
	enum ItemKind: Hashable {
		case song(_: Song, id: UUID = UUID())
		case showSong(_: ShowSong, id: UUID = UUID())
		case songIdentity(_: SongIdentity)
	}

	// MARK: - Properties
	var showIdentity: ShowIdentity?
	var songs: [Song] = []
	var showSongs: [ShowSong] = []
	var songIdentities: [SongIdentity] = []
	var songsListFetchType: SongsListFetchType = .show
	lazy var showSongCategories: [SongType: [ShowSong]] = [:]

	/// The resolved Apple Music songs keyed by Apple Music identifier.
	var resolvedSongs: [Int: MKSong] = [:]

	/// Observes playback changes so visible song cells reflect the currently playing song.
	private var playbackObserver: AnyCancellable?

	/// The player that previews songs.
	var player: AVPlayer?

	/// The index path of the currently-playing song.
	var currentPlayerIndexPath: IndexPath?

	// MARK: - SectionFetchable
	var cache: [IndexPath: KurozoraItem] = [:]
	var isFetchingSection: Set<SectionLayoutKind> = []

	var dataSource: UICollectionViewDiffableDataSource<SectionLayoutKind, ItemKind>!
	var snapshot: NSDiffableDataSourceSnapshot<SectionLayoutKind, ItemKind>!

	override var emptyStateImage: UIImage { .Empty.personQuestion }

	override var emptyStateTitle: String {
		switch self.songsListFetchType {
		case .show: return L10n.noShowSongs
		case .charts: return L10n.noItemsTitle(L10n.topCharts)
		}
	}

	override var emptyStateDetail: String {
		switch self.songsListFetchType {
		case .show: return L10n.cantGetShowSongs
		case .charts: return L10n.cantGetListDetail(L10n.topCharts.lowercased(with: .current))
		}
	}

	override var hasLoadedInitialData: Bool {
		switch self.songsListFetchType {
		case .show: return !self.showSongs.isEmpty || !self.songs.isEmpty
		case .charts: return !self.songIdentities.isEmpty
		}
	}

	override func viewDidLoad() {
		super.viewDidLoad()

		switch self.songsListFetchType {
		case .show:
			self.title = L10n.songs
		case .charts:
			self.title = L10n.xTopCharts(L10n.songs)
		}

		self.observePlaybackChanges()
	}

	/// Subscribes to playback changes, so visible song cells reflect the currently playing song.
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
				let song = self.showSongs[safe: indexPath.item]?.song ?? self.songs[safe: indexPath.item] ?? self.cache[indexPath] as? Song
			else { continue }
			cell.updatePlayButton(for: song)
			cell.updateArtwork(for: song, resolvedSong: song.attributes.amID.flatMap { self.resolvedSongs[$0] })
		}
	}

	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		self.player?.pause()
	}

	override func handleRefreshControl() {
		switch self.songsListFetchType {
		case .show:
			guard self.showIdentity != nil else { return }

			self.nextPageCursor = nil

			Task { [weak self] in
				guard let self = self else { return }
				await self.fetchShowSongs(forceFetch: true)
			}
		case .charts:
			super.handleRefreshControl()
		}
	}

	override func fetchItems() async {
		switch self.songsListFetchType {
		case .show:
			await self.fetchShowSongs()
		case .charts:
			await self.fetchTopSongs()
		}
	}

	/// Fetches the next page of the top ranked songs.
	func fetchTopSongs() async {
		guard !self.isRequestInProgress else { return }
		self.isRequestInProgress = true

		defer { self.endFetch() }

		do {
			let songIdentityResponse = try await KService.topSongs().cursor(self.nextPageCursor).limit(self.nextPageCursor != nil ? 100 : 25).response()

			if self.nextPageCursor == nil {
				self.songIdentities = []
			}

			self.nextPageCursor = songIdentityResponse.nextCursor
			self.songIdentities.append(contentsOf: songIdentityResponse.data)
			self.songIdentities.removeDuplicates()
		} catch {
			print(error.localizedDescription)
		}
	}

	func fetchShowSongs(forceFetch: Bool = false) async {
		defer { self.endFetch() }

		if forceFetch || (self.showSongs.isEmpty && self.songs.isEmpty) {
			guard let showIdentity = self.showIdentity else { return }

			do {
				let showSongResponse = try await KService.songs(for: showIdentity).limit(-1).response()
				self.showSongs = showSongResponse.data
			} catch {
				print(error.localizedDescription)
				return
			}
		}

		let appleMusicIDs = self.showSongs.compactMap { $0.song.attributes.amID }
			+ self.songs.compactMap { $0.attributes.amID }
		self.resolvedSongs = await MusicManager.shared.getSongs(for: appleMusicIDs)

		self.groupShowSongs()
	}

	func groupShowSongs() {
		var categorisedShowSongs = Dictionary(grouping: showSongs, by: { $0.attributes.type })
		categorisedShowSongs.forEach { key, _ in
			categorisedShowSongs[key]?.sort { $0.attributes.position < $1.attributes.position }
		}

		self.showSongCategories = categorisedShowSongs
	}

	// MARK: - SectionFetchable
	func extractIdentity<Element>(from item: ItemKind) -> Element? where Element: KurozoraItem {
		switch item {
		case .songIdentity(let songIdentity): return songIdentity as? Element
		case .song, .showSong: return nil
		}
	}

	// MARK: - Segue
	override func makeDestination(for identifier: any SegueIdentifier) -> UIViewController? {
		guard let identifier = identifier as? SegueIdentifiers else { return nil }

		switch identifier {
		case .showDetailsSegue: return ShowDetailsCollectionViewController()
		case .songDetailsSegue: return SongDetailsCollectionViewController()
		}
	}

	override func prepare(for identifier: any SegueIdentifier, destination: UIViewController, sender: Any?) {
		guard let identifier = identifier as? SegueIdentifiers else { return }

		switch identifier {
		case .showDetailsSegue:
			guard let destination = destination as? ShowDetailsCollectionViewController else { return }
			guard let show = sender as? Show else { return }
			destination.show = show
		case .songDetailsSegue:
			guard let destination = destination as? SongDetailsCollectionViewController else { return }
			guard let song = sender as? Song else { return }
			destination.song = song
		}
	}
}

// MARK: - KCollectionViewDataSource
extension ShowSongsListCollectionViewController {
	override func registerNibs(for collectionView: UICollectionView) -> [UICollectionReusableView.Type] {
		return [
			TitleHeaderCollectionReusableView.self
		]
	}

	override func configureDataSource() {
		let musicCellConfiguration = self.getConfiguredMusicCell()

		self.dataSource = UICollectionViewDiffableDataSource<SectionLayoutKind, ItemKind>(collectionView: collectionView) { collectionView, indexPath, itemKind in
			return collectionView.dequeueConfiguredReusableCell(using: musicCellConfiguration, for: indexPath, item: itemKind)
		}

		if self.showIdentity != nil {
			self.dataSource.supplementaryViewProvider = { [weak self] collectionView, kind, indexPath in
				guard let self = self else { return nil }
				guard let songType = SongType(rawValue: indexPath.section) else { return nil }

				let exploreSectionTitleCell = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withClass: TitleHeaderCollectionReusableView.self, for: indexPath)
				exploreSectionTitleCell.delegate = self
				exploreSectionTitleCell.configure(withTitle: "\(songType.stringValue) (\(self.showSongCategories[songType]?.count ?? 0))")

				return exploreSectionTitleCell
			}
		}
	}

	override func updateDataSource() {
		self.snapshot = NSDiffableDataSourceSnapshot<SectionLayoutKind, ItemKind>()

		if self.songsListFetchType == .charts {
			self.snapshot.appendSections([.main])

			let items: [ItemKind] = self.songIdentities.map { .songIdentity($0) }
			self.snapshot.appendItems(items, toSection: .main)
		} else if self.showIdentity != nil {
			SongType.allCases.forEach { songType in
				if self.showSongCategories.index(forKey: songType) != nil {
					let sectionHeader = SectionLayoutKind.header()
					self.snapshot.appendSections([sectionHeader])

					if let showSongCategory = self.showSongCategories[songType] {
						let items: [ItemKind] = showSongCategory.map { .showSong($0) }
						self.snapshot.appendItems(items, toSection: sectionHeader)
					}
				}
			}
		} else if !self.showSongs.isEmpty {
			let sectionHeader = SectionLayoutKind.header()
			self.snapshot.appendSections([sectionHeader])

			let items: [ItemKind] = self.showSongs.map { .showSong($0) }
			self.snapshot.appendItems(items, toSection: sectionHeader)
		} else if !self.songs.isEmpty {
			let sectionHeader = SectionLayoutKind.header()
			self.snapshot.appendSections([sectionHeader])

			let items: [ItemKind] = self.songs.map { .song($0) }
			self.snapshot.appendItems(items, toSection: sectionHeader)
		}

		self.dataSource.apply(self.snapshot)
	}

	private func getConfiguredMusicCell() -> UICollectionView.CellRegistration<MusicLockupCollectionViewCell, ItemKind> {
		return UICollectionView.CellRegistration<MusicLockupCollectionViewCell, ItemKind>(cellNib: MusicLockupCollectionViewCell.nib) { [weak self] cell, indexPath, itemKind in
			guard let self = self else { return }

			cell.delegate = self

			switch itemKind {
			case .showSong(let showSong, _):
				let showIDExists = self.showIdentity != nil
				let resolvedSong = showSong.song.attributes.amID.flatMap { self.resolvedSongs[$0] }
				cell.configure(using: showSong, at: indexPath, showEpisodes: showIDExists, showShow: !showIDExists, resolvedSong: resolvedSong)
				self.resolveMusicSong(showSong.song)
			case .song(let song, _):
				let resolvedSong = song.attributes.amID.flatMap { self.resolvedSongs[$0] }
				cell.configure(using: song, at: indexPath, resolvedSong: resolvedSong)
				self.resolveMusicSong(song)
			case .songIdentity:
				let song: Song? = self.fetchModel(at: indexPath)

				if song == nil, let section = self.snapshot.sectionIdentifier(containingItem: itemKind), !self.isFetchingSection.contains(section) {
					Task {
						await self.fetchSectionIfNeeded(ResourceCollection<Song>.self, SongIdentity.self, at: indexPath, itemKind: itemKind)
					}
				}

				let resolvedSong = song?.attributes.amID.flatMap { self.resolvedSongs[$0] }
				cell.configure(using: song, at: indexPath, rank: indexPath.item + 1, resolvedSong: resolvedSong)

				if let song = song {
					self.resolveMusicSong(song)
				}
			}
		}
	}
}

// MARK: - KCollectionViewDelegateLayout
extension ShowSongsListCollectionViewController {
	override func columnCount(forSection section: Int, layout layoutEnvironment: NSCollectionLayoutEnvironment) -> Int {
		let width = layoutEnvironment.container.effectiveContentSize.width
		let columnCount = Int((width / 250.0).rounded())
		return columnCount > 0 ? columnCount : 1
	}

	override func createLayout() -> UICollectionViewLayout? {
		return UICollectionViewCompositionalLayout { [weak self] section, layoutEnvironment in
			guard let self = self else { return nil }
			let columns = self.columnCount(forSection: section, layout: layoutEnvironment)
			let layoutSection = Layouts.musicSection(section, columns: columns, layoutEnvironment: layoutEnvironment, isHorizontal: false)

			if self.showIdentity != nil {
				let headerFooterSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(50.0))
				let sectionHeader = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerFooterSize, elementKind: UICollectionView.elementKindSectionHeader, alignment: .top)
				layoutSection.boundarySupplementaryItems = [sectionHeader]
			}

			return layoutSection
		}
	}
}

// MARK: - UICollectionViewDelegate
extension ShowSongsListCollectionViewController {
	override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		if self.songsListFetchType == .charts {
			guard let song = self.cache[indexPath] as? Song else { return }

			self.show(.songDetailsSegue, sender: song)
		} else if !self.showSongs.isEmpty {
			guard let showSong = self.showSongs[safe: indexPath.item] else { return }

			self.show(.songDetailsSegue, sender: showSong.song)
		} else if !self.songs.isEmpty {
			guard let song = self.songs[safe: indexPath.item] else { return }

			self.show(.songDetailsSegue, sender: song)
		}
	}

	override func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
		guard self.songsListFetchType == .charts else { return }

		self.paginateIfNeeded(at: indexPath, totalItems: self.songIdentities.count)
	}

	override func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
		let collectionViewCell = collectionView.cellForItem(at: indexPath)

		if self.songsListFetchType == .charts {
			guard
				let song = self.cache[indexPath] as? Song,
				let appleMusicID = song.attributes.amID,
				let resolvedSong = self.resolvedSongs[appleMusicID]
			else { return nil }

			return song.contextMenuConfiguration(in: self, userInfo: [
				"indexPath": indexPath,
				"song": resolvedSong
			], sourceView: collectionViewCell?.contentView, barButtonItem: nil)
		} else if !self.showSongs.isEmpty {
			guard
				let showSong = self.showSongs[safe: indexPath.item],
				let appleMusicID = showSong.song.attributes.amID,
				let song = self.resolvedSongs[appleMusicID]
			else { return nil }

			return showSong.song.contextMenuConfiguration(in: self, userInfo: [
				"indexPath": indexPath,
				"song": song
			], sourceView: collectionViewCell?.contentView, barButtonItem: nil)
		} else if !self.songs.isEmpty {
			return self.songs[indexPath.item].contextMenuConfiguration(in: self, userInfo: ["indexPath": indexPath], sourceView: collectionViewCell?.contentView, barButtonItem: nil)
		}

		return nil
	}
}

// MARK: - TitleHeaderCollectionReusableViewDelegate
extension ShowSongsListCollectionViewController: TitleHeaderCollectionReusableViewDelegate {
	func titleHeaderCollectionReusableView(_ reusableView: TitleHeaderCollectionReusableView, didPress button: UIButton) {}
}

// MARK: - MusicLockupCollectionViewCellDelegate
extension ShowSongsListCollectionViewController: MusicLockupCollectionViewCellDelegate {
	func showButtonPressed(_ sender: UIButton, indexPath: IndexPath) {
		guard let show = self.showSongs[safe: indexPath.item]?.show else { return }

		self.show(.showDetailsSegue, sender: show)
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

	func musicLockupCollectionViewCell(_ cell: MusicLockupCollectionViewCell, didTapPlayButtonAt indexPath: IndexPath) {
		switch self.songsListFetchType {
		case .show:
			let kkSongs = self.showSongs.isEmpty ? self.songs : self.showSongs.map { $0.song }
			guard kkSongs.indices.contains(indexPath.item) else { return }
			let tappedItem = indexPath.item

			Task { [weak self] in
				guard self != nil else { return }

				let appleMusicIDs = kkSongs.compactMap { $0.attributes.amID }
				let songsByID = await MusicManager.shared.getSongs(for: appleMusicIDs)

				var queueSongs: [MKSong] = []
				var queueKKSongs: [KKSong] = []
				var startIndex = 0

				for (offset, kkSong) in kkSongs.enumerated() {
					guard let appleMusicID = kkSong.attributes.amID, let song = songsByID[appleMusicID] else { continue }
					if offset == tappedItem {
						startIndex = queueSongs.count
					}
					queueSongs.append(song)
					queueKKSongs.append(kkSong)
				}

				guard !queueSongs.isEmpty else { return }
				MusicManager.shared.play(songs: queueSongs, kkSongs: queueKKSongs, startingAt: startIndex)
			}
		case .charts:
			let kkSongs: [KKSong] = self.songIdentities.indices.compactMap { index in
				self.cache[IndexPath(item: index, section: 0)] as? Song
			}
			guard let tappedSong = self.cache[indexPath] as? Song else { return }

			Task { [weak self] in
				guard self != nil else { return }

				let appleMusicIDs = kkSongs.compactMap { $0.attributes.amID }
				let songsByID = await MusicManager.shared.getSongs(for: appleMusicIDs)

				var queueSongs: [MKSong] = []
				var queueKKSongs: [KKSong] = []
				var startIndex = 0

				for kkSong in kkSongs {
					guard let appleMusicID = kkSong.attributes.amID, let song = songsByID[appleMusicID] else { continue }
					if kkSong.id == tappedSong.id {
						startIndex = queueSongs.count
					}
					queueSongs.append(song)
					queueKKSongs.append(kkSong)
				}

				guard !queueSongs.isEmpty else { return }
				MusicManager.shared.play(songs: queueSongs, kkSongs: queueKKSongs, startingAt: startIndex)
			}
		}
	}
}
