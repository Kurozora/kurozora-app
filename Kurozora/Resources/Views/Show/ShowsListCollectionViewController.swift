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

class ShowsListCollectionViewController: KCollectionViewController {
	// MARK: - Properties
	var personIdentity: PersonIdentity? = nil
	var characterIdentity: CharacterIdentity? = nil
	var showIdentity: ShowIdentity? = nil
	var studioIdentity: StudioIdentity? = nil
	var shows: [IndexPath: Show] = [:]
	var showIdentities: [ShowIdentity] = []
	var relatedShows: [RelatedShow] = []
	var showUpcoming: Bool = false
	var dataSource: UICollectionViewDiffableDataSource<SectionLayoutKind, ItemKind>! = nil
	var prefetchingIndexPathOperations: [IndexPath: DataRequest] = [:]

	/// The next page url of the pagination.
	var nextPageURL: String?

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
			self.fetchShows()
		}
	}

	// MARK: - Functions
	override func handleRefreshControl() {
		self.nextPageURL = nil

		if let showIdentity = self.showIdentity {
			self.showIdentity = showIdentity
		} else if let personIdentity = self.personIdentity {
			self.personIdentity = personIdentity
		} else if let characterIdentity = self.characterIdentity {
			self.characterIdentity = characterIdentity
		} else if let studioIdentity = self.studioIdentity {
			self.studioIdentity = studioIdentity
		}
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
	func fetchShows() {
		if self.showIdentity != nil {
			guard let showIdentity = showIdentity else { return }

			KService.getRelatedShows(forShow: showIdentity, next: self.nextPageURL) { [weak self] result in
				guard let self = self else { return }
				switch result {
				case .success(let relatedShowsResponse):
					// Reset data if necessary
					if self.nextPageURL == nil {
						self.relatedShows = []
						self.showIdentities = []
					}

					// Save next page url and append new data
					self.nextPageURL = relatedShowsResponse.next
					self.relatedShows.append(contentsOf: relatedShowsResponse.data)

					self.endFetch()
				case .failure: break
				}
			}
		} else if self.personIdentity != nil {
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

					self.endFetch()
				case .failure: break
				}
			}
		} else if self.characterIdentity != nil {
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

					self.endFetch()
				case .failure: break
				}
			}
		} else if self.studioIdentity != nil {
			guard let studioIdentity = self.studioIdentity else { return }

			KService.getShows(forStudio: studioIdentity, next: self.nextPageURL) { [weak self] result in
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

					self.endFetch()
				case .failure: break
				}
			}
		} else if self.showUpcoming {
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

					self.endFetch()
				case .failure: break
				}
			}
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

// MARK: - KCollectionViewDataSource
extension ShowsListCollectionViewController {
	override func registerCells(for collectionView: UICollectionView) -> [UICollectionViewCell.Type] {
		return [
			SmallLockupCollectionViewCell.self,
			UpcomingLockupCollectionViewCell.self
		]
	}

	override func configureDataSource() {
		let smallLockupCellRegistration = UICollectionView.CellRegistration<SmallLockupCollectionViewCell, ItemKind>(cellNib: UINib(resource: R.nib.smallLockupCollectionViewCell)) { [weak self] smallLockupCollectionViewCell, indexPath, itemKind in
			guard let self = self else { return }

			switch itemKind {
			case .showIdentity(let showIdentity, _):
				let show = self.fetchShow(at: indexPath)
				var showDataRequest = self.prefetchingIndexPathOperations[indexPath] ?? smallLockupCollectionViewCell.dataRequest

				if showDataRequest == nil && show == nil {
					showDataRequest = KService.getDetails(forShow: showIdentity) { [weak self] result in
						switch result {
						case .success(let shows):
							self?.shows[indexPath] = shows.first
							self?.setItemKindNeedsUpdate(itemKind)
						case .failure: break
						}
					}
				}

				smallLockupCollectionViewCell.dataRequest = showDataRequest
				smallLockupCollectionViewCell.delegate = self
				smallLockupCollectionViewCell.configure(using: show)
			case .relatedShow(let relatedShow, _):
				smallLockupCollectionViewCell.delegate = self
				smallLockupCollectionViewCell.configure(using: relatedShow)
			}
		}

		let upcomingLockupCellRegistration = UICollectionView.CellRegistration<UpcomingLockupCollectionViewCell, ItemKind>(cellNib: UINib(resource: R.nib.upcomingLockupCollectionViewCell)) { [weak self] upcomingLockupCollectionViewCell, indexPath, itemKind in
			guard let self = self else { return }

			switch itemKind {
			case .showIdentity(let showIdentity, _):
				let show = self.fetchShow(at: indexPath)
				var showDataRequest = self.prefetchingIndexPathOperations[indexPath] ?? upcomingLockupCollectionViewCell.dataRequest

				if showDataRequest == nil && show == nil {
					showDataRequest = KService.getDetails(forShow: showIdentity) { [weak self] result in
						switch result {
						case .success(let shows):
							self?.shows[indexPath] = shows.first
							self?.setItemKindNeedsUpdate(itemKind)
						case .failure: break
						}
					}
				}

				upcomingLockupCollectionViewCell.dataRequest = showDataRequest
				upcomingLockupCollectionViewCell.delegate = self
				upcomingLockupCollectionViewCell.configure(using: show)
			default: break
			}
		}

		self.dataSource = UICollectionViewDiffableDataSource<SectionLayoutKind, ItemKind>(collectionView: collectionView) { [weak self] (collectionView: UICollectionView, indexPath: IndexPath, itemKind: ItemKind) -> UICollectionViewCell? in
			guard let self = self else { return nil }

			if self.showUpcoming {
				return collectionView.dequeueConfiguredReusableCell(using: upcomingLockupCellRegistration, for: indexPath, item: itemKind)
			}

			return collectionView.dequeueConfiguredReusableCell(using: smallLockupCellRegistration, for: indexPath, item: itemKind)
		}

		self.updateDataSource()
	}

	override func updateDataSource() {
		var snapshot = NSDiffableDataSourceSnapshot<SectionLayoutKind, ItemKind>()
		snapshot.appendSections([.main])

		// Append items
		if self.relatedShows.isEmpty {
			let showItems: [ItemKind] = self.showIdentities.map { showIdentity in
				return .showIdentity(showIdentity)
			}
			snapshot.appendItems(showItems)
		} else {
			let relatedShowItems: [ItemKind] = self.relatedShows.map { relatedShow in
				return .relatedShow(relatedShow)
			}
			snapshot.appendItems(relatedShowItems)
		}

		self.dataSource.apply(snapshot)
	}

	func fetchShow(at indexPath: IndexPath) -> Show? {
		guard let show = self.shows[indexPath] else { return nil }
		return show
	}

	func setItemKindNeedsUpdate(_ itemKind: ItemKind) {
		var snapshot = self.dataSource.snapshot()
		snapshot.reconfigureItems([itemKind])
		self.dataSource.apply(snapshot, animatingDifferences: true)
	}
}

// MARK: - KCollectionViewDelegateLayout
extension ShowsListCollectionViewController {
	override func columnCount(forSection section: Int, layout layoutEnvironment: NSCollectionLayoutEnvironment) -> Int {
		let width = layoutEnvironment.container.effectiveContentSize.width
		let columnCount = width >= 414 ? (width / 384).rounded().int : (width / 284).rounded().int
		return columnCount > 0 ? columnCount : 1
	}

	override func createLayout() -> UICollectionViewLayout? {
		return UICollectionViewCompositionalLayout { [weak self] (section: Int, layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? in
			guard let self = self else { return nil }
			let columns = self.columnCount(forSection: section, layout: layoutEnvironment)

			if self.showUpcoming {
				return Layouts.upcomingSection(section, columns: columns, layoutEnvironment: layoutEnvironment, isHorizontal: false)
			}

			return Layouts.smallSection(section, columns: columns, layoutEnvironment: layoutEnvironment, isHorizontal: false)
		}
	}
}

// MARK: - BaseLockupCollectionViewCellDelegate
extension ShowsListCollectionViewController: BaseLockupCollectionViewCellDelegate {
	func chooseStatusButtonPressed(_ sender: UIButton, on cell: BaseLockupCollectionViewCell) {
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
						cell.libraryStatusButton?.setTitle("\(title) ▾", for: .normal)

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
							cell.libraryStatusButton?.setTitle("ADD", for: .normal)

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
				popoverController.sourceView = sender
				popoverController.sourceRect = sender.bounds
			}

			if (self.navigationController?.visibleViewController as? UIAlertController) == nil {
				self.present(actionSheetAlertController, animated: true, completion: nil)
			}
		}
	}

	func reminderButtonPressed(on cell: BaseLockupCollectionViewCell) {
		guard let indexPath = self.collectionView.indexPath(for: cell) else { return }
		(self.shows[indexPath] ?? self.relatedShows[indexPath.item].show).toggleReminder()
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
		case showIdentity(_: ShowIdentity, id: UUID = UUID())

		/// Indicates the item kind contains a RelatedShow object.
		case relatedShow(_: RelatedShow, id: UUID = UUID())

		// MARK: - Functions
		func hash(into hasher: inout Hasher) {
			switch self {
			case .showIdentity(let showIdentity, let id):
				hasher.combine(showIdentity)
				hasher.combine(id)
			case .relatedShow(let relatedShow, let id):
				hasher.combine(relatedShow)
				hasher.combine(id)
			}
		}

		static func == (lhs: ItemKind, rhs: ItemKind) -> Bool {
			switch (lhs, rhs) {
			case (.showIdentity(let showIdentity1, let id1), .showIdentity(let showIdentity2, let id2)):
				return showIdentity1.id == showIdentity2.id && id1 == id2
			case (.relatedShow(let relatedShow1, let id1), .relatedShow(let relatedShow2, let id2)):
				return relatedShow1.id == relatedShow2.id && id1 == id2
			default:
				return false
			}
		}
	}
}
