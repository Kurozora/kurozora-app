//
//  EpisodesCollectionViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 11/10/2018.
//  Copyright © 2018 Kurozora. All rights reserved.
//

import UIKit
import EmptyDataSet_Swift
import SwipeCellKit

class EpisodesCollectionViewController: UICollectionViewController {
	// MARK: - IBOutlets
	@IBOutlet weak var goToButton: UIBarButtonItem! {
		didSet {
			goToButton.theme_tintColor = KThemePicker.tintColor.rawValue
		}
	}

	// MARK: - Properties
    var seasonID: Int?
	var episodes: [EpisodesElement]? {
		didSet {
			self.collectionView?.reloadData()
		}
	}

	// MARK: - View
    override func viewDidLoad() {
        super.viewDidLoad()
		view.theme_backgroundColor = KThemePicker.backgroundColor.rawValue
		NotificationCenter.default.addObserver(self, selector: #selector(reloadEmptyDataView), name: .ThemeUpdateNotification, object: nil)

		collectionView.collectionViewLayout = createLayout()

		// Fetch episodes
		fetchEpisodes()

		// Setup empty data view
		setupEmptyDataView()
    }

	// MARK: - Functions
	/// Sets up the empty data view.
	func setupEmptyDataView() {
		collectionView?.emptyDataSetView { view in
			view.titleLabelString(NSAttributedString(string: "No Episodes", attributes: [.font: UIFont.systemFont(ofSize: 16, weight: .medium), .foregroundColor: KThemePicker.textColor.colorValue]))
				.detailLabelString(NSAttributedString(string: "This season doesn't have episodes yet. Please check back again later.", attributes: [.font: UIFont.systemFont(ofSize: 16), .foregroundColor: KThemePicker.subTextColor.colorValue]))
				.image(#imageLiteral(resourceName: "empty_episodes"))
				.imageTintColor(KThemePicker.textColor.colorValue)
				.verticalOffset(-50)
				.verticalSpace(5)
				.isScrollAllowed(true)
		}
	}

	/// Reload the empty data view.
	@objc func reloadEmptyDataView() {
		setupEmptyDataView()
		collectionView.reloadData()
	}

	/// Fetches the episodes from the server.
	func fetchEpisodes() {
		KService.shared.getEpisodes(forSeason: seasonID, withSuccess: { (episodes) in
			DispatchQueue.main.async {
				self.episodes = episodes?.episodes
			}
		})
	}

	/**
		Populate an action sheet for the given episode.

		- Parameter episode: The episode for which the action sheet should be populated
		- Parameter cell: The cell that needs to be updated if actions are taken.
	*/
	func populateActionSheet(for episode: EpisodesElement, at cell: EpisodesCollectionViewCell) {
		let tag = cell.episodeWatchedButton.tag
		let action = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
		action.addAction(UIAlertAction(title: (tag == 0) ? "Mark as Watched" : "Mark as Unwatched", style: .default, handler: { (_) in
			self.episodesCellWatchedButtonPressed(for: cell)
		}))
		action.addAction(UIAlertAction(title: "Rate", style: .default, handler: nil))
		action.addAction(UIAlertAction(title: "Share", style: .default, handler: nil))
		action.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))

		//Present the controller
		if let popoverController = action.popoverPresentationController {
			popoverController.sourceView = cell.episodeMoreButton
			popoverController.sourceRect = cell.episodeMoreButton.bounds
		}

		self.present(action, animated: true, completion: nil)
	}

	/// Goes to the first item in the presented collection view.
	fileprivate func goToFirstEpisode() {
		collectionView.scrollToItem(at: IndexPath(row: 0, section: 0), at: .centeredVertically, animated: true)
		goToButton.image = #imageLiteral(resourceName: "Symbols/chevron_down_circle")
	}

	/// Goes to the last item in the presented collection view.
	fileprivate func goToLastEpisode() {
		guard let episodes = episodes else { return }
		collectionView.scrollToItem(at: IndexPath(row: episodes.count - 1, section: 0), at: .centeredVertically, animated: true)
		goToButton.image = #imageLiteral(resourceName: "Symbols/chevron_up_circle")
	}

	/// Goes to the last watched episode in the presented collection view.
	fileprivate func goToLastWatchedEpisode() {
		guard let lastWatchedEpisode = episodes?.closestMatch(index: 0, predicate: {
			if let watched = $0.userDetails?.watched {
				return !watched
			}
			return false
		}) else { return }
		collectionView.scrollToItem(at: IndexPath(row: lastWatchedEpisode.0, section: 0), at: .centeredVertically, animated: true)
	}

	/// Builds and presents an action sheet.
	fileprivate func showActionList() {
		let action = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
		let visibleIndexPath = collectionView.indexPathsForVisibleItems

		if !visibleIndexPath.contains(IndexPath(item: 0, section: 0)) {
			// Go to first episode
			let goToFirstEpisode = UIAlertAction.init(title: "Go to first episode", style: .default, handler: { (_) in
				self.goToFirstEpisode()
			})
			action.addAction(goToFirstEpisode)
		} else {
			// Go to last episode
			let goToLastEpisode = UIAlertAction.init(title: "Go to last episode", style: .default, handler: { (_) in
				self.goToLastEpisode()
			})
			action.addAction(goToLastEpisode)
		}

		// Go to last watched episode
		let goToLastWatchedEpisode = UIAlertAction.init(title: "Go to last watched episode", style: .default, handler: { (_) in
			self.goToLastWatchedEpisode()
		})
		action.addAction(goToLastWatchedEpisode)

		action.addAction(UIAlertAction.init(title: "Cancel", style: .cancel, handler: nil))
		action.view.theme_tintColor = KThemePicker.tintColor.rawValue

		//Present the controller
		if let popoverController = action.popoverPresentationController {
			popoverController.barButtonItem = goToButton
		}

		self.present(action, animated: true, completion: nil)
	}

	// MARK: - IBActions
	@IBAction func goToButtonPressed(_ sender: UIBarButtonItem) {
		showActionList()
	}

	// MARK: - Segue
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if segue.identifier == "EpisodeDetailSegue", let episodeCell = sender as? EpisodesCollectionViewCell {
			if let episodeDetailViewController = segue.destination as? EpisodesDetailTableViewControlle, let indexPath = collectionView.indexPath(for: episodeCell) {
				episodeDetailViewController.episodeElement = episodes?[indexPath.row]
				episodeDetailViewController.episodeCell = episodeCell
				episodeDetailViewController.delegate = episodeCell
			}
		}
	}
}

// MARK: - UICollectionViewDataSource
extension EpisodesCollectionViewController {
	override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		guard let episodesCount = episodes?.count else { return 0 }
		return episodesCount
	}

	override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		let episodesCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "EpisodesCollectionViewCell", for: indexPath) as! EpisodesCollectionViewCell
		episodesCollectionViewCell.episodesDelegate = self
		episodesCollectionViewCell.delegate = self
		episodesCollectionViewCell.episodesElement = episodes?[indexPath.row]
		return episodesCollectionViewCell
	}
}

// MARK: - KCollectionViewDelegateLayout
extension EpisodesCollectionViewController {
	override func columnCount(forSection section: Int, layout layoutEnvironment: NSCollectionLayoutEnvironment) -> Int {
		let width = layoutEnvironment.container.effectiveContentSize.width
		let columnCount = (width / 374).int
		return columnCount > 0 ? columnCount : 1
	}

	override func groupHeightFraction(forSection section: Int, with columnsCount: Int) -> CGFloat {
		return (0.60 / columnsCount.double).cgFloat
	}

	override func contentInset(forItemInSection section: Int, layout layoutEnvironment: NSCollectionLayoutEnvironment) -> NSDirectionalEdgeInsets {
		return NSDirectionalEdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10)
	}

	override func contentInset(forSection section: Int, layout layoutEnvironment: NSCollectionLayoutEnvironment) -> NSDirectionalEdgeInsets {
		return NSDirectionalEdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10)
	}

	override func createLayout() -> UICollectionViewLayout {
		let layout = UICollectionViewCompositionalLayout { (section: Int, layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? in
			let columns = self.columnCount(forSection: section, layout: layoutEnvironment)
			let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
												  heightDimension: .fractionalHeight(1.0))
			let item = NSCollectionLayoutItem(layoutSize: itemSize)
			item.contentInsets = self.contentInset(forItemInSection: section, layout: layoutEnvironment)

			let heightFraction = self.groupHeightFraction(forSection: section, with: columns)
			let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
												   heightDimension: .fractionalWidth(heightFraction))
			let layoutGroup = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: columns)

			let layoutSection = NSCollectionLayoutSection(group: layoutGroup)
			layoutSection.contentInsets = self.contentInset(forSection: section, layout: layoutEnvironment)
			return layoutSection
		}
		return layout
	}
}

// MARK: - SwipeCollectionViewCellDelegate
extension EpisodesCollectionViewController: SwipeCollectionViewCellDelegate {
	func collectionView(_ collectionView: UICollectionView, editActionsForItemAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
		guard let episode = episodes?[indexPath.item] else { return nil }
		guard let cell = collectionView.cellForItem(at: indexPath) as? EpisodesCollectionViewCell else { return nil}

		switch orientation {
		case .right:
			let rateAction = SwipeAction(style: .default, title: "Rate") { _, _ in
			}
			rateAction.backgroundColor = .clear
			rateAction.image = #imageLiteral(resourceName: "rate_circle")
			rateAction.textColor = .kYellow
			rateAction.font = .systemFont(ofSize: 16, weight: .semibold)
			rateAction.transitionDelegate = ScaleTransition.default

			let moreAction = SwipeAction(style: .default, title: "More") { _, _ in
				self.populateActionSheet(for: episode, at: cell)
			}
			moreAction.backgroundColor = .clear
			moreAction.image = #imageLiteral(resourceName: "more_circle")
			moreAction.textColor = #colorLiteral(red: 0.25, green: 0.25, blue: 0.25, alpha: 1)
			moreAction.font = .systemFont(ofSize: 16, weight: .semibold)
			moreAction.transitionDelegate = ScaleTransition.default

			return [rateAction, moreAction]
		case .left:
			let watchedAction = SwipeAction(style: .default, title: "") { _, _ in
				self.episodesCellWatchedButtonPressed(for: cell)
			}
			watchedAction.backgroundColor = .clear
			if let tag = cell.episodeWatchedButton?.tag {
				watchedAction.title = (tag == 0) ? "Mark as Watched" : "Mark as Unwatched"
				watchedAction.image = (tag == 0) ? #imageLiteral(resourceName: "watched_circle") : #imageLiteral(resourceName: "unwatched_circle")
				watchedAction.textColor = (tag == 0) ? .kurozora : #colorLiteral(red: 0.6078431373, green: 0.6078431373, blue: 0.6078431373, alpha: 1)
			}
			watchedAction.font = .systemFont(ofSize: 16, weight: .semibold)
			watchedAction.transitionDelegate = ScaleTransition.default

			return [watchedAction]
		}
	}

	func visibleRect(for collectionView: UICollectionView) -> CGRect? {
		return collectionView.safeAreaLayoutGuide.layoutFrame
	}

	func collectionView(_ collectionView: UICollectionView, editActionsOptionsForItemAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> SwipeOptions {
		var options = SwipeOptions()
		options.expansionStyle = .selection
		options.transitionStyle = .reveal
		options.expansionDelegate = ScaleAndAlphaExpansion.default
		options.buttonSpacing = 5
		options.backgroundColor = .clear
		return options
	}
}

// MARK: - EpisodesCollectionViewCellDelegate
extension EpisodesCollectionViewController: EpisodesCollectionViewCellDelegate {
	func episodesCellMoreButtonPressed(for cell: EpisodesCollectionViewCell) {
		if let indexPath = collectionView.indexPath(for: cell) {
			guard let episode = episodes?[indexPath.row] else { return }
			populateActionSheet(for: episode, at: cell)
		}
	}

    func episodesCellWatchedButtonPressed(for cell: EpisodesCollectionViewCell) {
        if let indexPath = collectionView.indexPath(for: cell) {
			guard let episodeID = episodes?[indexPath.row].id else { return }
			var watched = 0

			if cell.episodeWatchedButton.tag == 0 {
				watched = 1
			}

			KService.shared.mark(asWatched: watched, forEpisode: episodeID) { (watchStatus) in
				DispatchQueue.main.async {
					cell.configureCell(with: watchStatus, shouldUpdate: true, withValue: watchStatus)
				}
			}
        }
    }
}

//extension EpisodesViewController: DropDownListDelegate {
//    func selectedAction(sender trigger: UIView, action: String, indexPath: IndexPath) {
//        if dataSource.isEmpty {
//            return
//        }
//
//        switch indexPath.row {
//        case 0:
//            // Go to top
//            self.collectionView.scrollToItem(at: IndexPath(row: 0, section: 0), at: UICollectionViewScrollPosition.top, animated: true)
//        case 1:
//            // Go to next episode
//            if let nextEpisode = anime.nextEpisode, nextEpisode > 0 {
//                self.collectionView.scrollToItem(at: IndexPath(row: nextEpisode - 1, section: 0), at: UICollectionViewScrollPosition.centeredVertically, animated: true)
//            }
//        case 2:
//            // Go to bottom
//            self.collectionView.scrollToItem(at: IndexPath(row: dataSource.count - 1, section: 0), at: UICollectionViewScrollPosition.bottom, animated: true)
//        default:
//            break
//        }
//    }
//
//    func dropDownDidDismissed(selectedAction: Bool) {
//
//    }
//}
//
//extension EpisodesViewController: RateViewControllerProtocol {
//    func rateControllerDidFinishedWith(anime: Anime, rating: Float) {
//        RateViewController.updateAnime(anime, withRating: rating*2.0)
//    }
//}
