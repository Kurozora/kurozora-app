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

/// The collection view controller in charge of providing the necessary functionalities for searching shows, threads and users.
class SearchResultsCollectionViewController: KCollectionViewController {
	// MARK: - Properties
	/// The collection of results fetched by the search request.
	var searchResults: Search?

	/// The collection of show identity results.
	var showIdentities: [ShowIdentity] = []

	/// The current scope of the search.
	var currentScope: KKSearchScope = .kurozora

	/// The search query that is performed.
	var searachQuery: String = ""

	/// The collection of suggested shows.
	var suggestionElements: [Show]? {
		didSet {
			if self.suggestionElements != nil {
				self.updateDataSource()
			}
		}
	}

	var characters: [IndexPath: Character] = [:]
	var episodes: [IndexPath: Episode] = [:]
	var people: [IndexPath: Person] = [:]
	var shows: [IndexPath: Show] = [:]
	var songs: [IndexPath: Song] = [:]
	var studios: [IndexPath: Studio] = [:]
	var users: [IndexPath: User] = [:]

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
		SearchHistory.getContent { [weak self] showDetailsElements in
			guard let self = self else { return }
			self.suggestionElements = showDetailsElements
		}

		if self.includesSearchBar {
			self.setupSearchController()
		}
    }

	// MARK: - Functions
	/// Setup the search controller with the desired settings.
	func setupSearchController() {
		// Set the current view as the view controller of the search
		self.kSearchController.viewController = self

		// Add search bar to navigation controller
		self.navigationItem.searchController = self.kSearchController
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
				await self.search(scope: searchScope, types: [.shows, .episodes, .characters, .people, .studios, .users], query: query)
			}
		case .library:
			WorkflowController.shared.isSignedIn {
				Task { [weak self] in
					guard let self = self else { return }
					await self.search(scope: searchScope, types: [.shows], query: query)
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

			switch self.currentScope {
			case .kurozora:
				self.searchResults = searchResponse.data
			case .library:
				self.nextPageURL = searchResponse.data.shows?.next
				self.showIdentities.append(contentsOf: searchResponse.data.shows?.data ?? [])
			}

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
		self.showIdentities = []
		self.characters = [:]
		self.episodes = [:]
		self.people = [:]
		self.shows = [:]
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
		case R.segue.searchResultsCollectionViewController.peopleListSegue.identifier:
			// Segue to people list
			guard let peopleListCollectionViewController = segue.destination as? PeopleListCollectionViewController else { return }
			peopleListCollectionViewController.searachQuery = self.searachQuery
			peopleListCollectionViewController.peopleListFetchType = .search
		case R.segue.searchResultsCollectionViewController.songsListSegue.identifier:
			// Segue to songs list
			guard let showSongsListCollectionViewController = segue.destination as? ShowSongsListCollectionViewController else { return }
			showSongsListCollectionViewController.showSongs = []
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
				actionSheetAlertController.addAction(UIAlertAction(title: "Remove from library", style: .destructive, handler: { _ in
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
	func titleHeaderCollectionReusableView(_ reusableView: TitleHeaderCollectionReusableView, didPressButton button: UIButton) {
		self.performSegue(withIdentifier: reusableView.segueID, sender: reusableView.indexPath)
	}
}

// MARK: - UserLockupCollectionViewCellDelegate
extension SearchResultsCollectionViewController: UserLockupCollectionViewCellDelegate {
	func userLockupCollectionViewCell(_ cell: UserLockupCollectionViewCell, didPressFollow button: UIButton) {
		guard let indexPath = self.collectionView.indexPath(for: cell) else { return }
		guard var user = self.users[indexPath] else { return }
		let userIdentity = UserIdentity(id: user.id)

		KService.updateFollowStatus(forUser: userIdentity) { result in
			switch result {
			case .success(let followUpdate):
				user.attributes.update(using: followUpdate)
				cell.updateFollowButton(using: followUpdate.followStatus)
			case .failure: break
			}
		}
	}
}

// MARK: - EpisodeLockupCollectionViewCellDelegate
extension SearchResultsCollectionViewController: EpisodeLockupCollectionViewCellDelegate {
	func episodeLockupCollectionViewCell(_ cell: EpisodeLockupCollectionViewCell, didPressWatchButton button: UIButton) {
		guard let indexPath = collectionView.indexPath(for: cell) else { return }
		Task {
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

// MARK: - Enums
extension SearchResultsCollectionViewController {
	/// List of character section layout kind.
	enum SectionLayoutKind: Int, CaseIterable {
		// MARK: - Cases
		/// Indicates the characters' section layout type.
		case characters

		/// Indicates the episodes' section layout type.
		case episodes

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
		/// Indicates the item kind contains a `CharacterIdentity` object.
		case characterIdentity(_: CharacterIdentity)

		/// Indicates the item kind contains a `EpisodeIdentity` object.
		case episodeIdentity(_: EpisodeIdentity)

		/// Indicates the item kind contains a `PersonIdentity` object.
		case personIdentity(_: PersonIdentity)

		/// Indicates the item kind contains a `ShowIdentity` object.
		case showIdentity(_: ShowIdentity)

		/// Indicates the item kind contains a `SongIdentity` object.
		case songIdentity(_: SongIdentity)

		/// Indicates the item kind contains a `StudioIdentity` object.
		case studioIdentity(_: StudioIdentity)

		/// Indicates the item kind contains a `UserIdentity` object.
		case userIdentity(_: UserIdentity)

		// MARK: - Functions
		func hash(into hasher: inout Hasher) {
			switch self {
			case .characterIdentity(let characterIdentity):
				hasher.combine(characterIdentity)
			case .episodeIdentity(let episodeIdentity):
				hasher.combine(episodeIdentity)
			case .personIdentity(let personIdentity):
				hasher.combine(personIdentity)
			case .showIdentity(let showIdentity):
				hasher.combine(showIdentity)
			case .songIdentity(let songIdentity):
				hasher.combine(songIdentity)
			case .studioIdentity(let studioIdentity):
				hasher.combine(studioIdentity)
			case .userIdentity(let userIdentity):
				hasher.combine(userIdentity)
			}
		}

		static func == (lhs: ItemKind, rhs: ItemKind) -> Bool {
			switch (lhs, rhs) {
			case (.characterIdentity(let characterIdentity1), .characterIdentity(let characterIdentity2)):
				return characterIdentity1 == characterIdentity2
			case (.episodeIdentity(let episodeIdentity1), .episodeIdentity(let episodeIdentity2)):
				return episodeIdentity1 == episodeIdentity2
			case (.personIdentity(let personIdentity1), .personIdentity(let personIdentity2)):
				return personIdentity1 == personIdentity2
			case (.showIdentity(let showIdentity1), .showIdentity(let showIdentity2)):
				return showIdentity1 == showIdentity2
			case (.songIdentity(let songIdentity1), .songIdentity(let songIdentity2)):
				return songIdentity1 == songIdentity2
			case (.studioIdentity(let studioIdentity1), .studioIdentity(let studioIdentity2)):
				return studioIdentity1 == studioIdentity2
			case (.userIdentity(let userIdentity1), .userIdentity(let userIdentity2)):
				return userIdentity1 == userIdentity2
			default:
				return false
			}
		}
	}
}
