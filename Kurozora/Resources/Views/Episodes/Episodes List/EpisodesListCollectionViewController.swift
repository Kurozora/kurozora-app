//
//  EpisodesListCollectionViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 11/10/2018.
//  Copyright © 2018 Kurozora. All rights reserved.
//

import UIKit
import KurozoraKit
import Alamofire

enum EpisodesListFetchType {
	case season
	case search
}

class EpisodesListCollectionViewController: KCollectionViewController {
	// MARK: - IBOutlets
	@IBOutlet weak var goToButton: UIBarButtonItem!
	@IBOutlet weak var filterButton: UIBarButtonItem!

	// MARK: - Properties
	var seasonIdentity: SeasonIdentity? = nil
	var episodes: [IndexPath: Episode] = [:]
	var episodeIdentities: [EpisodeIdentity] = []
	var searachQuery: String = ""
	var episodesListFetchType: EpisodesListFetchType = .search
	var dataSource: UICollectionViewDiffableDataSource<SectionLayoutKind, EpisodeIdentity>! = nil
	var prefetchingIndexPathOperations: [IndexPath: DataRequest] = [:]

	/// The next page url of the pagination.
	var nextPageURL: String?

	/// Whether a fetch request is currently in progress.
	var isRequestInProgress: Bool = false

	/// Indicates whether fillers should be hidden from the user.
	var shouldHideFillers: Bool = false

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

	// MARK: - Initializers
	/// Initialize a new instance of EpisodesListCollectionViewController with the given season id.
	///
	/// - Parameter seasonID: The season id to use when initializing the view.
	///
	/// - Returns: an initialized instance of EpisodesListCollectionViewController.
	static func `init`(with seasonID: String) -> EpisodesListCollectionViewController {
		if let episodesListCollectionViewController = R.storyboard.episodes.episodesListCollectionViewController() {
			episodesListCollectionViewController.seasonIdentity = SeasonIdentity(id: seasonID)
			episodesListCollectionViewController.episodesListFetchType = .season
			return episodesListCollectionViewController
		}

		fatalError("Failed to instantiate EpisodesListCollectionViewController with the given season id.")
	}

	// MARK: - View
	override func viewWillReload() {
		super.viewWillReload()

		self.handleRefreshControl()
	}

	override func viewDidLoad() {
		super.viewDidLoad()

		NotificationCenter.default.addObserver(self, selector: #selector(updateEpisodes(_:)), name: .KEpisodeWatchStatusDidUpdate, object: nil)

		#if DEBUG
		self._prefersRefreshControlDisabled = false
		#else
		self._prefersRefreshControlDisabled = true
		#endif

		// Add Refresh Control to Collection View
		#if !targetEnvironment(macCatalyst)
		self.refreshControl?.attributedTitle = NSAttributedString(string: "Pull to refresh the episodes.")
		#endif

		self.configureDataSource()

		if !self.episodeIdentities.isEmpty {
			self.endFetch()
		} else {
			Task { [weak self] in
				guard let self = self else { return }
				await self.fetchEpisodes()
			}
		}
	}

	// MARK: - Functions
	override func handleRefreshControl() {
		if self.seasonIdentity != nil {
			self.nextPageURL = nil
			Task { [weak self] in
				guard let self = self else { return }
				await self.fetchEpisodes()
			}
		}
	}

	override func configureEmptyDataView() {
		emptyBackgroundView.configureImageView(image: R.image.empty.episodes()!)
		emptyBackgroundView.configureLabels(title: "No Episodes", detail: "This season doesn't have episodes yet. Please check back again later.")

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

	/// Fetches the episodes from the server.
	func fetchEpisodes() async {
		guard !self.isRequestInProgress else {
			return
		}

		// Set request in progress
		self.isRequestInProgress = true

		#if !targetEnvironment(macCatalyst)
		self.refreshControl?.attributedTitle = NSAttributedString(string: "Refreshing episodes...")
		#endif

		switch self.episodesListFetchType {
		case .season:
			do {
				guard let seasonIdentity = self.seasonIdentity else { return }
				let episodeIdentityResponse = try await KService.getEpisodes(forSeason: seasonIdentity, next: self.nextPageURL).value

				// Reset data if necessary
				if self.nextPageURL == nil {
					self.episodeIdentities = []
				}

				// Save next page url and append new data
				self.nextPageURL = episodeIdentityResponse.next
				self.episodeIdentities.append(contentsOf: episodeIdentityResponse.data)
				self.episodeIdentities.removeDuplicates()
			} catch {
				print(error.localizedDescription)
			}
		case .search:
			do {
				let searchResponse = try await KService.search(.kurozora, of: [.episodes], for: self.searachQuery, next: self.nextPageURL, limit: 25, filter: nil).value

				// Reset data if necessary
				if self.nextPageURL == nil {
					self.episodeIdentities = []
				}

				// Save next page url and append new data
				self.nextPageURL = searchResponse.data.episodes?.next
				self.episodeIdentities.append(contentsOf: searchResponse.data.episodes?.data ?? [])
				self.episodeIdentities.removeDuplicates()
			} catch {
				print(error.localizedDescription)
			}
		}

		self.endFetch()

		// Reset refresh controller title
		#if !targetEnvironment(macCatalyst)
		self.refreshControl?.attributedTitle = NSAttributedString(string: "Pull to refresh the episodes.")
		#endif
	}

	/// Update the episodes list.
	///
	/// - Parameter notification: An object containing information broadcast to registered observers that bridges to Notification.
	@objc func updateEpisodes(_ notification: NSNotification) {
		guard let indexPath = notification.userInfo?["indexPath"] as? IndexPath, let selectedEpisode = dataSource.itemIdentifier(for: indexPath) else { return }

		var newSnapshot = dataSource.snapshot()
		newSnapshot.reloadItems([selectedEpisode])
		dataSource.apply(newSnapshot)
	}

	/// Goes to the first item in the presented collection view.
	fileprivate func goToFirstEpisode() {
		collectionView.safeScrollToItem(at: IndexPath(row: 0, section: 0), at: .centeredVertically, animated: true)
		goToButton.image = UIImage(systemName: "chevron.down.circle")
	}

	/// Goes to the last item in the presented collection view.
	fileprivate func goToLastEpisode() {
		collectionView.safeScrollToItem(at: IndexPath(row: dataSource.snapshot().numberOfItems - 1, section: 0), at: .centeredVertically, animated: true)
		goToButton.image = UIImage(systemName: "chevron.up.circle")
	}

	/// Goes to the last watched episode in the presented collection view.
	fileprivate func goToLastWatchedEpisode() {
		if let lastWatchedEpisode = self.episodes.first(where: { _, episode in
			if let episodeWatchStatus = episode.attributes.watchStatus {
				return episodeWatchStatus == .notWatched
			}
			return false
		}) {
			self.collectionView.safeScrollToItem(at: lastWatchedEpisode.key, at: .centeredVertically, animated: true)
		} else {
			self.goToLastEpisode()
		}
	}

	/// Builds and presents an action sheet.
	fileprivate func showActionList(_ sender: AnyObject) {
		let actionSheetAlertController = UIAlertController.actionSheet(title: nil, message: nil) { [weak self] actionSheetAlertController in
			guard let self = self else { return }
			let visibleIndexPath = collectionView.indexPathsForVisibleItems

			if !visibleIndexPath.contains(IndexPath(item: 0, section: 0)) {
				// Go to first episode
				let goToFirstEpisode = UIAlertAction(title: "Go to first episode", style: .default) { _ in
					self.goToFirstEpisode()
				}
				actionSheetAlertController.addAction(goToFirstEpisode)
			} else {
				// Go to last episode
				let goToLastEpisode = UIAlertAction(title: "Go to last episode", style: .default) { _ in
					self.goToLastEpisode()
				}
				actionSheetAlertController.addAction(goToLastEpisode)
			}

			// Go to last watched episode
			let goToLastWatchedEpisode = UIAlertAction(title: "Go to last watched episode", style: .default) { _ in
				self.goToLastWatchedEpisode()
			}
			actionSheetAlertController.addAction(goToLastWatchedEpisode)
		}

		// Present the controller
		if let popoverController = actionSheetAlertController.popoverPresentationController {
			popoverController.barButtonItem = sender as? UIBarButtonItem
		}

		self.present(actionSheetAlertController, animated: true, completion: nil)
	}

	/// Builds and presents the filter action sheet.
	fileprivate func showFilterActionList(_ sender: AnyObject) {
		let actionSheetAlertController = UIAlertController.actionSheet(title: nil, message: nil) { [weak self] actionSheetAlertController in
			guard let self = self else { return }
			// Toggle fillers
			let title = self.shouldHideFillers ? "Show fillers" : "Hide fillers"

			let toggleFillers = UIAlertAction(title: title, style: .default) { _ in
				self.shouldHideFillers = !self.shouldHideFillers
				self.updateDataSource()
			}
			actionSheetAlertController.addAction(toggleFillers)
		}

		// Present the controller
		if let popoverController = actionSheetAlertController.popoverPresentationController {
			popoverController.barButtonItem = sender as? UIBarButtonItem
		}

		self.present(actionSheetAlertController, animated: true, completion: nil)
	}

	// MARK: - IBActions
	@IBAction func goToButtonPressed(_ sender: UIBarButtonItem) {
		self.showActionList(sender)
	}

	@IBAction func filterButtonPressed(_ sender: UIBarButtonItem) {
		self.showFilterActionList(sender)
	}

	// MARK: - Segue
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if segue.identifier == R.segue.episodesListCollectionViewController.episodeDetailSegue.identifier, let episodeCell = sender as? EpisodeLockupCollectionViewCell {
			if let episodeDetailsCollectionViewController = segue.destination as? EpisodeDetailsCollectionViewController, let indexPath = self.collectionView.indexPath(for: episodeCell) {
				episodeDetailsCollectionViewController.indexPath = indexPath
				episodeDetailsCollectionViewController.episode = self.episodes[indexPath]
			}
		}
	}
}

// MARK: - EpisodeLockupCollectionViewCellDelegate
extension EpisodesListCollectionViewController: EpisodeLockupCollectionViewCellDelegate {
	func episodeLockupCollectionViewCell(_ cell: EpisodeLockupCollectionViewCell, didPressWatchButton button: UIButton) {
		guard let indexPath = collectionView.indexPath(for: cell) else { return }
		Task {
			await self.episodes[indexPath]?.updateWatchStatus(userInfo: ["indexPath": indexPath])
		}
	}

	func episodeLockupCollectionViewCell(_ cell: EpisodeLockupCollectionViewCell, didPressMoreButton button: UIButton) {
		guard let indexPath = self.collectionView.indexPath(for: cell) else { return }
		let episode = self.episodes[indexPath]

		let actionSheetAlertController = UIAlertController.actionSheet(title: nil, message: nil) { [weak self] actionSheetAlertController in
			guard let self = self else { return }
			let watchStatus = episode?.attributes.watchStatus

			if watchStatus != .disabled {
				let actionTitle = watchStatus == .notWatched ? "Mark as Watched" : "Mark as Un-watched"

				actionSheetAlertController.addAction(UIAlertAction(title: actionTitle, style: .default, handler: { _ in
					Task {
						await episode?.updateWatchStatus(userInfo: ["indexPath": indexPath])
					}
				}))
			}
//			actionSheetAlertController.addAction(UIAlertAction(title: "Rate", style: .default, handler: nil))
			actionSheetAlertController.addAction(UIAlertAction(title: Trans.share, style: .default, handler: { _ in
				episode?.openShareSheet(on: self, button)
			}))
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

// MARK: - SectionLayoutKind
extension EpisodesListCollectionViewController {
	/// List of episode section layout kind.
	///
	/// ```
	/// case main = 0
	/// ```
	enum SectionLayoutKind: Int, CaseIterable {
		case main = 0
	}
}
