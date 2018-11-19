//
//  EpisodesCollectionViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 11/10/2018.
//  Copyright © 2018 Kurozora. All rights reserved.
//

import KCommonKit
import SwiftyJSON
import SCLAlertView
import EmptyDataSet_Swift
import Kingfisher

class EpisodesCollectionViewController: UICollectionViewController, EmptyDataSetSource, EmptyDataSetDelegate {
    var canFadeImages = true
    var laidOutSubviews = false
    
    var loadingView:LoaderView!
    var seasonId:Int?
    var showId:Int?
    var episodes:[JSON]?
    var episodesCount:Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.isNavigationBarHidden = false
        loadingView = LoaderView(parentView: view)
        
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
        if #available(iOS 11.0, *) {
            collectionView?.contentInsetAdjustmentBehavior = .never
        }
        showId = KCommonKit.shared.showId
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
        let height: CGFloat = 195
        
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
        loadingView.startAnimating()
        Service.shared.getEpisodesFor(showId, seasonId, withSuccess: { (episodes) in
            if let episodes = episodes {
                self.episodesCount = episodes.episodeCount
                self.episodes = episodes.episodes
            }
            self.collectionView?.reloadData()
        }) { (errorMessage) in
            SCLAlertView().showError("Error getting episodes", subTitle: errorMessage)
        }
        collectionView?.animateFadeIn()
        loadingView.stopAnimating()
    }
    
    //    // MARK: - IBActions
    //
    //    @IBAction func goToPressed(sender: UIBarButtonItem) {
    //
    //        let dataSource = [["First Episode", "Next Episode", "Last Episode"]]
    //
    //        DropDownListViewController.showDropDownListWith(sender: navigationController!.navigationBar, viewController: self, delegate: self, dataSource: dataSource)
    //
    //    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let episodesCount = episodesCount, episodesCount != 0 {
            return episodesCount
        }
        return 0
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let episodeCell = collectionView.dequeueReusableCell(withReuseIdentifier: "EpisodeCell", for: indexPath) as! EpisodeCell
        
        if let episodeScreenshot = episodes?[indexPath.row]["screenshot"].stringValue, episodeScreenshot != "" {
            let screenshotUrl = URL(string: episodeScreenshot)
                let resource = ImageResource(downloadURL: screenshotUrl!)
            
            episodeCell.episodeImageView.kf.setImage(with: resource, placeholder: UIImage(named: "placeholder_episode"), options: [.transition(.fade(0.2))], progressBlock: nil, completionHandler: nil)
        } else {
            episodeCell.episodeImageView.image = UIImage(named: "placeholder_episode")
        }
        
        if let episodeTitle = episodes?[indexPath.row]["name"].stringValue, let episodeNumber = episodes?[indexPath.row]["number"].intValue, episodeTitle != "" {
            episodeCell.episodeTitleLabel.text = "Episode \(episodeNumber): \(episodeTitle)"
        } else {
            episodeCell.episodeTitleLabel.text = "Untitled"
        }
        
        if let episodeFirstAired = episodes?[indexPath.row]["first_aired"].stringValue, episodeFirstAired != "" {
            episodeCell.episodeFirstAiredLabel.text = episodeFirstAired
        } else {
            episodeCell.episodeFirstAiredLabel.text = ""
        }
        
        return episodeCell
    }
}

//extension EpisodesViewController: UICollectionViewDelegate {
//
//    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        let episode = dataSource[indexPath.row]
//        let threadController = KAnimeKit.customThreadViewController()
//        threadController.initWithEpisode(episode, anime: anime)
//        if InAppController.hasAnyPro() == nil {
//            threadController.interstitialPresentationPolicy = .Automatic
//        }
//
//        if let tabBar = tabBarController as? CustomTabBarController {
//            tabBar.disableDragDismiss()
//        }
//
//        navigationController?.pushViewController(threadController, animated: true)
//    }
//}
//
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
//
//extension EpisodesViewController: RateViewControllerProtocol {
//    func rateControllerDidFinishedWith(anime: Anime, rating: Float) {
//        RateViewController.updateAnime(anime, withRating: rating*2.0)
//    }
//}
