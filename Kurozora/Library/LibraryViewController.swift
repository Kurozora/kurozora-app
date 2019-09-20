//
//  LibraryViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 08/05/2018.
//  Copyright © 2018 Kurozora. All rights reserved.
//

import UIKit
import Tabman
import Pageboy
import SCLAlertView
import SwiftTheme

class LibraryViewController: TabmanViewController {
	@IBOutlet weak var changeLayoutButton: UIBarButtonItem!

	lazy var viewControllers = [UIViewController]()
	var searchResultsTableViewController: SearchResultsTableViewController?
	var searchController: SearchController!

	let librarySections: [LibrarySectionList] = [.watching, .planning, .completed, .onHold, .dropped]
	let bar = TMBar.ButtonBar()

	#if DEBUG
	var numberOfItems: (forWidth: CGFloat, forHeight: CGFloat) = {
		return LibraryListCollectionViewController().numberOfItems
	}()
	var numberOfItemsTextField: UITextField = UITextField(frame: CGRect(origin: .zero, size: CGSize(width: 100, height: 20)))

	@objc func updateLayout(_ textField: UITextField) {
		guard let textFieldText = numberOfItemsTextField.text else { return }
		guard let currentSection = self.currentViewController as? LibraryListCollectionViewController else { return }

		if textFieldText.isEmpty {
			currentSection.newNumberOfItems = nil
		} else {
			currentSection.newNumberOfItems = getNumbers(textFieldText)
		}

		currentSection.collectionView.reloadData()
	}

	func getNumbers(_ text: String) -> (forWidth: CGFloat, forHeight: CGFloat) {
		let stringArray = text.withoutSpacesAndNewLines.components(separatedBy: ",")
		let width = (stringArray.count > 1) ? Double(stringArray[0])?.cgFloat : numberOfItems.forWidth
		let height = (stringArray.count > 1) ? Double(stringArray[1])?.cgFloat : numberOfItems.forHeight
		return (width ?? numberOfItems.forWidth, height ?? numberOfItems.forHeight)
	}
	#endif

    override func viewDidLoad() {
        super.viewDidLoad()
		view.theme_backgroundColor = KThemePicker.backgroundColor.rawValue
		dataSource = self

		// Search bar
		searchResultsTableViewController = SearchResultsTableViewController.instantiateFromStoryboard() as? SearchResultsTableViewController
		searchResultsTableViewController?.delegate = self

		searchController = SearchController(searchResultsController: searchResultsTableViewController)
		searchController.delegate = self
		searchController.searchBar.selectedScopeButtonIndex = SearchScope.myLibrary.rawValue
		searchController.searchResultsUpdater = searchResultsTableViewController
		searchController.viewController = self

		let searchControllerBar = searchController.searchBar
		searchControllerBar.delegate = searchResultsTableViewController

		// Indicator
		bar.indicator.weight = .light
		bar.indicator.cornerStyle = .eliptical
		bar.indicator.overscrollBehavior = .bounce
		bar.indicator.theme_tintColor = KThemePicker.tintColor.rawValue

		// State
		bar.buttons.customize { (button) in
			button.selectedTintColor = ThemeManager.color(for: KThemePicker.tintColor.stringValue)
			button.tintColor = ThemeManager.color(for: KThemePicker.tintColor.stringValue)?.withAlphaComponent(0.4)
		}

		// Layout
		bar.layout.contentInset = UIEdgeInsets(top: 0.0, left: 16.0, bottom: 4.0, right: 16.0)
		bar.layout.interButtonSpacing = 24.0
		if UIDevice.isPad {
			bar.layout.contentMode = .fit
		}

		// Style
		bar.fadesContentEdges = true

		// configure the bar
		let systemBar = bar.systemBar()
		systemBar.backgroundStyle = .blur(style: .regular)
		addBar(systemBar, dataSource: self, at: .top)

		if let barItemsCount = bar.items?.count {
			bar.isHidden = barItemsCount <= 1
		}

		#if DEBUG
		numberOfItemsTextField.placeholder = "# items for: width, height"
		numberOfItemsTextField.text = "\(numberOfItems.forWidth), \(numberOfItems.forHeight)"
		numberOfItemsTextField.textAlignment = .center
		numberOfItemsTextField.addTarget(self, action: #selector(updateLayout(_:)), for: .editingDidEnd)
		navigationItem.title = nil
		navigationItem.titleView = numberOfItemsTextField
		#endif
    }

	// MARK: - Functions
    private func initializeViewControllers(with count: Int) {
        let storyboard = UIStoryboard(name: "library", bundle: nil)
        var viewControllers = [UIViewController]()

        for index in 0 ..< count {
            let viewController = storyboard.instantiateViewController(withIdentifier: "LibraryListCollectionViewController") as! LibraryListCollectionViewController
            var sectionTitle = librarySections[index].rawValue
			sectionTitle = (sectionTitle == "On-Hold" ? "OnHold" : sectionTitle)

			// Get the user's preferred library layout
			if let libraryLayouts = UserSettings.libraryLayouts as? [String: String] {
				let currentLayout = libraryLayouts[sectionTitle] ?? "Detailed"
				guard let libraryLayout = LibraryListStyle(rawValue: "\(currentLayout)Cell") else { return }

				viewController.libraryLayout = libraryLayout
			}
			viewController.sectionTitle = sectionTitle
			viewController.sectionIndex = index
			viewController.delegate = self
            viewControllers.append(viewController)
        }

        self.viewControllers = viewControllers
    }

	// Change layout button icon to reflect current layout when switching between views
	private func updateChangeLayoutButtonIcon(_ layout: LibraryListStyle) {
		if layout == .compact {
			changeLayoutButton.title = "Compact"
			changeLayoutButton.image = #imageLiteral(resourceName: "compact_view_icon")
		} else if layout == .detailed {
			changeLayoutButton.title = "Detailed"
			changeLayoutButton.image = #imageLiteral(resourceName: "detailed_view_icon")
		}
	}

	// Change layout between compact and detailed cells
	private func changeLayout() {
		guard let buttonTitle = changeLayoutButton.title else { return }
		guard let currentSection = self.currentViewController as? LibraryListCollectionViewController else { return }
		guard let sectionTitle = currentSection.sectionTitle else { return }

		var libraryLayout: LibraryListStyle = .detailed

		// Change button information
		if buttonTitle == "Detailed" {
			libraryLayout = .compact
			changeLayoutButton.title = "Compact"
			changeLayoutButton.image = #imageLiteral(resourceName: "compact_view_icon")
		} else if buttonTitle == "Compact" {
			changeLayoutButton.title = "Detailed"
			changeLayoutButton.image = #imageLiteral(resourceName: "detailed_view_icon")
		}

		// Add to UserSettings
		if let libraryLayouts = UserSettings.libraryLayouts as? [String: String] {
			var newLibraryLayouts = libraryLayouts
			newLibraryLayouts[sectionTitle] = changeLayoutButton.title
			UserSettings.set(newLibraryLayouts, forKey: .libraryLayouts)
		}

		// Update library list
		currentSection.libraryLayout = libraryLayout
		UIView.animate(withDuration: 0, animations: {
			guard let flowLayout = currentSection.collectionView.collectionViewLayout as? UICollectionViewFlowLayout else {
				return
			}
			flowLayout.invalidateLayout()
		}, completion: { _ in
			currentSection.collectionView.reloadData()
		})
	}

	// MARK: - IBActions
	@IBAction func changeLayoutButtonPressed(_ sender: UIBarButtonItem) {
		changeLayout()
	}

	@IBAction func searchButtonPressed(_ sender: UIBarButtonItem) {
		self.navigationItem.searchController = searchController
		searchController.searchBar.becomeFirstResponder()
	}
}

// MARK: - LibraryListViewControllerDelegate
extension LibraryViewController: LibraryListViewControllerDelegate {
	func updateLayoutChangeButton(current layout: LibraryListStyle) {
		updateChangeLayoutButtonIcon(layout)
	}
}

// MARK: - PageboyViewControllerDataSource
extension LibraryViewController: PageboyViewControllerDataSource {
	func numberOfViewControllers(in pageboyViewController: PageboyViewController) -> Int {
		let sectionsCount = librarySections.count
		initializeViewControllers(with: sectionsCount)
		return sectionsCount
	}

	func viewController(for pageboyViewController: PageboyViewController, at index: PageboyViewController.PageIndex) -> UIViewController? {
		return self.viewControllers[index]
	}

	func defaultPage(for pageboyViewController: PageboyViewController) -> PageboyViewController.Page? {
		return .at(index: UserSettings.libraryPage)
	}
}

// MARK: - TMBarDataSource
extension LibraryViewController: TMBarDataSource {
	func barItem(for bar: TMBar, at index: Int) -> TMBarItemable {
		let sectionTitle = librarySections[index].rawValue
		return TMBarItem(title: sectionTitle)
	}
}

// MARK: - UISearchControllerDelegate
extension LibraryViewController: UISearchControllerDelegate {
	func willPresentSearchController(_ searchController: UISearchController) {
		if var tabBarFrame = self.tabBarController?.tabBar.frame {
			tabBarFrame.origin.y = self.view.frame.size.height + (tabBarFrame.size.height)
			UIView.animate(withDuration: 0.5, animations: {
				self.tabBarController?.tabBar.isHidden = true
			})
		}
	}

	func willDismissSearchController(_ searchController: UISearchController) {
		if var tabBarFrame = self.tabBarController?.tabBar.frame {
			tabBarFrame.origin.y = self.view.frame.size.height - (tabBarFrame.size.height)
			UIView.animate(withDuration: 0.5, animations: {
				self.tabBarController?.tabBar.isHidden = false
			})
		}
	}
}

extension LibraryViewController: SearchResultsTableViewControllerDelegate {
	func didCancelSearchController() {
		self.navigationItem.searchController = nil
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
