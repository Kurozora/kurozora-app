//
//  CastListCollectionViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 01/10/2018.
//  Copyright © 2018 Kurozora. All rights reserved.
//

import KurozoraKit
import UIKit

/// The content kind a cast list belongs to.
enum CastKind: String {
	case show
	case literature
	case game
}

/// A paginated list of cast entries for a show, literature, or game.
class CastListCollectionViewController: ListCollectionViewController, SectionFetchable, TypedSegueHandling {
	// MARK: - Enums
	enum SegueIdentifiers: String, SegueIdentifier {
		case characterDetailsSegue
		case personDetailsSegue
	}

	/// The section identifier.
	enum SectionLayoutKind: Int, CaseIterable {
		case main = 0
	}

	/// An item displayed in the list.
	enum ItemKind: Hashable {
		case castIdentity(_: CastIdentity)
	}

	// MARK: - Properties
	var literatureIdentity: LiteratureIdentity?
	var showIdentity: ShowIdentity?
	var gameIdentity: GameIdentity?
	var castKind: CastKind = .show
	var castIdentities: [CastIdentity] = []

	// MARK: - SectionFetchable
	var cache: [IndexPath: KurozoraItem] = [:]
	var isFetchingSection: Set<SectionLayoutKind> = []

	var dataSource: UICollectionViewDiffableDataSource<SectionLayoutKind, ItemKind>!
	var snapshot: NSDiffableDataSourceSnapshot<SectionLayoutKind, ItemKind>!

	override var emptyStateImage: UIImage { .Empty.cast }
	override var emptyStateTitle: String { "No Cast" }
	override var emptyStateDetail: String { "This \(self.castKind.rawValue) doesn't have casts yet. Please check back again later." }

	override var hasLoadedInitialData: Bool {
		!self.castIdentities.isEmpty
	}

	override func viewDidLoad() {
		super.viewDidLoad()

		self.title = L10n.cast

		#if !targetEnvironment(macCatalyst)
		self.refreshControl?.attributedTitle = NSAttributedString(string: L10n.pullToRefreshItems(L10n.cast.lowercased(with: Locale.current)))
		#endif
	}

	override func fetchItems() async {
		guard !self.isRequestInProgress else { return }
		self.isRequestInProgress = true

		defer {
			self.endFetch()

			#if !targetEnvironment(macCatalyst)
			self.refreshControl?.attributedTitle = NSAttributedString(string: L10n.pullToRefreshItems(L10n.cast.lowercased(with: Locale.current)))
			#endif
		}

		#if !targetEnvironment(macCatalyst)
		self.refreshControl?.attributedTitle = NSAttributedString(string: L10n.refreshingItems(L10n.cast.lowercased(with: Locale.current)))
		#endif

		do {
			switch self.castKind {
			case .show:
				guard let showIdentity = self.showIdentity else { return }
				let response = try await KService.cast(for: showIdentity).cursor(self.nextPageCursor).limit(self.nextPageCursor != nil ? 100 : 25).response()

				if self.nextPageCursor == nil {
					self.castIdentities = []
				}

				self.nextPageCursor = response.nextCursor
				self.castIdentities.append(contentsOf: response.data)
				self.castIdentities.removeDuplicates()
			case .literature:
				guard let literatureIdentity = self.literatureIdentity else { return }
				let response = try await KService.cast(for: literatureIdentity).cursor(self.nextPageCursor).limit(self.nextPageCursor != nil ? 100 : 25).response()

				if self.nextPageCursor == nil {
					self.castIdentities = []
				}

				self.nextPageCursor = response.nextCursor
				self.castIdentities.append(contentsOf: response.data)
				self.castIdentities.removeDuplicates()
			case .game:
				guard let gameIdentity = self.gameIdentity else { return }
				let response = try await KService.cast(for: gameIdentity).cursor(self.nextPageCursor).limit(self.nextPageCursor != nil ? 100 : 25).response()

				if self.nextPageCursor == nil {
					self.castIdentities = []
				}

				self.nextPageCursor = response.nextCursor
				self.castIdentities.append(contentsOf: response.data)
				self.castIdentities.removeDuplicates()
			}
		} catch {
			print(error.localizedDescription)
		}
	}

	// MARK: - SectionFetchable
	func extractIdentity<Element>(from item: ItemKind) -> Element? where Element: KurozoraItem {
		switch item {
		case .castIdentity(let id): return id as? Element
		}
	}

	// MARK: - Segue
	override func makeDestination(for identifier: any SegueIdentifier) -> UIViewController? {
		guard let identifier = identifier as? SegueIdentifiers else { return nil }

		switch identifier {
		case .characterDetailsSegue: return CharacterDetailsCollectionViewController()
		case .personDetailsSegue: return PersonDetailsCollectionViewController()
		}
	}

	override func prepare(for identifier: any SegueIdentifier, destination: UIViewController, sender: Any?) {
		guard let identifier = identifier as? SegueIdentifiers else { return }

		switch identifier {
		case .characterDetailsSegue:
			guard let destination = destination as? CharacterDetailsCollectionViewController else { return }
			guard let character = sender as? Character else { return }
			destination.character = character
		case .personDetailsSegue:
			guard let destination = destination as? PersonDetailsCollectionViewController else { return }
			guard let person = sender as? Person else { return }
			destination.person = person
		}
	}
}

// MARK: - KCollectionViewDataSource
extension CastListCollectionViewController {
	override func configureDataSource() {
		let castCellRegistration = self.getCastCellRegistration()
		let characterCellRegistration = self.getCharacterCellRegistration()

		self.dataSource = UICollectionViewDiffableDataSource<SectionLayoutKind, ItemKind>(collectionView: collectionView) { [weak self] collectionView, indexPath, itemKind in
			guard let self = self else { return nil }

			switch self.castKind {
			case .show, .game:
				return collectionView.dequeueConfiguredReusableCell(using: castCellRegistration, for: indexPath, item: itemKind)
			case .literature:
				return collectionView.dequeueConfiguredReusableCell(using: characterCellRegistration, for: indexPath, item: itemKind)
			}
		}
	}

	override func updateDataSource() {
		self.snapshot = NSDiffableDataSourceSnapshot<SectionLayoutKind, ItemKind>()
		self.snapshot.appendSections([.main])

		let items: [ItemKind] = self.castIdentities.map { .castIdentity($0) }
		self.snapshot.appendItems(items, toSection: .main)

		self.dataSource.apply(self.snapshot)
	}

	private func getCastCellRegistration() -> UICollectionView.CellRegistration<CastCollectionViewCell, ItemKind> {
		return UICollectionView.CellRegistration<CastCollectionViewCell, ItemKind>(cellNib: CastCollectionViewCell.nib) { [weak self] cell, indexPath, itemKind in
			guard let self = self else { return }

			switch itemKind {
			case .castIdentity:
				let cast: Cast? = self.fetchModel(at: indexPath)

				if cast == nil, let section = self.snapshot.sectionIdentifier(containingItem: itemKind), !self.isFetchingSection.contains(section) {
					Task {
						await self.fetchSectionIfNeeded(ResourceCollection<Cast>.self, CastIdentity.self, at: indexPath, itemKind: itemKind)
					}
				}

				cell.delegate = self
				cell.configure(using: cast)
			}
		}
	}

	private func getCharacterCellRegistration() -> UICollectionView.CellRegistration<ProfileLockupCollectionViewCell, ItemKind> {
		return UICollectionView.CellRegistration<ProfileLockupCollectionViewCell, ItemKind>(cellNib: ProfileLockupCollectionViewCell.nib) { [weak self] cell, indexPath, itemKind in
			guard let self = self else { return }

			switch itemKind {
			case .castIdentity:
				let cast: Cast? = self.fetchModel(at: indexPath)

				if cast == nil, let section = self.snapshot.sectionIdentifier(containingItem: itemKind), !self.isFetchingSection.contains(section) {
					Task {
						await self.fetchSectionIfNeeded(ResourceCollection<Cast>.self, CastIdentity.self, at: indexPath, itemKind: itemKind)
					}
				}

				cell.configure(using: cast?.relationships.characters.data.first, role: cast?.attributes.role)
			}
		}
	}
}

// MARK: - KCollectionViewDelegateLayout
extension CastListCollectionViewController {
	override func columnCount(forSection section: Int, layout layoutEnvironment: NSCollectionLayoutEnvironment) -> Int {
		let width = layoutEnvironment.container.effectiveContentSize.width
		let columnCount: Int

		switch self.castKind {
		case .show, .game:
			columnCount = Int(width >= 414 ? (width / 384).rounded() : (width / 284).rounded())
		case .literature:
			columnCount = Int((width / 140.0).rounded())
		}

		return columnCount > 0 ? columnCount : 1
	}

	override func createLayout() -> UICollectionViewLayout? {
		return UICollectionViewCompositionalLayout { [weak self] section, layoutEnvironment in
			guard let self = self else { return nil }
			let columns = self.columnCount(forSection: section, layout: layoutEnvironment)

			return Layouts.castSection(section, columns: columns, layoutEnvironment: layoutEnvironment, isHorizontal: false)
		}
	}
}

// MARK: - UICollectionViewDelegate
extension CastListCollectionViewController {
	override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		switch self.castKind {
		case .show, .game:
			break
		case .literature:
			guard
				let cast = self.cache[indexPath] as? Cast,
				let character = cast.relationships.characters.data.first
			else { return }

			self.show(.characterDetailsSegue, sender: character)
		}
	}

	override func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
		self.paginateIfNeeded(at: indexPath, totalItems: self.castIdentities.count)
	}

	override func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
		guard let cast = self.cache[indexPath] as? Cast else { return nil }

		let collectionViewCell = collectionView.cellForItem(at: indexPath)
		return cast.contextMenuConfiguration(in: self, userInfo: ["indexPath": indexPath], sourceView: collectionViewCell?.contentView, barButtonItem: nil)
	}
}

// MARK: - CastCollectionViewCellDelegate
extension CastListCollectionViewController: CastCollectionViewCellDelegate {
	func castCollectionViewCell(_ cell: CastCollectionViewCell, didPressPersonButton button: UIButton) {
		guard let indexPath = collectionView.indexPath(for: cell) else { return }
		guard let cast = self.cache[indexPath] as? Cast else { return }
		guard let person = cast.relationships.people?.data.first else { return }

		self.show(.personDetailsSegue, sender: person)
	}

	func castCollectionViewCell(_ cell: CastCollectionViewCell, didPressCharacterButton button: UIButton) {
		guard let indexPath = collectionView.indexPath(for: cell) else { return }
		guard let cast = self.cache[indexPath] as? Cast else { return }
		guard let character = cast.relationships.characters.data.first else { return }

		self.show(.characterDetailsSegue, sender: character)
	}
}
