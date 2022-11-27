//
//  SongDetailsCollectionViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 26/11/2022.
//  Copyright © 2022 Kurozora. All rights reserved.
//

import UIKit
import KurozoraKit
import MusicKit
import Alamofire
import AVFoundation
import MediaPlayer

class SongDetailsCollectionViewController: KCollectionViewController {
	// MARK: - IBOutlets
	@IBOutlet weak var moreButton: UIBarButtonItem!

	// MARK: - Properties
	var songIdentity: SongIdentity? = nil
	var song: KKSong! {
		didSet {
			self.title = self.song.attributes.title
			self.songIdentity = SongIdentity(id: self.song.id)

			self._prefersActivityIndicatorHidden = true

			#if DEBUG
			#if !targetEnvironment(macCatalyst)
			self.refreshControl?.endRefreshing()
			#endif
			#endif
		}
	}
	var shows: [IndexPath: Show] = [:]
	var showIdentities: [ShowIdentity] = []
	var responseCount: Int = 0 {
		didSet {
			if self.responseCount == 2 {
				self.updateDataSource()
			}
		}
	}
	var appleMusicLink: URL?

	var dataSource: UICollectionViewDiffableDataSource<SectionLayoutKind, ItemKind>! = nil
	var snapshot: NSDiffableDataSourceSnapshot<SectionLayoutKind, ItemKind>! = nil
	var prefetchingIndexPathOperations: [IndexPath: DataRequest] = [:]

	/// The object that provides the interface to control the player’s transport behavior.
	var player: AVPlayer?

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

	// MARK: - Initializers
	/// Initialize a new instance of SongDetailsCollectionViewController with the given song id.
	///
	/// - Parameter songID: The song id to use when initializing the view.
	///
	/// - Returns: an initialized instance of SongDetailsCollectionViewController.
	static func `init`(with songID: Int) -> SongDetailsCollectionViewController {
		if let songDetailsCollectionViewController = R.storyboard.songs.songDetailsCollectionViewController() {
			songDetailsCollectionViewController.songIdentity = SongIdentity(id: songID)
			return songDetailsCollectionViewController
		}

		fatalError("Failed to instantiate SongDetailsCollectionViewController with the given song id.")
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

		Task { [weak self] in
			guard let self = self else { return }
			await self.fetchDetails()
		}
	}

	// MARK: - Functions
	override func handleRefreshControl() {
		Task { [weak self] in
			guard let self = self else { return }
			await self.fetchDetails()
		}
	}

	override func configureEmptyDataView() {
		emptyBackgroundView.configureImageView(image: R.image.empty.cast()!)
		emptyBackgroundView.configureLabels(title: "No Details", detail: "This song doesn't have details yet. Please check back again later.")

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

	/// Fetches the currently viewed song's details.
	func fetchDetails() async {
		guard let songIdentity = self.songIdentity else { return }

		do {
			let songResponse = try await KService.getDetails(forSong: songIdentity).value
			self.song = songResponse.data.first

			self.moreButton.menu = self.song?.makeContextMenu(in: self, userInfo: [:])

			self.responseCount += 1
		} catch {
			print(error.localizedDescription)
		}

		do {
			let showIdentityResponse = try await KService.getShows(forSong: songIdentity, limit: 10).value
			self.showIdentities = showIdentityResponse.data
			self.responseCount += 1
		} catch {
			print(error.localizedDescription)
		}
	}

	// MARK: - Segue
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		switch segue.identifier {
		case R.segue.songDetailsCollectionViewController.showDetailsSegue.identifier:
			guard let showDetailCollectionViewController = segue.destination as? ShowDetailsCollectionViewController else { return }
			guard let show = sender as? Show else { return }
			showDetailCollectionViewController.show = show
		default: break
		}
	}
}

// MARK: - UICollectionViewDataSource
extension SongDetailsCollectionViewController {
	override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
		let songDetailSection = self.snapshot.sectionIdentifiers[indexPath.section]
		let titleHeaderCollectionReusableView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withClass: TitleHeaderCollectionReusableView.self, for: indexPath)
		titleHeaderCollectionReusableView.delegate = self
		titleHeaderCollectionReusableView.configure(withTitle: songDetailSection.stringValue, indexPath: indexPath, segueID: songDetailSection.segueIdentifier)
		return titleHeaderCollectionReusableView
	}
}

// MARK: - TitleHeaderCollectionReusableViewDelegate
extension SongDetailsCollectionViewController: TitleHeaderCollectionReusableViewDelegate {
	func titleHeaderCollectionReusableView(_ reusableView: TitleHeaderCollectionReusableView, didPress button: UIButton) {
		self.performSegue(withIdentifier: reusableView.segueID, sender: reusableView.indexPath)
	}
}

// MARK: - BaseLockupCollectionViewCellDelegate
extension SongDetailsCollectionViewController: BaseLockupCollectionViewCellDelegate {
	func baseLockupCollectionViewCell(_ cell: BaseLockupCollectionViewCell, didPressStatus button: UIButton) {
		WorkflowController.shared.isSignedIn {
			guard let indexPath = self.collectionView.indexPath(for: cell) else { return }
			guard let show = self.shows[indexPath] else { return }

			let oldLibraryStatus = cell.libraryStatus
			let actionSheetAlertController = UIAlertController.actionSheetWithItems(items: KKLibrary.Status.alertControllerItems, currentSelection: oldLibraryStatus, action: { title, value  in
				KService.addToLibrary(withLibraryStatus: value, showID: show.id) { result in
					switch result {
					case .success(let libraryUpdate):
						show.attributes.update(using: libraryUpdate)

						// Update entry in library
						cell.libraryStatus = value
						button.setTitle("\(title) ▾", for: .normal)

						let libraryAddToNotificationName = Notification.Name("AddTo\(value.sectionValue)Section")
						NotificationCenter.default.post(name: libraryAddToNotificationName, object: nil)
					case .failure:
						break
					}
				}
			})

			if cell.libraryStatus != .none {
				actionSheetAlertController.addAction(UIAlertAction(title: "Remove from library", style: .destructive) { _ in
					KService.removeFromLibrary(showID: show.id) { result in
						switch result {
						case .success(let libraryUpdate):
							show.attributes.update(using: libraryUpdate)

							// Update edntry in library
							cell.libraryStatus = .none
							button.setTitle("ADD", for: .normal)

							let libraryRemoveFromNotificationName = Notification.Name("RemoveFrom\(oldLibraryStatus.sectionValue)Section")
							NotificationCenter.default.post(name: libraryRemoveFromNotificationName, object: nil)
						case .failure:
							break
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
	}

	func baseLockupCollectionViewCell(_ cell: BaseLockupCollectionViewCell, didPressReminder button: UIButton) {
		guard let indexPath = self.collectionView.indexPath(for: cell) else { return }
		guard let show = self.shows[indexPath] else { return }
		show.toggleReminder()
	}
}

// MARK: - SongHeaderCollectionViewCellDelegate
extension SongDetailsCollectionViewController: SongHeaderCollectionViewCellDelegate {
	func saveAppleMusicSong(_ song: MusicKit.Song?) {
		DispatchQueue.main.async {
			self.moreButton.menu = self.song?.makeContextMenu(in: self, userInfo: ["appleMusicLink": song?.url])
		}
	}

	func playButtonPressed(_ sender: UIButton, cell: SongHeaderCollectionViewCell) {
		guard let song = cell.song else { return }

		if let songURL = song.previewAssets?.first?.url {
			let playerItem = AVPlayerItem(url: songURL)

			if (self.player?.currentItem?.asset as? AVURLAsset)?.url == (playerItem.asset as? AVURLAsset)?.url {
				switch self.player?.timeControlStatus {
				case .playing:
					cell.playButton.setImage(UIImage(systemName: "play.fill"), for: .normal)
					cell.playButton.setTitle(Trans.preview.uppercased(), for: .normal)
					self.player?.pause()
				case .paused:
					cell.playButton.setImage(UIImage(systemName: "pause.fill"), for: .normal)
					cell.playButton.setTitle(Trans.stop.uppercased(), for: .normal)
					self.player?.play()
				default: break
				}
			} else {
				self.player = AVPlayer(playerItem: playerItem)
				self.player?.actionAtItemEnd = .none
				self.player?.play()
				cell.playButton.setImage(UIImage(systemName: "pause.fill"), for: .normal)
				cell.playButton.setTitle(Trans.stop.uppercased(), for: .normal)

				NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object: nil, queue: .current, using: { [weak self] _ in
					guard let self = self else { return }
					self.player = nil
					cell.playButton.setImage(UIImage(systemName: "play.fill"), for: .normal)
					cell.playButton.setTitle(Trans.preview.uppercased(), for: .normal)
				})
			}
		}
	}
}

extension SongDetailsCollectionViewController {
	enum SectionLayoutKind: Int, CaseIterable {
		// MARK: - Cases
		/// Indicates a header section layout type.
		case header = 0

		/// Indicates shows section layout type.
		case shows

		// MARK: - Properties
		/// The string value of a song section type.
		var stringValue: String {
			switch self {
			case .header:
				return Trans.header
			case .shows:
				return Trans.asHeardOn
			}
		}

		/// The string value of a song section type segue identifier.
		var segueIdentifier: String {
			switch self {
			case .header:
				return ""
			case .shows:
				return ""
			}
		}
	}

	/// List of available Item Kind types.
	enum ItemKind: Hashable {
		// MARK: - Cases
		/// Indicates the item kind contains a `Song` object.
		case song(_: KKSong, id: UUID = UUID())

		/// Indicates the item kind contains a `ShowIdentity` object.
		case showIdentity(_: ShowIdentity, id: UUID = UUID())

		// MARK: - Functions
		func hash(into hasher: inout Hasher) {
			switch self {
			case .song(let song, let id):
				hasher.combine(song)
				hasher.combine(id)
			case .showIdentity(let showIdentity, let id):
				hasher.combine(showIdentity)
				hasher.combine(id)
			}
		}

		static func == (lhs: ItemKind, rhs: ItemKind) -> Bool {
			switch (lhs, rhs) {
			case (.song(let song1, let id1), .song(let song2, let id2)):
				return song1 == song2 && id1 == id2
			case (.showIdentity(let showIdentity1, let id1), .showIdentity(let showIdentity2, let id2)):
				return showIdentity1 == showIdentity2 && id1 == id2
			default:
				return false
			}
		}
	}
}
