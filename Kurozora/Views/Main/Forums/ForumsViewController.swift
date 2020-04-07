//
//  ForumsViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 09/05/2018.
//  Copyright © 2018 Kurozora. All rights reserved.
//

import UIKit
import KurozoraKit
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
	var kSearchController: KSearchController = KSearchController()

	let bar = TMBar.KBar()

	// MARK: - View
	override func viewDidLoad() {
        super.viewDidLoad()
		view.theme_backgroundColor = KThemePicker.backgroundColor.rawValue
		NotificationCenter.default.addObserver(self, selector: #selector(reloadTabBarStyle), name: .ThemeUpdateNotification, object: nil)

		navigationItem.hidesSearchBarWhenScrolling = false

		// Setup search bar.
		setupSearchBar()

		// Tabman view controllers.
		dataSource = self

		// Fetch forum sections.
		fetchForumsSections()
    }

	// MARK: - Functions
	/// Sets up the search bar.
	fileprivate func setupSearchBar() {
		// Configure search bar
		kSearchController.searchScope = .thread
		kSearchController.viewController = self

		// Add search bar to navigation controller
		navigationItem.searchController = kSearchController
	}

	/// Fetches the forum sections from the server.
	func fetchForumsSections() {
		KService.getForumSections(withSuccess: { (sections) in
			DispatchQueue.main.async {
				self.sectionsCount = sections?.count
				self.sections = sections

				// Tabman bar.
				self.initTabmanBarView()
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
		var viewControllers = [UIViewController]()

		for index in 0 ..< count {
			if let forumsListViewController = R.storyboard.forums.forumsListViewController() {
				guard let sectionTitle = sections?[index].name else { return }
				forumsListViewController.sectionTitle = sectionTitle

				if let sectionID = sections?[index].id, sectionID != 0 {
					forumsListViewController.sectionID = sectionID
				}
				forumsListViewController.sectionIndex = index
				viewControllers.append(forumsListViewController)
			}
		}

		self.viewControllers = viewControllers
	}

	// MARK: - IBActions
	@IBAction func sortingBarButtonItemPressed(_ sender: UIBarButtonItem) {
		let action = UIAlertController.actionSheetWithItems(items: [("Top", "top", R.image.symbols.arrow_up_line_horizontal_3_decrease()!), ("Recent", "recent", R.image.symbols.clock()!)], currentSelection: threadSorting, action: { (title, value)  in
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
			if let kRichTextEditorViewController = R.storyboard.textEditor.kRichTextEditorViewController() {
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
