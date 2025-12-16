//
//  ShowSongsListCollectionViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 20/08/2020.
//  Copyright © 2020 Kurozora. All rights reserved.
//

import UIKit
import KurozoraKit
import AVFoundation

enum SongsListViewType: Int {
	case songs = 0
	case showSongs
}

class ShowSongsListCollectionViewController: KCollectionViewController, SectionFetchable {
	// MARK: - Enums
	enum SegueIdentifiers: String, SegueIdentifier {
		case showDetailsSegue
		case songDetailsSegue
	}

	// MARK: - Properties
	var showIdentity: ShowIdentity?
	var songs: [Song] = [] {
		didSet {
			self._prefersActivityIndicatorHidden = true
			#if DEBUG
			#if !targetEnvironment(macCatalyst)
			self.refreshControl?.endRefreshing()
			#endif
			#endif
		}
	}
	var showSongs: [ShowSong] = [] {
		didSet {
			self._prefersActivityIndicatorHidden = true
			#if DEBUG
			#if !targetEnvironment(macCatalyst)
			self.refreshControl?.endRefreshing()
			#endif
			#endif
		}
	}
	lazy var showSongCategories: [SongType: [ShowSong]] = [:]

	var cache: [IndexPath: KurozoraItem] = [:]
	var isFetchingSection: Set<SectionLayoutKind> = []

	var dataSource: UICollectionViewDiffableDataSource<SectionLayoutKind, ItemKind>!
	var snapshot: NSDiffableDataSourceSnapshot<SectionLayoutKind, ItemKind>!

	/// The object that provides the interface to control the player’s transport behavior.
	var player: AVPlayer?

	/// The index path of the song that's currently playing.
	var currentPlayerIndexPath: IndexPath?

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

	// MARK: - View
	override func viewWillReload() {
		super.viewWillReload()

		self.handleRefreshControl()
	}

	override func viewDidLoad() {
		super.viewDidLoad()

		#if DEBUG
		self._prefersRefreshControlDisabled = false
		#else
		self._prefersRefreshControlDisabled = true
		#endif

		self.configureDataSource()

		if !self.showSongs.isEmpty || !self.songs.isEmpty {
			self.updateDataSource()
			self.toggleEmptyDataView()
		} else {
			Task { [weak self] in
				guard let self = self else { return }
				await self.fetchShowSongs()
			}
		}
	}

	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)

		self.player?.pause()
	}

	// MARK: - Functions
	override func handleRefreshControl() {
		if self.showIdentity != nil {
			Task { [weak self] in
				guard let self = self else { return }
				await self.fetchShowSongs()
			}
		}
	}

	override func configureEmptyDataView() {
		emptyBackgroundView.configureImageView(image: .Empty.cast)
		emptyBackgroundView.configureLabels(title: "No show songs", detail: "Can't get show songs list. Please reload the page or restart the app and check your WiFi connection.")

		collectionView.backgroundView?.alpha = 0
	}

	/// Fades in and out the empty data view according to the number of rows.
	func toggleEmptyDataView() {
		if self.collectionView.numberOfItems == 0 {
			self.collectionView.backgroundView?.animateFadeIn()
		} else {
			self.collectionView.backgroundView?.animateFadeOut()
		}
	}

	func fetchShowSongs() async {
		do {
			guard let showIdentity = self.showIdentity else { return }
			let showSongResponse = try await KService.getSongs(forShow: showIdentity, limit: -1).value
			self.showSongs = showSongResponse.data
			self.groupShowSongs()
			self.updateDataSource()
			self.toggleEmptyDataView()
		} catch {
			print(error.localizedDescription)
		}
	}

	func groupShowSongs() {
		// Group show songs according to their type. (Opening, Ending, etc.)
		var categorisedShowSongs = Dictionary(grouping: showSongs, by: { $0.attributes.type })

		// Reorder grouped show songs according to the position attribute.
		categorisedShowSongs.forEach { key, _ in
			categorisedShowSongs[key]?.sort { $0.attributes.position < $1.attributes.position }
		}

		// Assign the new grouped show songs
		self.showSongCategories = categorisedShowSongs
	}

	// MARK: - SectionFetchable
	func extractIdentity<Element>(from item: ItemKind) -> Element? where Element: KurozoraItem {
		switch item {
		case .song, .showSong: return nil
		}
	}

	// MARK: - Segue
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		guard
			let segueIdentifier = segue.identifier,
			  let segueID = SegueIdentifiers(rawValue: segueIdentifier)
		else { return }

		switch segueID {
		case .showDetailsSegue:
			// Segue to show details
			guard let showDetailsCollectionViewController = segue.destination as? ShowDetailsCollectionViewController else { return }
			guard let show = sender as? Show else { return }
			showDetailsCollectionViewController.show = show
		case .songDetailsSegue:
			// Segue to song details
			guard let songDetailsCollectionViewController = segue.destination as? SongDetailsCollectionViewController else { return }
			guard let song = sender as? Song else { return }
			songDetailsCollectionViewController.song = song
		}
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
		self.performSegue(withIdentifier: SegueIdentifiers.showDetailsSegue, sender: show)
	}
}

// MARK: - SectionLayoutKind
extension ShowSongsListCollectionViewController {
	/// List of available Section Layout Kind types.
	enum SectionLayoutKind: Hashable {
		// MARK: - Cases
		/// Indicates a header section layout type.
		case header(id: UUID = UUID())

		// MARK: - Functions
		func hash(into hasher: inout Hasher) {
			switch self {
			case .header(let id):
				hasher.combine(id)
			}
		}

		static func == (lhs: SectionLayoutKind, rhs: SectionLayoutKind) -> Bool {
			switch (lhs, rhs) {
			case (.header(let id1), .header(let id2)):
				return id1 == id2
			}
		}
	}
}

// MARK: - ItemKind
extension ShowSongsListCollectionViewController {
	/// List of available Item Kind types.
	enum ItemKind: Hashable {
		// MARK: - Cases
		/// Indicates the item kind contains a `Song` object.
		case song(_: Song, id: UUID = UUID())

		/// Indicates the item kind contains a `ShowSong` object.
		case showSong(_: ShowSong, id: UUID = UUID())

		// MARK: - Functions
		func hash(into hasher: inout Hasher) {
			switch self {
			case .song(let song, let id):
				hasher.combine(song)
				hasher.combine(id)
			case .showSong(let showSong, let id):
				hasher.combine(showSong)
				hasher.combine(id)
			}
		}

		static func == (lhs: ItemKind, rhs: ItemKind) -> Bool {
			switch (lhs, rhs) {
			case (.song(let song1, let id1), .song(let song2, let id2)):
				return song1 == song2 && id1 == id2
			case (.showSong(let showSong1, let id1), .showSong(let showSong2, let id2)):
				return showSong1 == showSong2 && id1 == id2
			default:
				return false
			}
		}
	}
}

// MARK: - Cell Configuration
extension ShowSongsListCollectionViewController {
	func getConfiguredMusicCell() -> UICollectionView.CellRegistration<MusicLockupCollectionViewCell, ItemKind> {
		return UICollectionView.CellRegistration<MusicLockupCollectionViewCell, ItemKind>(cellNib: MusicLockupCollectionViewCell.nib) { [weak self] musicLockupCollectionViewCell, indexPath, itemKind in
			guard let self = self else { return }
			musicLockupCollectionViewCell.delegate = self

			switch itemKind {
			case .showSong(let showSong, _):
				let showIDExists = self.showIdentity != nil
				musicLockupCollectionViewCell.configure(using: showSong, at: indexPath, showEpisodes: showIDExists, showShow: !showIDExists)
			case .song(let song, _):
				musicLockupCollectionViewCell.configure(using: song, at: indexPath)
			}
		}
	}
}
