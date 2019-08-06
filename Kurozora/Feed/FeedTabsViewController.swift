//
//  FeedTabsViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 21/06/2019.
//  Copyright © 2019 Kurozora. All rights reserved.
//

import UIKit
import Tabman
import Pageboy
import SwiftTheme

class FeedTabsViewController: TabmanViewController {
	@IBOutlet weak var createThreadButton: UIButton!
	@IBOutlet weak var navigationProfileButton: UIButton!
	@IBOutlet weak var scrollView: UIScrollView!

	var sections: [FeedSectionsElement]? {
		didSet {
			self.reloadData()
		}
	}
	var sectionsCount: Int?
	var kRichTextEditorViewController: KRichTextEditorViewController?
	lazy var viewControllers = [UITableViewController]()

	let bar = TMBar.ButtonBar()

	override func viewDidLoad() {
		super.viewDidLoad()
		view.theme_backgroundColor = KThemePicker.backgroundColor.rawValue
		dataSource = self

		navigationProfileButton.setImage(User.currentUserAvatar, for: .normal)
		navigationProfileButton.theme_borderColor = KThemePicker.tableViewCellSubTextColor.rawValue
		navigationProfileButton.borderWidth = 2
		navigationProfileButton.cornerRadius = navigationProfileButton.height / 2

		Service.shared.getFeedSections(withSuccess: { (sections) in
			DispatchQueue.main.async {
				self.sectionsCount = sections?.count
				self.sections = sections
			}
		})

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
		if UIDevice.isPad() {
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

		view.sendSubviewToBack(scrollView)

		let storyboard = UIStoryboard(name: "editor", bundle: nil)
		kRichTextEditorViewController = storyboard.instantiateViewController(withIdentifier: "KRichTextEditorViewController") as? KRichTextEditorViewController
	}

	// MARK: - Functions
	private func initializeViewControllers(with count: Int) {
		let storyboard = UIStoryboard(name: "feed", bundle: nil)
		var viewControllers = [UITableViewController]()

		for index in 0 ..< count {
			let viewController = storyboard.instantiateViewController(withIdentifier: "FeedTableViewController") as! FeedTableViewController
//			guard let sectionTitle = sections?[index].name else { return }
//			viewController.sectionTitle = sectionTitle
			viewController.sectionTitle = "Section \(index)"

			if let sectionID = sections?[index].id, sectionID != 0 {
				viewController.sectionID = sectionID
			}
			viewController.sectionIndex = index
			viewControllers.append(viewController)
		}

		self.viewControllers = viewControllers
	}

	// MARK: - IBActions
	@IBAction func createThreadButton(_ sender: Any) {
		kRichTextEditorViewController?.delegate = viewControllers[currentIndex!] as! FeedTableViewController
		kRichTextEditorViewController?.sectionID = currentIndex! + 1

		let kurozoraNavigationController = KNavigationController.init(rootViewController: kRichTextEditorViewController!)
		if #available(iOS 11.0, *) {
			kurozoraNavigationController.navigationBar.prefersLargeTitles = false
		}

		present(kurozoraNavigationController, animated: true, completion: nil)
	}

	@IBAction func profileButtonPressed(_ sender: UIButton) {
		performSegue(withIdentifier: "ProfileSegue", sender: nil)
	}
}

// MARK: - PageboyViewControllerDataSource
extension FeedTabsViewController: PageboyViewControllerDataSource {
	func numberOfViewControllers(in pageboyViewController: PageboyViewController) -> Int {
		if let sectionsCount = sections?.count, sectionsCount != 0 {
			initializeViewControllers(with: sectionsCount)
			return sectionsCount
		}
		initializeViewControllers(with: 3)
		return 3
	}

	func viewController(for pageboyViewController: PageboyViewController, at index: PageboyViewController.PageIndex) -> UIViewController? {
		return self.viewControllers[index]
	}

	func defaultPage(for pageboyViewController: PageboyViewController) -> PageboyViewController.Page? {
		return nil
	}
}

// MARK: - TMBarDataSource
extension FeedTabsViewController: TMBarDataSource {
	func barItem(for bar: TMBar, at index: Int) -> TMBarItemable {
		guard let sectionTitle = sections?[index].name else { return TMBarItem(title: "Section \(index)") }
		return TMBarItem(title: sectionTitle)
	}
}
