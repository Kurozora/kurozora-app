//
//  ForumsViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 09/05/2018.
//  Copyright © 2018 Kurozora. All rights reserved.
//

import UIKit
import Tabman
import Pageboy
import SCLAlertView

class ForumsViewController: TabmanViewController {
	// MARK: - IBOutlets
    @IBOutlet weak var createThreadBarButtonItem: UIBarButtonItem!
	@IBOutlet weak var sortingBarButtonItem: UIBarButtonItem!
	@IBOutlet weak var bottomBarView: UIView!

	// MARK: - Properties
	var sections: [ForumsSectionsElement]? {
		didSet {
			self.reloadData()
		}
	}
	var sectionsCount: Int?
	var threadSorting: String?
	lazy var viewControllers = [UIViewController]()
	var searchResultsTableViewController: SearchResultsTableViewController?
	var searchController: SearchController!

	let bar = TMBar.KBar()

	// MARK: - View
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)

		navigationItem.hidesSearchBarWhenScrolling = false
	}

	override func viewDidLoad() {
        super.viewDidLoad()
		view.theme_backgroundColor = KThemePicker.backgroundColor.rawValue
		NotificationCenter.default.addObserver(self, selector: #selector(reloadTabBarStyle), name: .ThemeUpdateNotification, object: nil)

		// Setup search bar.
		setupSearchBar()

		// Tabman view controllers.
		dataSource = self

		// Tabman bar.
		initTabmanBarView()

		// Fetch forum sections.
		fetchForumsSections()
    }

	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)

		navigationItem.hidesSearchBarWhenScrolling = true
	}

	// MARK: - Functions
	/// Sets up the search bar.
	fileprivate func setupSearchBar() {
		searchResultsTableViewController = SearchResultsTableViewController.instantiateFromStoryboard() as? SearchResultsTableViewController

		searchController = SearchController(searchResultsController: searchResultsTableViewController)
		searchController.delegate = self
		searchController.searchBar.selectedScopeButtonIndex = SearchScope.thread.rawValue
		searchController.searchResultsUpdater = searchResultsTableViewController
		searchController.viewController = self

		let searchControllerBar = searchController.searchBar
		searchControllerBar.delegate = searchResultsTableViewController

		navigationItem.searchController = searchController
	}

	/// Fetches the forum sections from the server.
	func fetchForumsSections() {
		KService.shared.getForumSections(withSuccess: { (sections) in
			DispatchQueue.main.async {
				self.sectionsCount = sections?.count
				self.sections = sections
			}
		})
	}

	/// Applies the the style for the currently enabled theme on the tabman bar.
	private func styleTabmanBarView() {
		// Background view
		bar.backgroundView.style = .blur(style: KThemePicker.visualEffect.blurValue)

		// Indicator
		bar.indicator.layout(in: bar)

		// Scrolling
		bar.scrollMode = .interactive

		// State
		bar.buttons.customize { (button) in
			button.contentInset = UIEdgeInsets(top: 12.0, left: 12.0, bottom: 12.0, right: 12.0)
			button.selectedTintColor = KThemePicker.tintColor.colorValue
			button.tintColor = button.selectedTintColor.withAlphaComponent(0.25)
		}

		// Layout
		bar.layout.contentInset = UIEdgeInsets(top: 0.0, left: 8.0, bottom: 0.0, right: 8.0)
		bar.layout.interButtonSpacing = 0.0
		if UIDevice.isPad {
			bar.layout.contentMode = .fit
		}

		// Style
		bar.fadesContentEdges = true
	}

	/// Initializes the tabman bar view.
	private func initTabmanBarView() {
		// Style tabman bar
		styleTabmanBarView()

		// Add tabman bar to view
		addBar(bar, dataSource: self, at: .custom(view: bottomBarView, layout: { bar in
			bar.translatesAutoresizingMaskIntoConstraints = false
			NSLayoutConstraint.activate([
				bar.topAnchor.constraint(equalTo: self.bottomBarView.topAnchor),
				bar.bottomAnchor.constraint(equalTo: self.bottomBarView.bottomAnchor),
				bar.leftAnchor.constraint(lessThanOrEqualTo: self.bottomBarView.leftAnchor),
				bar.rightAnchor.constraint(lessThanOrEqualTo: self.bottomBarView.rightAnchor),
				bar.centerXAnchor.constraint(equalTo: self.bottomBarView.centerXAnchor)
			])
		}))

		bar.cornerRadius = bar.height / 2

		// Configure tabman bar visibility
		tabmanBarViewIsEnabled()
	}

	/// Hides or unhides the tabman bar view according to the user's sign in state.
	private func tabmanBarViewIsEnabled() {
		if let barItemsCount = bar.items?.count {
			bar.isHidden = barItemsCount <= 1
		}
	}

	/// Reloads the tab bar with the new data.
	@objc func reloadTabBarStyle() {
		styleTabmanBarView()
	}

	/**
		Initializes the view controllers which will be used for pagination.

		- Parameter count: The number of view controller to initialize.
	*/
	private func initializeViewControllers(with count: Int) {
		let storyboard = UIStoryboard(name: "forums", bundle: nil)
		var viewControllers = [UIViewController]()

		for index in 0 ..< count {
			let viewController = storyboard.instantiateViewController(withIdentifier: "ForumsListViewController") as! ForumsListViewController
			guard let sectionTitle = sections?[index].name else { return }
			viewController.sectionTitle = sectionTitle

			if let sectionID = sections?[index].id, sectionID != 0 {
				viewController.sectionID = sectionID
			}
			viewController.sectionIndex = index
			viewControllers.append(viewController)
		}

		self.viewControllers = viewControllers
	}

	// MARK: - IBActions
	@IBAction func sortingBarButtonItemPressed(_ sender: UIBarButtonItem) {
		let action = UIAlertController.actionSheetWithItems(items: [("Top", "top", #imageLiteral(resourceName: "Symbols/arrow_up_line_horizontal_3_decrease")), ("Recent", "recent", #imageLiteral(resourceName: "Symbols/clock"))], currentSelection: threadSorting, action: { (title, value)  in
			let currentSection = self.currentViewController as? ForumsListViewController
			currentSection?.threadOrder = value
			currentSection?.currentPage = 1
			self.sortingBarButtonItem.title = value
			self.sortingBarButtonItem.image = ForumsSortingStyle(rawValue: value)?.imageValue
			currentSection?.fetchThreads()
		})

		action.addAction(UIAlertAction.init(title: "Cancel", style: .cancel, handler: nil))

		//Present the controller
		if let popoverController = action.popoverPresentationController {
			popoverController.barButtonItem = sender
		}

		self.present(action, animated: true, completion: nil)
	}

	@IBAction func createThreadBarButtonItemPressed(_ sender: Any) {
		WorkflowController.shared.isSignedIn {
			if let kRichTextEditorViewController = KRichTextEditorViewController.instantiateFromStoryboard() as? KRichTextEditorViewController {
				if let currentIndex = self.currentIndex {
					kRichTextEditorViewController.delegate = self.viewControllers[currentIndex] as? ForumsListViewController
					kRichTextEditorViewController.sectionID = currentIndex + 1
				}

				let kurozoraNavigationController = KNavigationController.init(rootViewController: kRichTextEditorViewController)
				kurozoraNavigationController.navigationBar.prefersLargeTitles = false
				self.present(kurozoraNavigationController)
			}
		}
	}
}

// MARK: - PageboyViewControllerDataSource
extension ForumsViewController: PageboyViewControllerDataSource {
	func numberOfViewControllers(in pageboyViewController: PageboyViewController) -> Int {
		if let sectionsCount = sections?.count, sectionsCount != 0 {
			initializeViewControllers(with: sectionsCount)
			return sectionsCount
		}
		return 0
	}

	func viewController(for pageboyViewController: PageboyViewController, at index: PageboyViewController.PageIndex) -> UIViewController? {
		return self.viewControllers[index]
	}

	func defaultPage(for pageboyViewController: PageboyViewController) -> PageboyViewController.Page? {
		return .at(index: UserSettings.forumsPage)
	}
}

// MARK: - TMBarDataSource
extension ForumsViewController: TMBarDataSource {
	func barItem(for bar: TMBar, at index: Int) -> TMBarItemable {
		guard let sectionTitle = sections?[index].name else { return TMBarItem(title: "Section \(index)") }
		return TMBarItem(title: sectionTitle)
	}
}

// MARK: - UISearchControllerDelegate
extension ForumsViewController: UISearchControllerDelegate {
	func willPresentSearchController(_ searchController: UISearchController) {
		searchController.searchBar.showsCancelButton = true

		if var tabBarFrame = self.tabBarController?.tabBar.frame {
			tabBarFrame.origin.y = self.view.frame.size.height + (tabBarFrame.size.height)
			UIView.animate(withDuration: 0.5, animations: {
				self.tabBarController?.tabBar.isHidden = true
			})
		}
	}

	func willDismissSearchController(_ searchController: UISearchController) {
		searchController.searchBar.showsCancelButton = false

		if var tabBarFrame = self.tabBarController?.tabBar.frame {
			tabBarFrame.origin.y = self.view.frame.size.height - (tabBarFrame.size.height)
			UIView.animate(withDuration: 0.5, animations: {
				self.tabBarController?.tabBar.isHidden = false
			})
		}
	}
}
