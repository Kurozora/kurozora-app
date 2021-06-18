//
//  KTabBarController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 24/07/2018.
//  Copyright © 2018 Kurozora. All rights reserved.
//

import UIKit
import KurozoraKit
import ESTabBarController_swift

class KTabBarController: ESTabBarController {
	// MARK: - Properties
//	fileprivate var once: Bool = false

	override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
		super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
		self.sharedInit()
	}

	required init?(coder: NSCoder) {
		super.init(coder: coder)
		self.sharedInit()
	}

	// MARK: - View
//	override func viewWillAppear(_ animated: Bool) {
//		super.viewWillAppear(animated)
//
//		if !once {
//			self.tabBar.isTranslucent = true
//			self.tabBar.itemPositioning = .centered
//			self.tabBar.backgroundColor = .clear
//			self.tabBar.barStyle = .default
//
//			once = true
//		}
//	}

    override func viewDidLoad() {
		super.viewDidLoad()

		// Initialize views
		viewControllers = TabBarItem.allCases.map {
			let rootNavigationController = $0.kViewControllerValue
			rootNavigationController.tabBarItem = ESTabBarItem(BounceAnimation(), title: $0.stringValue, image: $0.imageValue, selectedImage: $0.selectedImageValue)
			return rootNavigationController
		}

		setupBadgeValue()
		NotificationCenter.default.addObserver(self, selector: #selector(toggleBadge), name: .KSNotificationsBadgeIsOn, object: nil)
    }

	// MARK: - Functions
	/// The shared settings used to initialize tab bar view.
	private func sharedInit() {
		self.tabBar.isTranslucent = true
		self.tabBar.itemPositioning = .centered
		self.tabBar.backgroundColor = .clear
		self.tabBar.barStyle = .default
	}

	/// Toggles the badge on/off on the tab bar item.
	@objc func toggleBadge() {
		setupBadgeValue()
	}

	/// Sets up the badge value on the tab bar item.
	fileprivate func setupBadgeValue() {
		if UserSettings.notificationsBadge, User.isSignedIn {
			self.tabBar.items?[3].badgeValue = "\(69)"
		} else {
			self.tabBar.items?[3].badgeValue = nil
		}
	}
}

extension KTabBarController {
	override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
		let selectedTwice = tabBar.selectedItem == item

		super.tabBar(tabBar, didSelect: item)

		if selectedTwice {
			let selectedViewController = (viewControllers?[selectedIndex] as? KNavigationController)?.visibleViewController
			switch selectedIndex {
			case 0:
				(selectedViewController as? UICollectionViewController)?.collectionView.safeScrollToItem(at: [0, 0], at: .top, animated: true)
			case 1:
				((selectedViewController as? KTabbedViewController)?.currentViewController as? UICollectionViewController)?.collectionView.safeScrollToItem(at: [0, 0], at: .top, animated: true)
			case 2:
				((selectedViewController as? KTabbedViewController)?.currentViewController as? UITableViewController)?.tableView.safeScrollToRow(at: [0, 0], at: .top, animated: true)
			case 3:
				(selectedViewController as? UITableViewController)?.tableView.safeScrollToRow(at: [0, 0], at: .top, animated: true)
			case 4:
				(selectedViewController as? UITableViewController)?.tableView.safeScrollToRow(at: [0, 0], at: .top, animated: true)
			default: break
			}
		}
	}
}

enum TabBarItem: Int, CaseIterable {
	case home = 0
	case library
	case forums
	case notifications
	case feed

	private struct RowIdentifier {
		static let home = UUID()
		static let library = UUID()
		static let forums = UUID()
		static let notifications = UUID()
		static let feed = UUID()
	}

	var stringValue: String {
		switch self {
		case .home:
			return "Explore"
		case .library:
			return "Library"
		case .forums:
			return "Forums"
		case .notifications:
			return "Notifications"
		case .feed:
			return "Feed"
		}
	}

	var imageValue: UIImage {
		switch self {
		case .home:
			return UIImage(systemName: "house")!
		case .library:
			return UIImage(systemName: "rectangle.stack")!
		case .forums:
			return UIImage(systemName: "doc.plaintext")!
		case .notifications:
			return UIImage(systemName: "app.badge")!
		case .feed:
			return UIImage(systemName: "person.crop.circle")!
		}
	}

	var selectedImageValue: UIImage {
		switch self {
		case .home:
			return UIImage(systemName: "house.fill")!
		case .library:
			return UIImage(systemName: "rectangle.stack.fill")!
		case .forums:
			return UIImage(systemName: "doc.plaintext.fill")!
		case .notifications:
			return UIImage(systemName: "app.badge.fill")!
		case .feed:
			return UIImage(systemName: "person.crop.circle.fill")!
		}
	}

	var viewControllerValue: UIViewController {
		switch self {
		case .home:
			return R.storyboard.home.homeCollectionViewController()!
		case .library:
			return R.storyboard.library.libraryViewController()!
		case .forums:
			return R.storyboard.forums.forumsViewController()!
		case .notifications:
			return R.storyboard.notifications.notificationsTableViewController()!
		case .feed:
			return R.storyboard.feed.feedTableViewController()!
		}
	}

	var kViewControllerValue: UIViewController {
		switch self {
		case .home:
			return R.storyboard.home.homeKNavigationController()!
		case .library:
			return R.storyboard.library.libraryKNavigationController()!
		case .forums:
			return R.storyboard.forums.forumsKNavigationController()!
		case .notifications:
			return R.storyboard.notifications.notificationKNvaigationController()!
		case .feed:
			return R.storyboard.feed.feedTableKNavigationController()!
		}
	}

	var rowIdentifierValue: UUID {
		switch self {
		case .home:
			return RowIdentifier.home
		case .library:
			return RowIdentifier.library
		case .forums:
			return RowIdentifier.forums
		case .notifications:
			return RowIdentifier.notifications
		case .feed:
			return RowIdentifier.feed
		}
	}
}
