//
//  EpisodesCollectionViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 11/10/2018.
//  Copyright © 2018 Kurozora. All rights reserved.
//

import KCommonKit
import Kingfisher
import SwiftyJSON
import SCLAlertView
import EmptyDataSet_Swift
import NVActivityIndicatorView

class EpisodesCollectionViewController: UICollectionViewController, NVActivityIndicatorViewable, EmptyDataSetSource, EmptyDataSetDelegate {
    var laidOutSubviews = false

    var seasonID: Int?
    var showID: Int?
    var episodes: [EpisodesElement]?
    var episodesSeason: EpisodesSeason?
	var watched: Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
		view.theme_backgroundColor = "Global.backgroundColor"
		
		startAnimating(CGSize(width: 100, height: 100), type: NVActivityIndicatorType.ballScaleMultiple, color: #colorLiteral(red: 1, green: 0.5764705882, blue: 0, alpha: 1), minimumDisplayTime: 3)

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

		showID = KCommonKit.shared.showID
        fetchEpisodes()
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        updateLayoutWithSize(viewSize: size)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if !laidOutSubviews {
            laidOutSubviews = true
            updateLayoutWithSize(viewSize: view.bounds.size)
        }
        
    }
    
    func updateLayoutWithSize(viewSize: CGSize) {
        let height: CGFloat = 240
        
        guard let collectionView = collectionView,
            let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout else {
                return
        }
        
        var size: CGSize?
        var inset: CGFloat = 0
        var lineSpacing: CGFloat = 0
        
        if UIDevice.isPad() {
            inset = 4
            lineSpacing = 4
            let columns: CGFloat = UIDevice.isLandscape() ? 3 : 2
            let totalWidth: CGFloat = viewSize.width - (inset * (columns + 1))
            size = CGSize(width: totalWidth / columns, height: height)
        } else {
            inset = 10
            lineSpacing = 10
            size = CGSize(width: viewSize.width - inset * 2, height: height)
        }
        layout.sectionInset = UIEdgeInsets(top: inset, left: inset, bottom: inset, right: inset)
        layout.minimumLineSpacing = lineSpacing
        layout.minimumInteritemSpacing = lineSpacing
        
        layout.itemSize = size!
        layout.invalidateLayout()
    }
    
    func fetchEpisodes() {
		Service.shared.getEpisodes(forSeason: seasonID, withSuccess: { (episodes) in
            if let episodes = episodes {
                self.episodesSeason = episodes.season
                self.episodes = episodes.episodes
            }
            self.collectionView?.reloadData()
        })
        collectionView?.animateFadeIn()
		self.stopAnimating()
    }
    
//	 MARK: - IBActions
    //    @IBAction func goToPressed(sender: UIBarButtonItem) {
    //
    //        let dataSource = [["First Episode", "Next Episode", "Last Episode"]]
    //
    //        DropDownListViewController.showDropDownListWith(sender: navigationController!.navigationBar, viewController: self, delegate: self, dataSource: dataSource)
    //
    //    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		guard let episodesCount = episodesSeason?.episodeCount else { return 0 }
		return episodesCount
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let episodeCell = collectionView.dequeueReusableCell(withReuseIdentifier: "EpisodeCell", for: indexPath) as! EpisodeCell
        
        if let episodeScreenshot = episodes?[indexPath.row].screenshot, episodeScreenshot != "" {
            let episodeScreenshotUrl = URL(string: episodeScreenshot)
                let resource = ImageResource(downloadURL: episodeScreenshotUrl!)
            
            episodeCell.episodeImageView.kf.setImage(with: resource, placeholder: #imageLiteral(resourceName: "placeholder_episode"), options: [.transition(.fade(0.2))])
        } else {
			episodeCell.episodeImageView.image = #imageLiteral(resourceName: "placeholder_episode")
        }
        
        if let episodeTitle = episodes?[indexPath.row].name, let episodeNumber = episodes?[indexPath.row].number {
			if episodeTitle != "" {
            	episodeCell.episodeTitleLabel.text = "Episode \(episodeNumber): \(episodeTitle)"
			} else {
				episodeCell.episodeTitleLabel.text = "Episode \(episodeNumber)"
			}
		} else if let episodeTitle = episodes?[indexPath.row].name {
			episodeCell.episodeTitleLabel.text = episodeTitle
		} else if let episodeNumber = episodes?[indexPath.row].number {
			episodeCell.episodeTitleLabel.text = "Episode \(episodeNumber)"
		}

        if let episodeFirstAired = episodes?[indexPath.row].firstAired {
            episodeCell.episodeFirstAiredLabel.text = episodeFirstAired
        }

		if let episodeWatched = episodes?[indexPath.row].userDetails?.watched {
			if episodeWatched {
				episodeCell.episodeWatchedButton.setTitleColor(#colorLiteral(red: 1, green: 0.5764705882, blue: 0, alpha: 1), for: .normal)
			} else {
				episodeCell.episodeWatchedButton.setTitleColor(#colorLiteral(red: 0.5843137255, green: 0.6156862745, blue: 0.6784313725, alpha: 1), for: .normal)
			}
		}

		episodeCell.delegate = self

        return episodeCell
    }
}

extension EpisodesCollectionViewController: EpisodeCellDelegate {
    func episodeCellWatchedPressed(cell: EpisodeCell) {
        if let indexPath = collectionView.indexPath(for: cell) {
			guard let episodeID = episodes?[indexPath.row].id else { return }

			if cell.episodeWatchedButton.titleColorForNormal == #colorLiteral(red: 1, green: 0.5764705882, blue: 0, alpha: 1) {
				self.watched = 0
			} else {
                self.watched = 1
			}

			Service.shared.mark(asWatched: self.watched, forEpisode: episodeID) { (success) in
				if success {
					if self.watched == 1 {
						cell.episodeWatchedButton.setTitleColor(#colorLiteral(red: 1, green: 0.5764705882, blue: 0, alpha: 1), for: .normal)
					} else {
						cell.episodeWatchedButton.setTitleColor(#colorLiteral(red: 0.5843137255, green: 0.6156862745, blue: 0.6784313725, alpha: 1), for: .normal)
					}
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
