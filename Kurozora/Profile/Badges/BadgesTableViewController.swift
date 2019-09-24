//
//  BadgesTableViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 02/12/2018.
//  Copyright © 2018 Kurozora. All rights reserved.
//

import UIKit
import EmptyDataSet_Swift
import SwiftyJSON

class BadgesTableViewController: UITableViewController {
	var badges: [BadgeElement]?
	var user: UserProfile? {
		didSet {
			self.badges = user?.badges
		}
	}

    override func viewDidLoad() {
        super.viewDidLoad()
		view.theme_backgroundColor = KThemePicker.backgroundColor.rawValue

		// Setup table view
		tableView.rowHeight = UITableView.automaticDimension
		tableView.estimatedRowHeight = UITableView.automaticDimension

		// Setup empty table view
		tableView.emptyDataSetView { (view) in
			if let username = self.user?.username {
				let detailLabelString = self.user?.id != User.currentID ? "\(username) has no badges to show." : "Badges you earn show up here."
				view.titleLabelString(NSAttributedString(string: "No Badges", attributes: [.font: UIFont.systemFont(ofSize: 16, weight: .medium), .foregroundColor: KThemePicker.textColor.colorValue]))
					.detailLabelString(NSAttributedString(string: detailLabelString, attributes: [.font: UIFont.systemFont(ofSize: 16), .foregroundColor: KThemePicker.subTextColor.colorValue]))
					.image(#imageLiteral(resourceName: "empty_badge"))
					.imageTintColor(KThemePicker.textColor.colorValue)
					.verticalOffset(-50)
					.verticalSpace(10)
					.isScrollAllowed(true)
			}
		}
    }

    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		if let badgesCount = badges?.count, badgesCount != 0 {
			return badgesCount
		}
        return 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let identifier = (indexPath.row % 2 == 0) ? "LeftBadgeCell" : "RightBadgeCell"
		let badgeTableViewCell = self.tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath as IndexPath) as! BadgeTableViewCell
		badgeTableViewCell.badge = self.badges?[indexPath.row]
		return badgeTableViewCell
	}
}
