//
//  EpisodesTableViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 11/10/2018.
//  Copyright © 2018 Kurozora. All rights reserved.
//

import KCommonKit
import EmptyDataSet_Swift
import SwipeCellKit

class EpisodesTableViewController: UITableViewController, EmptyDataSetSource, EmptyDataSetDelegate {
    var seasonID: Int?
	var episodes: [EpisodesElement]? {
		didSet {
			self.tableView?.reloadData()
		}
	}

    override func viewDidLoad() {
        super.viewDidLoad()
		view.theme_backgroundColor = KThemePicker.backgroundColor.rawValue

        tableView?.emptyDataSetSource = self
        tableView?.emptyDataSetDelegate = self
        tableView?.emptyDataSetView { view in
            view.titleLabelString(NSAttributedString(string: "No episodes found!"))
                .image(UIImage(named: ""))
                .shouldDisplay(true)
                .shouldFadeIn(true)
                .isTouchAllowed(true)
                .isScrollAllowed(true)
        }
		tableView.rowHeight = UITableView.automaticDimension
		tableView.estimatedRowHeight = UITableView.automaticDimension

        fetchEpisodes()
    }

	// MARK: - Functions
	func fetchEpisodes() {
		Service.shared.getEpisodes(forSeason: seasonID, withSuccess: { (episodes) in
			DispatchQueue.main.async {
				self.episodes = episodes?.episodes
			}
		})
	}

	func populateActionSheet(for episode: EpisodesElement, at cell: EpisodesTableViewCell) {
		let controller = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
		let tag = cell.episodeWatchedButton.tag
		controller.addAction(UIAlertAction(title: (tag == 0) ? "Mark as Watched" : "Mark as Unwatched", style: .default, handler: { (action) in
			self.episodesCellWatchedButtonPressed(for: cell)
		}))
		controller.addAction(UIAlertAction(title: "Rate", style: .default, handler: nil))
		controller.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
		self.present(controller, animated: true, completion: nil)
	}

	// MARK: - Segue
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if segue.identifier == "EpisodeDetailSegue", let episodeCell = sender as? EpisodesTableViewCell {
			if let episodeDetailViewController = segue.destination as? EpisodesDetailTableViewControlle, let indexPath = tableView.indexPath(for: episodeCell) {
				episodeDetailViewController.episodeElement = episodes?[indexPath.row]
				episodeDetailViewController.episodeCell = episodeCell
				episodeDetailViewController.delegate = episodeCell
			}
		}
	}
}

// MARK: - UITableViewDataSource
extension EpisodesTableViewController {
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		guard let episodesCount = episodes?.count else { return 0 }
		return episodesCount
	}

	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let episodeTableViewCell = tableView.dequeueReusableCell(withIdentifier: "EpisodesTableViewCell", for: indexPath) as! EpisodesTableViewCell

		episodeTableViewCell.episodesDelegate = self
		episodeTableViewCell.delegate = self
		episodeTableViewCell.episodesElement = episodes?[indexPath.row]

		return episodeTableViewCell
	}
}

// MARK: - UITableViewDelegate
extension EpisodesTableViewController {
	override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		return UITableView.automaticDimension
	}
}

// MARK: - SwipeTableViewCellDelegate
extension EpisodesTableViewController: SwipeTableViewCellDelegate {
	func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
		guard let episode = episodes?[indexPath.item] else { return nil }
		guard let cell = tableView.cellForRow(at: indexPath) as? EpisodesTableViewCell else { return nil}

		switch orientation {
		case .right:
			let rateAction = SwipeAction(style: .default, title: "Rate") { action, indexPath in
			}
			rateAction.backgroundColor = .clear
			rateAction.image = #imageLiteral(resourceName: "rate_circle")
			rateAction.textColor = #colorLiteral(red: 0.9725490196, green: 0.9058823529, blue: 0.1098039216, alpha: 1)
			rateAction.font = .systemFont(ofSize: 16, weight: .semibold)
			rateAction.transitionDelegate = ScaleTransition.default

			let moreAction = SwipeAction(style: .default, title: "More") { action, indexPath in
				self.populateActionSheet(for: episode, at: cell)
			}
			moreAction.backgroundColor = .clear
			moreAction.image = #imageLiteral(resourceName: "more_circle")
			moreAction.textColor = #colorLiteral(red: 0.25, green: 0.25, blue: 0.25, alpha: 1)
			moreAction.font = .systemFont(ofSize: 16, weight: .semibold)
			moreAction.transitionDelegate = ScaleTransition.default

			return [rateAction, moreAction]
		case .left:
			let watchedAction = SwipeAction(style: .default, title: "") { action, indexPath in
				self.episodesCellWatchedButtonPressed(for: cell)
			}
			watchedAction.backgroundColor = .clear
			if let tag = cell.episodeWatchedButton?.tag {
				watchedAction.title = (tag == 0) ? "Mark as Watched" : "Mark as Unwatched"
				watchedAction.image = (tag == 0) ? #imageLiteral(resourceName: "watched_circle") : #imageLiteral(resourceName: "unwatched_circle")
				watchedAction.textColor = (tag == 0) ? #colorLiteral(red: 1, green: 0.5764705882, blue: 0, alpha: 1) : #colorLiteral(red: 0.6078431373, green: 0.6078431373, blue: 0.6078431373, alpha: 1)
			}
			watchedAction.font = .systemFont(ofSize: 16, weight: .semibold)
			watchedAction.transitionDelegate = ScaleTransition.default

			return [watchedAction]
		}
	}

	func visibleRect(for tableView: UITableView) -> CGRect? {
		if #available(iOS 11.0, *) {
			return tableView.safeAreaLayoutGuide.layoutFrame
		} else {
			let topInset = navigationController?.navigationBar.frame.height ?? 0
			let bottomInset = navigationController?.toolbar?.frame.height ?? 0
			let bounds = tableView.bounds

			return CGRect(x: bounds.origin.x, y: bounds.origin.y + topInset, width: bounds.width, height: bounds.height - bottomInset)
		}
	}

	func tableView(_ tableView: UITableView, editActionsOptionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> SwipeOptions {
		var options = SwipeOptions()
		options.expansionStyle = .selection
		options.transitionStyle = .reveal
		options.expansionDelegate = ScaleAndAlphaExpansion.default

		options.buttonSpacing = 5
		options.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.2)

		return options
	}
}

// MARK: - EpisodeTableViewCellDelegate
extension EpisodesTableViewController: EpisodesTableViewCellDelegate {
	func episodesCellMoreButtonPressed(for cell: EpisodesTableViewCell) {
		if let indexPath = tableView.indexPath(for: cell) {
			guard let episode = episodes?[indexPath.row] else { return }
			populateActionSheet(for: episode, at: cell)
		}
	}

    func episodesCellWatchedButtonPressed(for cell: EpisodesTableViewCell) {
        if let indexPath = tableView.indexPath(for: cell) {
			guard let episodeID = episodes?[indexPath.row].id else { return }
			var watched = 0

			if cell.episodeWatchedButton.tag == 0 {
				watched = 1
			}

			Service.shared.mark(asWatched: watched, forEpisode: episodeID) { (watchStatus) in
				DispatchQueue.main.async {
					cell.configureCell(with: watchStatus, shouldUpdate: true, withValue: watchStatus)
				}
			}
        }
    }
}
//    func episodeCellMorePressed(cell: EpisodeCell) {
//        let indexPath = collectionView.indexPath(for: cell)!
//        let episode = dataSource[indexPath.row]
//        var textToShare = ""
//
//        if anime.episodes == indexPath.row + 1 {
//            textToShare = "Finished watching \(anime.title!) via #KurozoraApp"
//        } else {
//            textToShare = "Just watched \(anime.title!) ep \(episode.number) via #KurozoraApp"
//        }
//
//        var objectsToShare: [AnyObject] = [textToShare as AnyObject]
//        if let image = cell.screenshotImageView.image {
//            objectsToShare.append( image )
//        }
//
//        let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
//        activityVC.excludedActivityTypes = [UIActivityType.assignToContact, UIActivityType.copyToPasteboard, UIActivityType.addToReadingList,UIActivityType.print];
//        self.present(activityVC, animated: true, completion: nil)
//
//    }
//
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
