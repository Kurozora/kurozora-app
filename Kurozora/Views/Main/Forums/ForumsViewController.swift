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
	var forumsSections: [ForumsSection] = [] {
		didSet {
			self.reloadData()

			#if targetEnvironment(macCatalyst)
			self.touchBar = nil
			#endif
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

	/// Focuses on the search bar.
	@objc func toggleSearchBar() {
		self.navigationItem.searchController?.searchBar.textField?.becomeFirstResponder()
	}

	#if targetEnvironment(macCatalyst)
	/// Goes to the selected view.
	@objc func goToSelectedView(_ touchBarItem: NSPickerTouchBarItem) {
		self.bar.delegate?.bar(self.bar, didRequestScrollTo: touchBarItem.selectedIndex)
	}
	#endif

	/// Presents the text editor for creating new threads.
	@objc func createNewThread() {
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
		self.createNewThread()
	}

	// MARK: - TMBarDataSource
	override func barItem(for bar: TMBar, at index: Int) -> TMBarItemable {
		return TMBarItem(title: forumsSections[index].attributes.name)
	}

	// MARK: - TMBarDelegate
	override func bar(_ bar: TMBar, didRequestScrollTo index: PageboyViewController.PageIndex) {
		super.bar(bar, didRequestScrollTo: index)
		#if targetEnvironment(macCatalyst)
		self.tabBarTouchBarItem?.selectedIndex = index
		#endif
	}

	// MARK: - PageboyViewControllerDataSource
	override func numberOfViewControllers(in pageboyViewController: PageboyViewController) -> Int {
		return forumsSections.count
	}

	override func defaultPage(for pageboyViewController: PageboyViewController) -> PageboyViewController.Page? {
		#if targetEnvironment(macCatalyst)
		self.tabBarTouchBarItem?.selectedIndex = UserSettings.forumsPage
		#endif
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
			if let forumsListViewController = R.storyboard.forumsList.forumsListViewController() {
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

// MARK: - NSTouchBarDelegate
#if targetEnvironment(macCatalyst)
extension ForumsViewController: NSTouchBarDelegate {
	override func makeTouchBar() -> NSTouchBar? {
		let touchBar = NSTouchBar()
		touchBar.delegate = self
		touchBar.defaultItemIdentifiers = [
			.fixedSpaceSmall,
			.toggleSearchBar,
			.fixedSpaceSmall,
			.listTabBar,
			.flexibleSpace,
			.forumsComposeThread
		]
		return touchBar
	}

	func touchBar(_ touchBar: NSTouchBar, makeItemForIdentifier identifier: NSTouchBarItem.Identifier) -> NSTouchBarItem? {
		let touchBarItem: NSTouchBarItem?

		switch identifier {
		case .toggleSearchBar:
			guard let image = UIImage(systemName: "magnifyingglass") else { return nil }
			touchBarItem = NSButtonTouchBarItem(identifier: identifier, image: image, target: self, action: #selector(toggleSearchBar))
		case .listTabBar:
			let labels: [String] = forumsSections.map { (forumsSection) -> String in
				forumsSection.attributes.name
			}

			tabBarTouchBarItem = NSPickerTouchBarItem(identifier: identifier, labels: labels, selectionMode: .selectOne, target: self, action: #selector(goToSelectedView(_:)))
			tabBarTouchBarItem?.selectedIndex = self.currentIndex ?? 0
			touchBarItem = tabBarTouchBarItem
		case .forumsComposeThread:
			guard let image = UIImage(systemName: "pencil.circle") else { return nil }
			touchBarItem = NSButtonTouchBarItem(identifier: identifier, image: image, target: self, action: #selector(createNewThread))
		default:
			touchBarItem = nil
		}
		return touchBarItem
	}
}
#endif
