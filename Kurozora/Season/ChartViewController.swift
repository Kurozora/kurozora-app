//
//  ChartViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 08/05/2018.
//  Copyright © 2018 Kurozora. All rights reserved.
//

import KCommonKit

class ChartViewController: UIViewController {
//    enum SelectedList: Int {
//        case SeasonalChart = 0
//        case AllSeasons
//    }
//
//    let SortTypeDefault = "Season.SortType"
//    let LayoutTypeDefault = "Season.LayoutType"
//    let FirstHeaderCellHeight: CGFloat = 88.0
//    let HeaderCellHeight: CGFloat = 44.0
//
//    var canFadeImages = true
//    var showTableView = true
//
//    var currentSeasonalChartName = SeasonalChartService.seasonalChartString(0).title
//
//    var currentConfiguration: Configuration!
//
//    var orders: [SortType] = []
//    var viewTypes: [LayoutType] = []
//    var selectedList: SelectedList = .SeasonalChart {
//        didSet {
//            filterBar.isHidden = selectedList == .AllSeasons
//        }
//    }
//
//
//    var timer: Timer!
//    var animator: ZFModalTransitionAnimator!
//
//    var dataSource: [[Anime]] = [] {
//        didSet {
//            filteredDataSource = dataSource
//        }
//    }
//
//    var filteredDataSource: [[Anime]] = [] {
//        didSet {
//            canFadeImages = false
//            self.collectionView.reloadData()
//            canFadeImages = true
//        }
//    }
//
//    var chartsDataSource: [SeasonalChart] = [] {
//        didSet {
//            self.collectionView.reloadData()
//        }
//    }
//
//    var currentSortType: SortType {
//        get {
//            guard let sortType = UserDefaults.standard.object(forKey: SortTypeDefault) as? String,
//                let sortTypeEnum = SortType(rawValue: sortType) else {
//                    return SortType.Popularity
//            }
//            return sortTypeEnum
//        }
//        set ( value ) {
//            UserDefaults.standard.set(value.rawValue, forKey: SortTypeDefault)
//            UserDefaults.standard.synchronize()
//        }
//    }
//
//    var currentLayoutType: LayoutType {
//        get {
//            guard let layoutType = UserDefaults.standard.object(forKey: LayoutTypeDefault) as? String,
//                let layoutTypeEnum = LayoutType(rawValue: layoutType) else {
//                    return LayoutType.Chart
//            }
//            return layoutTypeEnum
//        }
//        set ( value ) {
//            UserDefaults.standard.set(value.rawValue, forKey: LayoutTypeDefault)
//            UserDefaults.standard.synchronize()
//        }
//    }
//
//    var loadingView: LoaderView!
//
//    @IBOutlet weak var collectionView: UICollectionView!
//    @IBOutlet weak var searchBar: UISearchBar!
//    @IBOutlet weak var navigationBarTitle: UILabel!
//    @IBOutlet weak var filterBar: UIView!
//    @IBOutlet weak var navigationItemView: UIView!
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//
//        DialogController.sharedInstance.canShowFBAppInvite(self)
//
//        AnimeCell.registerNibFor(collectionView: collectionView)
//
//        // Layout and sort
//        orders = [currentSortType, .None]
//        viewTypes = [currentLayoutType, .SeasonalChart]
//
//        // Update configuration
//        currentConfiguration = [
//            (FilterSection.View, currentLayoutType.rawValue, [LayoutType.Chart.rawValue]),
//            (FilterSection.Sort, currentSortType.rawValue, [SortType.Rating.rawValue, SortType.Popularity.rawValue, SortType.Title.rawValue, SortType.NextAiringEpisode.rawValue])
//        ]
//
//        collectionView.alpha = 0.0
//
//        timer = Timer.scheduledTimer(timeInterval: 60.0, target: self, selector: #selector(updateETACells), userInfo: nil, repeats: true)
//
//        loadingView = LoaderView(parentView: view)
//
//        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(changeSeasonalChart))
//        navigationItemView.addGestureRecognizer(tapGestureRecognizer)
//
//        prepareForList(selectedList: selectedList)
//
//        NotificationCenter.defaultCenter().addObserver(self, selector: "updateETACells", name: LibraryUpdatedNotification, object: nil)
//    }
//
//    deinit {
//        NotificationCenter.default.removeObserver(self)
//    }
//
//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//
//        if loadingView.animating == false {
//            loadingView.stopAnimating()
//            collectionView.animateFadeIn()
//        }
//
//    }
//
//    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
//        super.viewWillTransitionToSize(size, withTransitionCoordinator: coordinator)
//
//        if selectedList == .AllSeasons {
//            updateLayoutType(layoutType: .SeasonalChart, withSize: size)
//        } else {
//            updateLayoutType(layoutType: currentLayoutType, withSize: size)
//        }
//    }
//
//    // MARK: - UI Functions
//
//    @objc func updateETACells() {
//        canFadeImages = false
//        let indexPaths = collectionView.indexPathsForVisibleItems()
//        collectionView.reloadItemsAtIndexPaths(indexPaths)
//        canFadeImages = true
//    }
//
//    func prepareForList(selectedList: SelectedList) {
//
//        self.selectedList = selectedList
//
//        switch selectedList {
//        case .SeasonalChart:
//            collectionView.animateFadeOut()
//            loadingView.startAnimating()
//            navigationBarTitle.text = currentSeasonalChartName
//            fetchSeasonalChart(seasonalChart: currentSeasonalChartName)
//        case .AllSeasons:
//            navigationBarTitle.text = "All Seasons"
//            collectionView.reloadData()
//        }
//
//        navigationBarTitle.text! += " " + FontAwesome.AngleDown.rawValue
//
//        if selectedList == SelectedList.AllSeasons {
//            updateLayoutType(layoutType: .SeasonalChart, withSize: view.bounds.size)
//        } else {
//            updateLayoutType(layoutType: currentLayoutType, withSize: view.bounds.size)
//        }
//    }
//
//    func fetchAllSeasons() -> BFTask {
//        return ChartController.fetchAllSeasons()
//    }
//
//    func fetchSeasonalChart(seasonalChart: String) {
//
//        let startDate = NSDate()
//        var seasonsTask: BFTask!
//
//        if chartsDataSource.isEmpty {
//            seasonsTask = fetchAllSeasons().continueWithSuccessBlock { (task: BFTask!) -> AnyObject! in
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
//        seasonsTask.continueWithSuccessBlock { (task: BFTask!) -> AnyObject! in
//
//            guard let result = task.result as? [SeasonalChart], let selectedSeason = result.last else {
//                return nil
//            }
//            return ChartController.fetchSeasonalChartAnime(selectedSeason)
//
//            }.continueWithSuccessBlock { (task: BFTask!) -> AnyObject! in
//
//                guard let result = task.result as? [Anime] else {
//                    return nil
//                }
//                LibrarySyncController.matchAnimeWithProgress(result)
//                return BFTask(result: result)
//
//            }.continueWithExecutor(BFExecutor.mainThreadExecutor(), withBlock: { (task: BFTask!) -> AnyObject! in
//
//                print("Load seasons = \(NSDate().timeIntervalSinceDate(startDate))s")
//                if let result = task.result as? [Anime] {
//                    let tvAnime = result.filter({$0.type == "TV"})
//                    let tv = tvAnime.filter({$0.duration == 0 || $0.duration > 15})
//                    let tvShort = tvAnime.filter({$0.duration > 0 && $0.duration <= 15})
//                    let movieAnime = result.filter({$0.type == "Movie"})
//                    let ovaAnime = result.filter({$0.type == "OVA"})
//                    let onaAnime = result.filter({$0.type == "ONA"})
//                    let specialAnime = result.filter({$0.type == "Special"})
//
//                    self.dataSource = [tv, tvShort, movieAnime, ovaAnime, onaAnime, specialAnime]
//                    self.updateSortType(self.currentSortType)
//                }
//
//                self.loadingView.stopAnimating()
//                self.collectionView.animateFadeIn()
//                return nil
//            })
//    }
//
//
//
//    // MARK: - Utility Functions
//
//    func updateSortType(sortType: SortType) {
//
//        currentSortType = sortType
//
//        dataSource = dataSource.map() { (animeArray) -> [Anime] in
//            switch self.currentSortType {
//            case .Rating:
//                animeArray.sortInPlace({ $0.rank < $1.rank && $0.rank != 0 })
//            case .Popularity:
//                animeArray.sortInPlace({ $0.popularityRank < $1.popularityRank})
//            case .Title:
//                animeArray.sortInPlace({ $0.title < $1.title})
//            case .NextAiringEpisode:
//                animeArray.sortInPlace({ (anime1: Anime, anime2: Anime) in
//
//                    let startDate1 = anime1.nextEpisodeDate ?? NSDate(timeIntervalSinceNow: 60*60*24*100)
//                    let startDate2 = anime2.nextEpisodeDate ?? NSDate(timeIntervalSinceNow: 60*60*24*100)
//                    return startDate1.compare(startDate2) == .OrderedAscending
//                })
//            default:
//                break;
//            }
//            return animeArray
//        }
//
//        // Filter
//        searchBar(searchBar, textDidChange: searchBar.text!)
//    }
//
//    func updateLayoutType(layoutType: LayoutType, withSize viewSize: CGSize) {
//
//        if selectedList != SelectedList.AllSeasons {
//            currentLayoutType = layoutType
//        }
//
//        guard let collectionView = collectionView,
//            let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout else {
//                return
//        }
//
//        switch layoutType {
//        case .Chart:
//            AnimeCell.updateLayoutItemSizeWithLayout(layout: layout, viewSize: viewSize)
//        case .SeasonalChart:
//            let lineSpacing: CGFloat = 1
//            let columns: CGFloat = UIDevice.isLandscape() ? 3 : 2
//            let cellHeight: CGFloat = 36
//            var cellWidth: CGFloat = 0
//            layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
//            layout.minimumLineSpacing = CGFloat(lineSpacing)
//
//            if UIDevice.isPad {
//                cellWidth = viewSize.width / columns - columns * lineSpacing
//            } else {
//                cellWidth = viewSize.width
//            }
//            layout.itemSize = CGSize(width: cellWidth, height: cellHeight)
//        }
//
//        canFadeImages = false
//        collectionView.collectionViewLayout.invalidateLayout()
//        collectionView.reloadData()
//        canFadeImages = true
//    }
//
//    // MARK: - IBActions
//
//    @IBAction func showFilterPressed(sender: AnyObject) {
//
//        if let tabBar = tabBarController {
//            let controller = UIStoryboard(name: "Browse", bundle: nil).instantiateViewController(withIdentifier: "Filter") as! FilterViewController
//
//            controller.delegate = self
//            controller.initWith(configuration: currentConfiguration)
//            animator = tabBar.presentViewControllerModal(controller: controller)
//        }
//
//    }
//
//    @objc func changeSeasonalChart() {
//        if let sender = navigationController?.navigationBar,
//            let viewController = tabBarController {
//
//            var titlesDataSource: [String] = []
//            var iconsDataSource: [String] = []
//
//            for index in -1...2 {
//                let (iconName, title) = SeasonalChartService.seasonalChartString(index)
//                titlesDataSource.append(title)
//                iconsDataSource.append(iconName)
//            }
//
//            let dataSource = [titlesDataSource,["All Seasons"]]
//            let imageDataSource = [iconsDataSource,["icon-archived"]]
//
//            DropDownListViewController.showDropDownListWith(sender: sender, viewController: viewController, delegate: self, dataSource: dataSource, imageDataSource: imageDataSource)
//        }
//    }
//
//    @IBAction func showCalendarPressed(sender: AnyObject) {
//
//        if let _ = InAppController.hasAnyPro() {
//
//            let controller = UIStoryboard(name: "season", bundle: nil).instantiateViewControllerWithIdentifier("Calendar") as! CalendarViewController
//            presentViewController(controller, animated: true, completion: nil)
//
//        } else {
//            InAppPurchaseViewController.showInAppPurchaseWith(self)
//        }
//
//    }
}

//extension ChartViewController: UICollectionViewDataSource {

//    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
//        if selectedList == SelectedList.AllSeasons {
//            return 1
//        } else {
//            return filteredDataSource.count
//        }
//
//    }
//    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        if selectedList == SelectedList.AllSeasons {
//            return chartsDataSource.count
//        } else {
//            return filteredDataSource[section].count
//        }
//    }
//
//    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//
//        guard selectedList != SelectedList.AllSeasons else {
//            let reuseIdentifier = "SeasonCell";
//            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! BasicCollectionCell
//            let seasonalChart = chartsDataSource[indexPath.row]
//            cell.titleLabel.text = seasonalChart.title
//            cell.layoutIfNeeded()
//            return cell
//        }
//
//        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: AnimeCell.id, for: indexPath) as! AnimeCell
//        let anime = filteredDataSource[indexPath.section][indexPath.row]
//        cell.configureWithAnime(anime, canFadeImages: canFadeImages, showEtaAsAired: false)
//        cell.layoutIfNeeded()
//        return cell
//    }
//
//    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
//
//        var reusableView: UICollectionReusableView!
//
//        if kind == UICollectionElementKindSectionHeader {
//
//            let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "HeaderView", for: indexPath as IndexPath) as! BasicCollectionReusableView
//
//            var title = ""
//            switch indexPath.section {
//            case 0: title = "TV"
//            case 1: title = "TV Short"
//            case 2: title = "Movie"
//            case 3: title = "OVA"
//            case 4: title = "ONA"
//            case 5: title = "Special"
//            default: break
//            }
//
//            headerView.titleLabel.text = title
//
//
//            reusableView = headerView;
//        }
//
//        return reusableView
//    }
//
//    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
//
//        if filteredDataSource[section].count == 0
//            || selectedList == SelectedList.AllSeasons {
//            return CGSizeZero
//        } else {
//            let height = (section == 0) ? FirstHeaderCellHeight : HeaderCellHeight
//            return CGSize(width: view.bounds.size.width, height: height)
//        }
//    }
//
//}
//
//extension ChartViewController: UICollectionViewDelegate {
//    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//
//        view.endEditing(true)
//
//        if selectedList != SelectedList.AllSeasons {
//            let anime = filteredDataSource[indexPath.section][indexPath.row]
//            animator = presentAnimeModal(anime)
//        }
//
//        if selectedList == SelectedList.AllSeasons {
//            let seasonalChart = chartsDataSource[indexPath.row]
//            currentSeasonalChartName = seasonalChart.title
//            prepareForList(selectedList: .SeasonalChart)
//        }
//    }
//}
//
//extension ChartViewController: DropDownListDelegate {
//    func selectedAction(sender trigger: UIView, action: String, indexPath: IndexPath) {
//
//        if let _ = InAppController.hasAnyPro() {
//
//            if trigger.isEqual(navigationController?.navigationBar) {
//                switch (indexPath.row, indexPath.section) {
//                case (_, 0):
//                    currentSeasonalChartName = action
//                    prepareForList(selectedList: .SeasonalChart)
//                case (0,1):
//                    prepareForList(selectedList: .AllSeasons)
//                default: break
//                }
//
//            }
//
//        }
//
//    }
//
//    func dropDownDidDismissed(selectedAction: Bool) {
//        if selectedAction && InAppController.hasAnyPro() == nil {
//            InAppPurchaseViewController.showInAppPurchaseWith(self)
//        }
//
//    }
//}
//
//extension ChartViewController: UISearchBarDelegate {
//
//    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
//
//        if searchBar.text == "" {
//            filteredDataSource = dataSource
//            return
//        }
//
//        filteredDataSource = dataSource.map { ( animeTypeArray) -> [Anime] in
//            func filterText(anime: Anime) -> Bool {
//                return (anime.title!.rangeOfString(searchBar.text!) != nil) ||
//                    (anime.genres.joinWithSeparator(" ").rangeOfString(searchBar.text!) != nil)
//
//            }
//            return animeTypeArray.filter(filterText)
//        }
//
//    }
//}
//
//extension ChartViewController: FilterViewControllerDelegate {
//    func finishedWith(configuration: Configuration, selectedGenres: [String]) {
//
//        currentConfiguration = configuration
//
//        for (filterSection, value, _) in configuration {
//            if let value = value {
//                switch filterSection {
//                case .Sort:
//                    updateSortType(sortType: SortType(rawValue: value)!)
//                case .View:
//                    updateLayoutType(layoutType: LayoutType(rawValue: value)!, withSize: view.bounds.size)
//                default: break
//                }
//            }
//        }
//
//    }
//
//}
