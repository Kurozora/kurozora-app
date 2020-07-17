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

class ForumsViewController: KTabbedViewController {
	// MARK: - IBOutlets
    @IBOutlet weak var createThreadBarButtonItem: UIBarButtonItem!
	@IBOutlet weak var sortingBarButtonItem: UIBarButtonItem!

	// MARK: - Properties
	var sections: [ForumsSectionElement]? {
		didSet {
			self.reloadData()
		}
	}
	var forumOrder: ForumOrder = .top
	var kSearchController: KSearchController = KSearchController()

	// MARK: - View
	override func viewDidLoad() {
        super.viewDidLoad()

		// Setup search bar.
		setupSearchBar()
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

	// MARK: - IBActions
	@IBAction func sortingBarButtonItemPressed(_ sender: UIBarButtonItem) {
		let alertController = UIAlertController.actionSheetWithItems(items: ForumOrder.alertControllerItems, currentSelection: forumOrder, action: { (title, value, image)  in
			self.forumOrder = value

			let currentSection = self.currentViewController as? ForumsListViewController
			currentSection?.nextPageURL = nil
			currentSection?.forumOrder = value
			self.sortingBarButtonItem.title = title
			self.sortingBarButtonItem.image = image
			currentSection?.fetchThreads()
		})

		alertController.addAction(UIAlertAction.init(title: "Cancel", style: .cancel, handler: nil))

		//Present the controller
		if let popoverController = alertController.popoverPresentationController {
			popoverController.barButtonItem = sender
		}

		if (self.navigationController?.visibleViewController as? UIAlertController) == nil {
			self.present(alertController, animated: true, completion: nil)
		}
	}

	@IBAction func createThreadBarButtonItemPressed(_ sender: Any) {
		WorkflowController.shared.isSignedIn {
			if let kRichTextEditorViewController = R.storyboard.textEditor.kRichTextEditorViewController() {
				if let currentIndex = self.currentIndex {
					kRichTextEditorViewController.delegate = self.viewControllers?[currentIndex] as? ForumsListViewController
					kRichTextEditorViewController.sectionID = currentIndex + 1
				}

				let kurozoraNavigationController = KNavigationController.init(rootViewController: kRichTextEditorViewController)
				kurozoraNavigationController.navigationBar.prefersLargeTitles = false
				self.present(kurozoraNavigationController)
			}
		}
	}

	// MARK: - TMBarDataSource
	override func barItem(for bar: TMBar, at index: Int) -> TMBarItemable {
		guard let sectionTitle = sections?[index].name else { return TMBarItem(title: "Section \(index)") }
		return TMBarItem(title: sectionTitle)
	}

	// MARK: - PageboyViewControllerDataSource
	override func numberOfViewControllers(in pageboyViewController: PageboyViewController) -> Int {
		if let sectionsCount = sections?.count, sectionsCount != 0 {
			return sectionsCount
		}
		return 0
	}

	override func defaultPage(for pageboyViewController: PageboyViewController) -> PageboyViewController.Page? {
		return .at(index: UserSettings.forumsPage)
	}
}

// MARK: - KTabbedViewControllerDataSource
extension ForumsViewController {
	override func initializeViewControllers(with count: Int) -> [UIViewController]? {
		var viewControllers = [UIViewController]()

		for index in 0 ..< count {
			if let forumsListViewController = R.storyboard.forums.forumsListViewController() {
				guard let sectionTitle = sections?[index].name else { return nil }
				forumsListViewController.sectionTitle = sectionTitle

				if let sectionID = sections?[index].id, sectionID != 0 {
					forumsListViewController.sectionID = sectionID
				}
				forumsListViewController.sectionIndex = index
				viewControllers.append(forumsListViewController)
			}
		}

		return viewControllers
	}

	override func fetchSections() {
		KService.getForumSections { result in
			switch result {
			case .success(let sections):
				DispatchQueue.main.async {
					self.sections = sections
				}
			case .failure: break
			}
		}
	}
}
