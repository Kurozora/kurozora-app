//
//  ForumsViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 09/05/2018.
//  Copyright © 2018 Kurozora. All rights reserved.
//

import KCommonKit
import SwiftyJSON
import Tabman
import Pageboy
import SCLAlertView
import SwiftTheme

enum ForumSortingStyle: String {
	case top = "top"
	case recent = "recent"

	func image() -> UIImage? {
		switch self {
		case .top:
			return #imageLiteral(resourceName: "sort_top")
		case .recent:
			return #imageLiteral(resourceName: "sort_recent")
		}
	}
}

class ForumsViewController: TabmanViewController {
    @IBOutlet var tableView: UITableView!
    @IBOutlet weak var createThreadButton: UIButton!
	@IBOutlet weak var sortingBarButtonItem: UIBarButtonItem!

	var sections: [ForumSectionsElement]? {
		didSet {
			self.reloadData()
		}
	}
	var sectionsCount: Int?
	var threadSorting: String?
	var kRichTextEditorViewController: KRichTextEditorViewController?
	private var shadowImageView: UIImageView?
	lazy var viewControllers = [UIViewController]()
	var searchResultsViewController: SearchResultsTableViewController?

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
		view.theme_backgroundColor = KThemePicker.backgroundColor.rawValue

		// Search bar
		let storyboard: UIStoryboard = UIStoryboard(name: "search", bundle: nil)
		searchResultsViewController = storyboard.instantiateViewController(withIdentifier: "Search") as? SearchResultsTableViewController

		if #available(iOS 11.0, *) {
			let searchController = SearchController(searchResultsController: searchResultsViewController)
			searchController.delegate = self
			searchController.searchBar.selectedScopeButtonIndex = SearchScope.thread.rawValue
			searchController.searchResultsUpdater = searchResultsViewController

			let searchControllerBar = searchController.searchBar
			searchControllerBar.delegate = searchResultsViewController

			navigationItem.searchController = searchController
			navigationItem.hidesSearchBarWhenScrolling = false
			searchController.viewController = self
		}

		Service.shared.getForumSections(withSuccess: { (sections) in
			DispatchQueue.main.async {
				self.sectionsCount = sections?.count
				self.sections = sections
			}
		})

		dataSource = self

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

		// Style
		bar.backgroundView.style = .blur(style: .regular)
		bar.fadesContentEdges = true

		// configure the bar
		addBar(bar, dataSource: self, at: .top)
		bar.isHidden = false

		let editorStoryboard = UIStoryboard(name: "editor", bundle: nil)
		kRichTextEditorViewController = editorStoryboard.instantiateViewController(withIdentifier: "KRichTextEditorViewController") as? KRichTextEditorViewController
    }

	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillAppear(animated)

		shadowImageView?.isHidden = false
	}

	// MARK: - Functions
    private func initializeViewControllers(with count: Int) {
        let storyboard = UIStoryboard(name: "forums", bundle: nil)
        var viewControllers = [UIViewController]()

        for index in 0 ..< count {
            let viewController = storyboard.instantiateViewController(withIdentifier: "ForumsChild") as! ForumsChildViewController
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
	@IBAction func sortingButtonPressed(_ sender: UIBarButtonItem) {
		let action = UIAlertController.actionSheetWithItems(items: [("Top", "top", #imageLiteral(resourceName: "sort_top")),("Recent","recent", #imageLiteral(resourceName: "sort_recent"))], currentSelection: threadSorting, action: { (title, value)  in
			let currentSection = self.currentViewController as? ForumsChildViewController
			currentSection?.threadOrder = value
			currentSection?.pageNumber = 0
			self.sortingBarButtonItem.title = value
			self.sortingBarButtonItem.image = ForumSortingStyle(rawValue: value)?.image()
			currentSection?.fetchThreads()
		})

		action.addAction(UIAlertAction.init(title: "Cancel", style: .cancel, handler: nil))

		//Present the controller
		if let popoverController = action.popoverPresentationController {
			popoverController.sourceView = self.view
			popoverController.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
			popoverController.permittedArrowDirections = []
		}

		self.present(action, animated: true, completion: nil)
	}

	@IBAction func createThreadButton(_ sender: Any) {
		kRichTextEditorViewController?.delegate = viewControllers[currentIndex!] as! ForumsChildViewController
		kRichTextEditorViewController?.sectionID = currentIndex! + 1

		let kurozoraNavigationController = KNavigationController.init(rootViewController: kRichTextEditorViewController!)
		if #available(iOS 11.0, *) {
			kurozoraNavigationController.navigationBar.prefersLargeTitles = false
		}

		if #available(iOS 13.0, *) {
			self.present(kurozoraNavigationController, animated: true, completion: nil)
		} else {
			self.presentAsStork(kurozoraNavigationController, height: nil, showIndicator: false, showCloseButton: false)
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
		if var tabBarFrame = self.tabBarController?.tabBar.frame {
			tabBarFrame.origin.y = self.view.frame.size.height + (tabBarFrame.size.height)
			UIView.animate(withDuration: 0.5, animations: {
				self.tabBarController?.tabBar.frame = tabBarFrame
			})
		}
	}

	func willDismissSearchController(_ searchController: UISearchController) {
		if var tabBarFrame = self.tabBarController?.tabBar.frame {
			tabBarFrame.origin.y = self.view.frame.size.height - (tabBarFrame.size.height)
			UIView.animate(withDuration: 0.5, animations: {
				self.tabBarController?.tabBar.frame = tabBarFrame
			})
		}
	}
}
