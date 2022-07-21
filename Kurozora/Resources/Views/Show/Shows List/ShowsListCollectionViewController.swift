//
//  ShowsListCollectionViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 16/01/2020.
//  Copyright © 2020 Kurozora. All rights reserved.
//

import UIKit
import KurozoraKit
import Alamofire

enum ShowsListFetchType {
	case charcter
	case explore
	case person
	case moreByStudio
	case relatedShow
	case search
	case studio
	case upcoming
}

class ShowsListCollectionViewController: KCollectionViewController {
	// MARK: - Properties
	var personIdentity: PersonIdentity? = nil
	var characterIdentity: CharacterIdentity? = nil
	var showIdentity: ShowIdentity? = nil
	var studioIdentity: StudioIdentity? = nil
	var exploreCategoryIdentity: ExploreCategoryIdentity? = nil
	var shows: [IndexPath: Show] = [:]
	var showIdentities: [ShowIdentity] = []
	var relatedShows: [RelatedShow] = []
	var searachQuery: String = ""
	var showsListFetchType: ShowsListFetchType = .search
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

		if !self.showIdentities.isEmpty || !self.relatedShows.isEmpty {
			self.endFetch()
		} else {
			Task { [weak self] in
				guard let self = self else { return }
				await self.fetchShows()
			}
		}
	}

	// MARK: - Functions
	override func handleRefreshControl() {
		self.nextPageURL = nil
	}

	override func configureEmptyDataView() {
		emptyBackgroundView.configureImageView(image: R.image.empty.library()!)
		emptyBackgroundView.configureLabels(title: "No Shows", detail: "Can't get shows list. Please refresh the page or restart the app and check your WiFi connection.")

		collectionView.backgroundView?.alpha = 0
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
	func fetchShows() async {
		guard !self.isRequestInProgress else {
			return
		}

		// Set request in progress
		self.isRequestInProgress = true

		do {
			switch self.showsListFetchType {
			case .charcter:
				guard let characterIdentity = self.characterIdentity else { return }

				KService.getShows(forCharacter: characterIdentity, next: self.nextPageURL) { [weak self] result in
					guard let self = self else { return }
					switch result {
					case .success(let showIdentityResponse):
						// Reset data if necessary
						if self.nextPageURL == nil {
							self.showIdentities = []
						}

						// Save next page url and append new data
						self.nextPageURL = showIdentityResponse.next
						self.showIdentities.append(contentsOf: showIdentityResponse.data)
						self.showIdentities.removeDuplicates()

						self.endFetch()
					case .failure: break
					}
				}
			case .person:
				guard let personIdentity = self.personIdentity else { return }

				KService.getShows(forPerson: personIdentity, next: self.nextPageURL) { [weak self] result in
					guard let self = self else { return }
					switch result {
					case .success(let showIdentityResponse):
						// Reset data if necessary
						if self.nextPageURL == nil {
							self.showIdentities = []
						}

						// Save next page url and append new data
						self.nextPageURL = showIdentityResponse.next
						self.showIdentities.append(contentsOf: showIdentityResponse.data)
						self.showIdentities.removeDuplicates()

						self.endFetch()
					case .failure: break
					}
				}
			case .search:
				let searchResponse = try await KService.search(.kurozora, of: [.shows], for: self.searachQuery, next: self.nextPageURL, limit: 25).value

				// Reset data if necessary
				if self.nextPageURL == nil {
					self.relatedShows = []
					self.showIdentities = []
				}

				// Save next page url and append new data
				self.nextPageURL = searchResponse.data.shows?.next
				self.showIdentities.append(contentsOf: searchResponse.data.shows?.data ?? [])
				self.showIdentities.removeDuplicates()
			case .moreByStudio:
				guard let showIdentity = self.showIdentity else { return }
				let showIdentityResponse = try await KService.getMoreByStudio(forShow: showIdentity, next: self.nextPageURL).value

				// Reset data if necessary
				if self.nextPageURL == nil {
					self.showIdentities = []
				}

				// Save next page url and append new data
				self.nextPageURL = showIdentityResponse.next
				self.showIdentities.append(contentsOf: showIdentityResponse.data)
				self.showIdentities.removeDuplicates()
			case .relatedShow:
				guard let showIdentity = self.showIdentity else { return }
				let relatedShowsResponse = try await KService.getRelatedShows(forShow: showIdentity, next: self.nextPageURL).value

				// Reset data if necessary
				if self.nextPageURL == nil {
					self.relatedShows = []
					self.showIdentities = []
				}

				// Save next page url and append new data
				self.nextPageURL = relatedShowsResponse.next
				self.relatedShows.append(contentsOf: relatedShowsResponse.data)
				self.relatedShows.removeDuplicates()
			case .studio:
				guard let studioIdentity = self.studioIdentity else { return }
				let showIdentityResponse = try await KService.getShows(forStudio: studioIdentity, next: self.nextPageURL).value

				// Reset data if necessary
				if self.nextPageURL == nil {
					self.showIdentities = []
				}

				// Save next page url and append new data
				self.nextPageURL = showIdentityResponse.next
				self.showIdentities.append(contentsOf: showIdentityResponse.data)
				self.showIdentities.removeDuplicates()
			case .upcoming:
				KService.getUpcomingShows(next: self.nextPageURL) { [weak self] result in
					guard let self = self else { return }
					switch result {
					case .success(let showIdentityResponse):
						// Reset data if necessary
						if self.nextPageURL == nil {
							self.showIdentities = []
						}

						// Save next page url and append new data
						self.nextPageURL = showIdentityResponse.next
						self.showIdentities.append(contentsOf: showIdentityResponse.data)
						self.showIdentities.removeDuplicates()

						self.endFetch()
					case .failure: break
					}
				}
			case .explore:
				guard let exploreCategoryIdentity = self.exploreCategoryIdentity else { return }
				let exploreCategoryResponse = try await KService.getExplore(exploreCategoryIdentity, next: self.nextPageURL, limit: 25).value

				// Reset data if necessary
				if self.nextPageURL == nil {
					self.relatedShows = []
					self.showIdentities = []
				}

				// Save next page url and append new data
				self.nextPageURL = exploreCategoryResponse.data.first?.relationships.shows?.next
				self.showIdentities.append(contentsOf: exploreCategoryResponse.data.first?.relationships.shows?.data ?? [])
				self.showIdentities.removeDuplicates()
			}

			self.endFetch()
		} catch {
			print(error.localizedDescription)
		}
	}

	// MARK: - Segue
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		switch segue.identifier {
		case R.segue.showsListCollectionViewController.showDetailsSegue.identifier:
			guard let showDetailCollectionViewController = segue.destination as? ShowDetailsCollectionViewController else { return }
			guard let show = sender as? Show else { return }
			showDetailCollectionViewController.show = show
		default: break
		}
	}
}

// MARK: - BaseLockupCollectionViewCellDelegate
extension ShowsListCollectionViewController: BaseLockupCollectionViewCellDelegate {
	func baseLockupCollectionViewCell(_ cell: BaseLockupCollectionViewCell, didPressStatus button: UIButton) {
		WorkflowController.shared.isSignedIn {
			guard let indexPath = self.collectionView.indexPath(for: cell) else { return }
			let show = self.shows[indexPath] ?? self.relatedShows[indexPath.item].show

			let oldLibraryStatus = cell.libraryStatus
			let actionSheetAlertController = UIAlertController.actionSheetWithItems(items: KKLibrary.Status.alertControllerItems, currentSelection: oldLibraryStatus, action: { title, value  in
				KService.addToLibrary(withLibraryStatus: value, showID: show.id) { result in
					switch result {
					case .success(let libraryUpdate):
						show.attributes.update(using: libraryUpdate)

						// Update entry in library
						cell.libraryStatus = value
						button.setTitle("\(title) ▾", for: .normal)

						let libraryAddToNotificationName = Notification.Name("AddTo\(value.sectionValue)Section")
						NotificationCenter.default.post(name: libraryAddToNotificationName, object: nil)
					case .failure:
						break
					}
				}
			})

			if cell.libraryStatus != .none {
				actionSheetAlertController.addAction(UIAlertAction(title: "Remove from library", style: .destructive) { _ in
					KService.removeFromLibrary(showID: show.id) { result in
						switch result {
						case .success(let libraryUpdate):
							show.attributes.update(using: libraryUpdate)

							// Update edntry in library
							cell.libraryStatus = .none
							button.setTitle("ADD", for: .normal)

							let libraryRemoveFromNotificationName = Notification.Name("RemoveFrom\(oldLibraryStatus.sectionValue)Section")
							NotificationCenter.default.post(name: libraryRemoveFromNotificationName, object: nil)
						case .failure:
							break
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
		guard let indexPath = self.collectionView.indexPath(for: cell) else { return }
		let show = self.shows[indexPath] ?? self.relatedShows[indexPath.item].show
		show.toggleReminder()
	}
}

// MARK: - SectionLayoutKind
extension ShowsListCollectionViewController {
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
extension ShowsListCollectionViewController {
	/// List of item layout kind.
	enum ItemKind: Hashable {
		// MARK: - Cases
		/// Indicates the item kind contains a Show object.
		case showIdentity(_: ShowIdentity)

		/// Indicates the item kind contains a RelatedShow object.
		case relatedShow(_: RelatedShow)

		// MARK: - Functions
		func hash(into hasher: inout Hasher) {
			switch self {
			case .showIdentity(let showIdentity):
				hasher.combine(showIdentity)
			case .relatedShow(let relatedShow):
				hasher.combine(relatedShow)
			}
		}

		static func == (lhs: ItemKind, rhs: ItemKind) -> Bool {
			switch (lhs, rhs) {
			case (.showIdentity(let showIdentity1), .showIdentity(let showIdentity2)):
				return showIdentity1 == showIdentity2
			case (.relatedShow(let relatedShow1), .relatedShow(let relatedShow2)):
				return relatedShow1 == relatedShow2
			default:
				return false
			}
		}
	}
}
