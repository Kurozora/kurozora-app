//
//  LibraryViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 08/05/2018.
//  Copyright © 2018 Kusa. All rights reserved.
//

import KCommonKit
import Tabman
import Pageboy
import SCLAlertView

enum SectionList: String {
    case planning = "Planning"
    case watching = "Watching"
    case completed = "Completed"
    case onHold = "On-Hold"
    case dropped = "Dropped"
}

class LibraryViewController: TabmanViewController {
	lazy var viewControllers = [UIViewController]()
	private var shadowImageView: UIImageView?

	let librarySections: [SectionList]? = [.watching, .planning, .completed, .onHold, .dropped]
	let bar = TMBar.ButtonBar()

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)

		if shadowImageView == nil {
			shadowImageView = findShadowImage(under: navigationController!.navigationBar)
		}
		shadowImageView?.isHidden = true
	}

    override func viewDidLoad() {
        super.viewDidLoad()
		view.theme_backgroundColor = "Global.backgroundColor"
		dataSource = self

		// Indicator
		bar.indicator.weight = .light
		bar.indicator.cornerStyle = .eliptical
		bar.indicator.overscrollBehavior = .bounce
		bar.indicator.tintColor = .orange

		// State
		bar.buttons.customize { (button) in
			button.selectedTintColor = #colorLiteral(red: 1, green: 0.5764705882, blue: 0, alpha: 1)
			button.tintColor = #colorLiteral(red: 1, green: 0.5764705882, blue: 0, alpha: 1).withAlphaComponent(0.4)
		}
		bar.buttons.transitionStyle = .progressive

		// Layout
		bar.layout.contentInset = UIEdgeInsets(top: 0.0, left: 16.0, bottom: 4.0, right: 16.0)
		bar.layout.interButtonSpacing = 24.0

		// Style
		bar.backgroundView.style = .flat(color: #colorLiteral(red: 0.2801330686, green: 0.2974318862, blue: 0.3791741133, alpha: 1))
		bar.fadesContentEdges = true

		// configure the bar
		addBar(bar, dataSource: self, at: .top)
		bar.isHidden = (bar.items?.count)! <= 1
    }

	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillAppear(animated)

		shadowImageView?.isHidden = false
	}

	// MARK: - Functions
    private func initializeViewControllers(with count: Int) {
        let storyboard = UIStoryboard(name: "library", bundle: nil)
        var viewControllers = [UIViewController]()

        for index in 0 ..< count {
            let viewController = storyboard.instantiateViewController(withIdentifier: "AnimeList") as! AnimeListViewController
            guard let sectionTitle = librarySections?[index].rawValue else { return }
            viewController.sectionTitle = sectionTitle

            viewControllers.append(viewController)
        }

        self.viewControllers = viewControllers
    }

	private func findShadowImage(under view: UIView) -> UIImageView? {
		if view is UIImageView && view.bounds.size.height <= 1 {
			return (view as! UIImageView)
		}

		for subview in view.subviews {
			if let imageView = findShadowImage(under: subview) {
				return imageView
			}
		}
		return nil
	}

	// MARK: - IBActions
	@IBAction func changeLayoutButtonPressed(_ sender: UIBarButtonItem) {
		guard let title = sender.title else { return }
		let currentSection = self.currentViewController as? AnimeListViewController
		var libraryLayout = "Detailed"

		if title == "Detailed" {
			libraryLayout = "Compact"
			sender.title = "Compact"
			sender.image = #imageLiteral(resourceName: "compact_view_icon")
		} else if title == "Compact" {
			sender.title = "Detailed"
			sender.image = #imageLiteral(resourceName: "detailed_view_icon")
		}

		currentSection?.libraryLayout = libraryLayout
		currentSection?.collectionView.reloadData()
	}
}

// MARK: - PageboyViewControllerDataSource
extension LibraryViewController: PageboyViewControllerDataSource {
	func numberOfViewControllers(in pageboyViewController: PageboyViewController) -> Int {
		if let sectionsCount = librarySections?.count, sectionsCount != 0 {
			initializeViewControllers(with: sectionsCount)
			return sectionsCount
		}
		return 0
	}

	func viewController(for pageboyViewController: PageboyViewController, at index: PageboyViewController.PageIndex) -> UIViewController? {
		return self.viewControllers[index]
	}

	func defaultPage(for pageboyViewController: PageboyViewController) -> PageboyViewController.Page? {
		return nil
	}
}

// MARK: - TMBarDataSource
extension LibraryViewController: TMBarDataSource {
	func barItem(for bar: TMBar, at index: Int) -> TMBarItemable {
		guard let sectionTitle = librarySections?[index].rawValue else { return TMBarItem(title: "Section \(index)") }
		return TMBarItem(title: sectionTitle)
	}
}


//    let SortTypeDefault = "Library.SortType."
//    let LayoutTypeDefault = "Library.LayoutType."
//
//    var allAnimeLists: [AnimeList] = [.Watching, .Planning, .OnHold, .Completed, .Dropped]
//    var listControllers: [AnimeListViewController] = []
//
//    var loadingView: LoaderView!
//    var libraryController = LibraryController.sharedInstance
//    var animator: ZFModalTransitionAnimator!
//
//    var currentConfiguration: Configuration {
//        get {
//            return configurations[Int(currentIndex)]
//        }
//
//        set (value) {
//            configurations[Int(currentIndex)] = value
//        }
//    }
//    var configurations: [Configuration] = []
//    
//    func sortTypeForList(list: AnimeList) -> SortType {
//        let key = SortTypeDefault+list.rawValue
//        if let sortType = UserDefaults.standard.object(forKey: key) as? String, let sortTypeEnum = SortType(rawValue: sortType) {
//            return sortTypeEnum
//        } else {
//            return SortType.Title
//        }
//    }
//
//    func setSortTypeForList(sort:SortType, list: AnimeList) {
//        let key = SortTypeDefault+list.rawValue
//        UserDefaults.standard.set(sort.rawValue, forKey: key)
//        UserDefaults.standard.synchronize()
//    }
//
//    func layoutTypeForList(list: AnimeList) -> LibraryLayout {
//        let key = LayoutTypeDefault+list.rawValue
//        if let layoutType = UserDefaults.standard.object(forKey: key) as? String, let layoutTypeEnum = LibraryLayout(rawValue: layoutType) {
//            return layoutTypeEnum
//        } else {
//            return LibraryLayout.CheckIn
//        }
//
//    }
//
//    func setLayoutTypeForList(layout:LibraryLayout, list: AnimeList) {
//        let key = LayoutTypeDefault+list.rawValue
//        UserDefaults.standard.set(layout.rawValue, forKey: key)
//        UserDefaults.standard.synchronize()
//    }
//
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//
//        self.isProgressiveIndicator = true
//        self.buttonBarView.selectedBar.backgroundColor = UIColor.watching()
//
//        NotificationCenter.default.addObserver(self, selector: #selector(updateLibrary), name: NSNotification.Name(rawValue: LibraryUpdatedNotification), object: nil)
//        NotificationCenter.default.addObserver(self, selector: #selector(controllerRequestRefresh), name: NSNotification.Name(rawValue: LibraryCreatedNotification), object: nil)
//        
//        loadingView = LoaderView(parentView: view)
//
//        libraryController.delegate = self
//        loadingView.startAnimating()
//        if let library = libraryController.library {
//            updateListViewControllers(animeList: library)
//        }
//    }
//
//    deinit {
//        NotificationCenter.default.removeObserver(self)
//    }
//    
//    @objc func updateLibrary() {
//        fetchAnimeList(false)
//    }
//    
//    func fetchAnimeList(isRefreshing: Bool) -> BFTask {
//
//        if libraryController.currentlySyncing {
//            return BFTask(result: nil)
//        }
//
//        if !isRefreshing {
//            loadingView.startAnimating()
//        }
//
//        return libraryController.fetchAnimeList(isRefreshing).continueWithExecutor(BFExecutor.mainThreadExecutor(), withBlock: { (task: BFTask!) -> AnyObject? in
//
//            if let library = task.result as? [Anime] {
//                self.updateListViewControllers(library)
//            }
//
//            return nil
//        })
//    }
//    
//    func updateListViewControllers(animeList: [Anime]) {
//
//        var lists: [[Anime]] = [[],[],[],[],[]]
//
//        for anime in animeList {
//            if let progress = anime.progress {
//                switch progress.myAnimeListList() {
//                case .Watching:
//                    lists[0].append(anime)
//                case .Planning:
//                    lists[1].append(anime)
//                case .OnHold:
//                    lists[2].append(anime)
//                case .Completed:
//                    lists[3].append(anime)
//                case .Dropped:
//                    lists[4].append(anime)
//                }
//            }
//        }
//
//        for index in 0...4 {
//            let aList = lists[index]
//            if aList.count > 0 {
//                let controller = self.listControllers[index]
//                controller.animeList = aList
//                controller.updateSortType(sortType: controller.currentSortType)
//            }
//        }
//
//        loadingView.stopAnimating()
//    }
//
//
//    
//    // MARK: - PagerTabStripViewControllerDataSource
//
//    override func childViewControllersForPagerTabStripViewController(pagerTabStripViewController: PagerTabStripViewController!) -> [AnyObject]! {
//
//        // Initialize configurations
//        for list in allAnimeLists {
//            configurations.append(
//                [
//                    (FilterSection.View, layoutTypeForList(list: list).rawValue, LibraryLayout.allRawValues()),
//                    (FilterSection.Sort, sortTypeForList(list: list).rawValue, [SortType.Title.rawValue, SortType.NextEpisodeToWatch.rawValue, SortType.NextAiringEpisode.rawValue, SortType.MyRating.rawValue, SortType.Rating.rawValue, SortType.Popularity.rawValue, SortType.Newest.rawValue, SortType.Oldest.rawValue]),
//                    ]
//            )
//        }
//        
//        // Initialize controllers
//        let storyboard = UIStoryboard(name: "Library", bundle: nil)
//
//        var lists: [AnimeListViewController] = []
//
//        for index in 0...4 {
//            if let controller = storyboard.instantiateViewController(withIdentifier: "AnimeList") as? AnimeListViewController {
//                let animeList = allAnimeLists[index]
//
//                controller.initWithList(animeList: animeList, configuration: configurations[index])
//                controller.delegate = self
//                
//                lists.append(controller)
//            }
//        }
//        
//        listControllers = lists
//        
//        return lists
//    }
//
//    // MARK: - PagerTabStripViewControllerDelegate
//
//    override func pagerTabStripViewController(pagerTabStripViewController: PagerTabStripViewController!, updateIndicatorFromIndex fromIndex: Int, toIndex: Int, withProgressPercentage progressPercentage: CGFloat) {
//        super.pagerTabStripViewController(pagerTabStripViewController, updateIndicatorFromIndex: fromIndex, toIndex: toIndex, withProgressPercentage: progressPercentage)
//
//        if progressPercentage > 0.5 {
//            self.buttonBarView.selectedBar.backgroundColor = colorForIndex(index: toIndex)
//        } else {
//            self.buttonBarView.selectedBar.backgroundColor = colorForIndex(index: fromIndex)
//        }
//    }
//
//    func colorForIndex(index: Int) -> UIColor {
//        var color: UIColor?
//        switch index {
//        case 0:
//            color = UIColor.watching()
//        case 1:
//            color = UIColor.planning()
//        case 2:
//            color = UIColor.onHold()
//        case 3:
//            color = UIColor.completed()
//        case 4:
//            color = UIColor.dropped()
//        default: break
//        }
//        return color ?? UIColor.completed()
//    }
//    
//    // MARK: - IBActions
//
//    @IBAction func presentSearchPressed(sender: AnyObject) {
//
//        if let tabBar = tabBarController {
//            tabBar.presentSearchViewController(searchScope: .MyLibrary)
//        }
//    }
//
//    @IBAction func showFilterPressed(sender: AnyObject) {
//
//        if let tabBar = tabBarController,
//            let controller = UIStoryboard(name: "Browse", bundle: nil).instantiateViewController(withIdentifier: "Filter") as? FilterViewController {
//
//            controller.delegate = self
//            controller.initWith(configuration: currentConfiguration)
//            animator = tabBar.presentViewControllerModal(controller: controller)
//        }
//    }
//}
//
//
//extension LibraryViewController: FilterViewControllerDelegate {
//    func finishedWith(configuration: Configuration, selectedGenres: [String]) {
//        
//        let currentListIndex = Int(currentIndex)
//        currentConfiguration = configuration
//        listControllers[currentListIndex].currentConfiguration = currentConfiguration
//
//        if let value = currentConfiguration[0].value,
//            let layoutType = LibraryLayout(rawValue: value) {
//            setLayoutTypeForList(layout: layoutType, list: allAnimeLists[currentListIndex])
//        }
//
//        if let value = currentConfiguration[1].value,
//            let sortType = SortType(rawValue: value) {
//            setSortTypeForList(sort: sortType, list: allAnimeLists[currentListIndex])
//        }
//
//    }
//}
//
//extension LibraryViewController: AnimeListControllerDelegate {
//    func controllerRequestRefresh() -> BFTask {
//        return fetchAnimeList(true)
//    }
//}
//
//extension LibraryViewController: LibraryControllerDelegate {
//    func libraryControllerFinishedFetchingLibrary(library: [Anime]) {
//        updateListViewControllers(animeList: library)
//    }
