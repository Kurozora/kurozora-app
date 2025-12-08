//
//  GamesListCollectionViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 01/03/2023.
//  Copyright © 2023 Kurozora. All rights reserved.
//

import KurozoraKit
import UIKit

enum GamesListFetchType {
	case show
	case literature
	case character
	case explore
	case person
	case moreByStudio
	case relatedGame
	case search
	case studio
	case upcoming
}

class GamesListCollectionViewController: KCollectionViewController, SectionFetchable {
	// MARK: - Properties
	var showIdentity: ShowIdentity?
	var literatureIdentity: LiteratureIdentity?
	var personIdentity: PersonIdentity?
	var characterIdentity: CharacterIdentity?
	var gameIdentity: GameIdentity?
	var studioIdentity: StudioIdentity?
	var exploreCategoryIdentity: ExploreCategoryIdentity?

	var gameIdentities: [GameIdentity] = []

	var relatedGames: [RelatedGame] = []

	var searchQuery: String = ""
	var gamesListFetchType: GamesListFetchType = .search

	var cache: [IndexPath: KurozoraItem] = [:]
	var isFetchingSection: Set<SectionLayoutKind> = []

	var dataSource: UICollectionViewDiffableDataSource<SectionLayoutKind, ItemKind>!
	var snapshot: NSDiffableDataSourceSnapshot<SectionLayoutKind, ItemKind>!

	/// The next page url of the pagination.
	var nextPageURL: String?

	/// Whether a fetch request is currently in progress.
	var isRequestInProgress: Bool = false

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
	override func viewWillReload() {
		super.viewWillReload()

		self.handleRefreshControl()
	}

	override func viewDidLoad() {
		super.viewDidLoad()

		// Add refresh control
		#if DEBUG
		self._prefersRefreshControlDisabled = false
		#else
		self._prefersRefreshControlDisabled = true
		#endif

		self.configureDataSource()

		if !self.gameIdentities.isEmpty || !self.relatedGames.isEmpty {
			self.endFetch()
		} else {
			Task { [weak self] in
				guard let self = self else { return }
				await self.fetchGames()
			}
		}
	}

	// MARK: - Functions
	override func handleRefreshControl() {
		self.nextPageURL = nil
	}

	override func configureEmptyDataView() {
		self.emptyBackgroundView.configureImageView(image: .Empty.gameLibrary)
		self.emptyBackgroundView.configureLabels(title: "No Games", detail: "Can't get games list. Please refresh the page or restart the app and check your WiFi connection.")

		self.collectionView.backgroundView?.alpha = 0
	}

	/// Fades in and out the empty data view according to the number of rows.
	func toggleEmptyDataView() {
		if self.collectionView.numberOfItems == 0 {
			self.collectionView.backgroundView?.animateFadeIn()
		} else {
			self.collectionView.backgroundView?.animateFadeOut()
		}
	}

	func endFetch() {
		self.isRequestInProgress = false
		self.updateDataSource()
		self._prefersActivityIndicatorHidden = true
		self.toggleEmptyDataView()
		#if DEBUG
		#if !targetEnvironment(macCatalyst)
		self.refreshControl?.endRefreshing()
		#endif
		#endif
	}

	/// Fetches the characters.
	func fetchGames() async {
		guard !self.isRequestInProgress else {
			return
		}

		// Set request in progress
		self.isRequestInProgress = true

		do {
			switch self.gamesListFetchType {
			case .show:
				guard let showIdentity = self.showIdentity else { return }
				let relatedGamesResponse = try await KService.getRelatedGames(forShow: showIdentity, next: self.nextPageURL).value

				// Reset data if necessary
				if self.nextPageURL == nil {
					self.relatedGames = []
					self.gameIdentities = []
				}

				// Save next page url and append new data
				self.nextPageURL = relatedGamesResponse.next
				self.relatedGames.append(contentsOf: relatedGamesResponse.data)
				self.relatedGames.removeDuplicates()
			case .literature:
				guard let literatureIdentity = self.literatureIdentity else { return }
				let relatedGamesResponse = try await KService.getRelatedGames(forLiterature: literatureIdentity, next: self.nextPageURL).value

				// Reset data if necessary
				if self.nextPageURL == nil {
					self.relatedGames = []
					self.gameIdentities = []
				}

				// Save next page url and append new data
				self.nextPageURL = relatedGamesResponse.next
				self.relatedGames.append(contentsOf: relatedGamesResponse.data)
				self.relatedGames.removeDuplicates()
			case .character:
				guard let characterIdentity = self.characterIdentity else { return }
				let gameIdentityResponse = try await KService.getGames(forCharacter: characterIdentity, next: self.nextPageURL).value

				// Reset data if necessary
				if self.nextPageURL == nil {
					self.gameIdentities = []
				}

				// Save next page url and append new data
				self.nextPageURL = gameIdentityResponse.next
				self.gameIdentities.append(contentsOf: gameIdentityResponse.data)
				self.gameIdentities.removeDuplicates()
			case .person:
				guard let personIdentity = self.personIdentity else { return }
				let gameIdentityResponse = try await KService.getGames(forPerson: personIdentity, next: self.nextPageURL).value

				// Reset data if necessary
				if self.nextPageURL == nil {
					self.gameIdentities = []
				}

				// Save next page url and append new data
				self.nextPageURL = gameIdentityResponse.next
				self.gameIdentities.append(contentsOf: gameIdentityResponse.data)
				self.gameIdentities.removeDuplicates()
			case .search:
				let searchResponse = try await KService.search(.kurozora, of: [.games], for: self.searchQuery, next: self.nextPageURL, limit: self.nextPageURL != nil ? 100 : 25, filter: nil).value

				// Reset data if necessary
				if self.nextPageURL == nil {
					self.relatedGames = []
					self.gameIdentities = []
				}

				// Save next page url and append new data
				self.nextPageURL = searchResponse.data.games?.next
				self.gameIdentities.append(contentsOf: searchResponse.data.games?.data ?? [])
				self.gameIdentities.removeDuplicates()
			case .moreByStudio:
				guard let gameIdentity = self.gameIdentity else { return }
				let gameIdentityResponse = try await KService.getMoreByStudio(forGame: gameIdentity, next: self.nextPageURL).value

				// Reset data if necessary
				if self.nextPageURL == nil {
					self.gameIdentities = []
				}

				// Save next page url and append new data
				self.nextPageURL = gameIdentityResponse.next
				self.gameIdentities.append(contentsOf: gameIdentityResponse.data)
				self.gameIdentities.removeDuplicates()
			case .relatedGame:
				guard let gameIdentity = self.gameIdentity else { return }
				let relatedGamesResponse = try await KService.getRelatedGames(forGame: gameIdentity, next: self.nextPageURL).value

				// Reset data if necessary
				if self.nextPageURL == nil {
					self.relatedGames = []
					self.gameIdentities = []
				}

				// Save next page url and append new data
				self.nextPageURL = relatedGamesResponse.next
				self.relatedGames.append(contentsOf: relatedGamesResponse.data)
				self.relatedGames.removeDuplicates()
			case .studio:
				guard let studioIdentity = self.studioIdentity else { return }
				let gameIdentityResponse = try await KService.getGames(forStudio: studioIdentity, next: self.nextPageURL).value

				// Reset data if necessary
				if self.nextPageURL == nil {
					self.gameIdentities = []
				}

				// Save next page url and append new data
				self.nextPageURL = gameIdentityResponse.next
				self.gameIdentities.append(contentsOf: gameIdentityResponse.data)
				self.gameIdentities.removeDuplicates()
			case .upcoming:
				let gameIdentityResponse = try await KService.getUpcomingGames(next: self.nextPageURL).value

				// Reset data if necessary
				if self.nextPageURL == nil {
					self.gameIdentities = []
				}

				// Save next page url and append new data
				self.nextPageURL = gameIdentityResponse.next
				self.gameIdentities.append(contentsOf: gameIdentityResponse.data)
				self.gameIdentities.removeDuplicates()
			case .explore:
				guard let exploreCategoryIdentity = self.exploreCategoryIdentity else { return }
				let exploreCategoryResponse = try await KService.getExplore(exploreCategoryIdentity, next: self.nextPageURL, limit: self.nextPageURL != nil ? 100 : 25).value

				// Reset data if necessary
				if self.nextPageURL == nil {
					self.relatedGames = []
					self.gameIdentities = []
				}

				// Save next page url and append new data
				self.nextPageURL = exploreCategoryResponse.data.first?.relationships.games?.next
				self.gameIdentities.append(contentsOf: exploreCategoryResponse.data.first?.relationships.games?.data ?? [])
				self.gameIdentities.removeDuplicates()
			}

			self.endFetch()
		} catch {
			print(error.localizedDescription)
		}
	}

	// MARK: - SectionFetchable
	func extractIdentity<Element>(from item: ItemKind) -> Element? where Element: KurozoraItem {
		switch item {
		case .gameIdentity(let id): return id as? Element
		default: return nil
		}
	}

	// MARK: - Segue
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		switch segue.identifier {
		case R.segue.gamesListCollectionViewController.gameDetailsSegue.identifier:
			guard let gameDetailCollectionViewController = segue.destination as? GameDetailsCollectionViewController else { return }
			guard let game = sender as? Game else { return }
			gameDetailCollectionViewController.game = game
		default: break
		}
	}
}

// MARK: - BaseLockupCollectionViewCellDelegate
extension GamesListCollectionViewController: BaseLockupCollectionViewCellDelegate {
	func baseLockupCollectionViewCell(_ cell: BaseLockupCollectionViewCell, didPressStatus button: UIButton) async {
		let signedIn = await WorkflowController.shared.isSignedIn(on: self)
		guard signedIn else { return }
		guard let indexPath = self.collectionView.indexPath(for: cell) else { return }
		let game = (self.cache[indexPath] as? Game) ?? self.relatedGames[indexPath.item].game

		let oldLibraryStatus = cell.libraryStatus
		let actionSheetAlertController = UIAlertController.actionSheetWithItems(items: KKLibrary.Status.alertControllerItems(for: cell.libraryKind), currentSelection: oldLibraryStatus, action: { title, value in
			Task {
				do {
					let libraryUpdateResponse = try await KService.addToLibrary(.games, withLibraryStatus: value, modelID: game.id).value

					game.attributes.library?.update(using: libraryUpdateResponse.data)

					// Update entry in library
					cell.libraryStatus = value
					button.setTitle("\(title) ▾", for: .normal)

					let libraryAddToNotificationName = Notification.Name("AddTo\(value.sectionValue)Section")
					NotificationCenter.default.post(name: libraryAddToNotificationName, object: nil)

					// Request review
					ReviewManager.shared.requestReview(for: .itemAddedToLibrary(status: value))
				} catch let error as KKAPIError {
					self.presentAlertController(title: "Can't Add to Your Library 😔", message: error.message)
					print("----- Add to library failed", error.message)
				}
			}
		})

		if cell.libraryStatus != .none {
			actionSheetAlertController.addAction(UIAlertAction(title: Trans.removeFromLibrary, style: .destructive) { _ in
				Task {
					do {
						let libraryUpdateResponse = try await KService.removeFromLibrary(.games, modelID: game.id).value

						game.attributes.library?.update(using: libraryUpdateResponse.data)

						// Update entry in library
						cell.libraryStatus = .none
						button.setTitle(Trans.add.uppercased(), for: .normal)

						let libraryRemoveFromNotificationName = Notification.Name("RemoveFrom\(oldLibraryStatus.sectionValue)Section")
						NotificationCenter.default.post(name: libraryRemoveFromNotificationName, object: nil)
					} catch let error as KKAPIError {
						self.presentAlertController(title: "Can't Remove From Your Library 😔", message: error.message)
						print("----- Remove from library failed", error.message)
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

	func baseLockupCollectionViewCell(_ cell: BaseLockupCollectionViewCell, didPressReminder button: UIButton) async {
//		guard let indexPath = self.collectionView.indexPath(for: cell) else { return }
//		let game = self.games[indexPath] ?? self.relatedGames[indexPath.item].game
//		game.toggleReminder()
	}
}

// MARK: - SectionLayoutKind
extension GamesListCollectionViewController {
	/// List of section layout kind.
	///
	/// ```swift
	/// case main = 0
	/// ```
	enum SectionLayoutKind: Int, CaseIterable {
		// MARK: - Cases
		/// The main section.
		case main = 0
	}
}

// MARK: - ItemKind
extension GamesListCollectionViewController {
	/// List of item layout kind.
	enum ItemKind: Hashable {
		// MARK: - Cases
		/// Indicates the item kind contains a `GameIdentity` object.
		case gameIdentity(_: GameIdentity)

		/// Indicates the item kind contains a `RelatedGame` object.
		case relatedGame(_: RelatedGame)

		// MARK: - Functions
		func hash(into hasher: inout Hasher) {
			switch self {
			case .gameIdentity(let gameIdentity):
				hasher.combine(gameIdentity)
			case .relatedGame(let relatedGame):
				hasher.combine(relatedGame)
			}
		}

		static func == (lhs: ItemKind, rhs: ItemKind) -> Bool {
			switch (lhs, rhs) {
			case (.gameIdentity(let gameIdentity1), .gameIdentity(let gameIdentity2)):
				return gameIdentity1 == gameIdentity2
			case (.relatedGame(let relatedGame1), .relatedGame(let relatedGame2)):
				return relatedGame1 == relatedGame2
			default:
				return false
			}
		}
	}
}

// MARK: - Cell Configuration
extension GamesListCollectionViewController {
	func getConfiguredGameCell() -> UICollectionView.CellRegistration<GameLockupCollectionViewCell, ItemKind> {
		return UICollectionView.CellRegistration<GameLockupCollectionViewCell, ItemKind>(cellNib: GameLockupCollectionViewCell.nib) { [weak self] gameLockupCollectionViewCell, indexPath, itemKind in
			guard let self = self else { return }

			switch itemKind {
			case .gameIdentity:
				let game: Game? = self.fetchModel(at: indexPath)

				if game == nil, let section = self.snapshot.sectionIdentifier(containingItem: itemKind), !self.isFetchingSection.contains(section) {
					Task {
						await self.fetchSectionIfNeeded(GameResponse.self, GameIdentity.self, at: indexPath, itemKind: itemKind)
					}
				}

				gameLockupCollectionViewCell.delegate = self
				gameLockupCollectionViewCell.configure(using: game)
			case .relatedGame(let relatedShow):
				gameLockupCollectionViewCell.delegate = self
				gameLockupCollectionViewCell.configure(using: relatedShow)
			}
		}
	}

	func getConfiguredUpcomingCell() -> UICollectionView.CellRegistration<UpcomingLockupCollectionViewCell, ItemKind> {
		return UICollectionView.CellRegistration<UpcomingLockupCollectionViewCell, ItemKind>(cellNib: UpcomingLockupCollectionViewCell.nib) { [weak self] upcomingLockupCollectionViewCell, indexPath, itemKind in
			guard let self = self else { return }

			switch itemKind {
			case .gameIdentity:
				let game: Game? = self.fetchModel(at: indexPath)

				if game == nil, let section = self.snapshot.sectionIdentifier(containingItem: itemKind), !self.isFetchingSection.contains(section) {
					Task {
						await self.fetchSectionIfNeeded(GameResponse.self, GameIdentity.self, at: indexPath, itemKind: itemKind)
					}
				}

				upcomingLockupCollectionViewCell.delegate = self
				upcomingLockupCollectionViewCell.configure(using: game)
			default: break
			}
		}
	}
}
