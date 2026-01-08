//
//  LiteraturesListCollectionViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 01/02/2023.
//  Copyright © 2023 Kurozora. All rights reserved.
//

import KurozoraKit
import UIKit

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

class LiteraturesListCollectionViewController: KCollectionViewController, SectionFetchable {
	// MARK: - Enums
	enum SegueIdentifiers: String, SegueIdentifier {
		case literatureDetailsSegue
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

		// Add refresh control
		#if DEBUG
		self._prefersRefreshControlDisabled = false
		#else
		self._prefersRefreshControlDisabled = true
		#endif

		self.configureDataSource()

		if !self.literatureIdentities.isEmpty || !self.relatedLiteratures.isEmpty {
			self.endFetch()
		} else {
			Task { [weak self] in
				guard let self = self else { return }
				await self.fetchLiteratures()
			}
		}
	}

	// MARK: - Functions
	override func handleRefreshControl() {
		self.nextPageURL = nil
	}

	override func configureEmptyDataView() {
		self.emptyBackgroundView.configureImageView(image: .Empty.mangaLibrary)
		self.emptyBackgroundView.configureLabels(title: "No Literatures", detail: "Can't get literatures list. Please refresh the page or restart the app and check your WiFi connection.")

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

	/// Fetches the characters.
	func fetchLiteratures() async {
		guard !self.isRequestInProgress else {
			return
		}

		// Set request in progress
		self.isRequestInProgress = true

		do {
			switch self.literaturesListFetchType {
			case .show:
				guard let showIdentity = self.showIdentity else { return }
				let relatedLiteraturesResponse = try await KService.getRelatedLiteratures(forShow: showIdentity, next: self.nextPageURL).value

				// Reset data if necessary
				if self.nextPageURL == nil {
					self.relatedLiteratures = []
					self.literatureIdentities = []
				}

				// Save next page url and append new data
				self.nextPageURL = relatedLiteraturesResponse.next
				self.relatedLiteratures.append(contentsOf: relatedLiteraturesResponse.data)
				self.relatedLiteratures.removeDuplicates()
			case .game:
				guard let gameIdentity = self.gameIdentity else { return }
				let relatedLiteraturesResponse = try await KService.getRelatedLiteratures(forGame: gameIdentity, next: self.nextPageURL).value

				// Reset data if necessary
				if self.nextPageURL == nil {
					self.relatedLiteratures = []
					self.literatureIdentities = []
				}

				// Save next page url and append new data
				self.nextPageURL = relatedLiteraturesResponse.next
				self.relatedLiteratures.append(contentsOf: relatedLiteraturesResponse.data)
				self.relatedLiteratures.removeDuplicates()
			case .character:
				guard let characterIdentity = self.characterIdentity else { return }
				let literatureIdentityResponse = try await KService.getLiteratures(forCharacter: characterIdentity, next: self.nextPageURL).value

				// Reset data if necessary
				if self.nextPageURL == nil {
					self.literatureIdentities = []
				}

				// Save next page url and append new data
				self.nextPageURL = literatureIdentityResponse.next
				self.literatureIdentities.append(contentsOf: literatureIdentityResponse.data)
				self.literatureIdentities.removeDuplicates()
			case .person:
				guard let personIdentity = self.personIdentity else { return }
				let literatureIdentityResponse = try await KService.getLiteratures(forPerson: personIdentity, next: self.nextPageURL).value

				// Reset data if necessary
				if self.nextPageURL == nil {
					self.literatureIdentities = []
				}

				// Save next page url and append new data
				self.nextPageURL = literatureIdentityResponse.next
				self.literatureIdentities.append(contentsOf: literatureIdentityResponse.data)
				self.literatureIdentities.removeDuplicates()
			case .search:
				let searchResponse = try await KService.search(.kurozora, of: [.literatures], for: self.searchQuery, next: self.nextPageURL, limit: self.nextPageURL != nil ? 100 : 25, filter: nil).value

				// Reset data if necessary
				if self.nextPageURL == nil {
					self.relatedLiteratures = []
					self.literatureIdentities = []
				}

				// Save next page url and append new data
				self.nextPageURL = searchResponse.data.literatures?.next
				self.literatureIdentities.append(contentsOf: searchResponse.data.literatures?.data ?? [])
				self.literatureIdentities.removeDuplicates()
			case .moreByStudio:
				guard let literatureIdentity = self.literatureIdentity else { return }
				let literatureIdentityResponse = try await KService.getMoreByStudio(forLiterature: literatureIdentity, next: self.nextPageURL).value

				// Reset data if necessary
				if self.nextPageURL == nil {
					self.literatureIdentities = []
				}

				// Save next page url and append new data
				self.nextPageURL = literatureIdentityResponse.next
				self.literatureIdentities.append(contentsOf: literatureIdentityResponse.data)
				self.literatureIdentities.removeDuplicates()
			case .relatedLiterature:
				guard let literatureIdentity = self.literatureIdentity else { return }
				let relatedLiteraturesResponse = try await KService.getRelatedLiteratures(forLiterature: literatureIdentity, next: self.nextPageURL).value

				// Reset data if necessary
				if self.nextPageURL == nil {
					self.relatedLiteratures = []
					self.literatureIdentities = []
				}

				// Save next page url and append new data
				self.nextPageURL = relatedLiteraturesResponse.next
				self.relatedLiteratures.append(contentsOf: relatedLiteraturesResponse.data)
				self.relatedLiteratures.removeDuplicates()
			case .studio:
				guard let studioIdentity = self.studioIdentity else { return }
				let literatureIdentityResponse = try await KService.getLiteratures(forStudio: studioIdentity, next: self.nextPageURL).value

				// Reset data if necessary
				if self.nextPageURL == nil {
					self.literatureIdentities = []
				}

				// Save next page url and append new data
				self.nextPageURL = literatureIdentityResponse.next
				self.literatureIdentities.append(contentsOf: literatureIdentityResponse.data)
				self.literatureIdentities.removeDuplicates()
			case .upcoming:
				let literatureIdentityResponse = try await KService.getUpcomingLiteratures(next: self.nextPageURL).value

				// Reset data if necessary
				if self.nextPageURL == nil {
					self.literatureIdentities = []
				}

				// Save next page url and append new data
				self.nextPageURL = literatureIdentityResponse.next
				self.literatureIdentities.append(contentsOf: literatureIdentityResponse.data)
				self.literatureIdentities.removeDuplicates()
			case .explore:
				guard let exploreCategoryIdentity = self.exploreCategoryIdentity else { return }
				let exploreCategoryResponse = try await KService.getExplore(exploreCategoryIdentity, next: self.nextPageURL, limit: self.nextPageURL != nil ? 100 : 25).value

				// Reset data if necessary
				if self.nextPageURL == nil {
					self.relatedLiteratures = []
					self.literatureIdentities = []
				}

				// Save next page url and append new data
				self.nextPageURL = exploreCategoryResponse.data.first?.relationships.literatures?.next
				self.literatureIdentities.append(contentsOf: exploreCategoryResponse.data.first?.relationships.literatures?.data ?? [])
				self.literatureIdentities.removeDuplicates()
			}

			self.endFetch()
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
	override func makeDestination(for identifier: SegueIdentifier) -> UIViewController? {
		guard let segue = identifier as? SegueIdentifiers else { return nil }

		switch segue {
		case .literatureDetailsSegue: return LiteratureDetailsCollectionViewController()
		}
	}

	override func prepare(for identifier: any SegueIdentifier, destination: UIViewController, sender: Any?) {
		guard let identifier = identifier as? SegueIdentifiers else { return }

		switch identifier {
		case .literatureDetailsSegue:
			guard let literatureDetailCollectionViewController = destination as? LiteratureDetailsCollectionViewController else { return }
			guard let literature = sender as? Literature else { return }
			literatureDetailCollectionViewController.literature = literature
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
					let libraryUpdateResponse = try await KService.addToLibrary(.literatures, withLibraryStatus: value, modelID: literature.id).value

					literature.attributes.library?.update(using: libraryUpdateResponse.data)

					// Update entry in library
					cell.libraryStatus = value
					button.setTitle("\(title) ▾", for: .normal)

					let libraryAddToNotificationName = Notification.Name("AddTo\(value.sectionValue)Section")
					NotificationCenter.default.post(name: libraryAddToNotificationName, object: nil)

					// Request review
					ReviewManager.shared.requestReview(for: .itemAddedToLibrary(status: value))
				} catch let error as KKAPIError {
					self.presentAlertController(title: "Can't Add to Your Library 😔", message: error.message)
					print("----- Add to library failed", error.message)
				}
			}
		})

		if cell.libraryStatus != .none {
			actionSheetAlertController.addAction(UIAlertAction(title: Trans.removeFromLibrary, style: .destructive) { _ in
				Task {
					do {
						let libraryUpdateResponse = try await KService.removeFromLibrary(.literatures, modelID: literature.id).value

						literature.attributes.library?.update(using: libraryUpdateResponse.data)

						// Update entry in library
						cell.libraryStatus = .none
						button.setTitle(Trans.add.uppercased(), for: .normal)

						let libraryRemoveFromNotificationName = Notification.Name("RemoveFrom\(oldLibraryStatus.sectionValue)Section")
						NotificationCenter.default.post(name: libraryRemoveFromNotificationName, object: nil)
					} catch let error as KKAPIError {
						self.presentAlertController(title: "Can't Remove From Your Library 😔", message: error.message)
						print("----- Remove from library failed", error.message)
					}
				}
			})
		}

		// Present the controller
		if let popoverController = actionSheetAlertController.popoverPresentationController {
			popoverController.sourceView = button
			popoverController.sourceRect = button.bounds
		}

		if (self.navigationController?.visibleViewController as? UIAlertController) == nil {
			self.present(actionSheetAlertController, animated: true, completion: nil)
		}
	}

	func baseLockupCollectionViewCell(_ cell: BaseLockupCollectionViewCell, didPressReminder button: UIButton) async {
//		guard let indexPath = self.collectionView.indexPath(for: cell) else { return }
//		let literature = self.literatures[indexPath] ?? self.relatedLiteratures[indexPath.item].literature
//		literature.toggleReminder()
	}
}

// MARK: - SectionLayoutKind
extension LiteraturesListCollectionViewController {
	/// List of section layout kind.
	///
	/// ```swift
	/// case main = 0
	/// ```
	enum SectionLayoutKind: Int, CaseIterable {
		// MARK: - Cases
		/// The main section.
		case main = 0
	}
}

// MARK: - ItemKind
extension LiteraturesListCollectionViewController {
	/// List of item layout kind.
	enum ItemKind: Hashable {
		// MARK: - Cases
		/// Indicates the item kind contains a `LiteratureIdentity` object.
		case literatureIdentity(_: LiteratureIdentity)

		/// Indicates the item kind contains a `RelatedLiterature` object.
		case relatedLiterature(_: RelatedLiterature)

		// MARK: - Functions
		func hash(into hasher: inout Hasher) {
			switch self {
			case .literatureIdentity(let literatureIdentity):
				hasher.combine(literatureIdentity)
			case .relatedLiterature(let relatedLiterature):
				hasher.combine(relatedLiterature)
			}
		}

		static func == (lhs: ItemKind, rhs: ItemKind) -> Bool {
			switch (lhs, rhs) {
			case (.literatureIdentity(let literatureIdentity1), .literatureIdentity(let literatureIdentity2)):
				return literatureIdentity1 == literatureIdentity2
			case (.relatedLiterature(let relatedLiterature1), .relatedLiterature(let relatedLiterature2)):
				return relatedLiterature1 == relatedLiterature2
			default:
				return false
			}
		}
	}
}

// MARK: - Cell Configuration
extension LiteraturesListCollectionViewController {
	func getConfiguredSmallCell() -> UICollectionView.CellRegistration<SmallLockupCollectionViewCell, ItemKind> {
		return UICollectionView.CellRegistration<SmallLockupCollectionViewCell, ItemKind>(cellNib: SmallLockupCollectionViewCell.nib) { [weak self] smallLockupCollectionViewCell, indexPath, itemKind in
			guard let self = self else { return }

			switch itemKind {
			case .literatureIdentity:
				let literature: Literature? = self.fetchModel(at: indexPath)

				if literature == nil, let section = self.snapshot.sectionIdentifier(containingItem: itemKind), !self.isFetchingSection.contains(section) {
					Task {
						await self.fetchSectionIfNeeded(LiteratureResponse.self, LiteratureIdentity.self, at: indexPath, itemKind: itemKind)
					}
				}

				smallLockupCollectionViewCell.delegate = self
				smallLockupCollectionViewCell.configure(using: literature)
			case .relatedLiterature(let relatedLiterature):
				smallLockupCollectionViewCell.delegate = self
				smallLockupCollectionViewCell.configure(using: relatedLiterature)
			}
		}
	}

	func getConfiguredUpcomingCell() -> UICollectionView.CellRegistration<UpcomingLockupCollectionViewCell, ItemKind> {
		return UICollectionView.CellRegistration<UpcomingLockupCollectionViewCell, ItemKind>(cellNib: UpcomingLockupCollectionViewCell.nib) { [weak self] upcomingLockupCollectionViewCell, indexPath, itemKind in
			guard let self = self else { return }

			switch itemKind {
			case .literatureIdentity:
				let literature: Literature? = self.fetchModel(at: indexPath)

				if literature == nil, let section = self.snapshot.sectionIdentifier(containingItem: itemKind), !self.isFetchingSection.contains(section) {
					Task {
						await self.fetchSectionIfNeeded(LiteratureResponse.self, LiteratureIdentity.self, at: indexPath, itemKind: itemKind)
					}
				}

				upcomingLockupCollectionViewCell.delegate = self
				upcomingLockupCollectionViewCell.configure(using: literature)
			default: break
			}
		}
	}
}
