//
//  FeedViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 21/06/2019.
//  Copyright © 2019 Kurozora. All rights reserved.
//

import UIKit
import KurozoraKit
import Tabman
import Pageboy

class FeedViewController: KTabbedViewController {
	// MARK: - IBOutlets
	@IBOutlet weak var createPostButton: UIButton!
	@IBOutlet weak var profileImageButton: ProfileImageButton!

	// MARK: - Properties
	var feedSections: [FeedSection] = [] {
		didSet {
			self.reloadData()
		}
	}

	// MARK: - View
	override func viewWillReload() {
		super.viewWillReload()

		configureUserDetails()
	}

	override func viewDidLoad() {
		super.viewDidLoad()

		configureUserDetails()
	}

	// MARK: - Functions
	/// Configures the view with the user's details.
	func configureUserDetails() {
		profileImageButton.setImage(User.current?.attributes.profileImage ?? R.image.placeholders.userProfile(), for: .normal)
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
		return TMBarItem(title: feedSections[index].attributes.name)
	}

	// MARK: - PageboyViewControllerDataSource
	override func numberOfViewControllers(in pageboyViewController: PageboyViewController) -> Int {
		return feedSections.count
	}

	override func defaultPage(for pageboyViewController: PageboyViewController) -> PageboyViewController.Page? {
		return nil
	}
}

// MARK: - KTabbedViewControllerDataSource
extension FeedViewController {
	override func initializeViewControllers(with count: Int) -> [UIViewController]? {
		var viewControllers = [UIViewController]()

		for index in 0 ..< count {
			if let feedTableViewController = R.storyboard.feed.feedTableViewController() {
				feedTableViewController.sectionTitle = feedSections[index].attributes.name
				feedTableViewController.sectionID = feedSections[index].id
				feedTableViewController.sectionIndex = index
				viewControllers.append(feedTableViewController)
			}
		}

		return viewControllers
	}

	override func fetchSections() {
//		KService.getFeedSections { [weak self] result in
//			guard let self = self else { return }
//
//			switch result {
//			case .success(let feedSections):
//				DispatchQueue.main.async {
//					self.feedSections = feedSections
//				}
//			case .failure: break
//			}
//		}
	}
}
