//
//  PeopleListCollectionViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 20/08/2020.
//  Copyright © 2020 Kurozora. All rights reserved.
//

import KurozoraKit
import UIKit

/// A source of people for ``PeopleListCollectionViewController``.
enum PeopleListFetchType {
	case character
	case charts
	case explore
	case search
}

/// A paginated list of people (cast / crew).
class PeopleListCollectionViewController: ListCollectionViewController, SectionFetchable, TypedSegueHandling {
	// MARK: - Enums
	enum SegueIdentifiers: String, SegueIdentifier {
		case personDetailsSegue
	}

	/// The section identifier.
	enum SectionLayoutKind: Int, CaseIterable {
		case main = 0
	}

	/// An item displayed in the list.
	enum ItemKind: Hashable {
		case personIdentity(_: PersonIdentity)
	}

	// MARK: - Properties
	var characterIdentity: CharacterIdentity?
	var exploreCategoryIdentity: ExploreCategoryIdentity?
	var personIdentities: [PersonIdentity] = []
	var searchQuery: String = ""
	var peopleListFetchType: PeopleListFetchType = .search

	// MARK: - SectionFetchable
	var cache: [IndexPath: KurozoraItem] = [:]
	var isFetchingSection: Set<SectionLayoutKind> = []

	var dataSource: UICollectionViewDiffableDataSource<SectionLayoutKind, ItemKind>!
	var snapshot: NSDiffableDataSourceSnapshot<SectionLayoutKind, ItemKind>!

	override var emptyStateImage: UIImage? { UIImage(systemName: "person.crop.circle.badge.questionmark.fill") }
	override var emptyStateTitle: String {
		switch self.peopleListFetchType {
		case .charts: return L10n.noItemsTitle(L10n.topCharts)
		default: return L10n.noItemsTitle(L10n.people)
		}
	}
	override var emptyStateDetail: String {
		switch self.peopleListFetchType {
		case .charts: return L10n.cantGetListDetail(L10n.topCharts.lowercased(with: .current))
		default: return L10n.cantGetListDetail(L10n.people.lowercased(with: .current))
		}
	}

	override var hasLoadedInitialData: Bool {
		!self.personIdentities.isEmpty
	}

	override func viewDidLoad() {
		super.viewDidLoad()

		self.title = self.peopleListFetchType == .charts ? L10n.xTopCharts(L10n.people) : L10n.people

		#if !targetEnvironment(macCatalyst)
		self.refreshControl?.attributedTitle = NSAttributedString(string: L10n.pullToRefreshItems(L10n.people.lowercased(with: Locale.current)))
		#endif
	}

	override func fetchItems() async {
		guard !self.isRequestInProgress else { return }
		self.isRequestInProgress = true

		defer {
			self.endFetch()

			#if !targetEnvironment(macCatalyst)
			self.refreshControl?.attributedTitle = NSAttributedString(string: L10n.pullToRefreshItems(L10n.people.lowercased(with: Locale.current)))
			#endif
		}

		#if !targetEnvironment(macCatalyst)
		self.refreshControl?.attributedTitle = NSAttributedString(string: L10n.refreshingItems(L10n.people.lowercased(with: Locale.current)))
		#endif

		do {
			switch self.peopleListFetchType {
			case .character:
				guard let characterIdentity = self.characterIdentity else { return }
				let response = try await KService.people(for: characterIdentity).cursor(self.nextPageCursor).limit(self.nextPageCursor != nil ? 100 : 25).response()

				if self.nextPageCursor == nil {
					self.personIdentities = []
				}

				self.nextPageCursor = response.nextCursor
				self.personIdentities.append(contentsOf: response.data)
				self.personIdentities.removeDuplicates()
			case .charts:
				let response = try await KService.topPeople().cursor(self.nextPageCursor).limit(self.nextPageCursor != nil ? 100 : 25).response()

				if self.nextPageCursor == nil {
					self.personIdentities = []
				}

				self.nextPageCursor = response.nextCursor
				self.personIdentities.append(contentsOf: response.data)
				self.personIdentities.removeDuplicates()
			case .explore:
				guard let exploreCategoryIdentity = self.exploreCategoryIdentity else { return }
				let response = try await KService.exploreCategory(exploreCategoryIdentity).cursor(self.nextPageCursor).limit(self.nextPageCursor != nil ? 100 : 25).response()

				if self.nextPageCursor == nil {
					self.personIdentities = []
				}

				self.nextPageCursor = response.data.first?.relationships.people?.nextCursor
				self.personIdentities.append(contentsOf: response.data.first?.relationships.people?.data ?? [])
				self.personIdentities.removeDuplicates()
			case .search:
				let searchResponse = try await KService.search(.kurozora, types: [.people], query: self.searchQuery).cursor(self.nextPageCursor).limit(self.nextPageCursor != nil ? 100 : 25).filter(nil).response()

				if self.nextPageCursor == nil {
					self.personIdentities = []
				}

				self.nextPageCursor = searchResponse.data.people?.nextCursor
				self.personIdentities.append(contentsOf: searchResponse.data.people?.data ?? [])
				self.personIdentities.removeDuplicates()
			}
		} catch {
			print(error.localizedDescription)
		}
	}

	// MARK: - SectionFetchable
	func extractIdentity<Element>(from item: ItemKind) -> Element? where Element: KurozoraItem {
		switch item {
		case .personIdentity(let id): return id as? Element
		}
	}

	// MARK: - Segue
	override func makeDestination(for identifier: any SegueIdentifier) -> UIViewController? {
		guard let identifier = identifier as? SegueIdentifiers else { return nil }

		switch identifier {
		case .personDetailsSegue: return PersonDetailsCollectionViewController()
		}
	}

	override func prepare(for identifier: any SegueIdentifier, destination: UIViewController, sender: Any?) {
		guard let identifier = identifier as? SegueIdentifiers else { return }

		switch identifier {
		case .personDetailsSegue:
			guard let destination = destination as? PersonDetailsCollectionViewController else { return }
			guard let person = sender as? Person else { return }
			destination.person = person
		}
	}
}

// MARK: - KCollectionViewDataSource
extension PeopleListCollectionViewController {
	override func configureDataSource() {
		let personCellRegistration = self.getConfiguredPersonCell()

		self.dataSource = UICollectionViewDiffableDataSource<SectionLayoutKind, ItemKind>(collectionView: collectionView) { collectionView, indexPath, itemKind in
			return collectionView.dequeueConfiguredReusableCell(using: personCellRegistration, for: indexPath, item: itemKind)
		}
	}

	override func updateDataSource() {
		self.snapshot = NSDiffableDataSourceSnapshot<SectionLayoutKind, ItemKind>()
		self.snapshot.appendSections([.main])

		let items: [ItemKind] = self.personIdentities.map { .personIdentity($0) }
		self.snapshot.appendItems(items, toSection: .main)

		self.dataSource.apply(self.snapshot)
	}

	private func getConfiguredPersonCell() -> UICollectionView.CellRegistration<ProfileLockupCollectionViewCell, ItemKind> {
		return UICollectionView.CellRegistration<ProfileLockupCollectionViewCell, ItemKind>(cellNib: ProfileLockupCollectionViewCell.nib) { [weak self] cell, indexPath, itemKind in
			guard let self = self else { return }

			switch itemKind {
			case .personIdentity:
				let person: Person? = self.fetchModel(at: indexPath)

				if person == nil, let section = self.snapshot.sectionIdentifier(containingItem: itemKind), !self.isFetchingSection.contains(section) {
					Task {
						await self.fetchSectionIfNeeded(ResourceCollection<Person>.self, PersonIdentity.self, at: indexPath, itemKind: itemKind)
					}
				}

				cell.configure(using: person, rank: self.peopleListFetchType == .charts ? indexPath.item + 1 : nil)
			}
		}
	}
}

// MARK: - KCollectionViewDelegateLayout
extension PeopleListCollectionViewController {
	override func columnCount(forSection section: Int, layout layoutEnvironment: NSCollectionLayoutEnvironment) -> Int {
		let width = layoutEnvironment.container.effectiveContentSize.width
		let columnCount = Int((width / 140.0).rounded())
		return columnCount > 0 ? columnCount : 1
	}

	override func createLayout() -> UICollectionViewLayout? {
		return UICollectionViewCompositionalLayout { [weak self] section, layoutEnvironment in
			guard let self = self else { return nil }
			let columns = self.columnCount(forSection: section, layout: layoutEnvironment)

			return Layouts.peopleSection(section, columns: columns, layoutEnvironment: layoutEnvironment, isHorizontal: false)
		}
	}
}

// MARK: - UICollectionViewDelegate
extension PeopleListCollectionViewController {
	override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		guard let person = self.cache[indexPath] as? Person else { return }

		self.show(.personDetailsSegue, sender: person)
	}

	override func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
		self.paginateIfNeeded(at: indexPath, totalItems: self.personIdentities.count)
	}

	override func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
		guard let person = self.cache[indexPath] as? Person else { return nil }

		let collectionViewCell = collectionView.cellForItem(at: indexPath)
		return person.contextMenuConfiguration(in: self, userInfo: ["indexPath": indexPath], sourceView: collectionViewCell?.contentView, barButtonItem: nil)
	}
}
