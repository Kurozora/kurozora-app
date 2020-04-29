//
//  FeedTabsViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 21/06/2019.
//  Copyright © 2019 Kurozora. All rights reserved.
//

import UIKit
import KurozoraKit
import Tabman
import Pageboy

class FeedTabsViewController: KTabbedViewController {
	// MARK: - IBOutlets
	@IBOutlet weak var createPostButton: UIButton!
	@IBOutlet weak var navigationProfileButton: UIButton!

	// MARK: - Properties
	var sections: [FeedSectionElement]? {
		didSet {
			self.reloadData()
		}
	}

	// MARK: - View
	override func viewWillReload() {
		super.viewWillReload()

		setNavigationButtonImage()
	}

	override func viewDidLoad() {
		super.viewDidLoad()
		// Configure navigation profile button
		navigationProfileButton.theme_borderColor = KThemePicker.borderColor.rawValue
		navigationProfileButton.borderWidth = 2
		navigationProfileButton.cornerRadius = navigationProfileButton.height / 2
		setNavigationButtonImage()
	}

	// MARK: - Functions
	/// Sets the profile button image with the curren user's profile image.
	func setNavigationButtonImage() {
		navigationProfileButton.setImage(User.current?.profileImage ?? R.image.placeholders.userProfile(), for: .normal)
	}

	// MARK: - IBActions
	@IBAction func createPostButtonPressed(_ sender: UIButton) {
//		kRichTextEditorViewController?.delegate = viewControllers[currentIndex!] as! FeedTableViewController
//		kRichTextEditorViewController?.sectionID = currentIndex! + 1
//
//		let kurozoraNavigationController = KNavigationController.init(rootViewController: kRichTextEditorViewController!)
//		kurozoraNavigationController.navigationBar.prefersLargeTitles = false
//
//		present(kurozoraNavigationController, animated: true, completion: nil)
	}

	@IBAction func profileButtonPressed(_ sender: UIButton) {
		WorkflowController.shared.isSignedIn {
			if let profileTableViewController = R.storyboard.profile.profileTableViewController() {
				self.show(profileTableViewController, sender: nil)
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
		return nil
	}
}

// MARK: - KTabbedViewControllerDataSource
extension FeedTabsViewController {
	override func initializeViewControllers(with count: Int) -> [UIViewController]? {
		var viewControllers = [UIViewController]()

		for index in 0 ..< count {
			if let feedTableViewController = R.storyboard.feed.feedTableViewController() {
				guard let sectionTitle = sections?[index].name else { return nil }
				feedTableViewController.sectionTitle = sectionTitle

				if let sectionID = sections?[index].id, sectionID != 0 {
					feedTableViewController.sectionID = sectionID
				}
				feedTableViewController.sectionIndex = index
				viewControllers.append(feedTableViewController)
			}
		}

		return viewControllers
	}

	override func fetchSections() {
//		KService.getFeedSections { result in
//			switch result {
//			case .success(let sections):
//				DispatchQueue.main.async {
//					self.sections = sections
//				}
//			case .failure: break
//			}
//		}
	}
}
