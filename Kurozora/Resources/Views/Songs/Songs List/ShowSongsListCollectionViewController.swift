//
//  ShowSongsListCollectionViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 20/08/2020.
//  Copyright © 2020 Kurozora. All rights reserved.
//

import AVFoundation
import KurozoraKit
import UIKit

/// A display mode for ``ShowSongsListCollectionViewController``.
enum SongsListViewType: Int {
	case songs = 0
	case showSongs
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
		case header(id: UUID = UUID())
	}

	/// An item displayed in the list.
	enum ItemKind: Hashable {
		case song(_: Song, id: UUID = UUID())
		case showSong(_: ShowSong, id: UUID = UUID())
	}

	// MARK: - Properties
	var showIdentity: ShowIdentity?
	var songs: [Song] = []
	var showSongs: [ShowSong] = []
	lazy var showSongCategories: [SongType: [ShowSong]] = [:]

	/// The player that previews songs.
	var player: AVPlayer?

	/// The index path of the currently-playing song.
	var currentPlayerIndexPath: IndexPath?

	// MARK: - SectionFetchable
	var cache: [IndexPath: KurozoraItem] = [:]
	var isFetchingSection: Set<SectionLayoutKind> = []

	var dataSource: UICollectionViewDiffableDataSource<SectionLayoutKind, ItemKind>!
	var snapshot: NSDiffableDataSourceSnapshot<SectionLayoutKind, ItemKind>!

	override var emptyStateImage: UIImage { .Empty.cast }
	override var emptyStateTitle: String { "No show songs" }
	override var emptyStateDetail: String { "Can't get show songs list. Please reload the page or restart the app and check your WiFi connection." }

	override var hasLoadedInitialData: Bool {
		!self.showSongs.isEmpty || !self.songs.isEmpty
	}

	override func viewDidLoad() {
		super.viewDidLoad()

		self.title = L10n.songs
	}

	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		self.player?.pause()
	}

	override func handleRefreshControl() {
		guard self.showIdentity != nil else { return }

		self.nextPageCursor = nil

		Task { [weak self] in
			guard let self = self else { return }
			await self.fetchShowSongs(forceFetch: true)
		}
	}

	override func fetchItems() async {
		await self.fetchShowSongs()
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
		_ = await MusicManager.shared.getSongs(for: appleMusicIDs)

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

		if self.showIdentity != nil {
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
				cell.configure(using: showSong, at: indexPath, showEpisodes: showIDExists, showShow: !showIDExists)
			case .song(let song, _):
				cell.configure(using: song, at: indexPath)
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
		if !self.showSongs.isEmpty {
			guard let showSong = self.showSongs[safe: indexPath.item] else { return }

			self.show(.songDetailsSegue, sender: showSong.song)
		} else if !self.songs.isEmpty {
			guard let song = self.songs[safe: indexPath.item] else { return }

			self.show(.songDetailsSegue, sender: song)
		}
	}

	override func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
		let collectionViewCell = collectionView.cellForItem(at: indexPath)

		if !self.showSongs.isEmpty {
			guard
				let cell = collectionView.cellForItem(at: indexPath) as? MusicLockupCollectionViewCell,
				let song = cell.song
			else { return nil }

			return self.showSongs[indexPath.item].song.contextMenuConfiguration(in: self, userInfo: [
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
}
