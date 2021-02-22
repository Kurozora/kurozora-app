//
//  EpisodesCollectionViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 11/10/2018.
//  Copyright © 2018 Kurozora. All rights reserved.
//

import UIKit
import KurozoraKit

class EpisodesCollectionViewController: KCollectionViewController {
	// MARK: - IBOutlets
	@IBOutlet weak var goToButton: UIBarButtonItem!

	// MARK: - Properties
	var seasonID: Int = 0
	var episodes: [Episode] = [] {
		didSet {
			self.configureDataSource()
			self._prefersActivityIndicatorHidden = true
			self.toggleEmptyDataView()
			#if DEBUG
			#if !targetEnvironment(macCatalyst)
			self.refreshControl?.endRefreshing()
			#endif
			#endif
		}
	}
	var dataSource: UICollectionViewDiffableDataSource<SectionLayoutKind, Int>! = nil

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

		// Fetch episodes
		DispatchQueue.global(qos: .background).async {
			self.fetchEpisodes()
		}
	}

	// MARK: - Functions
	override func handleRefreshControl() {
		self.fetchEpisodes()
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
		KService.getEpisodes(forSeasonID: seasonID) { [weak self] result in
			guard let self = self else { return }
			switch result {
			case .success(let episodes):
				DispatchQueue.main.async {
					self.episodes = episodes
				}
			case .failure: break
			}
		}
	}

	/// Goes to the first item in the presented collection view.
	fileprivate func goToFirstEpisode() {
		collectionView.scrollToItem(at: IndexPath(row: 0, section: 0), at: .centeredVertically, animated: true)
		goToButton.image = UIImage(systemName: "chevron.down.circle")
	}

	/// Goes to the last item in the presented collection view.
	fileprivate func goToLastEpisode() {
		collectionView.scrollToItem(at: IndexPath(row: episodes.count - 1, section: 0), at: .centeredVertically, animated: true)
		goToButton.image = UIImage(systemName: "chevron.up.circle")
	}

	/// Goes to the last watched episode in the presented collection view.
	fileprivate func goToLastWatchedEpisode() {
		guard let lastWatchedEpisode = episodes.closestMatch(index: 0, predicate: { episode in
			if let episodeWatchStatus = episode.attributes.watchStatus {
				return episodeWatchStatus == .notWatched
			}
			return false
		}) else { return }
		collectionView.scrollToItem(at: IndexPath(row: lastWatchedEpisode.0, section: 0), at: .centeredVertically, animated: true)
	}

	/// Builds and presents an action sheet.
	fileprivate func showActionList() {
		let actionSheetAlertController = UIAlertController.actionSheet(title: nil, message: nil) { [weak self] actionSheetAlertController in
			let visibleIndexPath = collectionView.indexPathsForVisibleItems

			if !visibleIndexPath.contains(IndexPath(item: 0, section: 0)) {
				// Go to first episode
				let goToFirstEpisode = UIAlertAction.init(title: "Go to first episode", style: .default, handler: { (_) in
					self?.goToFirstEpisode()
				})
				actionSheetAlertController.addAction(goToFirstEpisode)
			} else {
				// Go to last episode
				let goToLastEpisode = UIAlertAction.init(title: "Go to last episode", style: .default, handler: { (_) in
					self?.goToLastEpisode()
				})
				actionSheetAlertController.addAction(goToLastEpisode)
			}

			// Go to last watched episode
			let goToLastWatchedEpisode = UIAlertAction.init(title: "Go to last watched episode", style: .default, handler: { (_) in
				self?.goToLastWatchedEpisode()
			})
			actionSheetAlertController.addAction(goToLastWatchedEpisode)
		}

		// Present the controller
		if let popoverController = actionSheetAlertController.popoverPresentationController {
			popoverController.barButtonItem = goToButton
		}

		self.present(actionSheetAlertController, animated: true, completion: nil)
	}

	// MARK: - IBActions
	@IBAction func goToButtonPressed(_ sender: UIBarButtonItem) {
		showActionList()
	}

	// MARK: - Segue
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if segue.identifier == R.segue.episodesCollectionViewController.episodeDetailSegue.identifier, let episodeCell = sender as? EpisodeLockupCollectionViewCell {
			if let episodeDetailViewController = segue.destination as? EpisodeDetailCollectionViewController, let indexPath = collectionView.indexPath(for: episodeCell) {
				episodeDetailViewController.episodeID = episodes[indexPath.row].id
			}
		}
	}
}

// MARK: - EpisodeLockupCollectionViewCellDelegate
extension EpisodesCollectionViewController: EpisodeLockupCollectionViewCellDelegate {
	func episodeLockupCollectionViewCell(_ cell: EpisodeLockupCollectionViewCell, didPressMoreButton button: UIButton) {
		let actionSheetAlertController = UIAlertController.actionSheet(title: nil, message: nil) { [weak self] actionSheetAlertController in
			let actionTitle = button.tag == 0 ? "Mark as Watched" : "Mark as Un-watched"
			actionSheetAlertController.addAction(UIAlertAction(title: actionTitle, style: .default, handler: { _ in
				cell.episode.updateWatchStatus()
			}))
			actionSheetAlertController.addAction(UIAlertAction(title: "Rate", style: .default, handler: nil))
			actionSheetAlertController.addAction(UIAlertAction(title: "Share", style: .default, handler: { _ in
				cell.episode.openShareSheet(on: self, button)
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
	/**
		List of episode section layout kind.

		```
		case main = 0
		```
	*/
	enum SectionLayoutKind: Int, CaseIterable {
		case main = 0
	}
}
