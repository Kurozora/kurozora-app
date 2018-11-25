//
//  DayViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 08/05/2018.
//  Copyright © 2018 Kusa. All rights reserved.
//

import KDatabaseKit
import Alamofire
import KCommonKit

class DayViewController: UIViewController {
//
//    var animator: ZFModalTransitionAnimator!
//    var dayString: String = ""
//    var dataSource: [Anime] = []
//    var section: Int = 0
//
//    @IBOutlet weak var collectionView: UICollectionView!
//
//    func initWithTitle(title: String, section: Int) {
//        dayString = title
//        self.section = section
//    }
//
//    func updateDataSource(dataSource: [Anime]) {
//
//        self.dataSource = dataSource
//        self.sort()
//        if self.isViewLoaded {
//            self.collectionView.reloadData()
//            self.collectionView.animateFadeIn()
//        }
//    }
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//
//        AnimeCell.registerNibFor(collectionView: collectionView)
//
//        updateLayout(withSize: view.bounds.size)
//    }
//
//
//
//    // MARK: - Utility Functions
//
//    func sort() {
//
//        dataSource.sortInPlace({ (anime1: Anime, anime2: Anime) in
//
//            let startDate1 = anime1.nextEpisodeDate ?? NSDate(timeIntervalSinceNow: 60*60*24*100)
//            let startDate2 = anime2.nextEpisodeDate ?? NSDate(timeIntervalSinceNow: 60*60*24*100)
//            return startDate1.compare(startDate2) == .OrderedAscending
//        })
//    }
//
//    func updateLayout(withSize viewSize: CGSize) {
//
//        guard let collectionView = collectionView,
//            let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout else {
//                return
//        }
//
//        AnimeCell.updateLayoutItemSizeWithLayout(layout: layout, viewSize: viewSize)
//    }
//
//}
//
//
//extension DayViewController: UICollectionViewDataSource {
//
//    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        return dataSource.count
//    }
//
//    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//
//        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: AnimeCell.id, for: indexPath) as! AnimeCell
//
//        let anime = dataSource[indexPath.row]
//
//        let nextDate = anime.nextEpisodeDate ?? NSDate(timeIntervalSinceNow: 60*60*24*100)
//        let showEtaAsAired = nextDate.timeIntervalSinceNow > 60*60*24 && section == 0
//
//        cell.configureWithAnime(anime, canFadeImages: true, showEtaAsAired: showEtaAsAired)
//        cell.layoutIfNeeded()
//        return cell
//    }
//
//
//    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
//        return CGSize(width: view.bounds.size.width, height: 0.0)
//    }
//
//}
//
//extension DayViewController: UICollectionViewDelegate {
//    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//
//        let anime = dataSource[indexPath.row]
//        animator = presentAnimeModal(anime: anime)
//    }
//}
//
//extension DayViewController: LibraryAnimeCellDelegate {
//    func cellPressedWatched(cell: LibraryAnimeCell, anime: Anime) {
//        if let _ = anime.progress,
//            let indexPath = collectionView.indexPath(for: cell) {
//
//            collectionView.reloadItems(at: [indexPath])
//        }
//    }
//
//    func cellPressedEpisodeThread(cell: LibraryAnimeCell, anime: Anime, episode: Episode) {
//        let threadController = KAnimeKit.customThreadViewController()
//        threadController.initWithEpisode(episode: episode, anime: anime)
//
//        if InAppController.hasAnyPro() == nil {
//            threadController.interstitialPresentationPolicy = .Automatic
//        }
//
//        navigationController?.pushViewController(threadController, animated: true)
//    }
//}
//
//extension DayViewController: PagerTabStripChildItem {
//    func titleForPagerTabStripViewController(pagerTabStripViewController: PagerTabStripViewController!) -> String! {
//        return dayString
//    }
//
//    func colorForPagerTabStripViewController(pagerTabStripViewController: PagerTabStripViewController!) -> UIColor! {
//        return UIColor.white
//    }
}
