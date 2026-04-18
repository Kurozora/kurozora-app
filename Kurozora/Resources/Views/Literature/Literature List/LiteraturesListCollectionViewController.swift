//
//  LiteraturesListCollectionViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 01/02/2023.
//  Copyright © 2023 Kurozora. All rights reserved.
//

import KurozoraKit
import UIKit

/// A source of literatures for ``LiteraturesListCollectionViewController``.
enum LiteraturesListFetchType {
	case show
	case game
	case character
	case explore
	case person
	case moreByStudio
	case relatedLiterature
	case search
	case studio
	case upcoming
}

/// A paginated list of literatures (or related literatures).
class LiteraturesListCollectionViewController: ListCollectionViewController, SectionFetchable {
	// MARK: - Enums
	enum SegueIdentifiers: String, SegueIdentifier {
		case literatureDetailsSegue
	}

	/// The section identifier.
	enum SectionLayoutKind: Int, CaseIterable {
		case main = 0
	}

	/// An item displayed in the list.
	enum ItemKind: Hashable {
		case literatureIdentity(_: LiteratureIdentity)
		case relatedLiterature(_: RelatedLiterature)
	}

	// MARK: - Properties
	var showIdentity: ShowIdentity?
	var gameIdentity: GameIdentity?
	var personIdentity: PersonIdentity?
	var characterIdentity: CharacterIdentity?
	var literatureIdentity: LiteratureIdentity?
	var studioIdentity: StudioIdentity?
	var exploreCategoryIdentity: ExploreCategoryIdentity?

	var literatureIdentities: [LiteratureIdentity] = []
	var relatedLiteratures: [RelatedLiterature] = []

	var searchQuery: String = ""
	var literaturesListFetchType: LiteraturesListFetchType = .search

	// MARK: - SectionFetchable
	var cache: [IndexPath: KurozoraItem] = [:]
	var isFetchingSection: Set<SectionLayoutKind> = []

	var dataSource: UICollectionViewDiffableDataSource<SectionLayoutKind, ItemKind>!
	var snapshot: NSDiffableDataSourceSnapshot<SectionLayoutKind, ItemKind>!

	override var emptyStateImage: UIImage { .Empty.mangaLibrary }
	override var emptyStateTitle: String { "No Literatures" }
	override var emptyStateDetail: String { "Can't get literatures list. Please refresh the page or restart the app and check your WiFi connection." }

	override var hasLoadedInitialData: Bool {
		!self.literatureIdentities.isEmpty || !self.relatedLiteratures.isEmpty
	}

	override func fetchItems() async {
		guard !self.isRequestInProgress else { return }
		self.isRequestInProgress = true

		defer { self.endFetch() }

		do {
			switch self.literaturesListFetchType {
			case .show:
				guard let showIdentity = self.showIdentity else { return }
				let response = try await KService.getRelatedLiteratures(forShow: showIdentity, next: self.nextPageURL, limit: self.nextPageURL != nil ? 100 : 25)

				if self.nextPageURL == nil {
					self.relatedLiteratures = []
					self.literatureIdentities = []
				}

				self.nextPageURL = response.next
				self.relatedLiteratures.append(contentsOf: response.data)
				self.relatedLiteratures.removeDuplicates()
			case .game:
				guard let gameIdentity = self.gameIdentity else { return }
				let response = try await KService.getRelatedLiteratures(forGame: gameIdentity, next: self.nextPageURL, limit: self.nextPageURL != nil ? 100 : 25)

				if self.nextPageURL == nil {
					self.relatedLiteratures = []
					self.literatureIdentities = []
				}

				self.nextPageURL = response.next
				self.relatedLiteratures.append(contentsOf: response.data)
				self.relatedLiteratures.removeDuplicates()
			case .character:
				guard let characterIdentity = self.characterIdentity else { return }
				let response = try await KService.getLiteratures(forCharacter: characterIdentity, next: self.nextPageURL, limit: self.nextPageURL != nil ? 100 : 25)

				if self.nextPageURL == nil {
					self.literatureIdentities = []
				}

				self.nextPageURL = response.next
				self.literatureIdentities.append(contentsOf: response.data)
				self.literatureIdentities.removeDuplicates()
			case .person:
				guard let personIdentity = self.personIdentity else { return }
				let response = try await KService.getLiteratures(forPerson: personIdentity, next: self.nextPageURL, limit: self.nextPageURL != nil ? 100 : 25)

				if self.nextPageURL == nil {
					self.literatureIdentities = []
				}

				self.nextPageURL = response.next
				self.literatureIdentities.append(contentsOf: response.data)
				self.literatureIdentities.removeDuplicates()
			case .search:
				let searchResponse = try await KService.search(.kurozora, of: [.literatures], for: self.searchQuery, next: self.nextPageURL, limit: self.nextPageURL != nil ? 100 : 25, filter: nil)

				if self.nextPageURL == nil {
					self.relatedLiteratures = []
					self.literatureIdentities = []
				}

				self.nextPageURL = searchResponse.data.literatures?.next
				self.literatureIdentities.append(contentsOf: searchResponse.data.literatures?.data ?? [])
				self.literatureIdentities.removeDuplicates()
			case .moreByStudio:
				guard let literatureIdentity = self.literatureIdentity else { return }
				let response = try await KService.getMoreByStudio(forLiterature: literatureIdentity, next: self.nextPageURL, limit: self.nextPageURL != nil ? 100 : 25)

				if self.nextPageURL == nil {
					self.literatureIdentities = []
				}

				self.nextPageURL = response.next
				self.literatureIdentities.append(contentsOf: response.data)
				self.literatureIdentities.removeDuplicates()
			case .relatedLiterature:
				guard let literatureIdentity = self.literatureIdentity else { return }
				let response = try await KService.getRelatedLiteratures(forLiterature: literatureIdentity, next: self.nextPageURL, limit: self.nextPageURL != nil ? 100 : 25)

				if self.nextPageURL == nil {
					self.relatedLiteratures = []
					self.literatureIdentities = []
				}

				self.nextPageURL = response.next
				self.relatedLiteratures.append(contentsOf: response.data)
				self.relatedLiteratures.removeDuplicates()
			case .studio:
				guard let studioIdentity = self.studioIdentity else { return }
				let response = try await KService.getLiteratures(forStudio: studioIdentity, next: self.nextPageURL, limit: self.nextPageURL != nil ? 100 : 25)

				if self.nextPageURL == nil {
					self.literatureIdentities = []
				}

				self.nextPageURL = response.next
				self.literatureIdentities.append(contentsOf: response.data)
				self.literatureIdentities.removeDuplicates()
			case .upcoming:
				let response = try await KService.getUpcomingLiteratures(next: self.nextPageURL, limit: self.nextPageURL != nil ? 100 : 25)

				if self.nextPageURL == nil {
					self.literatureIdentities = []
				}

				self.nextPageURL = response.next
				self.literatureIdentities.append(contentsOf: response.data)
				self.literatureIdentities.removeDuplicates()
			case .explore:
				guard let exploreCategoryIdentity = self.exploreCategoryIdentity else { return }
				let response = try await KService.getExplore(exploreCategoryIdentity, next: self.nextPageURL, limit: self.nextPageURL != nil ? 100 : 25)

				if self.nextPageURL == nil {
					self.relatedLiteratures = []
					self.literatureIdentities = []
				}

				self.nextPageURL = response.data.first?.relationships.literatures?.next
				self.literatureIdentities.append(contentsOf: response.data.first?.relationships.literatures?.data ?? [])
				self.literatureIdentities.removeDuplicates()
			}
		} catch {
			print(error.localizedDescription)
		}
	}

	// MARK: - SectionFetchable
	func extractIdentity<Element>(from item: ItemKind) -> Element? where Element: KurozoraItem {
		switch item {
		case .literatureIdentity(let id): return id as? Element
		default: return nil
		}
	}

	// MARK: - Segue
	override func makeDestination(for identifier: any SegueIdentifier) -> UIViewController? {
		guard let identifier = identifier as? SegueIdentifiers else { return nil }

		switch identifier {
		case .literatureDetailsSegue: return LiteratureDetailsCollectionViewController()
		}
	}

	override func prepare(for identifier: any SegueIdentifier, destination: UIViewController, sender: Any?) {
		guard let identifier = identifier as? SegueIdentifiers else { return }

		switch identifier {
		case .literatureDetailsSegue:
			guard let destination = destination as? LiteratureDetailsCollectionViewController else { return }
			guard let literature = sender as? Literature else { return }
			destination.literature = literature
		}
	}
}

// MARK: - KCollectionViewDataSource
extension LiteraturesListCollectionViewController {
	override func configureDataSource() {
		let smallLockupCellRegistration = self.getConfiguredSmallCell()
		let upcomingLockupCellRegistration = self.getConfiguredUpcomingCell()

		self.dataSource = UICollectionViewDiffableDataSource<SectionLayoutKind, ItemKind>(collectionView: collectionView) { [weak self] collectionView, indexPath, itemKind in
			guard let self = self else { return nil }

			switch self.literaturesListFetchType {
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

		switch self.literaturesListFetchType {
		case .relatedLiterature, .show, .game:
			let items: [ItemKind] = self.relatedLiteratures.map { .relatedLiterature($0) }
			self.snapshot.appendItems(items, toSection: .main)
		default:
			let items: [ItemKind] = self.literatureIdentities.map { .literatureIdentity($0) }
			self.snapshot.appendItems(items, toSection: .main)
		}

		self.dataSource.apply(self.snapshot)
	}

	private func getConfiguredSmallCell() -> UICollectionView.CellRegistration<SmallLockupCollectionViewCell, ItemKind> {
		return UICollectionView.CellRegistration<SmallLockupCollectionViewCell, ItemKind>(cellNib: SmallLockupCollectionViewCell.nib) { [weak self] cell, indexPath, itemKind in
			guard let self = self else { return }

			switch itemKind {
			case .literatureIdentity:
				let literature: Literature? = self.fetchModel(at: indexPath)

				if literature == nil, let section = self.snapshot.sectionIdentifier(containingItem: itemKind), !self.isFetchingSection.contains(section) {
					Task {
						await self.fetchSectionIfNeeded(LiteratureResponse.self, LiteratureIdentity.self, at: indexPath, itemKind: itemKind)
					}
				}

				cell.delegate = self
				cell.configure(using: literature)
			case .relatedLiterature(let relatedLiterature):
				cell.delegate = self
				cell.configure(using: relatedLiterature)
			}
		}
	}

	private func getConfiguredUpcomingCell() -> UICollectionView.CellRegistration<UpcomingLockupCollectionViewCell, ItemKind> {
		return UICollectionView.CellRegistration<UpcomingLockupCollectionViewCell, ItemKind>(cellNib: UpcomingLockupCollectionViewCell.nib) { [weak self] cell, indexPath, itemKind in
			guard let self = self else { return }

			switch itemKind {
			case .literatureIdentity:
				let literature: Literature? = self.fetchModel(at: indexPath)

				if literature == nil, let section = self.snapshot.sectionIdentifier(containingItem: itemKind), !self.isFetchingSection.contains(section) {
					Task {
						await self.fetchSectionIfNeeded(LiteratureResponse.self, LiteratureIdentity.self, at: indexPath, itemKind: itemKind)
					}
				}

				cell.delegate = self
				cell.configure(using: literature)
			default: break
			}
		}
	}
}

// MARK: - KCollectionViewDelegateLayout
extension LiteraturesListCollectionViewController {
	override func columnCount(forSection section: Int, layout layoutEnvironment: NSCollectionLayoutEnvironment) -> Int {
		let width = layoutEnvironment.container.effectiveContentSize.width
		let columnCount = Int(width >= 414 ? (width / 384).rounded() : (width / 284).rounded())
		return columnCount > 0 ? columnCount : 1
	}

	override func createLayout() -> UICollectionViewLayout? {
		return UICollectionViewCompositionalLayout { [weak self] section, layoutEnvironment in
			guard let self = self else { return nil }
			let columns = self.columnCount(forSection: section, layout: layoutEnvironment)

			if self.literaturesListFetchType == .upcoming {
				return Layouts.upcomingSection(section, columns: columns, layoutEnvironment: layoutEnvironment, isHorizontal: false)
			}

			return Layouts.smallSection(section, columns: columns, layoutEnvironment: layoutEnvironment, isHorizontal: false)
		}
	}
}

// MARK: - UICollectionViewDelegate
extension LiteraturesListCollectionViewController {
	override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		let literature = self.cache[indexPath] as? Literature
		let relatedLiterature = self.relatedLiteratures[safe: indexPath.item]?.literature
		guard let literature = literature ?? relatedLiterature else { return }

		self.show(SegueIdentifiers.literatureDetailsSegue, sender: literature)
	}

	override func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
		switch self.literaturesListFetchType {
		case .relatedLiterature, .show, .game:
			self.paginateIfNeeded(at: indexPath, totalItems: self.relatedLiteratures.count)
		default:
			self.paginateIfNeeded(at: indexPath, totalItems: self.literatureIdentities.count)
		}
	}

	override func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
		let collectionViewCell = collectionView.cellForItem(at: indexPath)

		switch self.literaturesListFetchType {
		case .relatedLiterature, .show, .game:
			guard let literature = self.relatedLiteratures[safe: indexPath.item]?.literature else { return nil }
			return literature.contextMenuConfiguration(in: self, userInfo: ["indexPath": indexPath], sourceView: collectionViewCell?.contentView, barButtonItem: nil)
		default:
			guard let literature = self.cache[indexPath] as? Literature else { return nil }
			return literature.contextMenuConfiguration(in: self, userInfo: ["indexPath": indexPath], sourceView: collectionViewCell?.contentView, barButtonItem: nil)
		}
	}
}

// MARK: - BaseLockupCollectionViewCellDelegate
extension LiteraturesListCollectionViewController: BaseLockupCollectionViewCellDelegate {
	func baseLockupCollectionViewCell(_ cell: BaseLockupCollectionViewCell, didPressStatus button: UIButton) async {
		let signedIn = await WorkflowController.shared.isSignedIn(on: self)
		guard signedIn else { return }
		guard let indexPath = self.collectionView.indexPath(for: cell) else { return }
		let literature = (self.cache[indexPath] as? Literature) ?? self.relatedLiteratures[indexPath.item].literature

		let oldLibraryStatus = cell.libraryStatus
		let actionSheetAlertController = UIAlertController.actionSheetWithItems(items: KKLibrary.Status.alertControllerItems(for: cell.libraryKind), currentSelection: oldLibraryStatus, action: { title, value in
			Task {
				do {
					let libraryUpdateResponse = try await KService.addToLibrary(.literatures, withLibraryStatus: value, modelID: literature.id)
					literature.attributes.library?.update(using: libraryUpdateResponse.data)

					cell.libraryStatus = value
					button.setTitle("\(title) ▾", for: .normal)

					let libraryAddToNotificationName = Notification.Name("AddTo\(value.sectionValue)Section")
					NotificationCenter.default.post(name: libraryAddToNotificationName, object: nil)

					ReviewManager.shared.requestReview(for: .itemAddedToLibrary(status: value))
				} catch let error as KKAPIError {
					self.presentAlertController(title: "Can't Add to Your Library 😔", message: error.message)
					print("----- Add to library failed", error.message)
				}
			}
		})

		if cell.libraryStatus != .none {
			actionSheetAlertController.addAction(UIAlertAction(title: L10n.removeFromLibrary, style: .destructive) { _ in
				Task {
					do {
						let libraryUpdateResponse = try await KService.removeFromLibrary(.literatures, modelID: literature.id)
						literature.attributes.library?.update(using: libraryUpdateResponse.data)

						cell.libraryStatus = .none
						button.setTitle(L10n.add.uppercased(), for: .normal)

						let libraryRemoveFromNotificationName = Notification.Name("RemoveFrom\(oldLibraryStatus.sectionValue)Section")
						NotificationCenter.default.post(name: libraryRemoveFromNotificationName, object: nil)
					} catch let error as KKAPIError {
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
