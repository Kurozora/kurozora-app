//
//  BrowseViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 25/04/2018.
//  Copyright © 2018 Kurozora. All rights reserved.
//

import KCommonKit
import UIKit
//import ANParseKit

enum BrowseType: String {
    case topAnime = "Top Anime"
    case topAiring = "Top Airing"
    case topUpcoming = "Top Upcoming"
    case topTVSeries = "Top TV Series"
    case topMovies = "Top Movies"
    case topOVA = "Top OVA"
    case topSpecials = "Top Specials"
    case justAdded = "Just Added"
    case mostPopular = "Most Popular"
    case filtering = "Advanced Search"

    static func allItems() -> [String] {
        return [
            BrowseType.topAnime.rawValue,
            BrowseType.topAiring.rawValue,
            BrowseType.topUpcoming.rawValue,
            BrowseType.topTVSeries.rawValue,
            BrowseType.topMovies.rawValue,
            BrowseType.topOVA.rawValue,
            BrowseType.topSpecials.rawValue,
            BrowseType.justAdded.rawValue,
            BrowseType.mostPopular.rawValue
        ]
    }
}

class BrowseViewController: UIViewController {
    //    var currentBrowseType: BrowseType = .TopAnime
    //    var animator: ZFModalTransitionAnimator!
    ////    var loadingView: LoaderView!
    //    var currentConfiguration: Configuration =
    //        [
    //            (FilterSection.Sort, SortType.Rating.rawValue, [SortType.Rating.rawValue, SortType.Popularity.rawValue, SortType.Title.rawValue, SortType.Newest.rawValue, SortType.Oldest.rawValue]),
    //            (FilterSection.FilterTitle, nil, []),
    //            (FilterSection.AnimeType, nil, AnimeType.allRawValues()),
    //            (FilterSection.Year, nil, allYears),
    //            (FilterSection.Status, nil, AnimeStatus.allRawValues()),
    //            (FilterSection.Studio, nil, allStudios.sort({$0.localizedCaseInsensitiveCompare($1) == NSComparisonResult.OrderedAscending})),
    //            (FilterSection.Classification, nil, AnimeClassification.allRawValues()),
    //            (FilterSection.Genres, nil, AnimeGenre.allRawValues())
    //    ]
    //    var selectedGenres: [String] = []
    //    var fetchController = FetchController()
    //
    //    @IBOutlet weak var navigationBarTitle: UILabel!
    //    @IBOutlet weak var collectionView: UICollectionView!
    //    @IBOutlet weak var navigationBarTitleView: UIView!
    //
    //    override func viewDidLoad() {
    //        super.viewDidLoad()
    //
    //        AnimeCell.registerNibFor(collectionView: collectionView)
    //
    //        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: "changeSeasonalChart")
    //        navigationBarTitleView.addGestureRecognizer(tapGestureRecognizer)
    //
    //        loadingView = LoaderView(parentView: view)
    //
    //        fetchListType(currentBrowseType)
    //        updateLayout(withSize: view.bounds.size)
    //
    //        NotificationCenter.defaultCenter().addObserver(self, selector: "updateETACells", name: LibraryUpdatedNotification, object: nil)
    //
    //        navigationController?.setNavigationBarHidden(false, animated: true)
    //
    //        if currentBrowseType == .Filtering {
    //            showFilterPressed(self)
    //        }
    //    }
    //
    //    override func viewWillAppear(animated: Bool) {
    //        super.viewWillAppear(animated)
    //
    //        if loadingView.animating == false {
    //            loadingView.stopAnimating()
    //            collectionView.animateFadeIn()
    //        }
    //    }
    //
    //    deinit {
    //        NotificationCenter.defaultCenter().removeObserver(self)
    //    }
    //
    //    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
    //        super.viewWillTransitionToSize(size, withTransitionCoordinator: coordinator)
    //
    //        updateLayout(withSize: size)
    //    }
    //
    //    func updateLayout(withSize viewSize: CGSize) {
    //
    //        guard let collectionView = collectionView,
    //            let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout else {
    //                return
    //        }
    //
    //        AnimeCell.updateLayoutItemSizeWithLayout(layout, viewSize: viewSize)
    //    }
    //
    //    func updateETACells() {
    //        let indexPaths = collectionView.indexPathsForVisibleItems()
    //        collectionView.reloadItemsAtIndexPaths(indexPaths)
    //    }
    //
    //    func fetchListType(type: BrowseType, customQuery: PFQuery? = nil) {
    //
    //        // Animate
    //        collectionView.animateFadeOut()
    //        loadingView.startAnimating()
    //
    //        // Update model
    //        currentBrowseType = type
    //
    //        // Update UI
    //        navigationBarTitle.text! = currentBrowseType.rawValue + " " + FontAwesome.AngleDown.rawValue
    //
    //        // Fetch
    //        var query: PFQuery!
    //        if let customQuery = customQuery {
    //            query = customQuery
    //        } else {
    //            query = BrowseViewController.queryForBrowseType(currentBrowseType, customQuery: customQuery)
    //        }
    //
    //        fetchController.configureWith(self, query: query, collectionView: collectionView)
    //        collectionView.reloadData()
    //    }
    //
    //    class func queryForBrowseType(browseType: BrowseType, customQuery: PFQuery? = nil) -> PFQuery {
    //        let query = Anime.query()!
    //        switch browseType {
    //        case .TopAnime:
    //            query
    //                .whereKey("rank", greaterThan: 0)
    //                .orderByAscending("rank")
    //        case .TopAiring:
    //            query
    //                .whereKey("rank", greaterThan: 0)
    //                .orderByAscending("rank")
    //                .whereKey("status", equalTo: AnimeStatus.CurrentlyAiring.rawValue)
    //        case .TopUpcoming:
    //            query
    //                .orderByAscending("popularityRank")
    //                .whereKey("status", equalTo: AnimeStatus.NotYetAired.rawValue)
    //        case .TopTVSeries:
    //            query.orderByAscending("rank")
    //                .whereKey("rank", greaterThan: 0)
    //                .whereKey("type", equalTo: AnimeType.TV.rawValue)
    //        case .TopMovies:
    //            query.orderByAscending("rank")
    //                .whereKey("rank", greaterThan: 0)
    //                .whereKey("type", equalTo: AnimeType.Movie.rawValue)
    //        case .TopOVA:
    //            query.orderByAscending("rank")
    //                .whereKey("rank", greaterThan: 0)
    //                .whereKey("type", equalTo: AnimeType.OVA.rawValue)
    //        case .TopSpecials:
    //            query.orderByAscending("rank")
    //                .whereKey("rank", greaterThan: 0)
    //                .whereKey("type", equalTo: AnimeType.Special.rawValue)
    //        case .JustAdded:
    //            query.orderByDescending("createdAt")
    //        case .MostPopular:
    //            query.orderByAscending("popularityRank")
    //        case .Filtering:
    //            // Do nothing
    //            break
    //        }
    //        return query
    //    }
    //
    //    func changeSeasonalChart() {
    //        if let navigationController = navigationController {
    //            DropDownListViewController.showDropDownListWith(sender: navigationController.navigationBar, viewController: navigationController, delegate: self, dataSource: [BrowseType.allItems()])
    //        }
    //    }
    //
    //    // MARK: - IBActions
    //
    //    @IBAction func showFilterPressed(sender: AnyObject) {
    //
    //        if let navigationController = navigationController {
    //            let controller = UIStoryboard(name: "Browse", bundle: nil).instantiateViewControllerWithIdentifier("Filter") as! FilterViewController
    //
    //            controller.delegate = self
    //            controller.initWith(configuration: currentConfiguration, selectedGenres: selectedGenres)
    //            animator = navigationController.presentViewControllerModal(controller)
    //        }
    //    }
}

//extension BrowseViewController: UICollectionViewDataSource {
//    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        return fetchController.dataCount()
//    }
//
//    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
//        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(AnimeCell.id, forIndexPath: indexPath) as! AnimeCell
//
//        let anime = fetchController.objectAtIndex(indexPath.row) as! Anime
//
//        cell.configureWithAnime(anime)
//        return cell
//    }
//}
//
//extension BrowseViewController: UICollectionViewDelegate {
//    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
//
//        let anime = fetchController.objectAtIndex(indexPath.row) as! Anime
//        self.animator = presentAnimeModal(anime)
//    }
//}

//extension BrowseViewController: FilterViewControllerDelegate {
//    func finishedWith(configuration configuration: Configuration, selectedGenres: [String]) {
//
//        currentConfiguration = configuration
//        self.selectedGenres = selectedGenres
//
//        let query = Anime.query()!
//
//        for (filterSection, value, _) in configuration {
//            if let value = value {
//                switch filterSection {
//                case .Sort:
//                    switch SortType(rawValue: value)! {
//                    case .Rating:
//                        query.whereKey("rank", greaterThan: 0)
//                        query.orderByAscending("rank")
//                    case .Popularity:
//                        query.orderByAscending("popularityRank")
//                    case .Title:
//                        query.orderByAscending("title")
//                    case .Newest:
//                        query.orderByDescending("startDate")
//                    case .Oldest:
//                        query.orderByAscending("startDate")
//                        query.whereKeyExists("startDate")
//                    default: break
//                    }
//                case .AnimeType:
//                    query.whereKey("type", equalTo: value)
//                case .Year:
//                    query.whereKey("year", equalTo: Int(value)!)
//                case .Status:
//                    query.whereKey("status", equalTo: value)
//                case .Studio:
//                    query.whereKey("producers", containedIn: [value])
//                case .Classification:
//                    let subquery = AnimeDetail.query()!
//                    subquery.whereKey("classification", equalTo: value)
//                    query.whereKey("details", matchesQuery: subquery)
//                default: break;
//                }
//            }
//        }
//
//        if selectedGenres.count != 0 {
//            query.whereKey("genres", containsAllObjectsInArray: selectedGenres)
//        }
//
//
//        fetchListType(BrowseType.Filtering, customQuery: query)
//    }
//}

//extension BrowseViewController: FetchControllerDelegate {
//
//    func didFetchFor(skip skip: Int) {
//        loadingView.stopAnimating()
//    }
//}

//extension BrowseViewController: DropDownListDelegate {
//    func selectedAction(trigger: UIView, action: String, indexPath: NSIndexPath) {
//
//        if let _ = InAppController.hasAnyPro() {
//            let rawValue = BrowseType.allItems()[indexPath.row]
//            fetchListType(BrowseType(rawValue: rawValue)!)
//        }
//    }
//
//    func dropDownDidDismissed(selectedAction: Bool) {
//        if selectedAction && InAppController.hasAnyPro() == nil {
//            InAppPurchaseViewController.showInAppPurchaseWith(self)
//        }
//    }
//}

//var allYears = ["2016","2015","2014","2013","2012","2011","2010","2009","2008","2007","2006","2005","2004","2003","2002","2001","2000","1999","1998","1997","1996","1995","1994","1993","1992","1991","1990","1989","1988","1987","1986","1985","1984","1983","1982","1981","1980","1979","1978","1977","1976","1975","1974","1973","1972","1971","1970"]
//
//var allStudios = ["P.A. Works", "Ordet", "Studio Khara", "Sega", "Production I.G", "Studio 4C", "Creators in Pack TOKYO", "Shirogumi", "Satelight", "Genco", "Kinema Citrus", "ufotable", "Artmic", "POLYGON PICTURES", "Lay-duce", "DAX Production", "Passione", "AIC A.S.T.A.", "office DCI", "Benesse Corporation", "NAZ", "Silver Link", "Gonzo", "AIC Plus+", "Media Factory", "DropWave", "Toho Company", "Production IMS", "Manglobe", "TYO Animations", "J.C. Staff", "Actas", "Brains Base", "Wit Studio", "Ultra Super Pictures", "Kenji Studio", "Kachidoki Studio", "Nomad", "TROYCA", "Studio 3Hz", "Seven Arcs", "Studio Deva Loka", "Arms", "Hoods Entertainment", "CoMix Wave", "Kyoto Animation", "Nippon Ichi Software", "Sunrise", "MAPPA", "Studio Deen", "Studio Unicorn", "Gathering", "Madhouse", "Tatsunoko Productions", "TNK", "Ascension", "Bridge", "Toei Animation", "Project No.9", "Trigger", "Nippon Animation", "Studio Colorido", "Diomedea", "Xebec", "SANZIGEN", "A-1 Pictures", "C-Station", "TMS Entertainment", "Studio Shuka", "Fanworks", "Encourage Films", "Studio Pierrot", "C2C", "Studio Gokumi", "Asahi Production", "AIC", "Fuji TV", "GoHands", "Oriental Light and Magic", "Poncotan", "Shogakukan Productions", "Studio Chizu", "Aniplex", "Telecom Animation Film", "Graphinica", "Trick Block", "VAP", "Bones", "Tezuka Productions", "Feel", "8bit", "Nexus", "Studio Gallop", "Gainax", "Dogakobo", "LIDEN FILMS", "DLE", "SynergySP", "Shaft", "Shin-Ei Animation", "White Fox", "David Production", "Zexcs", "Seven", "Anpro", "TV Tokyo", "Lerche", "Strawberry Meets Pictures", "Studio Ghibli", "Artland"]

// Madhouse Studios -> Madhouse
