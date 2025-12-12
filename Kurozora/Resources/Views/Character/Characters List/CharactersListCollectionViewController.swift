//
//  CharactersListCollectionViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 20/08/2020.
//  Copyright © 2020 Kurozora. All rights reserved.
//

import KurozoraKit
import UIKit

enum CharactersListFetchType {
	case person
	case explore
	case search
}

class CharactersListCollectionViewController: KCollectionViewController, SectionFetchable {
	// MARK: - Enums
	enum SegueIdentifiers: String, SegueIdentifier {
		case characterDetailsSegue
	}

	// MARK: - Properties
	var personIdentity: PersonIdentity?
	var characterIdentities: [CharacterIdentity] = []
	var exploreCategoryIdentity: ExploreCategoryIdentity?
	var searchQuery: String = ""
	var charactersListFetchType: CharactersListFetchType = .search

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

		#if DEBUG
		self._prefersRefreshControlDisabled = false
		#else
		self._prefersRefreshControlDisabled = true
		#endif

		// Add Refresh Control to Collection View
		#if !targetEnvironment(macCatalyst)
		self.refreshControl?.attributedTitle = NSAttributedString(string: "Pull to refresh the characters.")
		#endif

		self.configureDataSource()

		if !self.characterIdentities.isEmpty {
			self.endFetch()
		} else {
			Task { [weak self] in
				guard let self = self else { return }
				await self.fetchCharacters()
			}
		}
	}

	// MARK: - Functions
	override func handleRefreshControl() {
		if self.personIdentity != nil {
			self.nextPageURL = nil
			Task { [weak self] in
				guard let self = self else { return }
				await self.fetchCharacters()
			}
		}
	}

	override func configureEmptyDataView() {
		self.emptyBackgroundView.configureImageView(image: .Empty.cast)
		self.emptyBackgroundView.configureLabels(title: "No Characters", detail: "Can't get characters list. Please reload the page or restart the app and check your WiFi connection.")

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
		self.refreshControl?.attributedTitle = NSAttributedString(string: "Pull to refresh the characters.")
		#endif
		#endif
	}

	func fetchCharacters() async {
		guard !self.isRequestInProgress else {
			return
		}

		// Set request in progress
		self.isRequestInProgress = true

		#if !targetEnvironment(macCatalyst)
		self.refreshControl?.attributedTitle = NSAttributedString(string: "Refreshing characters...")
		#endif

		switch self.charactersListFetchType {
		case .person:
			do {
				guard let personIdentity = self.personIdentity else { return }
				let characterIdentityResponse = try await KService.getCharacters(forPerson: personIdentity, next: self.nextPageURL).value

				// Reset data if necessary
				if self.nextPageURL == nil {
					self.characterIdentities = []
				}

				// Save next page url and append new data
				self.nextPageURL = characterIdentityResponse.next
				self.characterIdentities.append(contentsOf: characterIdentityResponse.data)
				self.characterIdentities.removeDuplicates()
			} catch {
				print(error.localizedDescription)
			}
		case .explore:
			do {
				guard let exploreCategoryIdentity = self.exploreCategoryIdentity else { return }
				let exploreCategoryResponse = try await KService.getExplore(exploreCategoryIdentity, next: self.nextPageURL, limit: self.nextPageURL != nil ? 100 : 25).value

				// Reset data if necessary
				if self.nextPageURL == nil {
					self.characterIdentities = []
				}

				// Save next page url and append new data
				self.nextPageURL = exploreCategoryResponse.data.first?.relationships.characters?.next
				self.characterIdentities.append(contentsOf: exploreCategoryResponse.data.first?.relationships.characters?.data ?? [])
				self.characterIdentities.removeDuplicates()
			} catch {
				print(error.localizedDescription)
			}
		case .search:
			do {
				let searchResponse = try await KService.search(.kurozora, of: [.characters], for: self.searchQuery, next: self.nextPageURL, limit: self.nextPageURL != nil ? 100 : 25, filter: nil).value

				// Reset data if necessary
				if self.nextPageURL == nil {
					self.characterIdentities = []
				}

				// Save next page url and append new data
				self.nextPageURL = searchResponse.data.characters?.next
				self.characterIdentities.append(contentsOf: searchResponse.data.characters?.data ?? [])
				self.characterIdentities.removeDuplicates()
			} catch {
				print(error.localizedDescription)
			}
		}

		self.endFetch()
	}

	// MARK: - SectionFetchable
	func extractIdentity<Element>(from item: ItemKind) -> Element? where Element: KurozoraItem {
		switch item {
		case .characterIdentity(let id): return id as? Element
		}
	}

	// MARK: - Segue
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		guard
			let segueIdentifier = segue.identifier,
			let segueID = SegueIdentifiers(rawValue: segueIdentifier)
		else { return }

		switch segueID {
		case .characterDetailsSegue:
			guard let characterDetailsCollectionViewController = segue.destination as? CharacterDetailsCollectionViewController else { return }
			guard let character = sender as? Character else { return }
			characterDetailsCollectionViewController.character = character
		}
	}
}

// MARK: - SectionLayoutKind
extension CharactersListCollectionViewController {
	/// List of section layout kind.
	///
	/// ```swift
	/// case main = 0
	/// ```
	enum SectionLayoutKind: Int, CaseIterable {
		case main = 0
	}
}

// MARK: - ItemKind
extension CharactersListCollectionViewController {
	/// List of item layout kind.
	enum ItemKind: Hashable {
		// MARK: - Cases
		/// Indicates the item kind contains a `CharacterIdentity` object.
		case characterIdentity(_: CharacterIdentity)

		func hash(into hasher: inout Hasher) {
			switch self {
			case .characterIdentity(let characterIdentity):
				hasher.combine(characterIdentity)
			}
		}

		static func == (lhs: ItemKind, rhs: ItemKind) -> Bool {
			switch (lhs, rhs) {
			case (.characterIdentity(let characterIdentity1), .characterIdentity(let characterIdentity2)):
				return characterIdentity1 == characterIdentity2
			}
		}
	}
}

// MARK: - Cell Configuration
extension CharactersListCollectionViewController {
	func getConfiguredCharacterCell() -> UICollectionView.CellRegistration<CharacterLockupCollectionViewCell, ItemKind> {
		return UICollectionView.CellRegistration<CharacterLockupCollectionViewCell, ItemKind>(cellNib: CharacterLockupCollectionViewCell.nib) { [weak self] characterLockupCollectionViewCell, indexPath, itemKind in
			guard let self = self else { return }

			switch itemKind {
			case .characterIdentity:
				let character: Character? = self.fetchModel(at: indexPath)

				if character == nil, let section = self.snapshot.sectionIdentifier(containingItem: itemKind), !self.isFetchingSection.contains(section) {
					Task {
						await self.fetchSectionIfNeeded(CharacterResponse.self, CharacterIdentity.self, at: indexPath, itemKind: itemKind)
					}
				}

				characterLockupCollectionViewCell.configure(using: character)
			}
		}
	}
}
