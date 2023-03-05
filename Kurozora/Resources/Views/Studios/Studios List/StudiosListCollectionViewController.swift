//
//  StudiosListCollectionViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 14/06/2022.
//  Copyright © 2022 Kurozora. All rights reserved.
//

import UIKit
import KurozoraKit
import Alamofire

enum StudiosListFetchType {
	case game
	case literature
	case show
	case search
}

class StudiosListCollectionViewController: KCollectionViewController {
	// MARK: - Properties
	var gameIdentity: GameIdentity?
	var literatureIdentity: LiteratureIdentity?
	var showIdentity: ShowIdentity?
	var studios: [IndexPath: Studio] = [:]
	var studioIdentities: [StudioIdentity] = []
	var searachQuery: String = ""
	var studiosListFetchType: StudiosListFetchType = .search
	var dataSource: UICollectionViewDiffableDataSource<SectionLayoutKind, StudioIdentity>! = nil
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
		return _prefersActivityIndicatorHidden
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
		self.emptyBackgroundView.configureImageView(image: R.image.empty.cast()!)
		self.emptyBackgroundView.configureLabels(title: "No Studios", detail: "Can't get studios list. Please reload the page or restart the app and check your WiFi connection.")

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

	func fetchStudios() async {
		guard !self.isRequestInProgress else {
			return
		}
		self.isRequestInProgress = true

		#if !targetEnvironment(macCatalyst)
		self.refreshControl?.attributedTitle = NSAttributedString(string: "Refreshing studios...")
		#endif

		switch self.studiosListFetchType {
		case .game:
			guard let gameIdentity = self.gameIdentity else { return }
			do {
				let studioIdentityResponse = try await KService.getStudios(forGame: gameIdentity, next: self.nextPageURL).value
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
				let studioIdentityResponse = try await KService.getStudios(forLiterature: literatureIdentity, next: self.nextPageURL).value
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
				let studioIdentityResponse = try await KService.getStudios(forShow: showIdentity, next: self.nextPageURL).value
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
				let searchResponse = try await KService.search(.kurozora, of: [.studios], for: self.searachQuery, next: self.nextPageURL, limit: 25).value

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

	// MARK: - Segue
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		switch segue.identifier {
		case R.segue.studiosListCollectionViewController.studioDetailsSegue.identifier:
			guard let studioDetailsCollectionViewController = segue.destination as? StudioDetailsCollectionViewController else { return }
			guard let studio = sender as? Studio else { return }
			studioDetailsCollectionViewController.studio = studio
		default: break
		}
	}
}

// MARK: - SectionLayoutKind
extension StudiosListCollectionViewController {
	/// List of section layout kind.
	///
	/// ```
	/// case main = 0
	/// ```
	enum SectionLayoutKind: Int, CaseIterable {
		case main = 0
	}
}
