//
//  PeopleListCollectionViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 20/08/2020.
//  Copyright © 2020 Kurozora. All rights reserved.
//

import KurozoraKit
import UIKit

enum PeopleListFetchType {
	case character
	case explore
	case search
}

class PeopleListCollectionViewController: KCollectionViewController, SectionFetchable {
	// MARK: - Enums
	enum SegueIdentifiers: String, SegueIdentifier {
		case personDetailsSegue
	}

	// MARK: - Properties
	var characterIdentity: CharacterIdentity?
	var personIdentities: [PersonIdentity] = []
	var exploreCategoryIdentity: ExploreCategoryIdentity?
	var searchQuery: String = ""
	var peopleListFetchType: PeopleListFetchType = .search

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

		self.title = Trans.people

		#if DEBUG
		self._prefersRefreshControlDisabled = false
		#else
		self._prefersRefreshControlDisabled = true
		#endif

		// Add Refresh Control to Collection View
		#if !targetEnvironment(macCatalyst)
		self.refreshControl?.attributedTitle = NSAttributedString(string: "Pull to refresh the people.")
		#endif

		self.configureDataSource()

		if !self.personIdentities.isEmpty {
			self.endFetch()
		} else {
			Task { [weak self] in
				guard let self = self else { return }
				await self.fetchPeople()
			}
		}
	}

	// MARK: - Functions
	override func handleRefreshControl() {
		if self.characterIdentity != nil {
			self.nextPageURL = nil
			Task { [weak self] in
				guard let self = self else { return }
				await self.fetchPeople()
			}
		}
	}

	override func configureEmptyDataView() {
		emptyBackgroundView.configureImageView(image: .Empty.cast)
		emptyBackgroundView.configureLabels(title: "No People", detail: "Can't get people list. Please reload the page or restart the app and check your WiFi connection.")

		collectionView.backgroundView?.alpha = 0
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

	func fetchPeople() async {
		guard !self.isRequestInProgress else {
			return
		}

		// Set request in progress
		self.isRequestInProgress = true

		#if !targetEnvironment(macCatalyst)
		self.refreshControl?.attributedTitle = NSAttributedString(string: "Refreshing people...")
		#endif

		switch self.peopleListFetchType {
		case .character:
			do {
				guard let characterIdentity = self.characterIdentity else { return }
				let personIdentityResponse = try await KService.getPeople(forCharacter: characterIdentity, next: self.nextPageURL).value

				// Reset data if necessary
				if self.nextPageURL == nil {
					self.personIdentities = []
				}

				// Save next page url and append new data
				self.nextPageURL = personIdentityResponse.next
				self.personIdentities.append(contentsOf: personIdentityResponse.data)
				self.personIdentities.removeDuplicates()
			} catch {
				print(error.localizedDescription)
			}
		case .explore:
			do {
				guard let exploreCategoryIdentity = self.exploreCategoryIdentity else { return }
				let exploreCategoryResponse = try await KService.getExplore(exploreCategoryIdentity, next: self.nextPageURL, limit: self.nextPageURL != nil ? 100 : 25).value

				// Reset data if necessary
				if self.nextPageURL == nil {
					self.personIdentities = []
				}

				// Save next page url and append new data
				self.nextPageURL = exploreCategoryResponse.data.first?.relationships.people?.next
				self.personIdentities.append(contentsOf: exploreCategoryResponse.data.first?.relationships.people?.data ?? [])
				self.personIdentities.removeDuplicates()
			} catch {
				print(error.localizedDescription)
			}
		case .search:
			do {
				let searchResponse = try await KService.search(.kurozora, of: [.people], for: self.searchQuery, next: self.nextPageURL, limit: self.nextPageURL != nil ? 100 : 25, filter: nil).value

				// Reset data if necessary
				if self.nextPageURL == nil {
					self.personIdentities = []
				}

				// Save next page url and append new data
				self.nextPageURL = searchResponse.data.people?.next
				self.personIdentities.append(contentsOf: searchResponse.data.people?.data ?? [])
				self.personIdentities.removeDuplicates()
			} catch {
				print(error.localizedDescription)
			}
		}

		self.endFetch()

		// Reset refresh controller title
		#if !targetEnvironment(macCatalyst)
		self.refreshControl?.attributedTitle = NSAttributedString(string: "Pull to refresh the people.")
		#endif
	}

	// MARK: - SectionFetchable
	func extractIdentity<Element>(from item: ItemKind) -> Element? where Element: KurozoraItem {
		switch item {
		case .personIdentity(let id): return id as? Element
		}
	}

	// MARK: - Segue
	override func makeDestination(for identifier: SegueIdentifier) -> UIViewController? {
		guard let segue = identifier as? SegueIdentifiers else { return nil }

		switch segue {
		case .personDetailsSegue: return PersonDetailsCollectionViewController()
		}
	}

	override func prepare(for identifier: any SegueIdentifier, destination: UIViewController, sender: Any?) {
		guard let identifier = identifier as? SegueIdentifiers else { return }

		switch identifier {
		case .personDetailsSegue:
			guard let personDetailsCollectionViewController = destination as? PersonDetailsCollectionViewController else { return }
			guard let person = sender as? Person else { return }
			personDetailsCollectionViewController.person = person
		}
	}
}

// MARK: - SectionLayoutKind
extension PeopleListCollectionViewController {
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
extension PeopleListCollectionViewController {
	/// List of item layout kind.
	enum ItemKind: Hashable {
		// MARK: - Cases
		/// Indicates the item kind contains a `PersonIdentity` object.
		case personIdentity(_: PersonIdentity)

		// MARK: - Functions
		func hash(into hasher: inout Hasher) {
			switch self {
			case .personIdentity(let personIdentity):
				hasher.combine(personIdentity)
			}
		}

		static func == (lhs: ItemKind, rhs: ItemKind) -> Bool {
			switch (lhs, rhs) {
			case (.personIdentity(let personIdentity1), .personIdentity(let personIdentity2)):
				return personIdentity1 == personIdentity2
			}
		}
	}
}

// MARK: - Cell Configuration
extension PeopleListCollectionViewController {
	func getConfiguredPersonCell() -> UICollectionView.CellRegistration<PersonLockupCollectionViewCell, ItemKind> {
		return UICollectionView.CellRegistration<PersonLockupCollectionViewCell, ItemKind>(cellNib: PersonLockupCollectionViewCell.nib) { [weak self] smallLockupCollectionViewCell, indexPath, itemKind in
			guard let self = self else { return }

			switch itemKind {
			case .personIdentity:
				let person: Person? = self.fetchModel(at: indexPath)

				if person == nil, let section = self.snapshot.sectionIdentifier(containingItem: itemKind), !self.isFetchingSection.contains(section) {
					Task {
						await self.fetchSectionIfNeeded(PersonResponse.self, PersonIdentity.self, at: indexPath, itemKind: itemKind)
					}
				}

				smallLockupCollectionViewCell.configure(using: person)
			}
		}
	}
}
