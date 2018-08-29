//
//  EpisodeViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 13/05/2018.
//  Copyright © 2018 Kusa. All rights reserved.
//

import KCommonKit
import KDatabaseKit
//import Bolts

extension EpisodesViewController: StatusBarVisibilityProtocol {
    func shouldHideStatusBar() -> Bool {
        return false
    }
    func updateCanHideStatusBar(canHide: Bool) {
    }
}

class EpisodesViewController: AnimeBaseViewController {
//
//    var canFadeImages = true
//    var laidOutSubviews = false
//    var dataSource: [Episode] = [] {
//        didSet {
//            collectionView.reloadData()
//        }
//    }
//
//    var loadingView: LoaderView!
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        loadingView = LoaderView(parentView: view)
//
//        fetchEpisodes()
//
//    }
//
//    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
//        super.viewWillTransition(to: size, with: coordinator)
//
//        updateLayoutWithSize(viewSize: size)
//    }
//
//
//    override func viewDidLayoutSubviews() {
//        super.viewDidLayoutSubviews()
//
//        if !laidOutSubviews {
//            laidOutSubviews = true
//            updateLayoutWithSize(viewSize: view.bounds.size)
//        }
//
//    }
//
//    func updateLayoutWithSize(viewSize: CGSize) {
//
//        let height: CGFloat = 195
//
//        guard let collectionView = collectionView,
//            let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout else {
//                return
//        }
//
//        var size: CGSize?
//        var inset: CGFloat = 0
//        var lineSpacing: CGFloat = 0
//
//        if UIDevice.isPad() {
//            inset = 4
//            lineSpacing = 4
//            let columns: CGFloat = UIDevice.isLandscape() ? 3 : 2
//            let totalWidth: CGFloat = viewSize.width - (inset * (columns + 1))
//            size = CGSize(width: totalWidth / columns, height: height)
//        } else {
//            inset = 10
//            lineSpacing = 10
//            size = CGSize(width: viewSize.width - inset * 2, height: height)
//        }
//        layout.sectionInset = UIEdgeInsets(top: inset, left: inset, bottom: inset, right: inset)
//        layout.minimumLineSpacing = lineSpacing
//        layout.minimumInteritemSpacing = lineSpacing
//
//        layout.itemSize = size!
//        layout.invalidateLayout()
//    }
//
//    func fetchEpisodes() {
//
//        loadingView.startAnimating()
//
//        anime.episodeList().continueWithExecutor(BFExecutor.mainThreadExecutor(), withSuccessBlock: { (task: BFTask!) -> AnyObject? in
//
//            self.dataSource = task.result as! [Episode]
//            self.collectionView.animateFadeIn()
//            self.loadingView.stopAnimating()
//
//            return nil
//        })
//    }
//
//    // MARK: - IBActions
//
//    @IBAction func goToPressed(sender: UIBarButtonItem) {
//
//        let dataSource = [["First Episode", "Next Episode", "Last Episode"]]
//
//        DropDownListViewController.showDropDownListWith(sender: navigationController!.navigationBar, viewController: self, delegate: self, dataSource: dataSource)
//
//    }
//}
//
//
//extension EpisodesViewController: UICollectionViewDataSource {
//    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        return dataSource.count
//    }
//
//    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "EpisodeCell", for: indexPath) as! EpisodeCell
//
//        let episode = dataSource[indexPath.row]
//
//        cell.delegate = self
//
//        var watchStatus: EpisodeCell.WatchStatus = .Disabled
//
//        if let progress = anime.progress {
//            if progress.watchedEpisodes < indexPath.row + 1 {
//                watchStatus = .NotWatched
//            } else {
//                watchStatus = .Watched
//            }
//        }
//
//        cell.configureCellWithEpisode(episode, watchStatus: watchStatus)
//
//        return cell
//    }
//
//}
//
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
}
