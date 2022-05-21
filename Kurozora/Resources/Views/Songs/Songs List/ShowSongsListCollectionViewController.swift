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

class ShowSongsListCollectionViewController: KCollectionViewController {
	// MARK: - Properties
	var showIdentity: ShowIdentity? = nil
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
	var snapshot = NSDiffableDataSourceSnapshot<SectionLayoutKind, ItemKind>()
	var dataSource: UICollectionViewDiffableDataSource<SectionLayoutKind, ItemKind>! = nil

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

		if self.showIdentity != nil {
			DispatchQueue.global(qos: .userInteractive).async {
				self.fetchShowSongs()
			}
		} else {
			self.updateDataSource()
			self.toggleEmptyDataView()
		}
	}

	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)

		self.player?.pause()
	}

	// MARK: - Functions
	override func handleRefreshControl() {
		if self.showIdentity != nil {
			self.fetchShowSongs()
		}
	}

	override func configureEmptyDataView() {
		emptyBackgroundView.configureImageView(image: R.image.empty.cast()!)
		emptyBackgroundView.configureLabels(title: "No show songs", detail: "Can't get show songs list. Please reload the page or restart the app and check your WiFi connection.")

		collectionView.backgroundView?.alpha = 0
	}

	/// Fades in and out the empty data view according to the number of rows.
	func toggleEmptyDataView() {
		if self.collectionView.numberOfItems() == 0 {
			self.collectionView.backgroundView?.animateFadeIn()
		} else {
			self.collectionView.backgroundView?.animateFadeOut()
		}
	}

	func fetchShowSongs() {
		guard let showIdentity = self.showIdentity else { return }

		KService.getSongs(forShow: showIdentity, limit: -1) { [weak self] result in
			guard let self = self else { return }
			switch result {
			case .success(let showSongResponse):
				self.showSongs = showSongResponse.data
				self.groupShowSongs()
				self.updateDataSource()
				self.toggleEmptyDataView()
			case .failure: break
			}
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

	// MARK: - Segue
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		switch segue.identifier {
		case R.segue.showSongsListCollectionViewController.showDetailsSegue.identifier:
			// Segue to show details
			guard let showDetailCollectionViewController = segue.destination as? ShowDetailsCollectionViewController else { return }
			guard let show = sender as? Show else { return }
			showDetailCollectionViewController.show = show
		default: break
		}
	}
}

// MARK: - TitleHeaderCollectionReusableViewDelegate
extension ShowSongsListCollectionViewController: TitleHeaderCollectionReusableViewDelegate {
	func titleHeaderCollectionReusableView(_ reusableView: TitleHeaderCollectionReusableView, didPressButton button: UIButton) {}
}

// MARK: - MusicLockupCollectionViewCellDelegate
extension ShowSongsListCollectionViewController: MusicLockupCollectionViewCellDelegate {
	func playButtonPressed(_ sender: UIButton, cell: MusicLockupCollectionViewCell) {
		guard let song = cell.song else { return }

		if let songURL = song.previewAssets?.first?.url {
			let playerItem = AVPlayerItem(url: songURL)

			if (self.player?.currentItem?.asset as? AVURLAsset)?.url == (playerItem.asset as? AVURLAsset)?.url {
				switch self.player?.timeControlStatus {
				case .playing:
					cell.playButton.setImage(UIImage(systemName: "play.fill"), for: .normal)
					self.player?.pause()
				case .paused:
					cell.playButton.setImage(UIImage(systemName: "pause.fill"), for: .normal)
					self.player?.play()
				default: break
				}
			} else {
				if let indexPath = self.currentPlayerIndexPath {
					if let cell = collectionView.cellForItem(at: indexPath) as? MusicLockupCollectionViewCell {
						cell.playButton.setImage(UIImage(systemName: "play.fill"), for: .normal)
					}
				}

				self.currentPlayerIndexPath = cell.indexPath
				self.player = AVPlayer(playerItem: playerItem)
				self.player?.actionAtItemEnd = .none
				self.player?.play()
				cell.playButton.setImage(UIImage(systemName: "pause.fill"), for: .normal)

				NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object: nil, queue: .current, using: { [weak self] _ in
					guard let self = self else { return }

					self.player = nil
					cell.playButton.setImage(UIImage(systemName: "play.fill"), for: .normal)
				})
			}
		}
	}

	func showButtonPressed(_ sender: UIButton, indexPath: IndexPath) {
		let show = self.showSongs[indexPath.item].show
		self.performSegue(withIdentifier: R.segue.homeCollectionViewController.showDetailsSegue.identifier, sender: show)
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
		/// Indicates the item kind contains a `ShowSong` object.
		case showSong(_: ShowSong, id: UUID = UUID())

		// MARK: - Functions
		func hash(into hasher: inout Hasher) {
			switch self {
			case .showSong(let showSong, let id):
				hasher.combine(showSong)
				hasher.combine(id)
			}
		}

		static func == (lhs: ItemKind, rhs: ItemKind) -> Bool {
			switch (lhs, rhs) {
			case (.showSong(let showSong1, let id1), .showSong(let showSong2, let id2)):
				return showSong1 == showSong2 && id1 == id2
			}
		}
	}
}
