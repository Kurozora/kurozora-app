//
//  SeasonsCollectionViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 10/10/2018.
//  Copyright © 2018 Kurozora. All rights reserved.
//

import KCommonKit
import SwiftyJSON
import SCLAlertView
import EmptyDataSet_Swift
import Kingfisher

class SeasonsCollectionViewController: UICollectionViewController, EmptyDataSetSource, EmptyDataSetDelegate {
    var canFadeImages = true
    var laidOutSubviews = false
    
    var loadingView:LoaderView!
    var showId:Int?
    var seasonId:Int?
    var seasons:[JSON]?

    override func viewDidLoad() {
        super.viewDidLoad()
        loadingView = LoaderView(parentView: view)
        
        collectionView?.emptyDataSetSource = self
        collectionView?.emptyDataSetDelegate = self
        collectionView?.emptyDataSetView { view in
            view.titleLabelString(NSAttributedString(string: "No seasons found!"))
                .image(UIImage(named: ""))
                .shouldDisplay(true)
                .shouldFadeIn(true)
                .isTouchAllowed(true)
                .isScrollAllowed(true)
        }
        if #available(iOS 11.0, *) {
            collectionView?.contentInsetAdjustmentBehavior = .never
        }
        showId = KCommonKit.shared.showId
        fetchSeasons()
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
        let height: CGFloat = 126

        guard let collectionView = collectionView,
            let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout else {return}

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
    
    func fetchSeasons() {
        loadingView.startAnimating()
        Service.shared.getSeasonFor(showId, withSuccess: { (seasons) in
            if let seasons = seasons {
                self.seasons = seasons
            }
            self.collectionView?.reloadData()
        }) { (errorMessage) in
            SCLAlertView().showError("Error getting seasons", subTitle: errorMessage)
        }
        collectionView?.animateFadeIn()
        loadingView.stopAnimating()
    }
    
    
    // MARK: - IBAction
    @IBAction func dismissPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    
    // MARK: - UICollectionViewDataSource
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let seasonsCount = seasons?.count, seasonsCount != 0 {
            return seasonsCount
        }
        return 0
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let seasonCell = collectionView.dequeueReusableCell(withReuseIdentifier: "SeasonCell", for: indexPath) as! SeasonCollectionCell
        
        let posterUrl = URL(string: "https://something.com/somthing")
        let resource = ImageResource(downloadURL: posterUrl!)
        seasonCell.seasonPosterImageView.kf.setImage(with: resource, placeholder: UIImage(named: "placeholder_poster"), options: [.transition(.fade(0.2))], progressBlock: nil, completionHandler: nil)
        
        if let seasonNumber = seasons?[indexPath.row]["number"].intValue {
            seasonCell.seasonCountLabel.text = "Season \(seasonNumber)"
        } else {
            seasonCell.seasonCountLabel.text = "Season 0"
        }
        
        if let seasonTitle = seasons?[indexPath.row]["title"].stringValue, seasonTitle != "" {
            seasonCell.seasonTitleLabel.text = seasonTitle
        } else {
            seasonCell.seasonTitleLabel.text = "Unknown"
        }

        seasonCell.seasonStartDateLabel.text = "12-10-2000"
        seasonCell.seasonOverallRating.text = "5.00"
        return seasonCell
    }
    
    // MARK: - UICollectionViewDelegate
     override func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
        return false
     }
     
     override func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        return false
     }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let seasonId = seasons?[indexPath.item]["number"].intValue {
            performSegue(withIdentifier: "EpisodeSegue", sender: seasonId)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "EpisodeSegue") {
            let vc = segue.destination as! EpisodesCollectionViewController
            vc.seasonId = sender as? Int
        }
    }
}

    //extension EpisodesViewController: EpisodeCellDelegate {
    //    func episodeCellWatchedPressed(cell: EpisodeCell) {
    //        if let indexPath = collectionView.indexPath(for: cell),
    //            let progress = anime.progress {
    //
    //            let nextEpisode = indexPath.row + 1
    //            if progress.watchedEpisodes == nextEpisode {
    //                progress.watchedEpisodes = nextEpisode - 1
    //            } else {
    //                progress.watchedEpisodes = nextEpisode
    //            }
    //
    //            progress.updatedEpisodes(anime.episodes)
    //
    //            if progress.myAnimeListList() == .Completed {
    //                RateViewController.showRateDialogWith(self.tabBarController!, title: "You've finished\n\(anime.title!)!\ngive it a rating", initialRating: Float(progress.score)/2.0, anime: anime, delegate: self)
    //            }
    //
    //            progress.saveInBackground()
    //            LibrarySyncController.updateAnime(progress)
    //
    //            NotificationCenter.default.postNotificationName(LibraryUpdatedNotification, object: nil)
    //
    //            canFadeImages = false
    //            let indexPaths = collectionView.indexPathsForVisibleItems()
    //            collectionView.reloadItemsAtIndexPaths(indexPaths)
    //            canFadeImages = true
    //        }
    //
    //    }
    //
    //        let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
    //        activityVC.excludedActivityTypes = [UIActivityType.assignToContact, UIActivityType.copyToPasteboard, UIActivityType.addToReadingList,UIActivityType.print];
    //        self.present(activityVC, animated: true, completion: nil)
    //
    //    }
    //}
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
//}
