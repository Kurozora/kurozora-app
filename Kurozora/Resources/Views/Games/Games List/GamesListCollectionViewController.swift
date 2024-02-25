//
//  GamesListCollectionViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 01/03/2023.
//  Copyright © 2023 Kurozora. All rights reserved.
//

import UIKit
import KurozoraKit
import Alamofire

enum GamesListFetchType {
	case show
	case literature
	case charcter
	case explore
	case person
	case moreByStudio
	case relatedGame
	case search
	case studio
	case upcoming
}

class GamesListCollectionViewController: KCollectionViewController {
	// MARK: - Properties
	var showIdentity: ShowIdentity? = nil

	var literatureIdentity: LiteratureIdentity? = nil

	var personIdentity: PersonIdentity? = nil

	var characterIdentity: CharacterIdentity? = nil

	var gameIdentity: GameIdentity? = nil

	var studioIdentity: StudioIdentity? = nil

	var exploreCategoryIdentity: ExploreCategoryIdentity? = nil

	var games: [IndexPath: Game] = [:]
	var gameIdentities: [GameIdentity] = []

	var relatedGames: [RelatedGame] = []

	var searachQuery: String = ""
	var gamesListFetchType: GamesListFetchType = .search

	var dataSource: UICollectionViewDiffableDataSource<SectionLayoutKind, ItemKind>! = nil
	var prefetchingIndexPathOperations: [IndexPath: DataRequest] = [:]

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
		self.emptyBackgroundView.configureImageView(image: R.image.empty.gameLibrary()!)
		self.emptyBackgroundView.configureLabels(title: "No Games", detail: "Can't get games list. Please refresh the page or restart the app and check your WiFi connection.")

		self.collectionView.backgroundView?.alpha = 0
	}

	/// Fades in and out the empty data view according to the number of rows.
	func toggleEmptyDataView() {
		if self.collectionView.numberOfItems() == 0 {
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
			case .charcter:
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
				let searchResponse = try await KService.search(.kurozora, of: [.games], for: self.searachQuery, next: self.nextPageURL, limit: 25, filter: nil).value

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
				let exploreCategoryResponse = try await KService.getExplore(exploreCategoryIdentity, next: self.nextPageURL, limit: 25).value

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
	func baseLockupCollectionViewCell(_ cell: BaseLockupCollectionViewCell, didPressStatus button: UIButton) {
		WorkflowController.shared.isSignedIn { [weak self] in
			guard let self = self else { return }
			guard let indexPath = self.collectionView.indexPath(for: cell) else { return }
			let game = self.games[indexPath] ?? self.relatedGames[indexPath.item].game

			let oldLibraryStatus = cell.libraryStatus
			let actionSheetAlertController = UIAlertController.actionSheetWithItems(items: KKLibrary.Status.alertControllerItems(for: cell.libraryKind), currentSelection: oldLibraryStatus, action: { title, value  in
				Task {
					do {
						let libraryUpdateResponse = try await KService.addToLibrary(.games, withLibraryStatus: value, modelID: String(game.id)).value

						game.attributes.library?.update(using: libraryUpdateResponse.data)

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
				actionSheetAlertController.addAction(UIAlertAction(title: Trans.removeFromLibrary, style: .destructive) { _ in
					Task {
						do {
							let libraryUpdateResponse = try await KService.removeFromLibrary(.games, modelID: String(game.id)).value

							game.attributes.library?.update(using: libraryUpdateResponse.data)

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
//		guard let indexPath = self.collectionView.indexPath(for: cell) else { return }
//		let game = self.games[indexPath] ?? self.relatedGames[indexPath.item].game
//		game.toggleReminder()
	}
}

// MARK: - SectionLayoutKind
extension GamesListCollectionViewController {
	/// List of section layout kind.
	///
	/// ```
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
		/// Indicates the item kind contains a Game object.
		case gameIdentity(_: GameIdentity)

		/// Indicates the item kind contains a RelatedGame object.
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
