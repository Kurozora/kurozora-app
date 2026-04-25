//
//  GamesListCollectionViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 01/03/2023.
//  Copyright © 2023 Kurozora. All rights reserved.
//

import KurozoraKit
import UIKit

/// A source of games for ``GamesListCollectionViewController``.
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

/// A paginated list of games (or related games).
class GamesListCollectionViewController: ListCollectionViewController, SectionFetchable {
	// MARK: - Enums
	enum SegueIdentifiers: String, SegueIdentifier {
		case gameDetailsSegue
	}

	/// The section identifier.
	enum SectionLayoutKind: Int, CaseIterable {
		case main = 0
	}

	/// An item displayed in the list.
	enum ItemKind: Hashable {
		case gameIdentity(_: GameIdentity)
		case relatedGame(_: RelatedGame)
	}

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

	// MARK: - SectionFetchable
	var cache: [IndexPath: KurozoraItem] = [:]
	var isFetchingSection: Set<SectionLayoutKind> = []

	var dataSource: UICollectionViewDiffableDataSource<SectionLayoutKind, ItemKind>!
	var snapshot: NSDiffableDataSourceSnapshot<SectionLayoutKind, ItemKind>!

	override var emptyStateImage: UIImage { .Empty.gameLibrary }
	override var emptyStateTitle: String { "No Games" }
	override var emptyStateDetail: String { "Can't get games list. Please refresh the page or restart the app and check your WiFi connection." }

	override var hasLoadedInitialData: Bool {
		!self.gameIdentities.isEmpty || !self.relatedGames.isEmpty
	}

	override func fetchItems() async {
		guard !self.isRequestInProgress else { return }
		self.isRequestInProgress = true

		defer { self.endFetch() }

		do {
			switch self.gamesListFetchType {
			case .show:
				guard let showIdentity = self.showIdentity else { return }
				let response = try await KService.relatedGames(for: showIdentity).cursor(self.nextPageCursor).limit(self.nextPageCursor != nil ? 100 : 25).response()

				if self.nextPageCursor == nil {
					self.relatedGames = []
					self.gameIdentities = []
				}

				self.nextPageCursor = response.nextCursor
				self.relatedGames.append(contentsOf: response.data)
				self.relatedGames.removeDuplicates()
			case .literature:
				guard let literatureIdentity = self.literatureIdentity else { return }
				let response = try await KService.relatedGames(for: literatureIdentity).cursor(self.nextPageCursor).limit(self.nextPageCursor != nil ? 100 : 25).response()

				if self.nextPageCursor == nil {
					self.relatedGames = []
					self.gameIdentities = []
				}

				self.nextPageCursor = response.nextCursor
				self.relatedGames.append(contentsOf: response.data)
				self.relatedGames.removeDuplicates()
			case .character:
				guard let characterIdentity = self.characterIdentity else { return }
				let response = try await KService.games(for: characterIdentity).cursor(self.nextPageCursor).limit(self.nextPageCursor != nil ? 100 : 25).response()

				if self.nextPageCursor == nil {
					self.gameIdentities = []
				}

				self.nextPageCursor = response.nextCursor
				self.gameIdentities.append(contentsOf: response.data)
				self.gameIdentities.removeDuplicates()
			case .person:
				guard let personIdentity = self.personIdentity else { return }
				let response = try await KService.games(for: personIdentity).cursor(self.nextPageCursor).limit(self.nextPageCursor != nil ? 100 : 25).response()

				if self.nextPageCursor == nil {
					self.gameIdentities = []
				}

				self.nextPageCursor = response.nextCursor
				self.gameIdentities.append(contentsOf: response.data)
				self.gameIdentities.removeDuplicates()
			case .search:
				let searchResponse = try await KService.search(.kurozora, types: [.games], query: self.searchQuery).cursor(self.nextPageCursor).limit(self.nextPageCursor != nil ? 100 : 25).filter(nil).response()

				if self.nextPageCursor == nil {
					self.relatedGames = []
					self.gameIdentities = []
				}

				self.nextPageCursor = searchResponse.data.games?.nextCursor
				self.gameIdentities.append(contentsOf: searchResponse.data.games?.data ?? [])
				self.gameIdentities.removeDuplicates()
			case .moreByStudio:
				guard let gameIdentity = self.gameIdentity else { return }
				let response = try await KService.moreByStudio(for: gameIdentity).cursor(self.nextPageCursor).limit(self.nextPageCursor != nil ? 100 : 25).response()

				if self.nextPageCursor == nil {
					self.gameIdentities = []
				}

				self.nextPageCursor = response.nextCursor
				self.gameIdentities.append(contentsOf: response.data)
				self.gameIdentities.removeDuplicates()
			case .relatedGame:
				guard let gameIdentity = self.gameIdentity else { return }
				let response = try await KService.relatedGames(for: gameIdentity).cursor(self.nextPageCursor).limit(self.nextPageCursor != nil ? 100 : 25).response()

				if self.nextPageCursor == nil {
					self.relatedGames = []
					self.gameIdentities = []
				}

				self.nextPageCursor = response.nextCursor
				self.relatedGames.append(contentsOf: response.data)
				self.relatedGames.removeDuplicates()
			case .studio:
				guard let studioIdentity = self.studioIdentity else { return }
				let response = try await KService.games(for: studioIdentity).cursor(self.nextPageCursor).limit(self.nextPageCursor != nil ? 100 : 25).response()

				if self.nextPageCursor == nil {
					self.gameIdentities = []
				}

				self.nextPageCursor = response.nextCursor
				self.gameIdentities.append(contentsOf: response.data)
				self.gameIdentities.removeDuplicates()
			case .upcoming:
				let response = try await KService.upcomingGames().cursor(self.nextPageCursor).limit(self.nextPageCursor != nil ? 100 : 25).response()

				if self.nextPageCursor == nil {
					self.gameIdentities = []
				}

				self.nextPageCursor = response.nextCursor
				self.gameIdentities.append(contentsOf: response.data)
				self.gameIdentities.removeDuplicates()
			case .explore:
				guard let exploreCategoryIdentity = self.exploreCategoryIdentity else { return }
				let response = try await KService.exploreCategory(exploreCategoryIdentity).cursor(self.nextPageCursor).limit(self.nextPageCursor != nil ? 100 : 25).response()

				if self.nextPageCursor == nil {
					self.relatedGames = []
					self.gameIdentities = []
				}

				self.nextPageCursor = response.data.first?.relationships.games?.nextCursor
				self.gameIdentities.append(contentsOf: response.data.first?.relationships.games?.data ?? [])
				self.gameIdentities.removeDuplicates()
			}
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
	override func makeDestination(for identifier: any SegueIdentifier) -> UIViewController? {
		guard let identifier = identifier as? SegueIdentifiers else { return nil }

		switch identifier {
		case .gameDetailsSegue: return GameDetailsCollectionViewController()
		}
	}

	override func prepare(for identifier: any SegueIdentifier, destination: UIViewController, sender: Any?) {
		guard let identifier = identifier as? SegueIdentifiers else { return }

		switch identifier {
		case .gameDetailsSegue:
			guard let destination = destination as? GameDetailsCollectionViewController else { return }
			guard let game = sender as? Game else { return }
			destination.game = game
		}
	}
}

// MARK: - KCollectionViewDataSource
extension GamesListCollectionViewController {
	override func configureDataSource() {
		let gameLockupCellRegistration = self.getConfiguredGameCell()
		let upcomingLockupCellRegistration = self.getConfiguredUpcomingCell()

		self.dataSource = UICollectionViewDiffableDataSource<SectionLayoutKind, ItemKind>(collectionView: collectionView) { [weak self] collectionView, indexPath, itemKind in
			guard let self = self else { return nil }

			switch self.gamesListFetchType {
			case .upcoming:
				return collectionView.dequeueConfiguredReusableCell(using: upcomingLockupCellRegistration, for: indexPath, item: itemKind)
			default:
				return collectionView.dequeueConfiguredReusableCell(using: gameLockupCellRegistration, for: indexPath, item: itemKind)
			}
		}
	}

	override func updateDataSource() {
		self.snapshot = NSDiffableDataSourceSnapshot<SectionLayoutKind, ItemKind>()
		self.snapshot.appendSections([.main])

		switch self.gamesListFetchType {
		case .relatedGame, .show, .literature:
			let items: [ItemKind] = self.relatedGames.map { .relatedGame($0) }
			self.snapshot.appendItems(items, toSection: .main)
		default:
			let items: [ItemKind] = self.gameIdentities.map { .gameIdentity($0) }
			self.snapshot.appendItems(items, toSection: .main)
		}

		self.dataSource.apply(self.snapshot)
	}

	private func getConfiguredGameCell() -> UICollectionView.CellRegistration<GameLockupCollectionViewCell, ItemKind> {
		return UICollectionView.CellRegistration<GameLockupCollectionViewCell, ItemKind>(cellNib: GameLockupCollectionViewCell.nib) { [weak self] cell, indexPath, itemKind in
			guard let self = self else { return }

			switch itemKind {
			case .gameIdentity:
				let game: Game? = self.fetchModel(at: indexPath)

				if game == nil, let section = self.snapshot.sectionIdentifier(containingItem: itemKind), !self.isFetchingSection.contains(section) {
					Task {
						await self.fetchSectionIfNeeded(ResourceCollection<Game>.self, GameIdentity.self, at: indexPath, itemKind: itemKind)
					}
				}

				cell.delegate = self
				cell.configure(using: game)
			case .relatedGame(let relatedGame):
				cell.delegate = self
				cell.configure(using: relatedGame)
			}
		}
	}

	private func getConfiguredUpcomingCell() -> UICollectionView.CellRegistration<UpcomingLockupCollectionViewCell, ItemKind> {
		return UICollectionView.CellRegistration<UpcomingLockupCollectionViewCell, ItemKind>(cellNib: UpcomingLockupCollectionViewCell.nib) { [weak self] cell, indexPath, itemKind in
			guard let self = self else { return }

			switch itemKind {
			case .gameIdentity:
				let game: Game? = self.fetchModel(at: indexPath)

				if game == nil, let section = self.snapshot.sectionIdentifier(containingItem: itemKind), !self.isFetchingSection.contains(section) {
					Task {
						await self.fetchSectionIfNeeded(ResourceCollection<Game>.self, GameIdentity.self, at: indexPath, itemKind: itemKind)
					}
				}

				cell.delegate = self
				cell.configure(using: game)
			default: break
			}
		}
	}
}

// MARK: - KCollectionViewDelegateLayout
extension GamesListCollectionViewController {
	override func columnCount(forSection section: Int, layout layoutEnvironment: NSCollectionLayoutEnvironment) -> Int {
		let width = layoutEnvironment.container.effectiveContentSize.width
		let columnCount = Int(width >= 414 ? (width / 384).rounded() : (width / 284).rounded())
		return columnCount > 0 ? columnCount : 1
	}

	override func createLayout() -> UICollectionViewLayout? {
		return UICollectionViewCompositionalLayout { [weak self] section, layoutEnvironment in
			guard let self = self else { return nil }
			let columns = self.columnCount(forSection: section, layout: layoutEnvironment)

			if self.gamesListFetchType == .upcoming {
				return Layouts.upcomingSection(section, columns: columns, layoutEnvironment: layoutEnvironment, isHorizontal: false)
			}

			return Layouts.smallSection(section, columns: columns, layoutEnvironment: layoutEnvironment, isHorizontal: false)
		}
	}
}

// MARK: - UICollectionViewDelegate
extension GamesListCollectionViewController {
	override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		let game = self.cache[indexPath] as? Game
		let relatedGame = self.relatedGames[safe: indexPath.item]?.game
		guard let game = game ?? relatedGame else { return }

		self.show(SegueIdentifiers.gameDetailsSegue, sender: game)
	}

	override func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
		switch self.gamesListFetchType {
		case .relatedGame, .show, .literature:
			self.paginateIfNeeded(at: indexPath, totalItems: self.relatedGames.count)
		default:
			self.paginateIfNeeded(at: indexPath, totalItems: self.gameIdentities.count)
		}
	}

	override func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
		let collectionViewCell = collectionView.cellForItem(at: indexPath)

		switch self.gamesListFetchType {
		case .relatedGame, .show, .literature:
			guard let game = self.relatedGames[safe: indexPath.item]?.game else { return nil }
			return game.contextMenuConfiguration(in: self, userInfo: ["indexPath": indexPath], sourceView: collectionViewCell?.contentView, barButtonItem: nil)
		default:
			guard let game = self.cache[indexPath] as? Game else { return nil }
			return game.contextMenuConfiguration(in: self, userInfo: ["indexPath": indexPath], sourceView: collectionViewCell?.contentView, barButtonItem: nil)
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
		let actionSheetAlertController = UIAlertController.actionSheetWithItems(items: LibraryStatus.alertControllerItems(for: cell.libraryKind), currentSelection: oldLibraryStatus, action: { title, value in
			Task {
				do {
					let libraryUpdateResponse = try await KService.addToLibrary(.games, status: value, itemIDs: [game.id]).response()
					game.attributes.library?.update(using: libraryUpdateResponse.data)

					cell.libraryStatus = value
					button.setTitle("\(title) ▾", for: .normal)

					let libraryAddToNotificationName = Notification.Name("AddTo\(value.sectionValue)Section")
					NotificationCenter.default.post(name: libraryAddToNotificationName, object: nil)

					ReviewManager.shared.requestReview(for: .itemAddedToLibrary(status: value))
				} catch let error as APIError {
					self.presentAlertController(title: "Can't Add to Your Library 😔", message: error.message)
					print("----- Add to library failed", error.message)
				}
			}
		})

		if cell.libraryStatus != .none {
			actionSheetAlertController.addAction(UIAlertAction(title: L10n.removeFromLibrary, style: .destructive) { _ in
				Task {
					do {
						let libraryUpdateResponse = try await KService.removeFromLibrary(.games, itemIDs: [game.id]).response()
						game.attributes.library?.update(using: libraryUpdateResponse.data)

						cell.libraryStatus = .none
						button.setTitle(L10n.add.uppercased(), for: .normal)

						let libraryRemoveFromNotificationName = Notification.Name("RemoveFrom\(oldLibraryStatus.sectionValue)Section")
						NotificationCenter.default.post(name: libraryRemoveFromNotificationName, object: nil)
					} catch let error as APIError {
						self.presentAlertController(title: "Can't Remove From Your Library 😔", message: error.message)
						print("----- Remove from library failed", error.message)
					}
				}
			})
		}

		if let popoverController = actionSheetAlertController.popoverPresentationController {
			popoverController.sourceView = button
			popoverController.sourceRect = button.bounds
		}

		if (self.navigationController?.visibleViewController as? UIAlertController) == nil {
			self.present(actionSheetAlertController, animated: true, completion: nil)
		}
	}

	func baseLockupCollectionViewCell(_ cell: BaseLockupCollectionViewCell, didPressReminder button: UIButton) async {}
}
