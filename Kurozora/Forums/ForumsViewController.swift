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
	var vc: KRichTextEditorControllerView?
	private var shadowImageView: UIImageView?
	lazy var viewControllers = [UIViewController]()

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
		bar.indicator.tintColor = .orange

		// State
		bar.buttons.customize { (button) in
			button.selectedTintColor = ThemeManager.color(for: "Global.tintColor")
			button.tintColor = ThemeManager.color(for: "Global.tintColor")?.withAlphaComponent(0.4)
		}

		// Layout
		bar.layout.contentInset = UIEdgeInsets(top: 0.0, left: 16.0, bottom: 4.0, right: 16.0)
		bar.layout.interButtonSpacing = 24.0

		// Style
		bar.backgroundView.style = .blur(style: .dark)
		bar.fadesContentEdges = true

		// configure the bar
		addBar(bar, dataSource: self, at: .top)
		bar.isHidden = false

		let storyboard = UIStoryboard(name: "editor", bundle: nil)
		vc = storyboard.instantiateViewController(withIdentifier: "RichEditor") as? KRichTextEditorControllerView
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
		let action = UIAlertController.actionSheetWithItems(items: [("↑ Top", "top"),("◕ Recent","recent")], currentSelection: threadSorting, action: { (title, value)  in
			let currentSection = self.currentViewController as? ForumsChildViewController
			currentSection?.threadOrder = value
			currentSection?.pageNumber = 0
			self.sortingBarButtonItem.title = title
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
		vc?.delegate = viewControllers[currentIndex!] as! ForumsChildViewController
		vc?.sectionID = currentIndex! + 1

		let kurozoraNavigationController = KurozoraNavigationController.init(rootViewController: vc!)
		if #available(iOS 11.0, *) {
			kurozoraNavigationController.navigationBar.prefersLargeTitles = false
		}

		present(kurozoraNavigationController, animated: true, completion: nil)
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
		guard let pageIndex = GlobalVariables().KUserDefaults?.integer(forKey: "ForumsPage") else { return nil }
		return .at(index: pageIndex)
	}
}

// MARK: - TMBarDataSource
extension ForumsViewController: TMBarDataSource {
	func barItem(for bar: TMBar, at index: Int) -> TMBarItemable {
		guard let sectionTitle = sections?[index].name else { return TMBarItem(title: "Section \(index)") }
		return TMBarItem(title: sectionTitle)
	}
}
