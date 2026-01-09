//
//  StudiosListCollectionViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 14/06/2022.
//  Copyright © 2022 Kurozora. All rights reserved.
//

import KurozoraKit
import UIKit

enum StudiosListFetchType {
	case game
	case literature
	case show
	case search
}

class StudiosListCollectionViewController: KCollectionViewController, SectionFetchable {
	// MARK: - Enums
	enum SegueIdentifiers: String, SegueIdentifier {
		case studioDetailsSegue
	}

	// MARK: - Properties
	var gameIdentity: GameIdentity?
	var literatureIdentity: LiteratureIdentity?
	var showIdentity: ShowIdentity?
	var studioIdentities: [StudioIdentity] = []
	var searchQuery: String = ""
	var studiosListFetchType: StudiosListFetchType = .search

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

		self.title = Trans.studios

		#if DEBUG
		self._prefersRefreshControlDisabled = false
		#else
		self._prefersRefreshControlDisabled = true
		#endif

		// Add Refresh Control to Collection View
		#if !targetEnvironment(macCatalyst)
		self.refreshControl?.attributedTitle = NSAttributedString(string: "Pull to refresh the studios.")
		#endif

		self.configureDataSource()

		if !self.studioIdentities.isEmpty {
			self.endFetch()
		} else {
			Task { [weak self] in
				guard let self = self else { return }
				await self.fetchStudios()
			}
		}
	}

	// MARK: - Functions
	override func handleRefreshControl() {
		if self.showIdentity != nil || self.literatureIdentity != nil || self.gameIdentity != nil {
			self.nextPageURL = nil
			Task { [weak self] in
				guard let self = self else { return }
				await self.fetchStudios()
			}
		}
	}

	override func configureEmptyDataView() {
		self.emptyBackgroundView.configureImageView(image: .Empty.cast)
		self.emptyBackgroundView.configureLabels(title: "No Studios", detail: "Can't get studios list. Please reload the page or restart the app and check your WiFi connection.")

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
		#endif
		#endif
	}

	func fetchStudios() async {
		guard !self.isRequestInProgress else {
			return
		}

		// Set request in progress
		self.isRequestInProgress = true

		#if !targetEnvironment(macCatalyst)
		self.refreshControl?.attributedTitle = NSAttributedString(string: "Refreshing studios...")
		#endif

		switch self.studiosListFetchType {
		case .game:
			guard let gameIdentity = self.gameIdentity else { return }
			do {
				let studioIdentityResponse = try await KService.getStudios(forGame: gameIdentity, next: self.nextPageURL, limit: self.nextPageURL != nil ? 100 : 25).value
				// Reset data if necessary
				if self.nextPageURL == nil {
					self.studioIdentities = []
				}

				// Save next page url and append new data
				self.nextPageURL = studioIdentityResponse.next
				self.studioIdentities.append(contentsOf: studioIdentityResponse.data)
				self.studioIdentities.removeDuplicates()
			} catch {
				print(error.localizedDescription)
			}
		case .literature:
			guard let literatureIdentity = self.literatureIdentity else { return }
			do {
				let studioIdentityResponse = try await KService.getStudios(forLiterature: literatureIdentity, next: self.nextPageURL, limit: self.nextPageURL != nil ? 100 : 25).value
				// Reset data if necessary
				if self.nextPageURL == nil {
					self.studioIdentities = []
				}

				// Save next page url and append new data
				self.nextPageURL = studioIdentityResponse.next
				self.studioIdentities.append(contentsOf: studioIdentityResponse.data)
				self.studioIdentities.removeDuplicates()
			} catch {
				print(error.localizedDescription)
			}
		case .show:
			guard let showIdentity = self.showIdentity else { return }
			do {
				let studioIdentityResponse = try await KService.getStudios(forShow: showIdentity, next: self.nextPageURL, limit: self.nextPageURL != nil ? 100 : 25).value
				// Reset data if necessary
				if self.nextPageURL == nil {
					self.studioIdentities = []
				}

				// Save next page url and append new data
				self.nextPageURL = studioIdentityResponse.next
				self.studioIdentities.append(contentsOf: studioIdentityResponse.data)
				self.studioIdentities.removeDuplicates()
			} catch {
				print(error.localizedDescription)
			}
		case .search:
			do {
				let searchResponse = try await KService.search(.kurozora, of: [.studios], for: self.searchQuery, next: self.nextPageURL, limit: self.nextPageURL != nil ? 100 : 25, filter: nil).value

				// Reset data if necessary
				if self.nextPageURL == nil {
					self.studioIdentities = []
				}

				// Save next page url and append new data
				self.nextPageURL = searchResponse.data.studios?.next
				self.studioIdentities.append(contentsOf: searchResponse.data.studios?.data ?? [])
				self.studioIdentities.removeDuplicates()
			} catch {
				print(error.localizedDescription)
			}
		}

		self.endFetch()

		// Reset refresh controller title
		#if !targetEnvironment(macCatalyst)
		self.refreshControl?.attributedTitle = NSAttributedString(string: "Pull to refresh the studios.")
		#endif
	}

	// MARK: - SectionFetchable
	func extractIdentity<Element>(from item: ItemKind) -> Element? where Element: KurozoraItem {
		switch item {
		case .studioIdentity(let id): return id as? Element
		}
	}

	// MARK: - Segue
	override func makeDestination(for identifier: SegueIdentifier) -> UIViewController? {
		guard let segue = identifier as? SegueIdentifiers else { return nil }

		switch segue {
		case .studioDetailsSegue: return StudioDetailsCollectionViewController()
		}
	}

	override func prepare(for identifier: any SegueIdentifier, destination: UIViewController, sender: Any?) {
		guard let identifier = identifier as? SegueIdentifiers else { return }

		switch identifier {
		case .studioDetailsSegue:
			guard let studioDetailsCollectionViewController = destination as? StudioDetailsCollectionViewController else { return }
			guard let studio = sender as? Studio else { return }
			studioDetailsCollectionViewController.studio = studio
		}
	}
}

// MARK: - SectionLayoutKind
extension StudiosListCollectionViewController {
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
extension StudiosListCollectionViewController {
	/// List of item layout kind.
	enum ItemKind: Hashable {
		// MARK: - Cases
		/// Indicates the item kind contains a `StudioIdentity` object.
		case studioIdentity(_: StudioIdentity)

		// MARK: - Functions
		func hash(into hasher: inout Hasher) {
			switch self {
			case .studioIdentity(let studioIdentity):
				hasher.combine(studioIdentity)
			}
		}

		static func == (lhs: ItemKind, rhs: ItemKind) -> Bool {
			switch (lhs, rhs) {
			case (.studioIdentity(let studioIdentity1), .studioIdentity(let studioIdentity2)):
				return studioIdentity1 == studioIdentity2
			}
		}
	}
}

// MARK: - Cell Configuration
extension StudiosListCollectionViewController {
	func getConfiguredStudioCell() -> UICollectionView.CellRegistration<StudioLockupCollectionViewCell, ItemKind> {
		return UICollectionView.CellRegistration<StudioLockupCollectionViewCell, ItemKind>(cellNib: StudioLockupCollectionViewCell.nib) { [weak self] studioLockupCollectionViewCell, indexPath, itemKind in
			guard let self = self else { return }

			switch itemKind {
			case .studioIdentity:
				let studio: Studio? = self.fetchModel(at: indexPath)

				if studio == nil, let section = self.snapshot.sectionIdentifier(containingItem: itemKind), !self.isFetchingSection.contains(section) {
					Task {
						await self.fetchSectionIfNeeded(StudioResponse.self, StudioIdentity.self, at: indexPath, itemKind: itemKind)
					}
				}

				studioLockupCollectionViewCell.configure(using: studio)
			}
		}
	}
}
