//
//  LiteraturesListCollectionViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 01/02/2023.
//  Copyright © 2023 Kurozora. All rights reserved.
//

import UIKit
import KurozoraKit
import Alamofire

enum LiteraturesListFetchType {
	case show
	case game
	case charcter
	case explore
	case person
	case moreByStudio
	case relatedLiterature
	case search
	case studio
	case upcoming
}

class LiteraturesListCollectionViewController: KCollectionViewController {
	// MARK: - Properties
	var showIdentity: ShowIdentity? = nil

	var gameIdentity: GameIdentity? = nil

	var personIdentity: PersonIdentity? = nil

	var characterIdentity: CharacterIdentity? = nil

	var literatureIdentity: LiteratureIdentity? = nil

	var studioIdentity: StudioIdentity? = nil

	var exploreCategoryIdentity: ExploreCategoryIdentity? = nil

	var literatures: [IndexPath: Literature] = [:]
	var literatureIdentities: [LiteratureIdentity] = []

	var relatedLiteratures: [RelatedLiterature] = []

	var searachQuery: String = ""
	var literaturesListFetchType: LiteraturesListFetchType = .search

	var dataSource: UICollectionViewDiffableDataSource<SectionLayoutKind, ItemKind>! = nil
	var prefetchingIndexPathOperations: [IndexPath: DataRequest] = [:]

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
		self.emptyBackgroundView.configureImageView(image: R.image.empty.mangaLibrary()!)
		self.emptyBackgroundView.configureLabels(title: "No Literatures", detail: "Can't get literatures list. Please refresh the page or restart the app and check your WiFi connection.")

		self.collectionView.backgroundView?.alpha = 0
	}

	/// Fades in and out the empty data view according to the number of rows.
	func toggleEmptyDataView() {
		if self.collectionView.numberOfItems() == 0 {
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
			case .charcter:
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
				let searchResponse = try await KService.search(.kurozora, of: [.literatures], for: self.searachQuery, next: self.nextPageURL, limit: 25).value

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
				let exploreCategoryResponse = try await KService.getExplore(exploreCategoryIdentity, next: self.nextPageURL, limit: 25).value

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

	// MARK: - Segue
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		switch segue.identifier {
		case R.segue.literaturesListCollectionViewController.literatureDetailsSegue.identifier:
			guard let literatureDetailCollectionViewController = segue.destination as? LiteratureDetailsCollectionViewController else { return }
			guard let literature = sender as? Literature else { return }
			literatureDetailCollectionViewController.literature = literature
		default: break
		}
	}
}

// MARK: - BaseLockupCollectionViewCellDelegate
extension LiteraturesListCollectionViewController: BaseLockupCollectionViewCellDelegate {
	func baseLockupCollectionViewCell(_ cell: BaseLockupCollectionViewCell, didPressStatus button: UIButton) {
		WorkflowController.shared.isSignedIn {
			guard let indexPath = self.collectionView.indexPath(for: cell) else { return }
			let literature = self.literatures[indexPath] ?? self.relatedLiteratures[indexPath.item].literature

			let oldLibraryStatus = cell.libraryStatus
			let actionSheetAlertController = UIAlertController.actionSheetWithItems(items: KKLibrary.Status.alertControllerItems(for: cell.libraryKind), currentSelection: oldLibraryStatus, action: { title, value  in
				Task {
					do {
						let libraryUpdateResponse = try await KService.addToLibrary(.literatures, withLibraryStatus: value, modelID: String(literature.id)).value

						literature.attributes.update(using: libraryUpdateResponse.data)

						// Update entry in library
						cell.libraryStatus = value
						button.setTitle("\(title) ▾", for: .normal)

						let libraryAddToNotificationName = Notification.Name("AddTo\(value.sectionValue)Section")
						NotificationCenter.default.post(name: libraryAddToNotificationName, object: nil)
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
							let libraryUpdateResponse = try await KService.removeFromLibrary(.literatures, modelID: String(literature.id)).value

							literature.attributes.update(using: libraryUpdateResponse.data)

							// Update edntry in library
							cell.libraryStatus = .none
							button.setTitle("ADD", for: .normal)

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
	}

	func baseLockupCollectionViewCell(_ cell: BaseLockupCollectionViewCell, didPressReminder button: UIButton) {
//		guard let indexPath = self.collectionView.indexPath(for: cell) else { return }
//		let literature = self.literatures[indexPath] ?? self.relatedLiteratures[indexPath.item].literature
//		literature.toggleReminder()
	}
}

// MARK: - SectionLayoutKind
extension LiteraturesListCollectionViewController {
	/// List of section layout kind.
	///
	/// ```
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
		/// Indicates the item kind contains a Literature object.
		case literatureIdentity(_: LiteratureIdentity)

		/// Indicates the item kind contains a RelatedLiterature object.
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
