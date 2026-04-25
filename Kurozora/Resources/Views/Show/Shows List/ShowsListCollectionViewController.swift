//
//  ShowsListCollectionViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 16/01/2020.
//  Copyright © 2020 Kurozora. All rights reserved.
//

import KurozoraKit
import UIKit

/// A source of shows for ``ShowsListCollectionViewController``.
enum ShowsListFetchType {
	case game
	case literature
	case character
	case explore
	case person
	case moreByStudio
	case relatedShow
	case search
	case studio
	case upcoming
}

/// A paginated list of shows (or related shows).
class ShowsListCollectionViewController: ListCollectionViewController, SectionFetchable {
	// MARK: - Enums
	enum SegueIdentifiers: String, SegueIdentifier {
		case showDetailsSegue
	}

	/// The section identifier.
	enum SectionLayoutKind: Int, CaseIterable {
		case main = 0
	}

	/// An item displayed in the list.
	enum ItemKind: Hashable {
		case showIdentity(_: ShowIdentity)
		case relatedShow(_: RelatedShow)
	}

	// MARK: - Properties
	var gameIdentity: GameIdentity?
	var literatureIdentity: LiteratureIdentity?
	var personIdentity: PersonIdentity?
	var characterIdentity: CharacterIdentity?
	var showIdentity: ShowIdentity?
	var studioIdentity: StudioIdentity?
	var exploreCategoryIdentity: ExploreCategoryIdentity?

	var showIdentities: [ShowIdentity] = []
	var relatedShows: [RelatedShow] = []

	var searchQuery: String = ""
	var showsListFetchType: ShowsListFetchType = .search

	// MARK: - SectionFetchable
	var cache: [IndexPath: KurozoraItem] = [:]
	var isFetchingSection: Set<SectionLayoutKind> = []

	var dataSource: UICollectionViewDiffableDataSource<SectionLayoutKind, ItemKind>! = nil
	var snapshot: NSDiffableDataSourceSnapshot<SectionLayoutKind, ItemKind>! = nil

	override var emptyStateImage: UIImage { .Empty.animeLibrary }
	override var emptyStateTitle: String { "No Shows" }
	override var emptyStateDetail: String { "Can't get shows list. Please refresh the page or restart the app and check your WiFi connection." }

	override var hasLoadedInitialData: Bool {
		!self.showIdentities.isEmpty || !self.relatedShows.isEmpty
	}

	override func fetchItems() async {
		guard !self.isRequestInProgress else { return }
		self.isRequestInProgress = true

		defer { self.endFetch() }

		do {
			switch self.showsListFetchType {
			case .game:
				guard let gameIdentity = self.gameIdentity else { return }
				let response = try await KService.relatedShows(for: gameIdentity).cursor(self.nextPageCursor).limit(self.nextPageCursor != nil ? 100 : 25).response()

				if self.nextPageCursor == nil {
					self.relatedShows = []
					self.showIdentities = []
				}

				self.nextPageCursor = response.nextCursor
				self.relatedShows.append(contentsOf: response.data)
				self.relatedShows.removeDuplicates()
			case .literature:
				guard let literatureIdentity = self.literatureIdentity else { return }
				let response = try await KService.relatedShows(for: literatureIdentity).cursor(self.nextPageCursor).limit(self.nextPageCursor != nil ? 100 : 25).response()

				if self.nextPageCursor == nil {
					self.relatedShows = []
					self.showIdentities = []
				}

				self.nextPageCursor = response.nextCursor
				self.relatedShows.append(contentsOf: response.data)
				self.relatedShows.removeDuplicates()
			case .character:
				guard let characterIdentity = self.characterIdentity else { return }
				let response = try await KService.shows(for: characterIdentity).cursor(self.nextPageCursor).limit(self.nextPageCursor != nil ? 100 : 25).response()

				if self.nextPageCursor == nil {
					self.showIdentities = []
				}

				self.nextPageCursor = response.nextCursor
				self.showIdentities.append(contentsOf: response.data)
				self.showIdentities.removeDuplicates()
			case .person:
				guard let personIdentity = self.personIdentity else { return }
				let response = try await KService.shows(for: personIdentity).cursor(self.nextPageCursor).limit(self.nextPageCursor != nil ? 100 : 25).response()

				if self.nextPageCursor == nil {
					self.showIdentities = []
				}

				self.nextPageCursor = response.nextCursor
				self.showIdentities.append(contentsOf: response.data)
				self.showIdentities.removeDuplicates()
			case .search:
				let searchResponse = try await KService.search(.kurozora, types: [.shows], query: self.searchQuery).cursor(self.nextPageCursor).limit(self.nextPageCursor != nil ? 100 : 25).filter(nil).response()

				if self.nextPageCursor == nil {
					self.relatedShows = []
					self.showIdentities = []
				}

				self.nextPageCursor = searchResponse.data.shows?.nextCursor
				self.showIdentities.append(contentsOf: searchResponse.data.shows?.data ?? [])
				self.showIdentities.removeDuplicates()
			case .moreByStudio:
				guard let showIdentity = self.showIdentity else { return }
				let response = try await KService.moreByStudio(for: showIdentity).cursor(self.nextPageCursor).limit(self.nextPageCursor != nil ? 100 : 25).response()

				if self.nextPageCursor == nil {
					self.showIdentities = []
				}

				self.nextPageCursor = response.nextCursor
				self.showIdentities.append(contentsOf: response.data)
				self.showIdentities.removeDuplicates()
			case .relatedShow:
				guard let showIdentity = self.showIdentity else { return }
				let response = try await KService.relatedShows(for: showIdentity).cursor(self.nextPageCursor).limit(self.nextPageCursor != nil ? 100 : 25).response()

				if self.nextPageCursor == nil {
					self.relatedShows = []
					self.showIdentities = []
				}

				self.nextPageCursor = response.nextCursor
				self.relatedShows.append(contentsOf: response.data)
				self.relatedShows.removeDuplicates()
			case .studio:
				guard let studioIdentity = self.studioIdentity else { return }
				let response = try await KService.shows(for: studioIdentity).cursor(self.nextPageCursor).limit(self.nextPageCursor != nil ? 100 : 25).response()

				if self.nextPageCursor == nil {
					self.showIdentities = []
				}

				self.nextPageCursor = response.nextCursor
				self.showIdentities.append(contentsOf: response.data)
				self.showIdentities.removeDuplicates()
			case .upcoming:
				let response = try await KService.upcomingShows().cursor(self.nextPageCursor).limit(self.nextPageCursor != nil ? 100 : 25).response()

				if self.nextPageCursor == nil {
					self.showIdentities = []
				}

				self.nextPageCursor = response.nextCursor
				self.showIdentities.append(contentsOf: response.data)
				self.showIdentities.removeDuplicates()
			case .explore:
				guard let exploreCategoryIdentity = self.exploreCategoryIdentity else { return }
				let response = try await KService.exploreCategory(exploreCategoryIdentity).cursor(self.nextPageCursor).limit(self.nextPageCursor != nil ? 100 : 25).response()

				if self.nextPageCursor == nil {
					self.relatedShows = []
					self.showIdentities = []
				}

				self.nextPageCursor = response.data.first?.relationships.shows?.nextCursor
				self.showIdentities.append(contentsOf: response.data.first?.relationships.shows?.data ?? [])
				self.showIdentities.removeDuplicates()
			}
		} catch {
			print(error.localizedDescription)
		}
	}

	// MARK: - SectionFetchable
	func extractIdentity<Element>(from item: ItemKind) -> Element? where Element: KurozoraItem {
		switch item {
		case .showIdentity(let id): return id as? Element
		default: return nil
		}
	}

	// MARK: - Segue
	override func makeDestination(for identifier: any SegueIdentifier) -> UIViewController? {
		guard let identifier = identifier as? SegueIdentifiers else { return nil }

		switch identifier {
		case .showDetailsSegue: return ShowDetailsCollectionViewController()
		}
	}

	override func prepare(for identifier: any SegueIdentifier, destination: UIViewController, sender: Any?) {
		guard let identifier = identifier as? SegueIdentifiers else { return }

		switch identifier {
		case .showDetailsSegue:
			guard let destination = destination as? ShowDetailsCollectionViewController else { return }
			guard let show = sender as? Show else { return }
			destination.show = show
		}
	}
}

// MARK: - KCollectionViewDataSource
extension ShowsListCollectionViewController {
	override func configureDataSource() {
		let smallLockupCellRegistration = self.getConfiguredSmallCell()
		let upcomingLockupCellRegistration = self.getConfiguredUpcomingCell()

		self.dataSource = UICollectionViewDiffableDataSource<SectionLayoutKind, ItemKind>(collectionView: collectionView) { [weak self] collectionView, indexPath, itemKind in
			guard let self = self else { return nil }

			switch self.showsListFetchType {
			case .upcoming:
				return collectionView.dequeueConfiguredReusableCell(using: upcomingLockupCellRegistration, for: indexPath, item: itemKind)
			default:
				return collectionView.dequeueConfiguredReusableCell(using: smallLockupCellRegistration, for: indexPath, item: itemKind)
			}
		}
	}

	override func updateDataSource() {
		self.snapshot = NSDiffableDataSourceSnapshot<SectionLayoutKind, ItemKind>()
		self.snapshot.appendSections([.main])

		switch self.showsListFetchType {
		case .relatedShow, .literature, .game:
			let items: [ItemKind] = self.relatedShows.map { .relatedShow($0) }
			self.snapshot.appendItems(items, toSection: .main)
		default:
			let items: [ItemKind] = self.showIdentities.map { .showIdentity($0) }
			self.snapshot.appendItems(items, toSection: .main)
		}

		self.dataSource.apply(self.snapshot)
	}

	private func getConfiguredSmallCell() -> UICollectionView.CellRegistration<SmallLockupCollectionViewCell, ItemKind> {
		return UICollectionView.CellRegistration<SmallLockupCollectionViewCell, ItemKind>(cellNib: SmallLockupCollectionViewCell.nib) { [weak self] cell, indexPath, itemKind in
			guard let self = self else { return }

			switch itemKind {
			case .showIdentity:
				let show: Show? = self.fetchModel(at: indexPath)

				if show == nil, let section = self.snapshot.sectionIdentifier(containingItem: itemKind), !self.isFetchingSection.contains(section) {
					Task {
						await self.fetchSectionIfNeeded(ResourceCollection<Show>.self, ShowIdentity.self, at: indexPath, itemKind: itemKind)
					}
				}

				cell.delegate = self
				cell.configure(using: show)
			case .relatedShow(let relatedShow):
				cell.delegate = self
				cell.configure(using: relatedShow)
			}
		}
	}

	private func getConfiguredUpcomingCell() -> UICollectionView.CellRegistration<UpcomingLockupCollectionViewCell, ItemKind> {
		return UICollectionView.CellRegistration<UpcomingLockupCollectionViewCell, ItemKind>(cellNib: UpcomingLockupCollectionViewCell.nib) { [weak self] cell, indexPath, itemKind in
			guard let self = self else { return }

			switch itemKind {
			case .showIdentity:
				let show: Show? = self.fetchModel(at: indexPath)

				if show == nil, let section = self.snapshot.sectionIdentifier(containingItem: itemKind), !self.isFetchingSection.contains(section) {
					Task {
						await self.fetchSectionIfNeeded(ResourceCollection<Show>.self, ShowIdentity.self, at: indexPath, itemKind: itemKind)
					}
				}

				cell.delegate = self
				cell.configure(using: show)
			default: break
			}
		}
	}
}

// MARK: - KCollectionViewDelegateLayout
extension ShowsListCollectionViewController {
	override func columnCount(forSection section: Int, layout layoutEnvironment: NSCollectionLayoutEnvironment) -> Int {
		let width = layoutEnvironment.container.effectiveContentSize.width
		let columnCount = Int(width >= 414 ? (width / 384).rounded() : (width / 284).rounded())
		return columnCount > 0 ? columnCount : 1
	}

	override func createLayout() -> UICollectionViewLayout? {
		return UICollectionViewCompositionalLayout { [weak self] section, layoutEnvironment in
			guard let self = self else { return nil }
			let columns = self.columnCount(forSection: section, layout: layoutEnvironment)

			if self.showsListFetchType == .upcoming {
				return Layouts.upcomingSection(section, columns: columns, layoutEnvironment: layoutEnvironment, isHorizontal: false)
			}

			return Layouts.smallSection(section, columns: columns, layoutEnvironment: layoutEnvironment, isHorizontal: false)
		}
	}
}

// MARK: - UICollectionViewDelegate
extension ShowsListCollectionViewController {
	override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		let show = self.cache[indexPath] as? Show
		let relatedShow = self.relatedShows[safe: indexPath.item]?.show
		guard let show = show ?? relatedShow else { return }

		self.show(SegueIdentifiers.showDetailsSegue, sender: show)
	}

	override func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
		switch self.showsListFetchType {
		case .relatedShow, .literature, .game:
			self.paginateIfNeeded(at: indexPath, totalItems: self.relatedShows.count)
		default:
			self.paginateIfNeeded(at: indexPath, totalItems: self.showIdentities.count)
		}
	}

	override func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
		let collectionViewCell = collectionView.cellForItem(at: indexPath)

		switch self.showsListFetchType {
		case .relatedShow, .literature, .game:
			guard let show = self.relatedShows[safe: indexPath.item]?.show else { return nil }
			return show.contextMenuConfiguration(in: self, userInfo: ["indexPath": indexPath], sourceView: collectionViewCell?.contentView, barButtonItem: nil)
		default:
			guard let show = self.cache[indexPath] as? Show else { return nil }
			return show.contextMenuConfiguration(in: self, userInfo: ["indexPath": indexPath], sourceView: collectionViewCell?.contentView, barButtonItem: nil)
		}
	}
}

// MARK: - BaseLockupCollectionViewCellDelegate
extension ShowsListCollectionViewController: BaseLockupCollectionViewCellDelegate {
	func baseLockupCollectionViewCell(_ cell: BaseLockupCollectionViewCell, didPressStatus button: UIButton) async {
		let signedIn = await WorkflowController.shared.isSignedIn(on: self)
		guard signedIn else { return }
		guard let indexPath = self.collectionView.indexPath(for: cell) else { return }
		let show = (self.cache[indexPath] as? Show) ?? self.relatedShows[indexPath.item].show

		let oldLibraryStatus = cell.libraryStatus
		let actionSheetAlertController = UIAlertController.actionSheetWithItems(items: LibraryStatus.alertControllerItems(for: cell.libraryKind), currentSelection: oldLibraryStatus, action: { title, value in
			Task {
				do {
					let libraryUpdateResponse = try await KService.addToLibrary(.shows, status: value, itemIDs: [show.id]).response()
					show.attributes.library?.update(using: libraryUpdateResponse.data)

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
						let libraryUpdateResponse = try await KService.removeFromLibrary(.shows, itemIDs: [show.id]).response()
						show.attributes.library?.update(using: libraryUpdateResponse.data)

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

	func baseLockupCollectionViewCell(_ cell: BaseLockupCollectionViewCell, didPressReminder button: UIButton) async {
		guard let indexPath = self.collectionView.indexPath(for: cell) else { return }
		let show = (self.cache[indexPath] as? Show) ?? self.relatedShows[indexPath.item].show

		await show.toggleReminder(on: self)
		cell.configureReminderButton(for: show.attributes.library?.reminderStatus)
	}
}
