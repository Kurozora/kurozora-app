//
//  EpisodesCollectionViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 11/10/2018.
//  Copyright © 2018 Kurozora. All rights reserved.
//

import KCommonKit
import EmptyDataSet_Swift
import SwipeCellKit

class EpisodesCollectionViewController: UICollectionViewController, EmptyDataSetSource, EmptyDataSetDelegate {
    var seasonID: Int?
	var episodes: [EpisodesElement]? {
		didSet {
			self.collectionView?.reloadData()
		}
	}
	var gap: CGFloat = UIDevice.isPad ? 40 : 20
	var numberOfItems: (forWidth: CGFloat, forHeight: CGFloat) {
		get {
			if UIDevice.isLandscape {
				switch UIDevice.type {
				case .iPhone_5_5S_5C_SE:	return (2, 1.8)
				case .iPhone_6_6S_7_8:		return (2, 1.8)
				case .iPhone_6_6S_7_8_PLUS:	return (2, 1.8)
				case .iPhone_Xr:			return (2, 1.6)
				case .iPhone_X_Xs:			return (2, 1.6)
				case .iPhone_Xs_Max:		return (2, 1.6)

				case .iPad:					return (2, 3.6)
				case .iPadAir3:				return (3, 3.6)
				case .iPadPro11:			return (3, 3.4)
				case .iPadPro12:			return (3, 3.4)
				}
			}

			switch UIDevice.type {
			case .iPhone_5_5S_5C_SE:	return (1, 3)
			case .iPhone_6_6S_7_8:		return (1, 3)
			case .iPhone_6_6S_7_8_PLUS:	return (1, 3)
			case .iPhone_Xr:			return (1, 3.8)
			case .iPhone_X_Xs:			return (1, 3.8)
			case .iPhone_Xs_Max:		return (1, 3.8)

			case .iPad:					return (2, 4.4)
			case .iPadAir3:				return (2, 4.4)
			case .iPadPro11:			return (2, 4.6)
			case .iPadPro12:			return (2, 4.6)
			}
		}
	}

	#if DEBUG
	var newNumberOfItems: (forWidth: CGFloat, forHeight: CGFloat)?
	var _numberOfItems: (forWidth: CGFloat, forHeight: CGFloat) {
		get {
			guard let newNumberOfItems = newNumberOfItems else { return numberOfItems }
			return newNumberOfItems
		}
	}

	var numberOfItemsTextField: UITextField = UITextField(frame: CGRect(origin: .zero, size: CGSize(width: 100, height: 20)))

	@objc func updateLayout(_ textField: UITextField) {
		guard let textFieldText = numberOfItemsTextField.text, !textFieldText.isEmpty else { return }
		newNumberOfItems = getNumbers(textFieldText)
		collectionView.reloadData()
	}

	func getNumbers(_ text: String) -> (forWidth: CGFloat, forHeight: CGFloat) {
		let stringArray = text.withoutSpacesAndNewLines.components(separatedBy: ",")
		let width = (stringArray.count > 1) ? Double(stringArray[0])?.cgFloat : numberOfItems.forWidth
		let height = (stringArray.count > 1) ? Double(stringArray[1])?.cgFloat : numberOfItems.forHeight
		return (width ?? numberOfItems.forWidth, height ?? numberOfItems.forHeight)
	}
	#endif

    override func viewDidLoad() {
        super.viewDidLoad()
		view.theme_backgroundColor = KThemePicker.backgroundColor.rawValue

        collectionView?.emptyDataSetSource = self
        collectionView?.emptyDataSetDelegate = self
        collectionView?.emptyDataSetView { view in
            view.titleLabelString(NSAttributedString(string: "No episodes found!"))
                .image(UIImage(named: ""))
                .shouldDisplay(true)
                .shouldFadeIn(true)
                .isTouchAllowed(true)
                .isScrollAllowed(true)
        }

        fetchEpisodes()

		#if DEBUG
		numberOfItemsTextField.placeholder = "# items for: width, height"
		numberOfItemsTextField.text = "\(numberOfItems.forWidth), \(numberOfItems.forHeight)"
		numberOfItemsTextField.textAlignment = .center
		numberOfItemsTextField.addTarget(self, action: #selector(updateLayout(_:)), for: .editingDidEnd)
		navigationItem.title = nil
		navigationItem.titleView = numberOfItemsTextField
		#endif
    }

	override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
		super.viewWillTransition(to: size, with: coordinator)
		guard let flowLayout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout else {
			return
		}
		flowLayout.invalidateLayout()
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

	// MARK: - Functions
	func fetchEpisodes() {
		Service.shared.getEpisodes(forSeason: seasonID, withSuccess: { (episodes) in
			DispatchQueue.main.async {
				self.episodes = episodes?.episodes
			}
		})
	}

	func populateActionSheet(for episode: EpisodesElement, at cell: EpisodesCollectionViewCell) {
		let controller = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
		let tag = cell.episodeWatchedButton.tag
		controller.addAction(UIAlertAction(title: (tag == 0) ? "Mark as Watched" : "Mark as Unwatched", style: .default, handler: { (action) in
			self.episodesCellWatchedButtonPressed(for: cell)
		}))
		controller.addAction(UIAlertAction(title: "Rate", style: .default, handler: nil))
		controller.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
		self.present(controller, animated: true, completion: nil)
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

// MARK: - SwipeCollectionViewCellDelegate
extension EpisodesCollectionViewController: SwipeCollectionViewCellDelegate {
	func collectionView(_ collectionView: UICollectionView, editActionsForItemAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
		guard let episode = episodes?[indexPath.item] else { return nil }
		guard let cell = collectionView.cellForItem(at: indexPath) as? EpisodesCollectionViewCell else { return nil}

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

	func visibleRect(for collectionView: UICollectionView) -> CGRect? {
		if #available(iOS 11.0, *) {
			return collectionView.safeAreaLayoutGuide.layoutFrame
		} else {
			let topInset = navigationController?.navigationBar.frame.height ?? 0
			let bottomInset = navigationController?.toolbar?.frame.height ?? 0
			let bounds = collectionView.bounds

			return CGRect(x: bounds.origin.x, y: bounds.origin.y + topInset, width: bounds.width, height: bounds.height - bottomInset)
		}
	}

	func collectionView(_ collectionView: UICollectionView, editActionsOptionsForItemAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> SwipeOptions {
		var options = SwipeOptions()
		options.expansionStyle = .selection
		options.transitionStyle = .reveal
		options.expansionDelegate = ScaleAndAlphaExpansion.default

		options.buttonSpacing = 5
		options.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.2)

		return options
	}
}

// MARK: - UICollectionViewDelegateFlowLayout
extension EpisodesCollectionViewController: UICollectionViewDelegateFlowLayout {
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
		#if DEBUG
		return CGSize(width: (collectionView.width - gap) / _numberOfItems.forWidth, height: (collectionView.height - gap) / _numberOfItems.forHeight)
		#else
		return CGSize(width: (collectionView.width - gap) / numberOfItems.forWidth, height: (collectionView.height - gap) / numberOfItems.forHeight)
		#endif
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
