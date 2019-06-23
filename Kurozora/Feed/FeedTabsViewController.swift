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
	@IBOutlet var tableView: UITableView!
	@IBOutlet weak var createThreadButton: UIButton!

	var sections: [FeedSectionsElement]? {
		didSet {
			self.reloadData()
		}
	}
	var sectionsCount: Int?
	var kRichTextEditorControllerView: KRichTextEditorControllerView?
//	private var shadowImageView: UIImageView?
	lazy var viewControllers = [UITableViewController]()

	let bar = TMBar.ButtonBar()

	//	override func viewWillAppear(_ animated: Bool) {
	//		super.viewWillAppear(animated)
	//
	//		if shadowImageView == nil {
	//			shadowImageView = findShadowImage(under: navigationController!.navigationBar)
	//		}
	//		shadowImageView?.isHidden = true
	//	}

	override func viewDidLoad() {
		super.viewDidLoad()
		view.theme_backgroundColor = KThemePicker.backgroundColor.rawValue

		Service.shared.getFeedSections(withSuccess: { (sections) in
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
			button.selectedTintColor = ThemeManager.color(for: KThemePicker.tintColor.stringValue())
			button.tintColor = ThemeManager.color(for: KThemePicker.tintColor.stringValue())?.withAlphaComponent(0.4)
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

		let storyboard = UIStoryboard(name: "editor", bundle: nil)
		kRichTextEditorControllerView = storyboard.instantiateViewController(withIdentifier: "RichEditor") as? KRichTextEditorControllerView
	}

//	override func viewWillDisappear(_ animated: Bool) {
//		super.viewWillAppear(animated)
//
//		shadowImageView?.isHidden = false
//	}

	// MARK: - Functions
	private func initializeViewControllers(with count: Int) {
		let storyboard = UIStoryboard(name: "feed", bundle: nil)
		var viewControllers = [UITableViewController]()

		for index in 0 ..< count {
			let viewController = storyboard.instantiateViewController(withIdentifier: "Feed") as! FeedTableViewController
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

//	private func findShadowImage(under view: UIView) -> UIImageView? {
//		if view is UIImageView && view.bounds.size.height <= 1 {
//			return (view as! UIImageView)
//		}
//
//		for subview in view.subviews {
//			if let imageView = findShadowImage(under: subview) {
//				return imageView
//			}
//		}
//		return nil
//	}

	// MARK: - IBActions
	@IBAction func createThreadButton(_ sender: Any) {
		kRichTextEditorControllerView?.delegate = viewControllers[currentIndex!] as! FeedTableViewController
		kRichTextEditorControllerView?.sectionID = currentIndex! + 1

		let kurozoraNavigationController = KNavigationController.init(rootViewController: kRichTextEditorControllerView!)
		if #available(iOS 11.0, *) {
			kurozoraNavigationController.navigationBar.prefersLargeTitles = false
		}

		present(kurozoraNavigationController, animated: true, completion: nil)
	}
}

// MARK: - PageboyViewControllerDataSource
extension FeedTabsViewController: PageboyViewControllerDataSource {
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
