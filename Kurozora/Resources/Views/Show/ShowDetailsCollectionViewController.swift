//
//  ShowDetailsCollectionViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 09/08/2018.
//  Copyright © 2018 Kurozora. All rights reserved.
//

import UIKit
import KurozoraKit
import Alamofire
import AVFoundation
import Intents
import IntentsUI

class ShowDetailsCollectionViewController: KCollectionViewController {
	// MARK: - IBOutlets
	@IBOutlet weak var navigationTitleView: UIView!
	@IBOutlet weak var navigationTitleLabel: UILabel! {
		didSet {
			self.navigationTitleLabel.theme_textColor = KThemePicker.barTitleTextColor.rawValue
		}
	}

	// MARK: - Properties
	var showIdentity: ShowIdentity? = nil
	var show: Show! {
		didSet {
			self.navigationTitleLabel.text = self.show.attributes.title
			self.showIdentity = ShowIdentity(id: self.show.id)

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
	var responseCount: Int = 0 {
		didSet {
			if self.responseCount == 6 {
				self.updateDataSource()
			}
		}
	}

	/// Season properties.
	var seasons: [IndexPath: Season] = [:]
	var seasonIdentities: [SeasonIdentity] = []

	/// Related Show properties.
	var relatedShows: [RelatedShow] = []

	/// Cast properties.
	var cast: [IndexPath: Cast] = [:]
	var castIdentities: [CastIdentity] = []

	/// Studio properties.
	var studios: [IndexPath: Studio] = [:]
	var studioIdentities: [StudioIdentity] = []
//	var studio: Studio!
	var studioShows: [IndexPath: Show] = [:]
	var studioShowIdentities: [ShowIdentity] = []

	/// Show Song properties.
	var showSongs: [ShowSong] = []

	/// The object that provides the interface to control the player’s transport behavior.
	var player: AVPlayer?

	/// The index path of the song that's currently playing.
	var currentPlayerIndexPath: IndexPath?

	var dataSource: UICollectionViewDiffableDataSource<SectionLayoutKind, ItemKind>! = nil
	var snapshot: NSDiffableDataSourceSnapshot<SectionLayoutKind, ItemKind>! = nil
	var prefetchingIndexPathOperations: [IndexPath: DataRequest] = [:]

	// Touch Bar
	#if targetEnvironment(macCatalyst)
	var toggleShowIsFavoriteTouchBarItem: NSButtonTouchBarItem?
	var toggleShowIsRemindedTouchBarItem: NSButtonTouchBarItem?
	#endif

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

	// MARK: - Initializers
	/// Initialize a new instance of ShowDetailsCollectionViewController with the given show id.
	///
	/// - Parameter showID: The show id to use when initializing the view.
	///
	/// - Returns: an initialized instance of ShowDetailsCollectionViewController.
	static func `init`(with showID: Int) -> ShowDetailsCollectionViewController {
		if let showDetailsCollectionViewController = R.storyboard.shows.showDetailsCollectionViewController() {
			showDetailsCollectionViewController.showIdentity = ShowIdentity(id: showID)
			return showDetailsCollectionViewController
		}

		fatalError("Failed to instantiate ShowDetailsCollectionViewController with the given show id.")
	}

	/// Initialize a new instance of ShowDetailsCollectionViewController with the given show object.
	///
	/// - Parameter show: The `Show` object to use when initializing the view controller.
	///
	/// - Returns: an initialized instance of ShowDetailsCollectionViewController.
	static func `init`(with show: Show) -> ShowDetailsCollectionViewController {
		if let showDetailsCollectionViewController = R.storyboard.shows.showDetailsCollectionViewController() {
			showDetailsCollectionViewController.show = show
			return showDetailsCollectionViewController
		}

		fatalError("Failed to instantiate ShowDetailsCollectionViewController with the given Show object.")
	}

	// MARK: - View
	override func viewDidLoad() {
		super.viewDidLoad()
		NotificationCenter.default.addObserver(self, selector: #selector(handleFavoriteToggle(_:)), name: .KShowFavoriteIsToggled, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(handleReminderToggle(_:)), name: .KShowReminderIsToggled, object: nil)

		self.navigationTitleLabel.alpha = 0

		// Add refresh control
		#if DEBUG
		self._prefersRefreshControlDisabled = false
		#else
		self._prefersRefreshControlDisabled = true
		#endif

		self.configureDataSource()

		// Fetch show details.
		Task { [weak self] in
			guard let self = self else { return }
			await self.fetchDetails()
		}
	}

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)

		// Make the navigation bar background clear
		self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
		self.navigationController?.navigationBar.shadowImage = UIImage()
	}

	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)

		// Restore the navigation bar to default
		self.navigationController?.navigationBar.setBackgroundImage(nil, for: .default)
		self.navigationController?.navigationBar.shadowImage = nil
	}

	// MARK: - Functions
	override func handleRefreshControl() {
		Task { [weak self] in
			guard let self = self else { return }
			await self.fetchDetails()
		}
	}

	override func configureEmptyDataView() {
		emptyBackgroundView.configureImageView(image: R.image.empty.library()!)
		emptyBackgroundView.configureLabels(title: "No Details", detail: "This show doesn't have details yet. Please check back again later.")

		collectionView.backgroundView?.alpha = 0
	}

	/// Fades in and out the empty data view according to the number of rows.
	func toggleEmptyDataView() {
		if self.collectionView.numberOfSections == 0 {
			self.collectionView.backgroundView?.animateFadeIn()
		} else {
			self.collectionView.backgroundView?.animateFadeOut()
		}
	}

	/// Fetches details for the given show identity. If none given then the currently viewed show's details are fetched.
	func fetchDetails() async {
		guard let showIdentity = self.showIdentity else { return }

		if self.show == nil {
			KService.getDetails(forShow: showIdentity) { [weak self] result in
				guard let self = self else { return }
				switch result {
				case .success(let shows):
					self.show = shows.first

					// Donate suggestion to Siri
					self.userActivity = self.show.openDetailUserActivity
				case .failure: break
				}
			}
		} else {
			// Donate suggestion to Siri
			self.userActivity = self.show.openDetailUserActivity

			self.updateDataSource()
		}

		do {
			let seasonIdentityResponse = try await KService.getSeasons(forShow: showIdentity, reversed: true, next: nil, limit: 10).value
			self.seasonIdentities = seasonIdentityResponse.data
			self.responseCount += 1
		} catch {
			print(error.localizedDescription)
		}

		do {
			let castIdentityResponse = try await KService.getCast(forShow: showIdentity, limit: 10).value
			self.castIdentities = castIdentityResponse.data
			self.responseCount += 1
		} catch {
			print(error.localizedDescription)
		}

		do {
			let showSongResponse = try await KService.getSongs(forShow: showIdentity, limit: 10).value
			self.showSongs = showSongResponse.data
			self.responseCount += 1
		} catch {
			print(error.localizedDescription)
		}

		do {
			let studioIdentityResponse = try await KService.getStudios(forShow: showIdentity, limit: 10).value
			self.studioIdentities = studioIdentityResponse.data

			self.responseCount += 1
		} catch {
			print(error.localizedDescription)
		}

		do {
			let showIdentityResponse = try await KService.getMoreByStudio(forShow: showIdentity, limit: 10).value
			self.studioShowIdentities = showIdentityResponse.data

			self.responseCount += 1
		} catch {
			print(error.localizedDescription)
		}

		do {
			let relatedShowResponse = try await KService.getRelatedShows(forShow: showIdentity, limit: 10).value
			self.relatedShows = relatedShowResponse.data
			self.responseCount += 1
		} catch {
			print(error.localizedDescription)
		}
	}

	@objc func toggleFavorite() {
		self.show?.toggleFavorite()
	}

	@objc func toggleReminder() {
		self.show?.toggleReminder()
	}

	@objc func shareShow() {
		self.show?.openShareSheet(on: self)
	}

	@objc func handleFavoriteToggle(_ notification: NSNotification) {
		#if targetEnvironment(macCatalyst)
		let name = self.show.attributes.favoriteStatus == .favorited ? "heart.fill" : "heart"
		self.toggleShowIsFavoriteTouchBarItem?.image = UIImage(systemName: name)
		#endif
	}

	@objc func handleReminderToggle(_ notification: NSNotification) {
		#if targetEnvironment(macCatalyst)
		let name = self.show.attributes.reminderStatus == .reminded ? "bell.fill" : "bell"
		self.toggleShowIsRemindedTouchBarItem?.image = UIImage(systemName: name)
		#endif
	}

	// MARK: - IBActions
	@IBAction func moreButtonPressed(_ sender: UIBarButtonItem) {
		self.show?.openShareSheet(on: self, barButtonItem: sender)
	}

	// MARK: - Segue
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		switch segue.identifier {
		case R.segue.showDetailsCollectionViewController.seasonsListSegue.identifier:
			guard let seasonsCollectionViewController = segue.destination as? SeasonsListCollectionViewController else { return }
			seasonsCollectionViewController.showIdentity = self.showIdentity
		case R.segue.showDetailsCollectionViewController.castListSegue.identifier:
			guard let castListCollectionViewController = segue.destination as? CastListCollectionViewController else { return }
			castListCollectionViewController.showIdentity = self.showIdentity
		case R.segue.showDetailsCollectionViewController.songsListSegue.identifier:
			guard let showSongsListCollectionViewController = segue.destination as? ShowSongsListCollectionViewController else { return }
			showSongsListCollectionViewController.showIdentity = self.showIdentity
		case R.segue.showDetailsCollectionViewController.episodesListSegue.identifier:
			guard let episodesListCollectionViewController = segue.destination as? EpisodesListCollectionViewController else { return }
			guard let season = sender as? Season else { return }
			episodesListCollectionViewController.seasonIdentity = SeasonIdentity(id: season.id)
			episodesListCollectionViewController.episodesListFetchType = .season
		case R.segue.showDetailsCollectionViewController.showsListSegue.identifier:
			guard let showsListCollectionViewController = segue.destination as? ShowsListCollectionViewController else { return }
			guard let indexPath = sender as? IndexPath else { return }

			if indexPath.section == SectionLayoutKind.moreByStudio.rawValue {
				showsListCollectionViewController.title = "\(Trans.moreBy) \(self.show.attributes.studio ?? Trans.studio)"
				showsListCollectionViewController.showIdentity = self.showIdentity
				showsListCollectionViewController.showsListFetchType = .moreByStudio
			} else {
				showsListCollectionViewController.title = "Related"
				showsListCollectionViewController.showIdentity = self.showIdentity
				showsListCollectionViewController.showsListFetchType = .relatedShow
			}
		case R.segue.showDetailsCollectionViewController.studiosListSegue.identifier:
			guard let studiosListCollectionViewController = segue.destination as? StudiosListCollectionViewController else { return }
			studiosListCollectionViewController.showIdentity = self.showIdentity
			studiosListCollectionViewController.studiosListFetchType = .show
		case R.segue.showDetailsCollectionViewController.showDetailsSegue.identifier:
			guard let showDetailsCollectionViewController = segue.destination as? ShowDetailsCollectionViewController else { return }
			guard let show = sender as? Show else { return }
			showDetailsCollectionViewController.show = show
		case R.segue.showDetailsCollectionViewController.studioDetailsSegue.identifier:
			guard let studioDetailsCollectionViewController = segue.destination as? StudioDetailsCollectionViewController else { return }
			guard let studio = sender as? Studio else { return }
			studioDetailsCollectionViewController.studio = studio
		case R.segue.showDetailsCollectionViewController.characterDetailsSegue.identifier:
			guard let characterDetailsCollectionViewController = segue.destination as? CharacterDetailsCollectionViewController else { return }
			guard let cell = sender as? CastCollectionViewCell else { return }
			guard let indexPath = self.collectionView.indexPath(for: cell) else { return }
			guard let character = self.cast[indexPath]?.relationships.characters.data.first else { return }
			characterDetailsCollectionViewController.character = character
		case R.segue.showDetailsCollectionViewController.personDetailsSegue.identifier:
			guard let personDetailsCollectionViewController = segue.destination as? PersonDetailsCollectionViewController else { return }
			guard let cell = sender as? CastCollectionViewCell else { return }
			guard let indexPath = self.collectionView.indexPath(for: cell) else { return }
			guard let person = self.cast[indexPath]?.relationships.people.data.first else { return }
			personDetailsCollectionViewController.person = person
		default: break
		}
	}
}

// MARK: - CastCollectionViewCellDelegate
extension ShowDetailsCollectionViewController: CastCollectionViewCellDelegate {
	func castCollectionViewCell(_ cell: CastCollectionViewCell, didPressPersonButton button: UIButton) {
		self.performSegue(withIdentifier: R.segue.showDetailsCollectionViewController.personDetailsSegue.identifier, sender: cell)
	}

	func castCollectionViewCell(_ cell: CastCollectionViewCell, didPressCharacterButton button: UIButton) {
		self.performSegue(withIdentifier: R.segue.showDetailsCollectionViewController.characterDetailsSegue.identifier, sender: cell)
	}
}

// MARK: - TextViewCollectionViewCellDelegate
extension ShowDetailsCollectionViewController: TextViewCollectionViewCellDelegate {
	func textViewCollectionViewCell(_ cell: TextViewCollectionViewCell, didPressButton button: UIButton) {
		if let synopsisKNavigationController = R.storyboard.synopsis.instantiateInitialViewController() {
			if let synopsisViewController = synopsisKNavigationController.viewControllers.first as? SynopsisViewController {
				synopsisViewController.title = cell.textViewCollectionViewCellType.stringValue
				synopsisViewController.synopsis = self.show.attributes.synopsis
			}
			synopsisKNavigationController.modalPresentationStyle = .fullScreen
			self.present(synopsisKNavigationController, animated: true)
		}
	}
}

// MARK: - TitleHeaderCollectionReusableViewDelegate
extension ShowDetailsCollectionViewController: TitleHeaderCollectionReusableViewDelegate {
	func titleHeaderCollectionReusableView(_ reusableView: TitleHeaderCollectionReusableView, didPressButton button: UIButton) {
		self.performSegue(withIdentifier: reusableView.segueID, sender: reusableView.indexPath)
	}
}

// MARK: - UIScrollViewDelegate
extension ShowDetailsCollectionViewController {
	override func scrollViewDidScroll(_ scrollView: UIScrollView) {
		let navigationBar = self.navigationController?.navigationBar
		let firstCell = self.collectionView.cellForItem(at: [0, 0])

		let globalNavigationBarPositionY = navigationBar?.superview?.convert(navigationBar?.frame.origin ?? CGPoint(x: 0, y: 0), to: nil).y ?? .zero
		let offset = scrollView.contentOffset.y
		let firstCellHeight = firstCell?.frame.size.height ?? .zero

		let percentage = offset / (firstCellHeight - globalNavigationBarPositionY)

		if percentage.isFinite, percentage >= 0 {
			self.navigationTitleLabel.alpha = percentage
		}
	}
}

// MARK: - RatingCollectionViewCellDelegate
extension ShowDetailsCollectionViewController: RatingCollectionViewCellDelegate {
	func rateShow(with rating: Double) {
		self.show.rate(using: rating)
	}

	func rateEpisode(with rating: Double) { }
}

// MARK: - MusicLockupCollectionViewCellDelegate
extension ShowDetailsCollectionViewController: MusicLockupCollectionViewCellDelegate {
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
					if let cell = self.collectionView.cellForItem(at: indexPath) as? MusicLockupCollectionViewCell {
						cell.playButton.setImage(UIImage(systemName: "play.circle.fill"), for: .normal)
					}
				}

				self.currentPlayerIndexPath = cell.indexPath
				self.player = AVPlayer(playerItem: playerItem)
				self.player?.actionAtItemEnd = .none
				self.player?.play()
				cell.playButton.setImage(UIImage(systemName: "pause.circle.fill"), for: .normal)

				NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object: nil, queue: .current, using: { [weak self] _ in
					self?.player = nil
					cell.playButton.setImage(UIImage(systemName: "play.circle.fill"), for: .normal)
				})
			}
		}
	}

	func showButtonPressed(_ sender: UIButton, indexPath: IndexPath) {}
}

extension ShowDetailsCollectionViewController {
	enum SectionLayoutKind: Int, CaseIterable {
		// MARK: - Cases
		/// Indicates a header section layout type.
		case header = 0
		case badge
		case synopsis
		case rating
		case information
		case seasons
		case cast
		case songs
		case studios
		case moreByStudio
		case relatedShows
		case sosumi

		// MARK: - Properties
		/// The string value of a show section type.
		var stringValue: String {
			switch self {
			case .header:
				return Trans.header
			case .badge:
				return Trans.badges
			case .synopsis:
				return Trans.synopsis
			case .rating:
				return Trans.ratings
			case .information:
				return Trans.information
			case .seasons:
				return Trans.seasons
			case .cast:
				return Trans.cast
			case .songs:
				return Trans.songs
			case .studios:
				return Trans.studios
			case .moreByStudio:
				return Trans.moreBy
			case .relatedShows:
				return Trans.related
			case .sosumi:
				return Trans.copyright
			}
		}

		/// The string value of a show section type segue identifier.
		var segueIdentifier: String {
			switch self {
			case .header:
				return ""
			case .badge:
				return ""
			case .synopsis:
				return ""
			case .rating:
				return ""
			case .information:
				return ""
			case .seasons:
				return R.segue.showDetailsCollectionViewController.seasonsListSegue.identifier
			case .cast:
				return R.segue.showDetailsCollectionViewController.castListSegue.identifier
			case .songs:
				return R.segue.showDetailsCollectionViewController.songsListSegue.identifier
			case .studios:
				return R.segue.showDetailsCollectionViewController.studiosListSegue.identifier
			case .moreByStudio:
				return R.segue.showDetailsCollectionViewController.showsListSegue.identifier
			case .relatedShows:
				return R.segue.showDetailsCollectionViewController.showsListSegue.identifier
			case .sosumi:
				return ""
			}
		}
	}

	/// List of available Item Kind types.
	enum ItemKind: Hashable {
		// MARK: - Cases
		/// Indicates the item kind contains a `Show` object.
		case show(_: Show, id: UUID = UUID())

		/// Indicates the item kind contains a `SeasonIdentity` object.
		case seasonIdentity(_: SeasonIdentity, id: UUID = UUID())

		/// Indicates the item kind contains a `ShowIdentity` object.
		case showIdentity(_: ShowIdentity, id: UUID = UUID())

		/// Indicates the item kind contains a `RelatedShow` object.
		case relatedShow(_: RelatedShow, id: UUID = UUID())

		/// Indicates the item kind contains a `ShowSong` object.
		case showSong(_: ShowSong, id: UUID = UUID())

		/// Indicates the item kind contains a `CharacterIdentity` object.
		case characterIdentity(_: CharacterIdentity, id: UUID = UUID())

		/// Indicates the item kind contains a `PersonIdentity` object.
		case personIdentity(_: PersonIdentity, id: UUID = UUID())

		/// Indicates the item kind contains a `CastIdentity` object.
		case castIdentity(_: CastIdentity, id: UUID = UUID())

		/// Indicates the item kind contains a `StudioIdentity` object.
		case studioIdentity(_: StudioIdentity, id: UUID = UUID())

		// MARK: - Functions
		func hash(into hasher: inout Hasher) {
			switch self {
			case .show(let show, let id):
				hasher.combine(show)
				hasher.combine(id)
			case .seasonIdentity(let seasonIdentity, let id):
				hasher.combine(seasonIdentity)
				hasher.combine(id)
			case .showIdentity(let showIdentity, let id):
				hasher.combine(showIdentity)
				hasher.combine(id)
			case .relatedShow(let relatedShow, let id):
				hasher.combine(relatedShow)
				hasher.combine(id)
			case .showSong(let showSong, let id):
				hasher.combine(showSong)
				hasher.combine(id)
			case .characterIdentity(let characterIdentity, let id):
				hasher.combine(characterIdentity)
				hasher.combine(id)
			case .personIdentity(let personIdentity, let id):
				hasher.combine(personIdentity)
				hasher.combine(id)
			case .castIdentity(let castIdentity, let id):
				hasher.combine(castIdentity)
				hasher.combine(id)
			case .studioIdentity(let studioIdentity, let id):
				hasher.combine(studioIdentity)
				hasher.combine(id)
			}
		}

		static func == (lhs: ItemKind, rhs: ItemKind) -> Bool {
			switch (lhs, rhs) {
			case (.show(let show1, let id1), .show(let show2, let id2)):
				return show1 == show2 && id1 == id2
			case (.seasonIdentity(let seasonIdentity1, let id1), .seasonIdentity(let seasonIdentity2, let id2)):
				return seasonIdentity1 == seasonIdentity2 && id1 == id2
			case (.showIdentity(let showIdentity1, let id1), .showIdentity(let showIdentity2, let id2)):
				return showIdentity1 == showIdentity2 && id1 == id2
			case (.relatedShow(let relatedShow1, let id1), .relatedShow(let relatedShow2, let id2)):
				return relatedShow1 == relatedShow2 && id1 == id2
			case (.showSong(let showSong1, let id1), .showSong(let showSong2, let id2)):
				return showSong1 == showSong2 && id1 == id2
			case (.characterIdentity(let characterIdentity1, let id1), .characterIdentity(let characterIdentity2, let id2)):
				return characterIdentity1 == characterIdentity2 && id1 == id2
			case (.personIdentity(let personIdentity1, let id1), .personIdentity(let personIdentity2, let id2)):
				return personIdentity1 == personIdentity2 && id1 == id2
			case (.castIdentity(let castIdentity1, let id1), .castIdentity(let castIdentity2, let id2)):
				return castIdentity1 == castIdentity2 && id1 == id2
			case (.studioIdentity(let studioIdentity1, let id1), .studioIdentity(let studioIdentity2, let id2)):
				return studioIdentity1 == studioIdentity2 && id1 == id2
			default:
				return false
			}
		}
	}
}
