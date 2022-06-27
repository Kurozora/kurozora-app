//
//  EpisodesCollectionViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 11/10/2018.
//  Copyright © 2018 Kurozora. All rights reserved.
//

import UIKit
import KurozoraKit
import Alamofire

class EpisodesCollectionViewController: KCollectionViewController {
	// MARK: - IBOutlets
	@IBOutlet weak var goToButton: UIBarButtonItem!
	@IBOutlet weak var filterButton: UIBarButtonItem!

	// MARK: - Properties
	var seasonID: Int = 0
	var episodes: [IndexPath: Episode] = [:]
	var episodeIdentities: [EpisodeIdentity] = [] {
		didSet {
			self.updateDataSource()
			self._prefersActivityIndicatorHidden = true
			self.toggleEmptyDataView()
			#if DEBUG
			#if !targetEnvironment(macCatalyst)
			self.refreshControl?.endRefreshing()
			#endif
			#endif
		}
	}
	var dataSource: UICollectionViewDiffableDataSource<SectionLayoutKind, EpisodeIdentity>! = nil
	var prefetchingIndexPathOperations: [IndexPath: DataRequest] = [:]

	/// The next page url of the pagination.
	var nextPageURL: String?

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
	/// Initialize a new instance of EpisodesCollectionViewController with the given season id.
	///
	/// - Parameter seasonID: The season id to use when initializing the view.
	///
	/// - Returns: an initialized instance of EpisodesCollectionViewController.
	static func `init`(with seasonID: Int) -> EpisodesCollectionViewController {
		if let episodesCollectionViewController = R.storyboard.episodes.episodesCollectionViewController() {
			episodesCollectionViewController.seasonID = seasonID
			return episodesCollectionViewController
		}

		fatalError("Failed to instantiate EpisodesCollectionViewController with the given season id.")
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

		// Fetch episodes
		DispatchQueue.global(qos: .userInteractive).async {
			self.fetchEpisodes()
		}
	}

	// MARK: - Functions
	override func handleRefreshControl() {
		self.nextPageURL = nil
		DispatchQueue.global(qos: .userInteractive).async {
			self.fetchEpisodes()
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

	/// Fetches the episodes from the server.
	func fetchEpisodes() {
		DispatchQueue.main.async { [weak self] in
			guard let self = self else { return }
			#if !targetEnvironment(macCatalyst)
			self.refreshControl?.attributedTitle = NSAttributedString(string: "Refreshing episodes...")
			#endif
		}

		let seasonIdentity = SeasonIdentity(id: self.seasonID)
		KService.getEpisodes(forSeasonID: seasonIdentity, next: self.nextPageURL) { [weak self] result in
			guard let self = self else { return }
			switch result {
			case .success(let episodeIdentityResponse):
				// Reset data if necessary
				if self.nextPageURL == nil {
					self.episodeIdentities = []
				}

				// Save next page url and append new data
				self.nextPageURL = episodeIdentityResponse.next
				self.episodeIdentities.append(contentsOf: episodeIdentityResponse.data)
				self.episodeIdentities.removeDuplicates()

				// Reset refresh controller title
				#if !targetEnvironment(macCatalyst)
				self.refreshControl?.attributedTitle = NSAttributedString(string: "Pull to refresh the episodes.")
				#endif
			case .failure: break
			}
		}
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
		if segue.identifier == R.segue.episodesCollectionViewController.episodeDetailSegue.identifier, let episodeCell = sender as? EpisodeLockupCollectionViewCell {
			if let episodeDetailViewController = segue.destination as? EpisodeDetailCollectionViewController, let indexPath = self.collectionView.indexPath(for: episodeCell) {
				episodeDetailViewController.indexPath = indexPath
				episodeDetailViewController.episode = self.episodes[indexPath]
			}
		}
	}
}

// MARK: - EpisodeLockupCollectionViewCellDelegate
extension EpisodesCollectionViewController: EpisodeLockupCollectionViewCellDelegate {
	func episodeLockupCollectionViewCell(_ cell: EpisodeLockupCollectionViewCell, didPressWatchButton button: UIButton) {
		guard let indexPath = collectionView.indexPath(for: cell) else { return }
		self.episodes[indexPath]?.updateWatchStatus(userInfo: ["indexPath": indexPath])
	}

	func episodeLockupCollectionViewCell(_ cell: EpisodeLockupCollectionViewCell, didPressMoreButton button: UIButton) {
		let actionSheetAlertController = UIAlertController.actionSheet(title: nil, message: nil) { [weak self] actionSheetAlertController in
			guard let self = self else { return }
			let actionTitle = button.tag == 0 ? "Mark as Watched" : "Mark as Un-watched"

			actionSheetAlertController.addAction(UIAlertAction(title: actionTitle, style: .default, handler: { _ in
				guard let indexPath = self.collectionView.indexPath(for: cell) else { return }
				self.episodes[indexPath]?.updateWatchStatus(userInfo: ["indexPath": indexPath])
			}))
//			actionSheetAlertController.addAction(UIAlertAction(title: "Rate", style: .default, handler: nil))
			actionSheetAlertController.addAction(UIAlertAction(title: Trans.share, style: .default, handler: { _ in
				guard let indexPath = self.collectionView.indexPath(for: cell) else { return }
				self.episodes[indexPath]?.openShareSheet(on: self, button)
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
extension EpisodesCollectionViewController {
	/// List of episode section layout kind.
	///
	/// ```
	/// case main = 0
	/// ```
	enum SectionLayoutKind: Int, CaseIterable {
		case main = 0
	}
}
