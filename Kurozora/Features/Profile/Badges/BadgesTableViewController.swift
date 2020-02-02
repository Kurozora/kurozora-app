//
//  BadgesTableViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 02/12/2018.
//  Copyright © 2018 Kurozora. All rights reserved.
//

import UIKit
import SwiftyJSON

class BadgesTableViewController: KTableViewController {
	// MARK: - Properties
	var badges: [BadgeElement]?
	var user: UserProfile? {
		didSet {
			_prefersActivityIndicatorHidden = true
			self.badges = user?.badges
		}
	}

	// Activity indicator
	var _prefersActivityIndicatorHidden = false {
		didSet {
			self.setNeedsActivityIndicatorAppearanceUpdate()
		}
	}
	override var prefersActivityIndicatorHidden: Bool {
		return _prefersActivityIndicatorHidden
	}

	// MARK: - View
    override func viewDidLoad() {
        super.viewDidLoad()
    }

	// MARK: - Functions
	override func setupEmptyDataSetView() {
		tableView.emptyDataSetView { (view) in
			if let username = self.user?.username {
				let detailLabelString = self.user?.id != User.currentID ? "\(username) has no badges to show." : "Badges you earn show up here."
				view.titleLabelString(NSAttributedString(string: "No Badges", attributes: [.font: UIFont.systemFont(ofSize: 16, weight: .medium), .foregroundColor: KThemePicker.textColor.colorValue]))
					.detailLabelString(NSAttributedString(string: detailLabelString, attributes: [.font: UIFont.systemFont(ofSize: 16), .foregroundColor: KThemePicker.subTextColor.colorValue]))
					.image(#imageLiteral(resourceName: "empty_badge"))
					.imageTintColor(KThemePicker.textColor.colorValue)
					.verticalOffset(-50)
					.verticalSpace(5)
					.isScrollAllowed(true)
			}
		}
	}
}

// MARK: - UITableViewDataSource
extension BadgesTableViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		guard let badgesCount = badges?.count else { return 0 }
        return badgesCount
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let identifier = (indexPath.row % 2 == 0) ? "LeftBadgeCell" : "RightBadgeCell"
		let badgeTableViewCell = self.tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath as IndexPath) as! BadgeTableViewCell
		badgeTableViewCell.badge = self.badges?[indexPath.row]
		return badgeTableViewCell
	}
}
