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
	var showID: Int = 0
	var showSongs: [ShowSong] = [] {
		didSet {
			if self.showID != 0 {
				self.groupShowSongs()
			}

			self.configureDataSource()
			self._prefersActivityIndicatorHidden = true
			self.toggleEmptyDataView()
			#if DEBUG
			#if !targetEnvironment(macCatalyst)
			self.refreshControl?.endRefreshing()
			#endif
			#endif

		}
	}
	lazy var showSongCategories: [SongType: [ShowSong]] = [:]
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

		if self.showID != 0 {
			DispatchQueue.global(qos: .userInteractive).async {
				self.fetchShowSongs()
			}
		}
	}

	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)

		self.player?.pause()
	}

	// MARK: - Functions
	override func handleRefreshControl() {
		if self.showID != 0 {
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
		KService.getSongs(forShowID: self.showID) { [weak self] result in
			guard let self = self else { return }
			switch result {
			case .success(let showSongResponse):
				self.showSongs = showSongResponse.data
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
			if let showDetailCollectionViewController = segue.destination as? ShowDetailsCollectionViewController {
				guard let show = sender as? Show else { return }
				showDetailCollectionViewController.showID = show.id
			}
		default: break
		}
	}
}

// MARK: - KCollectionViewDataSource
extension ShowSongsListCollectionViewController {
	override func registerCells(for collectionView: UICollectionView) -> [UICollectionViewCell.Type] {
		return [MusicLockupCollectionViewCell.self]
	}

	override func registerNibs(for collectionView: UICollectionView) -> [UICollectionReusableView.Type] {
		return [TitleHeaderCollectionReusableView.self]
	}

	override func configureDataSource() {
		self.dataSource = UICollectionViewDiffableDataSource<SectionLayoutKind, ItemKind>(collectionView: collectionView) { [weak self] (collectionView: UICollectionView, indexPath: IndexPath, item: ItemKind) -> UICollectionViewCell? in
			guard let self = self else { return nil }
			let showIDExists = self.showID != 0

			switch item {
			case .showSong(let showSong, _):
				let musicLockupCollectionViewCell = collectionView.dequeueReusableCell(withClass: MusicLockupCollectionViewCell.self, for: indexPath)
				musicLockupCollectionViewCell.delegate = self
				musicLockupCollectionViewCell.configureCell(with: showSong, at: indexPath, showEpisodes: showIDExists, showShow: !showIDExists)
				return musicLockupCollectionViewCell
			}
		}

		if self.showID != 0 {
			dataSource.supplementaryViewProvider = { [weak self] (collectionView: UICollectionView, kind: String, indexPath: IndexPath) -> UICollectionReusableView? in
				guard let self = self else { return nil }
				guard let songType = SongType(rawValue: indexPath.section) else { return nil }

				// Get a supplementary view of the desired kind.
				let exploreSectionTitleCell = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withClass: TitleHeaderCollectionReusableView.self, for: indexPath)
				exploreSectionTitleCell.delegate = self
				exploreSectionTitleCell.configure(withTitle: "\(songType.stringValue) (\(self.showSongCategories[songType]?.count ?? 0))")
				return exploreSectionTitleCell
			}
		}

		var snapshot = NSDiffableDataSourceSnapshot<SectionLayoutKind, ItemKind>()

		if self.showID != 0 {
			SongType.allCases.forEach { [weak self] songType in
				guard let self = self else { return }
				if self.showSongCategories.has(key: songType) {
					let sectionHeader = SectionLayoutKind.header()
					snapshot.appendSections([sectionHeader])

					if let showSongCategory = self.showSongCategories[songType] {
						let showSongItems: [ItemKind] = showSongCategory.map { showSong in
							return .showSong(showSong)
						}
						snapshot.appendItems(showSongItems, toSection: sectionHeader)
					}
				}
			}
		} else {
			let sectionHeader = SectionLayoutKind.header()
			snapshot.appendSections([sectionHeader])

			let showSongItems: [ItemKind] = self.showSongs.map { showSong in
				return .showSong(showSong)
			}
			snapshot.appendItems(showSongItems, toSection: sectionHeader)
		}

		self.dataSource.apply(snapshot)
	}
}

// MARK: - KCollectionViewDelegateLayout
extension ShowSongsListCollectionViewController {
	override func columnCount(forSection section: Int, layout layoutEnvironment: NSCollectionLayoutEnvironment) -> Int {
		let width = layoutEnvironment.container.effectiveContentSize.width
		let columnCount = (width / 200).rounded().int
		return columnCount > 0 ? columnCount : 1
	}

	override func contentInset(forItemInSection section: Int, layout collectionViewLayout: NSCollectionLayoutEnvironment) -> NSDirectionalEdgeInsets {
		return NSDirectionalEdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10)
	}

	override func contentInset(forSection section: Int, layout collectionViewLayout: NSCollectionLayoutEnvironment) -> NSDirectionalEdgeInsets {
		return NSDirectionalEdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10)
	}

	override func createLayout() -> UICollectionViewLayout? {
		let layout = UICollectionViewCompositionalLayout { [weak self] (section: Int, layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? in
			guard let self = self else { return nil }
			let columns = self.columnCount(forSection: section, layout: layoutEnvironment)

			// Add layout item.
			let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(100.0))
			let item = NSCollectionLayoutItem(layoutSize: itemSize)

			// Add layout group
			let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(100.0))
			let layoutGroup = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: columns)
			layoutGroup.interItemSpacing = .fixed(10.0)

			// Add layout section.
			let layoutSection = NSCollectionLayoutSection(group: layoutGroup)
			layoutSection.contentInsets = self.contentInset(forSection: section, layout: layoutEnvironment)
			layoutSection.interGroupSpacing = 10.0

			if self.showID != 0 {
				// Add header supplementary view.
				let headerFooterSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(100))
				let sectionHeader = NSCollectionLayoutBoundarySupplementaryItem(
					layoutSize: headerFooterSize,
					elementKind: UICollectionView.elementKindSectionHeader, alignment: .top)
				layoutSection.boundarySupplementaryItems = [sectionHeader]
			}
			return layoutSection
		}
		return layout
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
					cell.playButton.setImage(UIImage(systemName: "play.circle.fill"), for: .normal)
					self.player?.pause()
				case .paused:
					cell.playButton.setImage(UIImage(systemName: "pause.circle.fill"), for: .normal)
					self.player?.play()
				default: break
				}
			} else {
				if let indexPath = self.currentPlayerIndexPath {
					if let cell = collectionView.cellForItem(at: indexPath) as? MusicLockupCollectionViewCell {
						cell.playButton.setImage(UIImage(systemName: "play.circle.fill"), for: .normal)
					}
				}

				self.currentPlayerIndexPath = cell.indexPath
				self.player = AVPlayer(playerItem: playerItem)
				self.player?.actionAtItemEnd = .none
				self.player?.play()
				cell.playButton.setImage(UIImage(systemName: "pause.circle.fill"), for: .normal)

				NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object: nil, queue: .current, using: { [weak self] _ in
					guard let self = self else { return }

					self.player = nil
					cell.playButton.setImage(UIImage(systemName: "play.circle.fill"), for: .normal)
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
				return showSong1.id == showSong2.id && id1 == id2
			}
		}
	}
}
