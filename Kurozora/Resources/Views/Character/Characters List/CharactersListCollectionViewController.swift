//
//  CharactersListCollectionViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 20/08/2020.
//  Copyright © 2020 Kurozora. All rights reserved.
//

import KurozoraKit
import UIKit

/// A source of characters for ``CharactersListCollectionViewController``.
enum CharactersListFetchType {
	case person
	case explore
	case search
}

/// A paginated list of characters.
class CharactersListCollectionViewController: ListCollectionViewController, SectionFetchable, TypedSegueHandling {
	// MARK: - Enums
	enum SegueIdentifiers: String, SegueIdentifier {
		case characterDetailsSegue
	}

	/// The section identifier.
	enum SectionLayoutKind: Int, CaseIterable {
		case main = 0
	}

	/// An item displayed in the list.
	enum ItemKind: Hashable {
		case characterIdentity(_: CharacterIdentity)
	}

	// MARK: - Properties
	var personIdentity: PersonIdentity?
	var exploreCategoryIdentity: ExploreCategoryIdentity?
	var characterIdentities: [CharacterIdentity] = []
	var searchQuery: String = ""
	var charactersListFetchType: CharactersListFetchType = .search

	// MARK: - SectionFetchable
	var cache: [IndexPath: KurozoraItem] = [:]
	var isFetchingSection: Set<SectionLayoutKind> = []

	var dataSource: UICollectionViewDiffableDataSource<SectionLayoutKind, ItemKind>!
	var snapshot: NSDiffableDataSourceSnapshot<SectionLayoutKind, ItemKind>!

	override var emptyStateImage: UIImage { .Empty.cast }
	override var emptyStateTitle: String { L10n.noItemsTitle(L10n.characters) }
	override var emptyStateDetail: String { L10n.cantGetListDetail(L10n.characters.lowercased(with: .current)) }

	override var hasLoadedInitialData: Bool {
		!self.characterIdentities.isEmpty
	}

	override func viewDidLoad() {
		super.viewDidLoad()

		self.title = L10n.characters

		#if !targetEnvironment(macCatalyst)
		self.refreshControl?.attributedTitle = NSAttributedString(string: L10n.pullToRefreshItems(L10n.characters.lowercased(with: Locale.current)))
		#endif
	}

	override func fetchItems() async {
		guard !self.isRequestInProgress else { return }
		self.isRequestInProgress = true

		defer {
			self.endFetch()

			#if !targetEnvironment(macCatalyst)
			self.refreshControl?.attributedTitle = NSAttributedString(string: L10n.pullToRefreshItems(L10n.characters.lowercased(with: Locale.current)))
			#endif
		}

		#if !targetEnvironment(macCatalyst)
		self.refreshControl?.attributedTitle = NSAttributedString(string: L10n.refreshingItems(L10n.characters.lowercased(with: Locale.current)))
		#endif

		do {
			switch self.charactersListFetchType {
			case .person:
				guard let personIdentity = self.personIdentity else { return }
				let response = try await KService.characters(for: personIdentity).cursor(self.nextPageCursor).limit(self.nextPageCursor != nil ? 100 : 25).response()

				if self.nextPageCursor == nil {
					self.characterIdentities = []
				}

				self.nextPageCursor = response.nextCursor
				self.characterIdentities.append(contentsOf: response.data)
				self.characterIdentities.removeDuplicates()
			case .explore:
				guard let exploreCategoryIdentity = self.exploreCategoryIdentity else { return }
				let response = try await KService.exploreCategory(exploreCategoryIdentity).cursor(self.nextPageCursor).limit(self.nextPageCursor != nil ? 100 : 25).response()

				if self.nextPageCursor == nil {
					self.characterIdentities = []
				}

				self.nextPageCursor = response.data.first?.relationships.characters?.nextCursor
				self.characterIdentities.append(contentsOf: response.data.first?.relationships.characters?.data ?? [])
				self.characterIdentities.removeDuplicates()
			case .search:
				let searchResponse = try await KService.search(.kurozora, types: [.characters], query: self.searchQuery).cursor(self.nextPageCursor).limit(self.nextPageCursor != nil ? 100 : 25).filter(nil).response()

				if self.nextPageCursor == nil {
					self.characterIdentities = []
				}

				self.nextPageCursor = searchResponse.data.characters?.nextCursor
				self.characterIdentities.append(contentsOf: searchResponse.data.characters?.data ?? [])
				self.characterIdentities.removeDuplicates()
			}
		} catch {
			print(error.localizedDescription)
		}
	}

	// MARK: - SectionFetchable
	func extractIdentity<Element>(from item: ItemKind) -> Element? where Element: KurozoraItem {
		switch item {
		case .characterIdentity(let id): return id as? Element
		}
	}

	// MARK: - Segue
	override func makeDestination(for identifier: any SegueIdentifier) -> UIViewController? {
		guard let identifier = identifier as? SegueIdentifiers else { return nil }

		switch identifier {
		case .characterDetailsSegue: return CharacterDetailsCollectionViewController()
		}
	}

	override func prepare(for identifier: any SegueIdentifier, destination: UIViewController, sender: Any?) {
		guard let identifier = identifier as? SegueIdentifiers else { return }

		switch identifier {
		case .characterDetailsSegue:
			guard let destination = destination as? CharacterDetailsCollectionViewController else { return }
			guard let character = sender as? Character else { return }
			destination.character = character
		}
	}
}

// MARK: - KCollectionViewDataSource
extension CharactersListCollectionViewController {
	override func configureDataSource() {
		let characterCellRegistration = self.getConfiguredCharacterCell()

		self.dataSource = UICollectionViewDiffableDataSource<SectionLayoutKind, ItemKind>(collectionView: collectionView) { collectionView, indexPath, itemKind in
			return collectionView.dequeueConfiguredReusableCell(using: characterCellRegistration, for: indexPath, item: itemKind)
		}
	}

	override func updateDataSource() {
		self.snapshot = NSDiffableDataSourceSnapshot<SectionLayoutKind, ItemKind>()
		self.snapshot.appendSections([.main])

		let items: [ItemKind] = self.characterIdentities.map { .characterIdentity($0) }
		self.snapshot.appendItems(items, toSection: .main)

		self.dataSource.apply(self.snapshot)
	}

	private func getConfiguredCharacterCell() -> UICollectionView.CellRegistration<ProfileLockupCollectionViewCell, ItemKind> {
		return UICollectionView.CellRegistration<ProfileLockupCollectionViewCell, ItemKind>(cellNib: ProfileLockupCollectionViewCell.nib) { [weak self] cell, indexPath, itemKind in
			guard let self = self else { return }

			switch itemKind {
			case .characterIdentity:
				let character: Character? = self.fetchModel(at: indexPath)

				if character == nil, let section = self.snapshot.sectionIdentifier(containingItem: itemKind), !self.isFetchingSection.contains(section) {
					Task {
						await self.fetchSectionIfNeeded(ResourceCollection<Character>.self, CharacterIdentity.self, at: indexPath, itemKind: itemKind)
					}
				}

				cell.configure(using: character)
			}
		}
	}
}

// MARK: - KCollectionViewDelegateLayout
extension CharactersListCollectionViewController {
	override func columnCount(forSection section: Int, layout layoutEnvironment: NSCollectionLayoutEnvironment) -> Int {
		let width = layoutEnvironment.container.effectiveContentSize.width
		let columnCount = Int((width / 140.0).rounded())
		return columnCount > 0 ? columnCount : 1
	}

	override func createLayout() -> UICollectionViewLayout? {
		return UICollectionViewCompositionalLayout { [weak self] section, layoutEnvironment in
			guard let self = self else { return nil }
			let columns = self.columnCount(forSection: section, layout: layoutEnvironment)

			return Layouts.charactersSection(section, columns: columns, layoutEnvironment: layoutEnvironment, isHorizontal: false)
		}
	}
}

// MARK: - UICollectionViewDelegate
extension CharactersListCollectionViewController {
	override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		guard let character = self.cache[indexPath] as? Character else { return }

		self.show(.characterDetailsSegue, sender: character)
	}

	override func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
		self.paginateIfNeeded(at: indexPath, totalItems: self.characterIdentities.count)
	}

	override func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
		guard let character = self.cache[indexPath] as? Character else { return nil }

		let collectionViewCell = collectionView.cellForItem(at: indexPath)
		return character.contextMenuConfiguration(in: self, userInfo: ["indexPath": indexPath], sourceView: collectionViewCell?.contentView, barButtonItem: nil)
	}
}
