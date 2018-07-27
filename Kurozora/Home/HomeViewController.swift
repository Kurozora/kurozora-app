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
//import iAd

class HomeViewController: UIViewController {
    
    enum HomeSection: Int {
        case AiringToday, CurrentSeason, ExploreAll
    }
    
    @IBOutlet weak var headerViewController: UICollectionView!
    @IBOutlet weak var tableView: UITableView!
    
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
//    let currentSeasonalChartWithFanart: [Anime] = []
//
//    let chartsDataSource: [SeasonalChart] = []
    
//    var headerTimer: Timer!
//    var animator: ZFModalTransitionAnimator!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        
//        updateHeaderViewControllerLayout(withSize: CGSize(width: view.bounds.width, height: frame.size.height))
    }
    
//    func getDayOfWeek() -> String {
//        let dateFormatter = DateFormatter()
//        let todayDate = NSDate()
//        let weekdayIndex = NSCalendar.current.component(.weekday, from: todayDate as Date) - 1
//        return dateFormatter.weekdaySymbols[weekdayIndex]
//    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
//        headerTimer = Timer.scheduledTimer(timeInterval: 10.0, target: self, selector: #selector(moveHeaderView), userInfo: nil, repeats: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
//        if let timer = headerTimer {
//            timer.invalidate()
//        }
//        headerTimer = nil
    }
    
//    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
//
//        defer {
//            super.viewWillTransition(to: size, with: coordinator)
//        }
//
//        if !UIDevice.current.userInterfaceIdiom == .pad {
//            return
//        }
        
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
//    }
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

//extension HomeViewController: UITableViewDataSource, UITableViewDelegate {
//
//    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
//        return sections.count
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
//        case .AiringToday:
//            cell.dataSource = airingToday
//        case .CurrentSeason:
//            cell.dataSource = currentSeasonalChartDataSource
//        case .ExploreAll:
//            cell.dataSource = exploreAllAnimeDataSource
//        }
//
//        cell.selectedAnimeCallBack = { anime in
//            self.animator = self.presentAnimeModal(anime)
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
//        cell.titleLabel.text = sections[section]
//        cell.subtitleLabel.text = sectionDetails[section]
//        cell.section = section
//
//        switch HomeSection(rawValue: section)! {
//        case .AiringToday:
//            cell.actionButton.setTitle("Calendar", for: .normal)
//        case .CurrentSeason:
//            cell.actionButton.setTitle("Seasons", for: .normal)
//        case .ExploreAll:
//            cell.actionButton.setTitle("Discover", for: .normal)
//        }
        
//        cell.actionButtonCallback = { section in
//            switch HomeSection(rawValue: section)! {
//            case .AiringToday:
//                self.showCalendar()
//            case .CurrentSeason:
//                self.showSeasonalCharts()
//            case .ExploreAll:
//                self.showBrowse()
//            }
//        }
        
//        return cell
//    }
//
//    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
//        return 40
//    }
//}

// MARK: - HeaderViewController DataSource, Delegate

//extension HomeViewController: UICollectionViewDataSource, UICollectionViewDelegate {
//    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        return currentSeasonalChartWithFanart.count
//    }
//
//    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//
//        guard let cell = collectionView.dequeueReusableCellWithReuseIdentifier("BasicCollectionCell", forIndexPath: indexPath) as? BasicCollectionCell else {
//            return UICollectionViewCell()
//        }
//
//        let anime = currentSeasonalChartWithFanart[indexPath.row]
//
//        if let fanart = anime.fanart {
//            cell.titleimageView.setImageFrom(urlString: fanart)
//        }
//
//        AnimeCell.updateInformationLabel(anime, informationLabel: cell.subtitleLabel)
//        cell.titleLabel.text = anime.title ?? ""
//
//        return cell
//    }
//
//    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        let anime = currentSeasonalChartWithFanart[indexPath.row]
//        animator = presentAnimeModal(anime)
//    }
//}
