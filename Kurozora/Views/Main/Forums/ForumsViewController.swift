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

protocol ForumsViewControllerDelegate: class {
	/**
		Tells your `ForumsViewControllerDelegate` to order the forums with the specified order type.

		- Parameter forumOrder: The order type by which the forums should be ordered.
	*/
	func orderForums(by forumOrder: ForumOrder)

	/**
		Tells your `ForumsViewControllerDelegate` the current order value used to order the items in the forums.

		- Returns: The current order value used to order the items in the forums.
	*/
	func orderValue() -> ForumOrder
}

class ForumsViewController: KTabbedViewController {
	// MARK: - IBOutlets
    @IBOutlet weak var createThreadBarButtonItem: UIBarButtonItem!
	@IBOutlet weak var sortingBarButtonItem: UIBarButtonItem!

	// MARK: - Properties
	var forumsSections: [ForumsSection] = [] {
		didSet {
			self.reloadData()
		}
	}
	var kSearchController: KSearchController = KSearchController()

	weak var forumsViewControllerDelegate: ForumsViewControllerDelegate?

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

	/// Updates the sort type button icon to reflect the current sort type when switching between views.
	fileprivate func updateForumOrderBarButtonItem(_ forumOrder: ForumOrder) {
		sortingBarButtonItem.title = forumOrder.rawValue
		sortingBarButtonItem.image = forumOrder.imageValue
	}

	// MARK: - IBActions
	@IBAction func sortingBarButtonItemPressed(_ sender: UIBarButtonItem) {
		let actionSheetAlertController = UIAlertController.actionSheetWithItems(items: ForumOrder.alertControllerItems, currentSelection: self.forumsViewControllerDelegate?.orderValue(), action: { [weak self] (title, value, image)  in
			guard let self = self else { return }
			self.forumsViewControllerDelegate?.orderForums(by: value)

			let currentSection = self.currentViewController as? ForumsListViewController
			currentSection?.nextPageURL = nil
			currentSection?.forumOrder = value
			self.sortingBarButtonItem.title = title
			self.sortingBarButtonItem.image = image
			currentSection?.fetchThreads()
		})

		// Present the controller
		if let popoverController = actionSheetAlertController.popoverPresentationController {
			popoverController.barButtonItem = sender
		}

		if (self.navigationController?.visibleViewController as? UIAlertController) == nil {
			self.present(actionSheetAlertController, animated: true, completion: nil)
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
				self.present(kurozoraNavigationController, animated: true)
			}
		}
	}

	// MARK: - TMBarDataSource
	override func barItem(for bar: TMBar, at index: Int) -> TMBarItemable {
		return TMBarItem(title: forumsSections[index].attributes.name)
	}

	// MARK: - PageboyViewControllerDataSource
	override func numberOfViewControllers(in pageboyViewController: PageboyViewController) -> Int {
		return forumsSections.count
	}

	override func defaultPage(for pageboyViewController: PageboyViewController) -> PageboyViewController.Page? {
		return .at(index: UserSettings.forumsPage)
	}
}

// MARK: - ForumsListViewControllerDelegate
extension ForumsViewController: ForumsListViewControllerDelegate {
	func updateForumOrderButton(with orderType: ForumOrder) {
		updateForumOrderBarButtonItem(orderType)
	}
}

// MARK: - KTabbedViewControllerDataSource
extension ForumsViewController {
	override func initializeViewControllers(with count: Int) -> [UIViewController]? {
		var viewControllers = [UIViewController]()

		for index in 0 ..< count {
			if let forumsListViewController = R.storyboard.forums.forumsListViewController() {
				forumsListViewController.sectionTitle = forumsSections[index].attributes.name
				forumsListViewController.sectionID = forumsSections[index].id
				forumsListViewController.sectionIndex = index
				forumsListViewController.delegate = self
				viewControllers.append(forumsListViewController)
			}
		}

		return viewControllers
	}

	override func fetchSections() {
		KService.getForumSections { [weak self] result in
			guard let self = self else { return }
			switch result {
			case .success(let forumsSections):
				DispatchQueue.main.async {
					self.forumsSections = forumsSections
				}
			case .failure: break
			}
		}
	}
}
