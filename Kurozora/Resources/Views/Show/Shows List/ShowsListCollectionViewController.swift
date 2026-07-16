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
class ShowsListCollectionViewController: ListCollectionViewController, SectionFetchable, TypedSegueHandling {
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

	/// Observes local library mutations to refresh visible cells.
	private var libraryObserver: LocalLibraryEntryObserver?

	var dataSource: UICollectionViewDiffableDataSource<SectionLayoutKind, ItemKind>! = nil
	var snapshot: NSDiffableDataSourceSnapshot<SectionLayoutKind, ItemKind>! = nil

	override var emptyStateImage: UIImage { .Empty.animeLibrary }
	override var emptyStateTitle: String { L10n.noItemsTitle(L10n.shows) }
	override var emptyStateDetail: String { L10n.cantGetListRefresh(L10n.shows.lowercased(with: .current)) }

	override var hasLoadedInitialData: Bool {
		!self.showIdentities.isEmpty || !self.relatedShows.isEmpty
	}

	override func viewDidLoad() {
		super.viewDidLoad()
		self.observeLibraryChanges()
	}

	/// Subscribes to local library mutations affecting the visible cells.
	private func observeLibraryChanges() {
		guard let slug = User.current?.attributes.slug else { return }
		self.libraryObserver = LocalLibraryEntryObserver(
			matching: LocalLibraryEntryObserver.matches(userSlug: slug, kind: .shows),
			onChange: { [weak self] entry in
				self?.applyLibraryEntryChange(forTrackableID: entry.trackableID, isRemoval: false)
			},
			onRemove: { [weak self] removed in
				self?.applyLibraryEntryChange(forTrackableID: removed.trackableID, isRemoval: true)
			}
		)
	}

	/// Updates every visible cell whose underlying show matches the given entry's trackable identity.
	private func applyLibraryEntryChange(forTrackableID trackableID: String, isRemoval: Bool) {
		var matchedItems: [ItemKind] = []
		let currentSnapshot = self.dataSource.snapshot()

		for item in currentSnapshot.itemIdentifiers {
			switch item {
			case .showIdentity(let identity):
				if identity.id.rawValue == trackableID,
				   let index = currentSnapshot.indexOfItem(item),
				   let show = self.cache[IndexPath(item: index, section: 0)] as? Show {
					matchedItems.append(item)
				}
			case .relatedShow(let relatedShow):
				if relatedShow.show.id.rawValue == trackableID {
					matchedItems.append(item)
				}
			}
		}

		guard !matchedItems.isEmpty else { return }
		var snapshot = currentSnapshot
		snapshot.reconfigureItems(matchedItems)
		self.dataSource.apply(snapshot, animatingDifferences: false)
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

		self.show(.showDetailsSegue, sender: show)
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

					if let slug = User.current?.attributes.slug {
						LibraryStore.shared.apply(libraryUpdateResponse.data.relationships.libraries, forUserSlug: slug, kind: .shows)
					}

					cell.libraryStatus = value
					button.setTitle("\(title) ▾", for: .normal)

					ReviewManager.shared.requestReview(for: .itemAddedToLibrary(status: value))
				} catch let error as APIError {
					self.presentAlertController(title: L10n.cantAddToLibraryTitle, message: error.message)
					print("----- Add to library failed", error.message)
				}
			}
		})

		if cell.libraryStatus != .none {
			actionSheetAlertController.addAction(UIAlertAction(title: L10n.removeFromLibrary, style: .destructive) { _ in
				Task {
					do {
						let libraryUpdateResponse = try await KService.removeFromLibrary(.shows, itemIDs: [show.id]).response()

						if let slug = User.current?.attributes.slug {
							LibraryStore.shared.applyRemoved(forTrackableID: show.id.rawValue, userSlug: slug, kind: .shows)
						}

						cell.libraryStatus = .none
						button.setTitle(L10n.add.uppercased(with: Locale.current), for: .normal)

					} catch let error as APIError {
						self.presentAlertController(title: L10n.cantRemoveFromLibraryTitle, message: error.message)
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
		cell.configureReminderButton(for: show.libraryAttributes?.reminderStatus)
	}
}
