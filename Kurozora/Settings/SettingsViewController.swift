//
//  SettingsViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 21/04/2018.
//  Copyright © 2018 Kusa. All rights reserved.
//

import UIKit
import KCommonKit
import Kingfisher
import SCLAlertView

let DefaultLoadingScreen = "Defaults.InitialLoadingScreen";

class SettingsViewController: UITableViewController {
	@IBOutlet weak var usernameLabel: UILabel!
	@IBOutlet weak var userAvatar: UIImageView!
	@IBOutlet weak var cacheSizeLabel: UILabel!

    //    let FacebookPageDeepLink = "fb://profile/713541968752502"
    //    let FacebookPageURL = "https://www.facebook.com/KurozoraApp"
    let TwitterPageDeepLink = "twitter://user?id=991929359052177409"
    let TwitterPageURL = "https://www.twitter.com/KurozoraApp"
    let MediumPageDeepLink = "medium://@kurozora"
    let MediumPageURL = "https://medium.com/@kurozora"

	// Section vars
	let sectionTitles = ["Account", "Admin", "System", "General", "IAP", "Rate", "Social", "Privacy"]
	var numberOfCollapsedCells = 0
	var icons = [UIImage]()
	var firstTime = true

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
		
		userAvatar.image = User.currentUserAvatar()
        usernameLabel.text = GlobalVariables().KDefaults["username"]
        
        // Calculate cache size
        caculateCache()
    }

	override func viewDidLoad() {
		super.viewDidLoad()
		view.theme_backgroundColor = "Global.backgroundColor"
		
		// facebookLikeButton.objectID = "https://www.facebook.com/KurozoraApp"
		tableView.register(UINib(nibName: "CollapsibleSectionHeaderCell", bundle: nil), forCellReuseIdentifier: "SectionHeaderCell")
		tableView.register(UINib(nibName: "CollapsedIconTableCell", bundle: nil), forCellReuseIdentifier: "CollapsedIconTableCell")
		caculateCache()
//		UserSettings.set([], forKey: .collapsedSections)
		if firstTime {
			firstTime = false
			tableView.reloadData()
		}
	}

	override func viewWillLayoutSubviews() {
		super.viewWillLayoutSubviews()

		for cell in tableView.visibleCells {
			guard let indexPath = tableView.indexPath(for: cell) else { return }
			var rectCorner: UIRectCorner!
			var roundCorners = true
			let numberOfRows: Int = tableView.numberOfRows(inSection: indexPath.section)

			if numberOfRows == 1 {
				// single cell
				rectCorner = UIRectCorner.allCorners
			} else if indexPath.row == numberOfRows - 1 {
				// bottom cell
				rectCorner = [.bottomLeft, .bottomRight]
			} else if indexPath.row == 0 {
				// top cell
				rectCorner = [.topLeft, .topRight]
			} else {
				roundCorners = false
			}

			if roundCorners {
				tableView.cellForRow(at: indexPath)?.contentView.roundedCorners(rectCorner, radius: 10)
			}
		}
	}
    
    // MARK: - Functions
    func caculateCache() {
		ImageCache.default.calculateDiskStorageSize { (result) in
			switch result {
			case .success(let size):
				// Convert from bytes to mebibytes (2^20)
				let sizeInMiB = Double(size) / 1024 / 1024
				self.cacheSizeLabel.text = String(format:"%.2f", sizeInMiB) + "MiB"
			case .failure(let error):
				print("Cache size calculation error: \(error)")
			}
		}
    }

	func getIcons(for section: Int) {
		numberOfCollapsedCells = tableView.numberOfRows(inSection: section)
		icons = []
		for rowIndex in 1...numberOfCollapsedCells {
			guard let cell = tableView.cellForRow(at: IndexPath(row: rowIndex-1, section: section)) else { return }
			for subview in cell.contentView.subviews {
				if let view = subview as? DesignableView {
					for subview in view.subviews {
						if let icon = subview as? UIImageView, let iconImage = icon.image {
							icons.append(iconImage)
						}
					}
				}
			}
		}
	}

	@objc func collapse(_ sender: UIButton) {
		var collapsedSections = UserSettings.collapsedSections()

		getIcons(for: sender.tag)

		if let sectionIndex = collapsedSections.firstIndex(of: sender.tag) {
			collapsedSections.remove(at: sectionIndex)
		} else {
			collapsedSections.append(sender.tag)
		}

		UserSettings.set(collapsedSections, forKey: .collapsedSections)
		tableView.reloadSections([sender.tag], with: .fade)
	}
    
    // MARK: - IBActions
    @IBAction func dismissPressed(_ sender: AnyObject) {
		firstTime = true
        self.dismiss(animated: true, completion: nil)
    }
}

// MARK: - UITableViewDataSource
extension SettingsViewController {
	override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
		return 44
	}

	override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
		let numberOfRows: Int = tableView.numberOfRows(inSection: section)

		let sectionCell = tableView.dequeueReusableCell(withIdentifier: "SectionHeaderCell") as! CollapsibleSectionHeaderCell
		sectionCell.sectionTitleLabel.text = sectionTitles[section]
		sectionCell.sectionTitleLabel.theme_textColor = "Global.textColor"
		sectionCell.sectionButton.tag = section
		sectionCell.sectionButton.addTarget(self, action: #selector(collapse(_:)), for: .touchUpInside)

		let collapsedSections = UserSettings.collapsedSections()
		if collapsedSections.contains(section) {
			sectionCell.sectionButton.setTitle("Show More", for: .normal)
		} else {
			sectionCell.sectionButton.setTitle("Show Less", for: .normal)
		}

		if numberOfRows == 1 && sectionCell.sectionButton.title(for: .normal) == "Show Less" {
			sectionCell.sectionButton.isEnabled = false
			sectionCell.sectionButton.isHidden = true
		}

		return sectionCell.contentView
	}

	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		let count = super.tableView(tableView, numberOfRowsInSection: section)
		if let isAdmin = User.isAdmin() {
			if !isAdmin && section == 1 {
				return count - 1
			}
		}

		let collapsedSections = UserSettings.collapsedSections()
		if collapsedSections.contains(section) && !firstTime {
			return 1
		}

		return count
	}

	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let collapsedSections = UserSettings.collapsedSections()

		if let isAdmin = User.isAdmin() {
			if !isAdmin && indexPath.section == 1 {
				return super.tableView(tableView, cellForRowAt: IndexPath(row: 0, section: indexPath.section + 1))
			}
		}

		if collapsedSections.contains(indexPath.section) && !firstTime {
			let collapsedIconTableCell = tableView.dequeueReusableCell(withIdentifier: "CollapsedIconTableCell", for: indexPath) as! CollapsedIconTableCell
			collapsedIconTableCell.numberOfCollapsedItems = numberOfCollapsedCells
			collapsedIconTableCell.icons = icons

			return collapsedIconTableCell
		}

		return super.tableView(tableView, cellForRowAt: indexPath)
	}

	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		tableView.deselectRow(at: indexPath, animated: true)

		switch (indexPath.section, indexPath.row) {
		// case (0,0): break
		// case (1,0): break
		// case (2,0): break
		case (3,1): // Clear cache
			let alertView = SCLAlertView()
			alertView.addButton("Clear 🗑", action: {
				// Clear memory cache right away.
				KingfisherManager.shared.cache.clearMemoryCache()

				// Clear disk cache. This is an async operation.
				KingfisherManager.shared.cache.clearDiskCache()

				// Clean expired or size exceeded disk cache. This is an async operation.
				KingfisherManager.shared.cache.cleanExpiredDiskCache()

				// Refresh cacheSizeLabel
				self.caculateCache()
			})

			alertView.showWarning("Clear all cache?", subTitle: "All of your caches will be cleared and Kurozora will restart.", closeButtonTitle: "Cancel")
			//        case (0,2):
			//        case (3,0):
			//            // Unlock features
			//            let controller = UIStoryboard(name: "InApp", bundle: nil).instantiateViewControllerWithIdentifier("InApp") as! InAppPurchaseViewController
			//            navigationController?.pushViewController(controller, animated: true)
			//        case (3,1):
			//            // Restore purchases
			//            InAppTransactionController.restorePurchases().continueWithBlock({ (task: BFTask!) -> AnyObject? in
			//
			//                if let _ = task.result {
			//                    let alert = UIAlertController(title: "Restored!", message: nil, preferredStyle: UIAlertControllerStyle.Alert)
			//                    alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
			//
			//                    self.presentViewController(alert, animated: true, completion: nil)
			//                }
			//
			//                return nil
			//            })
			//        case (4,0):
			//            // Rate app
		//            iRate.sharedInstance().openRatingsPageInAppStore()
		case (5,0): // Open Twitter
			var url: URL?
			let twitterScheme = URL(string: "twitter://")!

			if UIApplication.shared.canOpenURL(twitterScheme) {
				url = URL(string: TwitterPageDeepLink)
			} else {
				url = URL(string: TwitterPageURL)
			}
			UIApplication.shared.open(url!, options: [:], completionHandler: nil)
		case (5,1): // Open Medium
			var url: URL?
			let mediumScheme = URL(string: "medium://")!

			if UIApplication.shared.canOpenURL(mediumScheme) {
				url = URL(string: MediumPageDeepLink)
			} else {
				url = URL(string: MediumPageURL)
			}
			UIApplication.shared.open(url!, options: [:], completionHandler: nil)
		default: break
//			SCLAlertView().showInfo(String(indexPath.section), subTitle: String(indexPath.row))
		}
	}

	//    override func tableView(tableView: UITableView, titleForFooterInSection section: Int) -> String? {
	//
	//        switch section {
	//        case 0:
	//            return nil
	//        case 1:
	//            var message = ""
	//            if let user = User.currentUser(),
	//                user.hasTrial() &&
	//                    InAppController.purchasedPro() == nil &&
	//                    InAppController.purchasedProPlus() == nil {
	//                message = "** You're on a 15 day PRO trial **\n"
	//            }
	//            message += "Going PRO unlocks all features and help us keep improving the app"
	//            return message
	//        case 2:
	//            return "If you're looking for support drop us a message on Facebook or Twitter"
	//        case 3:
	//            let version = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as! String
	//            let build = Bundle.main.infoDictionary!["CFBundleVersion"] as! String
	//            return "Created by Anime fans for Anime fans, enjoy!\nKurozora \(version) (\(build))"
	//        default:
	//            return nil
	//        }
	//    }
}

// MARK: - UITableViewDelegate
extension SettingsViewController {
	override func tableView(_ tableView: UITableView, willDisplayFooterView view: UIView, forSection section: Int) {
		if let footerView = view as? UITableViewHeaderFooterView {
			footerView.textLabel?.theme_textColor = "Global.textColor"
			footerView.textLabel?.alpha = 0.50
		}
	}
}
