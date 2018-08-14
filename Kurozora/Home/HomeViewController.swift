//
//  HomeViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 01/05/2018.
//  Copyright © 2018 Kusa. All rights reserved.
//

import Foundation
import UIKit
import KDatabaseKit
import KCommonKit
import SCLAlertView
import SwiftyJSON

class HomeViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    
    enum HomeSection: Int {
        case TopTVShows, LatestTVEpisodes, CurrentSeason
    }
    
    var itemSize = CGSize(width: 0, height: 0)
    
    @IBOutlet weak var headerViewController: UICollectionView!
//    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var horizontalShelfViewController: UICollectionView!
    @IBOutlet weak var topAnimeHorizontalShelfViewController: UICollectionView!
    @IBOutlet weak var newAnimeEpisodesHorizontalShelfViewController: UICollectionView!
    
    let horizontalShelfCollectionViewIdentifier = "HorizontalShelfCollectionCell"
    let topAnimeShelfCollectionViewIdentifier = "PosterCell"
    let topAnimeEpisodesShelfCollectionViewIdentifier = "topAnimeEpisodesShelfCollectionCell"
    
    var animeArray:[JSON] = []
    
//    fileprivate let sectionInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    
//    let sections: [String] = ["Airing Today", "Current Season", "Explore all anime"]
//    var sectionDetails: [String] = ["", "", "with advanced filters"]
    
//    var airingDataSource: [[Anime]] = [[]] {
//        didSet {
//            tableView.reloadData()
//        }
//    }
//
//    var currentSeasonalChartDataSource: [Anime] = [] {
//        didSet {
//            headerViewController.reloadData()
//            tableView.reloadData()
//        }
//    }
    
//    var exploreAllAnimeDataSource: [Anime] = [] {
//        didSet {
//            tableView.reloadData()
//        }
//    }
//
//    var airingToday: [Anime] {
//        return airingDataSource[0]
//    }
//
    let currentSeasonalChartWithFanart : Array = [["title": "Re:Zero Kara Hajimeru Isekai Seikatsu", "fanart": "colorful.png", "score": "9.99", "genre": "Action, Adventure & Drama"], ["title" : "Naruto", "fanart" : "colorful.png", "score": "9.78", "genre": "Action & Adventure"], ["title" : "One Piece", "fanart" : "colorful.png", "score": "9.89", "genre": "Action & Adventure"], ["title" : "Joey no Pico", "fanart" : "colorful.png", "score": "10.00", "genre": "Gay shit"]]
    
//    let chartsDataSource: [SeasonalChart] = []
    
//    var headerTimer: Timer!
//    var animator: ZFModalTransitionAnimator!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let posterCellNib = UINib.init(nibName: "PosterCell", bundle: nil)
        self.topAnimeHorizontalShelfViewController.register(posterCellNib, forCellWithReuseIdentifier: "PosterCell")
        self.newAnimeEpisodesHorizontalShelfViewController.register(posterCellNib, forCellWithReuseIdentifier: "PosterCell")
        
        horizontalShelfViewController.delegate = self
        topAnimeHorizontalShelfViewController.delegate = self
        newAnimeEpisodesHorizontalShelfViewController.delegate = self
        
        horizontalShelfViewController.dataSource = self
        topAnimeHorizontalShelfViewController.dataSource = self
        newAnimeEpisodesHorizontalShelfViewController.dataSource = self
        
        self.view.addSubview(horizontalShelfViewController)
        self.view.addSubview(topAnimeHorizontalShelfViewController)
        self.view.addSubview(newAnimeEpisodesHorizontalShelfViewController)
        
        let searchController = UISearchController(searchResultsController: nil)
        if #available(iOS 11.0, *) {
            navigationItem.searchController = searchController
        } else {
            // Fallback on earlier versions
        }
        
//        if let layout = horizontalShelfViewController.collectionViewLayout as? UICollectionViewFlowLayout {
//            layout.minimumLineSpacing = 10
//            layout.minimumInteritemSpacing = 10
//        }
//        horizontalShelfViewController.contentInset = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 0)
//        horizontalShelfViewController.isPagingEnabled = false
//        view.layoutIfNeeded()
//
//        let width = horizontalShelfViewController.bounds.size.width-24
//        let height = width * (3/4)
//        itemSize = CGSize(width: width, height: height)
//        view.layoutIfNeeded()
        
        // FIXME: WARNING CHECK THIS OUT
//        TitleHeaderView.registerNibFor(tableView: tableView)
//        TableCellWithCollection.registerNibFor(tableView: tableView)
        
//        fetchCurrentSeasonalChart()
//        fetchAiringToday()
//        fetchExploreAnime()
        
//        sectionDetails[0] = getDayOfWeek()
//        sectionDetails[1] = SeasonalChartService.seasonalChartString(0).title
//        sectionDetails[2] = "with advanced filters"
        
        // Updating tableHeaderView depending on if it is iPad or iPhone
//        var frame = tableView.tableHeaderView!.frame
//        frame.size.height = UIDevice.current.userInterfaceIdiom == .pad ? 250 : 185
//        tableView.tableHeaderView!.frame = frame
//
//        updateHeaderViewControllerLayout(withSize: CGSize(width: view.bounds.width, height: frame.size.height))
    }
    
//    func getDayOfWeek() -> String {
//        let dateFormatter = DateFormatter()
//        let todayDate = NSDate()
//        let weekdayIndex = NSCalendar.current.component(.weekday, from: todayDate as Date) - 1
//        return dateFormatter.weekdaySymbols[weekdayIndex]
//    }
    
    override func viewWillAppear(_ animated: Bool) {
//        headerTimer = Timer.scheduledTimer(timeInterval: 10.0, target: self, selector: #selector(moveHeaderView), userInfo: nil, repeats: true)
        Request.getAnime( withSuccess: { (array) in
            self.animeArray = array
            
            DispatchQueue.main.async() {
                self.topAnimeHorizontalShelfViewController.reloadData()
            }
        }) { (errorMsg) in
            SCLAlertView().showError("Anime", subTitle: errorMsg)
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
//        if let timer = headerTimer {
//            timer.invalidate()
//        }
//        headerTimer = nil
    }
    
//    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
//        let pageWidth = itemSize.width
//        targetContentOffset.pointee = scrollView.contentOffset
//        var factor: CGFloat = 0.5
//
//        if velocity.x < 0 {
//            factor = -factor
//            print("right")
//        } else {
//            print("left")
//        }
//
//        let a:CGFloat = scrollView.contentOffset.x/pageWidth
//        var index = Int( round(a+factor) )
//
//        if index < 0 {
//            index = 0
//        }
//
//        if index > 6 - 1 {
//            index = 6 - 1
//        }
//
////        let indexPath = IndexPath(row: index, section: 0)
////        horizontalShelfCollectionView?.scrollToItem(at: indexPath, at: .left, animated: true)
//    }
    
    // MARK: - UICollectionViewDelegateFlowLayout protocol
//    func collectionView(_ collectionView: UICollectionView,
//                        layout collectionViewLayout: UICollectionViewLayout,
//                        insetForSectionAt section: Int) -> UIEdgeInsets {
//        return sectionInsets
//    }
//
//    func collectionView(_ collectionView: UICollectionView,
//                        layout collectionViewLayout: UICollectionViewLayout,
//                        sizeForItemAt indexPath: IndexPath) -> CGSize {
//        return itemSize
//    }
    
    // MARK: - UICollectionViewDataSource protocol
    
    // My function
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == self.horizontalShelfViewController {
            return 6 // Replace with count of your data for collectionViewA
        }else if collectionView == self.topAnimeHorizontalShelfViewController {
            return animeArray.count
        }

        return animeArray.count // Replace with count of your data for collectionViewB
    }
    
//     make a cell for each cell index path
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if collectionView == self.horizontalShelfViewController {
            // get a reference to our storyboard cell
            let horizontalShelfCollectionCell = collectionView.dequeueReusableCell(withReuseIdentifier: "HorizontalShelfCollectionCell", for: indexPath as IndexPath) as! HorizontalShelfCollectionCell
            
            // Use the outlet in our custom class to get a reference in the cell
            horizontalShelfCollectionCell.titleLabel.text = "ReZero: Kara Hajimeru Isekai Seikatsu"
            horizontalShelfCollectionCell.subtitleLabel.text = "Action - Adventure - Fantasy - Game - Romance"
            horizontalShelfCollectionCell.bannerImageView.image = UIImage(named: "aozora.png")
            horizontalShelfCollectionCell.shadowImageView.image = UIImage(named: "shadow.png")
            
            //        self.collectionView.register(PosterCell.self, forCellWithReuseIdentifier: "PosterCell")
            
            return horizontalShelfCollectionCell
        }
        else if collectionView == self.topAnimeHorizontalShelfViewController {
            // get a reference to our storyboard cell
            let topAnimeShelfCollectionCell = collectionView.dequeueReusableCell(withReuseIdentifier: "PosterCell", for: indexPath as IndexPath) as! PosterCell
            
            // Use the outlet in our custom class to get a reference in the cell
            topAnimeShelfCollectionCell.titleLabel.text = animeArray[indexPath.row]["title"].stringValue
            topAnimeShelfCollectionCell.scoreLabel.text = "9.99"
            topAnimeShelfCollectionCell.genreLabel.text = "Action & Adventure"

            do {
                let url = URL(string: animeArray[indexPath.row]["poster_url"].stringValue)
                let data = try Data(contentsOf: url!)
                topAnimeShelfCollectionCell.imageView.image = UIImage(data: data)
            }
            catch{
                print(error)
            }
            
            return topAnimeShelfCollectionCell
        }
        else {
            // get a reference to our storyboard cell
            let newAnimeEpisodesShelfCollectionCell = collectionView.dequeueReusableCell(withReuseIdentifier: "PosterCell", for: indexPath as IndexPath) as! PosterCell
            
            // Use the outlet in our custom class to get a reference in the cell
            newAnimeEpisodesShelfCollectionCell.titleLabel.text = animeArray[indexPath.row]["title"].stringValue
            newAnimeEpisodesShelfCollectionCell.scoreLabel.text = "9.99"
            newAnimeEpisodesShelfCollectionCell.genreLabel.text = "Action & Adventure"
            
            do {
                let url = URL(string: animeArray[indexPath.row]["poster_url"].stringValue)
                let data = try Data(contentsOf: url!)
                newAnimeEpisodesShelfCollectionCell.imageView.image = UIImage(data: data)
            }
            catch{
                print(error)
            }
            
            return newAnimeEpisodesShelfCollectionCell
        }
    }
    
    // MARK: - UICollectionViewDelegate protocol

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        horizontalShelfViewController.scrollToItem(at: indexPath, at: .left, animated: true)
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {

        defer {
            super.viewWillTransition(to: size, with: coordinator)
        }

//        if !UIDevice.current.userInterfaceIdiom == .pad {
//            return
//        }
//
//        let nextIndexPath = self.headerCellIndexPath(next: false)
//        let headerSize = CGSize(width: size.width, height: self.headerViewController.bounds.size.height)
//
//        coordinator.animate(alongsideTransition: { (context) in
//
//            self.updateHeaderViewControllerLayout(withSize: headerSize)
//            self.headerViewController.collectionViewLayout.invalidateLayout()
//            self.headerViewController.reloadData()
//
//            if let nextIndexPath = nextIndexPath {
//                let rect = CGRect(x: CGFloat(nextIndexPath.row) * headerSize.width, y: 0, width: headerSize.width, height: headerSize.height)
//                self.headerViewController.scrollRectToVisible(rect, animated: false)
//            }
//
//        }) { (context) in
//
//        }
    }
//
//    func updateHeaderViewControllerLayout(withSize: CGSize) {
//        guard let layout = headerViewController.collectionViewLayout as? UICollectionViewFlowLayout else {
//            return
//        }
//        print(withSize)
//        layout.itemSize = withSize
//    }
    
//    func fetchCurrentSeasonalChart() {
//
//        let seasonalChart = SeasonalChartService.seasonalChartString(0).title
//
//        let startDate = NSDate()
//        var seasonsTask: BFTask!
//
//        if currentSeasonalChartDataSource.isEmpty {
//            seasonsTask = ChartController.fetchAllSeasons().continueWithSuccessBlock { (task: BFTask!) -> AnyObject? in
//
//                let result = task.result as! [SeasonalChart]
//                self.chartsDataSource = result
//                let selectedSeasonalChart = result.filter({$0.title == seasonalChart})
//                return BFTask(result: selectedSeasonalChart)
//            }
//        } else {
//            let selectedSeasonalChart = chartsDataSource.filter({$0.title == seasonalChart})
//            seasonsTask = BFTask(result: selectedSeasonalChart)
//        }
//
//        seasonsTask.continueWithSuccessBlock { (task: BFTask!) -> AnyObject? in
//
//            guard let result = task.result as? [SeasonalChart], let selectedSeason = result.last else {
//                return nil
//            }
//            return ChartController.fetchSeasonalChartAnime(selectedSeason)
//
//            }.continueWithExecutor(BFExecutor.mainThreadExecutor(), withBlock: { (task: BFTask!) -> AnyObject? in
//
//                print("Load seasons = \(NSDate().timeIntervalSinceDate(startDate))s")
//                if let result = task.result as? [Anime] {
//                    // Seasonal Chart datasource
//                    self.currentSeasonalChartDataSource = result
//                        .filter({$0.type == "TV"})
//                        .sort({ $0.rank < $1.rank})
//
//                    // Top Banner DataSource
//                    self.currentSeasonalChartWithFanart = self.currentSeasonalChartDataSource
//                        .filter({ $0.fanart != nil })
//
//                    // Shuffle the data
//                    for _ in 0..<10 {
//                        self.currentSeasonalChartWithFanart.sortInPlace { (_,_) in arc4random() < arc4random() }
//                    }
//                }
//
//                return nil
//            })
//    }
    
//    func fetchAiringToday() {
//
//        let query = Anime.query()!
//        query.whereKeyExists("startDateTime")
//        query.whereKey("status", equalTo: "currently airing")
//        query.findObjectsInBackgroundWithBlock({ (result, error) -> Void in
//
//            if let result = result as? [Anime] {
//
//                var animeByWeekday: [[Anime]] = [[],[],[],[],[],[],[]]
//
//                let calendar = NSCalendar.currentCalendar()
//                let unitFlags: NSCalendarUnit = .Weekday
//
//                for anime in result {
//                    let startDateTime = anime.nextEpisodeDate ?? NSDate()
//                    let dateComponents = calendar.components(unitFlags, fromDate: startDateTime)
//                    let weekday = dateComponents.weekday-1
//                    animeByWeekday[weekday].append(anime)
//
//                }
//
//                var todayWeekday = calendar.components(unitFlags, fromDate: NSDate()).weekday - 1
//                while (todayWeekday > 0) {
//                    let currentFirstWeekdays = animeByWeekday[0]
//                    animeByWeekday.removeAtIndex(0)
//                    animeByWeekday.append(currentFirstWeekdays)
//                    todayWeekday -= 1
//                }
//
//                self.airingDataSource = animeByWeekday
//            }
//
//        })
//
//    }
    
//    func fetchExploreAnime() {
//        // Fetch
//        let browseTypes: [BrowseType] = [.TopAnime, .TopUpcoming, .TopTVSeries, .TopMovies, .MostPopular]
//        let selectedBrowseType = Int(arc4random() % 5)
//
//        let query = BrowseViewController.queryForBrowseType(browseTypes[selectedBrowseType])
//
//        query.findObjectsInBackgroundWithBlock { (result, error) in
//            guard let animeList = result as? [Anime] else {
//                return
//            }
//
//            self.exploreAllAnimeDataSource = animeList
//        }
//    }
    
//    @objc func moveHeaderView(timer: Timer) {
//        if let nextIndexPath = headerCellIndexPath(next: true) {
//            headerViewController.scrollToItem(at: nextIndexPath as IndexPath, at: .centeredHorizontally, animated: true)
//        }
//    }
    
//    func headerCellIndexPath(next: Bool) -> NSIndexPath? {
//        let lastIndex = airingToday.count - 1
//
//        guard let visibleCellIdx = headerViewController.indexPathsForVisibleItems.last, lastIndex > 0 else {
//            return nil
//        }
//
//        if !next {
//            return visibleCellIdx as NSIndexPath
//        }
//
//        let nextCellIndexPath: NSIndexPath!
//
//        if visibleCellIdx.row == lastIndex {
//            nextCellIndexPath = NSIndexPath(row: 0, section: 0)
//        } else {
//            nextCellIndexPath = NSIndexPath(row: visibleCellIdx.row + 1, section: 0)
//        }
//        return nextCellIndexPath
//    }
    
    // MARK: - IBActions
    
//    @IBAction func searchPressed(sender: AnyObject) {
//        if let tabBar = tabBarController {
//            tabBar.presentSearchViewController(.MyLibrary)
//        }
//    }
}

//private extension HomeViewController {
//    func showCalendar() {
//        guard let _ = InAppController.hasAnyPro() else {
//            InAppPurchaseViewController.showInAppPurchaseWith(self)
//            return
//        }
//
//        let controller = UIStoryboard(name: "Season", bundle: nil).instantiateViewControllerWithIdentifier("Calendar") as! CalendarViewController
//        navigationController?.pushViewController(controller, animated: true)
//    }
//
//    func showSeasonalCharts() {
//        let seasons = UIStoryboard(name: "Season", bundle: nil).instantiateViewController(withIdentifier: "ChartViewController")
//        navigationController?.pushViewController(seasons, animated: true)
//    }
//
//    func showBrowse() {
//        guard let browse = UIStoryboard(name: "Browse", bundle: nil).instantiateViewController(withIdentifier: "Browse") as? BrowseViewController else {
//            return
//        }
//        navigationController?.pushViewController(browse, animated: true)
//    }
//}

// MARK: TableCellWithCollection

//extension HomeViewController: UITableViewDataSource, UITableViewDelegate {
//
//    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
//        return 1
//    }
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return 1
//    }
//
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        guard let cell = tableView.dequeueReusableCell(withIdentifier: "TableCellWithCollection") as? TableCellWithCollection else {
//            return UITableViewCell()
//        }
//
//        switch HomeSection(rawValue: indexPath.section)! {
//        case .TopTVShows: break
////            cell.dataSource = airingToday
//        case .LatestTVEpisodes: break
////            cell.dataSource = currentSeasonalChartDataSource
//        case .CurrentSeason: break
////            cell.dataSource = exploreAllAnimeDataSource
//        }
//
//        cell.collectionView.reloadData()
//
//        return cell
//    }
//
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//
//    }
//
//    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
//        guard let cell = tableView.dequeueReusableCell(withIdentifier: "TitleHeaderView") as? TitleHeaderView else {
//            return UIView()
//        }
//        cell.titleLabel.text = "Top TV Shows"
//        cell.section = 1
//
//        switch HomeSection(rawValue: section)! {
//        case .TopTVShows:
//            cell.actionButton.setTitle("Top TV Shows", for: .normal)
//        case .LatestTVEpisodes:
//            cell.actionButton.setTitle("Latest TV Episodes", for: .normal)
//        case .CurrentSeason:
//            cell.actionButton.setTitle("Current Season", for: .normal)
//        }
//
//        cell.actionButton.setTitle("Top TV Shows", for: .normal)
//
//        cell.actionButtonCallback = { section in
//            switch HomeSection(rawValue: section)! {
//            case .TopTVShows: break
////                self.showCalendar()
//            case .LatestTVEpisodes: break
////                self.showSeasonalCharts()
//            case .CurrentSeason: break
////                self.showBrowse()
//            }
//        }
//
//        return cell
//    }
//
//    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
//        return 40
//    }
//}

// MARK: - HeaderViewController DataSource, Delegate

//extension HomeViewController {
//    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        return 4
//    }
//
//    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//
//        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PosterCell", for: indexPath) as? PosterCell else {
//            return UICollectionViewCell()
//        }
//
//        let anime = currentSeasonalChartWithFanart[indexPath.row]
//
//        if let fanart = anime["fanart"] {
//            cell.imageView.image = UIImage(named: fanart)
//        }
//
//        cell.titleLabel.text = anime["title"] ?? ""
//        cell.scoreLabel.text = anime["score"] ?? ""
//        cell.genreLabel.text = anime["genre"] ?? ""
//
//        return cell
//    }
//
//    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//
//    }
//}
