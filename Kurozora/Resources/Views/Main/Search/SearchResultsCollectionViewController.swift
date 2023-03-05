//
//  SearchResultsCollectionViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 25/04/2018.
//  Copyright © 2018 Kurozora. All rights reserved.
//

import UIKit
import KurozoraKit
import Alamofire
import AVFoundation
import MediaPlayer

/// The collection view controller in charge of providing the necessary functionalities for searching shows, threads and users.
class SearchResultsCollectionViewController: KCollectionViewController {
	// MARK: - Properties
	/// The collection of results fetched by the search request.
	var searchResults: Search?

	/// The current scope of the search.
	var currentScope: KKSearchScope = .kurozora

	/// The search query that is performed.
	var searachQuery: String = ""

	/// The collection of suggested shows.
	var suggestionElements: [Show] = []

	var characters: [IndexPath: Character] = [:]
	var episodes: [IndexPath: Episode] = [:]
	var people: [IndexPath: Person] = [:]
	var shows: [IndexPath: Show] = [:]
	var literatures: [IndexPath: Literature] = [:]
	var games: [IndexPath: Game] = [:]
	var songs: [IndexPath: Song] = [:]
	var studios: [IndexPath: Studio] = [:]
	var users: [IndexPath: User] = [:]

	/// The object that provides the interface to control the player’s transport behavior.
	var player: AVPlayer?

	/// The index path of the song that's currently playing.
	var currentPlayerIndexPath: IndexPath?

	var dataSource: UICollectionViewDiffableDataSource<SectionLayoutKind, ItemKind>! = nil
	var snapshot: NSDiffableDataSourceSnapshot<SectionLayoutKind, ItemKind>! = nil
	var prefetchingIndexPathOperations: [IndexPath: DataRequest] = [:]

	/// The next page url of the pagination.
	var nextPageURL: String?

	/// Whether a fetch request is currently in progress.
	var isRequestInProgress: Bool = false

	/// The object containing the search controller
	lazy var kSearchController: KSearchController = KSearchController()

	/// Whether to include a search controller in the navigation bar
	var includesSearchBar = true

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
		// Disable Refresh Control & hide Activity Indicator
		self._prefersRefreshControlDisabled = true
		self._prefersActivityIndicatorHidden = true

		self.configureDataSource()

		// Fetch user's search history.
		self.suggestionElements = SearchHistory.getContent()

		if self.includesSearchBar {
			self.setupSearchController()
		}
    }

	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)

		self.player?.pause()
	}

	// MARK: - Functions
	/// Setup the search controller with the desired settings.
	func setupSearchController() {
		// Set the current view as the view controller of the search
		self.kSearchController.viewController = self

		// Add search bar to navigation controller
		self.navigationItem.searchController = self.kSearchController

		#if targetEnvironment(macCatalyst)
		#else
		if #available(iOS 16.0, *) {
			self.navigationItem.preferredSearchBarPlacement = .stacked
		} else {
		}
		#endif
	}

	/// Perform search with the given search text and the search scope.
	///
	/// - Parameters:
	///    - query: The string which to search for.
	///    - searchScope: The scope in which the text should be searched.
	///    - resettingResults: Whether to reset the results.
	func performSearch(with query: String, in searchScope: KKSearchScope, resettingResults: Bool = true) {
		// Prepare view for search
		self.currentScope = searchScope

		if resettingResults {
			// Show activity indicator.
			self._prefersActivityIndicatorHidden = false

			// Reset results
			self.resetSearchResults()
		}

		// Decide with wich endpoint to perform the search
		switch searchScope {
		case .kurozora:
			Task { [weak self] in
				guard let self = self else { return }
				await self.search(scope: searchScope, types: [.shows, .literatures, .games, .episodes, .characters, .people, .songs, .studios, .users], query: query)
			}
		case .library:
			WorkflowController.shared.isSignedIn { [weak self] in
				Task {
					guard let self = self else { return }
					await self.search(scope: searchScope, types: [.shows, .literatures, .games], query: query)
				}
			}
		}
	}

	func search(scope: KKSearchScope, types: [KKSearchType], query: String) async {
		guard !self.isRequestInProgress else {
			return
		}

		// Set request in progress
		self.isRequestInProgress = true

		// Store search query
		self.searachQuery = query

		do {
			let limit = self.currentScope == .library ? 25 : 5

			// Perform library search request.
			let searchResponse = try await KService.search(scope, of: types, for: query, next: self.nextPageURL, limit: limit).value

			self.searchResults = searchResponse.data
			self.isRequestInProgress = false

			// Update data source.
			self.updateDataSource()
		} catch {
			self.isRequestInProgress = false
			print(error.localizedDescription)
		}

		// Hide activity indicator.
		self._prefersActivityIndicatorHidden = true
	}

	/// Sets all search results to nil and reloads the table view
	fileprivate func resetSearchResults() {
		self.searchResults = nil
		self.nextPageURL = nil
		self.characters = [:]
		self.episodes = [:]
		self.people = [:]
		self.shows = [:]
		self.literatures = [:]
		self.games = [:]
		self.songs = [:]
		self.studios = [:]
		self.users = [:]
		self.updateDataSource()
	}

	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		switch segue.identifier {
		case R.segue.searchResultsCollectionViewController.characterDetailsSegue.identifier:
			// Segue to character details
			guard let characterDetailCollectionViewController = segue.destination as? CharacterDetailsCollectionViewController else { return }
			guard let character = sender as? Character else { return }
			characterDetailCollectionViewController.character = character
		case R.segue.searchResultsCollectionViewController.episodeDetailsSegue.identifier:
			// Segue to episode details
			guard let episodeDetailsCollectionViewController = segue.destination as? EpisodeDetailsCollectionViewController else { return }
			guard let episode = sender as? Episode else { return }
			episodeDetailsCollectionViewController.episode = episode
		case R.segue.searchResultsCollectionViewController.literatureDetailsSegue.identifier:
			// Segue to literature details
			guard let literatureDetailCollectionViewController = segue.destination as? LiteratureDetailsCollectionViewController else { return }
			guard let literature = sender as? Literature else { return }
			literatureDetailCollectionViewController.literature = literature
		case R.segue.searchResultsCollectionViewController.gameDetailsSegue.identifier:
			// Segue to game details
			guard let gameDetailCollectionViewController = segue.destination as? GameDetailsCollectionViewController else { return }
			guard let game = sender as? Game else { return }
			gameDetailCollectionViewController.game = game
		case R.segue.searchResultsCollectionViewController.personDetailsSegue.identifier:
			// Segue to person details
			guard let personDetailCollectionViewController = segue.destination as? PersonDetailsCollectionViewController else { return }
			guard let person = sender as? Person else { return }
			personDetailCollectionViewController.person = person
		case R.segue.searchResultsCollectionViewController.showDetailsSegue.identifier:
			// Segue to show details
			guard let showDetailCollectionViewController = segue.destination as? ShowDetailsCollectionViewController else { return }
			guard let show = sender as? Show else { return }
			showDetailCollectionViewController.show = show
		case R.segue.searchResultsCollectionViewController.songDetailsSegue.identifier:
			// Segue to studio details
			guard let songDetailCollectionViewController = segue.destination as? SongDetailsCollectionViewController else { return }
			guard let song = sender as? Song else { return }
			songDetailCollectionViewController.song = song
		case R.segue.searchResultsCollectionViewController.studioDetailsSegue.identifier:
			// Segue to studio details
			guard let studioDetailCollectionViewController = segue.destination as? StudioDetailsCollectionViewController else { return }
			guard let studio = sender as? Studio else { return }
			studioDetailCollectionViewController.studio = studio
		case R.segue.searchResultsCollectionViewController.userDetailsSegue.identifier:
			// Segue to user details
			guard let profileTableViewController = segue.destination as? ProfileTableViewController else { return }
			guard let user = sender as? User else { return }
			profileTableViewController.user = user
		case R.segue.searchResultsCollectionViewController.charactersListSegue.identifier:
			// Segue to characters list
			guard let charactersListCollectionViewController = segue.destination as? CharactersListCollectionViewController else { return }
			charactersListCollectionViewController.searachQuery = self.searachQuery
			charactersListCollectionViewController.charactersListFetchType = .search
		case R.segue.searchResultsCollectionViewController.episodesListSegue.identifier:
			// Segue to episodes list
			guard let episodesListCollectionViewController = segue.destination as? EpisodesListCollectionViewController else { return }
			episodesListCollectionViewController.searachQuery = self.searachQuery
			episodesListCollectionViewController.episodesListFetchType = .search
		case R.segue.searchResultsCollectionViewController.literaturesListSegue.identifier:
			// Segue to literatures list
			guard let literaturesListCollectionViewController = segue.destination as? LiteraturesListCollectionViewController else { return }
			literaturesListCollectionViewController.searachQuery = self.searachQuery
			literaturesListCollectionViewController.literaturesListFetchType = .search
		case R.segue.searchResultsCollectionViewController.gamesListSegue.identifier:
			// Segue to games list
			guard let gamesListCollectionViewController = segue.destination as? GamesListCollectionViewController else { return }
			gamesListCollectionViewController.searachQuery = self.searachQuery
			gamesListCollectionViewController.gamesListFetchType = .search
		case R.segue.searchResultsCollectionViewController.peopleListSegue.identifier:
			// Segue to people list
			guard let peopleListCollectionViewController = segue.destination as? PeopleListCollectionViewController else { return }
			peopleListCollectionViewController.searachQuery = self.searachQuery
			peopleListCollectionViewController.peopleListFetchType = .search
		case R.segue.searchResultsCollectionViewController.songsListSegue.identifier:
			// Segue to songs list
			guard let showSongsListCollectionViewController = segue.destination as? ShowSongsListCollectionViewController else { return }
			showSongsListCollectionViewController.songs = self.songs.map { _, song in
				return song
			}
		case R.segue.searchResultsCollectionViewController.showsListSegue.identifier:
			// Segue to shows list
			guard let showsListCollectionViewController = segue.destination as? ShowsListCollectionViewController else { return }
			showsListCollectionViewController.searachQuery = self.searachQuery
			showsListCollectionViewController.showsListFetchType = .search
		case R.segue.searchResultsCollectionViewController.studiosListSegue.identifier:
			// Segue to studios list
			guard let studiosListCollectionViewController = segue.destination as? StudiosListCollectionViewController else { return }
			studiosListCollectionViewController.searachQuery = self.searachQuery
			studiosListCollectionViewController.studiosListFetchType = .search
		case R.segue.searchResultsCollectionViewController.usersListSegue.identifier:
			// Segue to users list
			guard let usersListCollectionViewController = segue.destination as? UsersListCollectionViewController else { return }
			usersListCollectionViewController.searachQuery = self.searachQuery
			usersListCollectionViewController.usersListFetchType = .search
		default: break
		}
	}
}

// MARK: - UISearchBarDelegate
extension SearchResultsCollectionViewController: UISearchBarDelegate {
	func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
		guard let searchScope = KKSearchScope(rawValue: selectedScope) else { return }
		guard let query = searchBar.text, !query.isEmpty else { return }

		switch searchScope {
		case .library:
			WorkflowController.shared.isSignedIn {
				self.performSearch(with: query, in: searchScope)
				return
			}
			searchBar.selectedScopeButtonIndex = self.currentScope.rawValue
		default:
			self.performSearch(with: query, in: searchScope)
		}
	}

	func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
		guard let searchScope = KKSearchScope(rawValue: searchBar.selectedScopeButtonIndex) else { return }
		guard let query = searchBar.text else { return }
		self.performSearch(with: query, in: searchScope)
	}

	func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
		self.resetSearchResults()
	}
}

// MARK: - BaseLockupCollectionViewCellDelegate
extension SearchResultsCollectionViewController: BaseLockupCollectionViewCellDelegate {
	func baseLockupCollectionViewCell(_ cell: BaseLockupCollectionViewCell, didPressReminder button: UIButton) { }

	func baseLockupCollectionViewCell(_ cell: BaseLockupCollectionViewCell, didPressStatus button: UIButton) {
		WorkflowController.shared.isSignedIn {
			guard let indexPath = self.collectionView.indexPath(for: cell) else { return }
			let modelID: String

			switch cell.libraryKind {
			case .shows:
				guard let show = self.shows[indexPath] else { return }
				modelID = show.id
			case .literatures:
				guard let literature = self.literatures[indexPath] else { return }
				modelID = literature.id
			case .games:
				guard let game = self.games[indexPath] else { return }
				modelID = game.id
			}

			let oldLibraryStatus = cell.libraryStatus
			let actionSheetAlertController = UIAlertController.actionSheetWithItems(items: KKLibrary.Status.alertControllerItems(for: cell.libraryKind), currentSelection: oldLibraryStatus, action: { title, value  in
				Task {
					do {
						let libraryUpdateResponse = try await KService.addToLibrary(cell.libraryKind, withLibraryStatus: value, modelID: modelID).value

						switch cell.libraryKind {
						case .shows:
							self.shows[indexPath]?.attributes.update(using: libraryUpdateResponse.data)
						case .literatures:
							self.literatures[indexPath]?.attributes.update(using: libraryUpdateResponse.data)
						case .games:
							self.games[indexPath]?.attributes.update(using: libraryUpdateResponse.data)
						}

						// Update entry in library
						cell.libraryStatus = value
						button.setTitle("\(title) ▾", for: .normal)

						let libraryAddToNotificationName = Notification.Name("AddTo\(value.sectionValue)Section")
						NotificationCenter.default.post(name: libraryAddToNotificationName, object: nil)
					} catch let error as KKAPIError {
						self.presentAlertController(title: "Can't Add to Your Library 😔", message: error.message)
						print("----- Add to library failed", error.message)
					}
				}
			})

			if cell.libraryStatus != .none {
				actionSheetAlertController.addAction(UIAlertAction(title: Trans.removeFromLibrary, style: .destructive, handler: { _ in
					Task {
						do {
							let libraryUpdateResponse = try await KService.removeFromLibrary(cell.libraryKind, modelID: modelID).value

							switch cell.libraryKind {
							case .shows:
								self.shows[indexPath]?.attributes.update(using: libraryUpdateResponse.data)
							case .literatures:
								self.literatures[indexPath]?.attributes.update(using: libraryUpdateResponse.data)
							case .games:
								self.games[indexPath]?.attributes.update(using: libraryUpdateResponse.data)
							}

							// Update edntry in library
							cell.libraryStatus = .none
							button.setTitle("ADD", for: .normal)

							let libraryRemoveFromNotificationName = Notification.Name("RemoveFrom\(oldLibraryStatus.sectionValue)Section")
							NotificationCenter.default.post(name: libraryRemoveFromNotificationName, object: nil)
						} catch let error as KKAPIError {
							self.presentAlertController(title: "Can't Remove From Your Library 😔", message: error.message)
							print("----- Remove from library failed", error.message)
						}
					}
				}))
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
}

// MARK: - TitleHeaderCollectionReusableViewDelegate
extension SearchResultsCollectionViewController: TitleHeaderCollectionReusableViewDelegate {
	func titleHeaderCollectionReusableView(_ reusableView: TitleHeaderCollectionReusableView, didPress button: UIButton) {
		self.performSegue(withIdentifier: reusableView.segueID, sender: reusableView.indexPath)
	}
}

// MARK: - UserLockupCollectionViewCellDelegate
extension SearchResultsCollectionViewController: UserLockupCollectionViewCellDelegate {
	func userLockupCollectionViewCell(_ cell: UserLockupCollectionViewCell, didPressFollow button: UIButton) {
		guard let indexPath = self.collectionView.indexPath(for: cell) else { return }
		guard var user = self.users[indexPath] else { return }

		Task {
			do {
				let userIdentity = UserIdentity(id: user.id)
				let followUpdateResponse = try await KService.updateFollowStatus(forUser: userIdentity).value
				user.attributes.update(using: followUpdateResponse.data)
				cell.updateFollowButton(using: followUpdateResponse.data.followStatus)
			} catch {
				print("-----", error.localizedDescription)
			}
		}
	}
}

// MARK: - EpisodeLockupCollectionViewCellDelegate
extension SearchResultsCollectionViewController: EpisodeLockupCollectionViewCellDelegate {
	func episodeLockupCollectionViewCell(_ cell: EpisodeLockupCollectionViewCell, didPressWatchButton button: UIButton) {
		guard let indexPath = collectionView.indexPath(for: cell) else { return }
		Task { [weak self] in
			guard let self = self else { return }
			await self.episodes[indexPath]?.updateWatchStatus(userInfo: ["indexPath": indexPath])
		}
	}

	func episodeLockupCollectionViewCell(_ cell: EpisodeLockupCollectionViewCell, didPressMoreButton button: UIButton) {
		guard let indexPath = self.collectionView.indexPath(for: cell) else { return }
		let episode = self.episodes[indexPath]

		let actionSheetAlertController = UIAlertController.actionSheet(title: nil, message: nil) { [weak self] actionSheetAlertController in
			guard let self = self else { return }
			let watchStatus = episode?.attributes.watchStatus

			if watchStatus != .disabled {
				let actionTitle = watchStatus == .notWatched ? "Mark as Watched" : "Mark as Un-watched"

				actionSheetAlertController.addAction(UIAlertAction(title: actionTitle, style: .default, handler: { _ in
					Task {
						await episode?.updateWatchStatus(userInfo: ["indexPath": indexPath])
					}
				}))
			}
//			actionSheetAlertController.addAction(UIAlertAction(title: "Rate", style: .default, handler: nil))
			actionSheetAlertController.addAction(UIAlertAction(title: Trans.share, style: .default, handler: { _ in
				episode?.openShareSheet(on: self, button)
			}))
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

// MARK: - MusicLockupCollectionViewCellDelegate
extension SearchResultsCollectionViewController: MusicLockupCollectionViewCellDelegate {
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
		// No action
	}
}

// MARK: - Enums
extension SearchResultsCollectionViewController {
	/// List of character section layout kind.
	enum SectionLayoutKind: Int, CaseIterable {
		// MARK: - Cases
		/// Indicates a search history section layout type.
		case searchHistory

		/// Indicates the characters' section layout type.
		case characters

		/// Indicates the episodes' section layout type.
		case episodes

		/// Indicates the games' section layout type.
		case games

		/// Indicates the literatures' section layout type.
		case literatures

		/// Indicates the people's section layout type.
		case people

		/// Indicates the songs' section layout type.
		case songs

		/// Indicates the shows' section layout type.
		case shows

		/// Indicates the studios' section layout type.
		case studios

		/// Indicates the users' section layout type.
		case users
	}

	/// List of available Item Kind types.
	enum ItemKind: Hashable {
		// MARK: - Cases
		/// Indicates the item kind contains a `Show` object.
		case show(_: Show)

		/// Indicates the item kind contains a `Literature` object.
		case literature(_: Literature)

		/// Indicates the item kind contains a `Game` object.
		case game(_: Game)

		/// Indicates the item kind contains a `CharacterIdentity` object.
		case characterIdentity(_: CharacterIdentity, _: UUID = UUID())

		/// Indicates the item kind contains a `EpisodeIdentity` object.
		case episodeIdentity(_: EpisodeIdentity, _: UUID = UUID())

		/// Indicates the item kind contains a `GameIdentity` object.
		case gameIdentity(_: GameIdentity, _: UUID = UUID())

		/// Indicates the item kind contains a `LiteratureIdentity` object.
		case literatureIdentity(_: LiteratureIdentity, _: UUID = UUID())

		/// Indicates the item kind contains a `PersonIdentity` object.
		case personIdentity(_: PersonIdentity, _: UUID = UUID())

		/// Indicates the item kind contains a `ShowIdentity` object.
		case showIdentity(_: ShowIdentity, _: UUID = UUID())

		/// Indicates the item kind contains a `SongIdentity` object.
		case songIdentity(_: SongIdentity, _: UUID = UUID())

		/// Indicates the item kind contains a `StudioIdentity` object.
		case studioIdentity(_: StudioIdentity, _: UUID = UUID())

		/// Indicates the item kind contains a `UserIdentity` object.
		case userIdentity(_: UserIdentity, _: UUID = UUID())

		// MARK: - Functions
		func hash(into hasher: inout Hasher) {
			switch self {
			case .show(let show):
				hasher.combine(show)
			case .literature(let literature):
				hasher.combine(literature)
			case .game(let game):
				hasher.combine(game)
			case .characterIdentity(let characterIdentity, let uuid):
				hasher.combine(characterIdentity)
				hasher.combine(uuid)
			case .episodeIdentity(let episodeIdentity, let uuid):
				hasher.combine(episodeIdentity)
				hasher.combine(uuid)
			case .gameIdentity(let gameIdentity, let uuid):
				hasher.combine(gameIdentity)
				hasher.combine(uuid)
			case .literatureIdentity(let literatureIdentity, let uuid):
				hasher.combine(literatureIdentity)
				hasher.combine(uuid)
			case .personIdentity(let personIdentity, let uuid):
				hasher.combine(personIdentity)
				hasher.combine(uuid)
			case .showIdentity(let showIdentity, let uuid):
				hasher.combine(showIdentity)
				hasher.combine(uuid)
			case .songIdentity(let songIdentity, let uuid):
				hasher.combine(songIdentity)
				hasher.combine(uuid)
			case .studioIdentity(let studioIdentity, let uuid):
				hasher.combine(studioIdentity)
				hasher.combine(uuid)
			case .userIdentity(let userIdentity, let uuid):
				hasher.combine(userIdentity)
				hasher.combine(uuid)
			}
		}

		static func == (lhs: ItemKind, rhs: ItemKind) -> Bool {
			switch (lhs, rhs) {
			case (.show(let show1), .show(let show2)):
				return show1 == show2
			case (.literature(let literature1), .literature(let literature2)):
				return literature1 == literature2
			case (.game(let game1), .game(let game2)):
				return game1 == game2
			case (.characterIdentity(let characterIdentity1, let uuid1), .characterIdentity(let characterIdentity2, let uuid2)):
				return characterIdentity1 == characterIdentity2 && uuid1 == uuid2
			case (.episodeIdentity(let episodeIdentity1, let uuid1), .episodeIdentity(let episodeIdentity2, let uuid2)):
				return episodeIdentity1 == episodeIdentity2 && uuid1 == uuid2
			case (.gameIdentity(let gameIdentity1, let uuid1), .gameIdentity(let gameIdentity2, let uuid2)):
				return gameIdentity1 == gameIdentity2 && uuid1 == uuid2
			case (.literatureIdentity(let literatureIdentity1, let uuid1), .literatureIdentity(let literatureIdentity2, let uuid2)):
				return literatureIdentity1 == literatureIdentity2 && uuid1 == uuid2
			case (.personIdentity(let personIdentity1, let uuid1), .personIdentity(let personIdentity2, let uuid2)):
				return personIdentity1 == personIdentity2 && uuid1 == uuid2
			case (.showIdentity(let showIdentity1, let uuid1), .showIdentity(let showIdentity2, let uuid2)):
				return showIdentity1 == showIdentity2 && uuid1 == uuid2
			case (.songIdentity(let songIdentity1, let uuid1), .songIdentity(let songIdentity2, let uuid2)):
				return songIdentity1 == songIdentity2 && uuid1 == uuid2
			case (.studioIdentity(let studioIdentity1, let uuid1), .studioIdentity(let studioIdentity2, let uuid2)):
				return studioIdentity1 == studioIdentity2 && uuid1 == uuid2
			case (.userIdentity(let userIdentity1, let uuid1), .userIdentity(let userIdentity2, let uuid2)):
				return userIdentity1 == userIdentity2 && uuid1 == uuid2
			default:
				return false
			}
		}
	}
}
