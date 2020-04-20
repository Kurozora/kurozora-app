//
//  FeedTabsViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 21/06/2019.
//  Copyright © 2019 Kurozora. All rights reserved.
//

import UIKit
import KurozoraKit
import Kingfisher
import Tabman
import Pageboy
import SwiftTheme

class FeedTabsViewController: TabmanViewController {
	// MARK: - IBOutlets
	@IBOutlet weak var createThreadButton: UIButton!
	@IBOutlet weak var navigationProfileButton: UIButton!

	// MARK: - Properties
	var sections: [FeedSectionsElement]? {
		didSet {
			self.reloadData()
		}
	}
	var sectionsCount: Int?
	lazy var viewControllers = [UITableViewController]()

	let bar = TMBar.ButtonBar()

	// MARK: - View
	override func viewDidLoad() {
		super.viewDidLoad()
		view.theme_backgroundColor = KThemePicker.backgroundColor.rawValue
		NotificationCenter.default.addObserver(self, selector: #selector(reloadTabBarStyle), name: .ThemeUpdateNotification, object: nil)

		// Configure navigation profile button
		navigationProfileButton.theme_borderColor = KThemePicker.borderColor.rawValue
		navigationProfileButton.borderWidth = 2
		navigationProfileButton.cornerRadius = navigationProfileButton.height / 2
		navigationProfileButton.setImage(User.current?.profileImage, for: .normal)

		// Fetch feed sections
//		KurozoraKit.shared.getFeedSections(withSuccess: { (sections) in
//			DispatchQueue.main.async {
//				self.sectionsCount = sections?.count
//				self.sections = sections
//			}
//		})

		// Tabman view controllers
		dataSource = self

		// Tabman bar
		initTabmanBarView()
	}

	// MARK: - Functions
	private func initializeViewControllers(with count: Int) {
		var viewControllers = [UITableViewController]()

		for index in 0 ..< count {
			if let feedTableViewController = R.storyboard.feed.feedTableViewController() {
	//			guard let sectionTitle = sections?[index].name else { return }
	//			viewController.sectionTitle = sectionTitle
				feedTableViewController.sectionTitle = "Section \(index)"

				if let sectionID = sections?[index].id, sectionID != 0 {
					feedTableViewController.sectionID = sectionID
				}
				feedTableViewController.sectionIndex = index
				viewControllers.append(feedTableViewController)
			}
		}

		self.viewControllers = viewControllers
	}

	/// Applies the the style for the currently enabled theme on the tabman bar.
	private func styleTabmanBarView() {
		// Background view
		bar.backgroundView.style = .blur(style: KThemePicker.visualEffect.blurValue)

		// Indicator
		bar.indicator.weight = .light
		bar.indicator.cornerStyle = .eliptical
		bar.indicator.overscrollBehavior = .bounce
		bar.indicator.theme_tintColor = KThemePicker.tintColor.rawValue

		// State
		bar.buttons.customize { (button) in
			button.selectedTintColor = KThemePicker.tintColor.colorValue
			button.tintColor = KThemePicker.tintColor.colorValue.withAlphaComponent(0.4)
		}

		// Layout
		bar.layout.contentInset = UIEdgeInsets(top: 0.0, left: 16.0, bottom: 0.0, right: 16.0)
		bar.layout.interButtonSpacing = 24.0
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
		addBar(bar, dataSource: self, at: .top)

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

	// MARK: - IBActions
	@IBAction func createThreadButton(_ sender: Any) {
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
}

// MARK: - PageboyViewControllerDataSource
extension FeedTabsViewController: PageboyViewControllerDataSource {
	func numberOfViewControllers(in pageboyViewController: PageboyViewController) -> Int {
//		if let sectionsCount = sections?.count, sectionsCount != 0 {
//			initializeViewControllers(with: sectionsCount)
//			return sectionsCount
//		}
		initializeViewControllers(with: 1)
		return 1
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




// MARK: - Extension
extension UserProfile {
	var profileImage: UIImage? {
		let profileImageView = UIImageView()
		if let usernameInitials = username?.initials {
			let placeholderImage = usernameInitials.toImage(placeholder: R.image.placeholders.profile_image()!)
			profileImageView.setImage(with: profileImageURL ?? "", placeholder: placeholderImage)
		}
		return profileImageView.image
	}
}
