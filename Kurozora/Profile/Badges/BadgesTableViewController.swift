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

class BadgesTableViewController: UITableViewController, EmptyDataSetSource, EmptyDataSetDelegate {
	var badges: [JSON]?

    override func viewDidLoad() {
        super.viewDidLoad()
		view.theme_backgroundColor = KThemePicker.backgroundColor.rawValue

		// Setup table view
		tableView.dataSource = self
		tableView.delegate = self

		tableView.rowHeight = UITableView.automaticDimension
		tableView.estimatedRowHeight = UITableView.automaticDimension

		// Setup empty table view
		tableView.emptyDataSetSource = self
		tableView.emptyDataSetDelegate = self
		tableView.emptyDataSetView { (view) in
			view.titleLabelString(NSAttributedString(string: "No badges found!"))
				.shouldDisplay(true)
				.shouldFadeIn(true)
				.isTouchAllowed(true)
				.isScrollAllowed(false)
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
		if (indexPath.row % 2 == 0) {
			let leftBadgeCell:LeftBadgeCell = self.tableView.dequeueReusableCell(withIdentifier: "LeftBadgeCell", for: indexPath as IndexPath) as! LeftBadgeCell

			// Set badge text, description and font color
			if let badgeText = badges?[indexPath.row]["text"].stringValue, badgeText != "", let badgeTextColor = badges?[indexPath.row]["textColor"].stringValue, badgeTextColor != "", let badgeDescription = badges?[indexPath.row]["description"].stringValue, badgeDescription != "" {
				leftBadgeCell.badgeTitleLabel.text = badgeText
				leftBadgeCell.badgeTitleLabel.textColor = UIColor(hexString: badgeTextColor)

				leftBadgeCell.badgeDescriptionLabel.text = badgeDescription
				leftBadgeCell.badgeDescriptionLabel.textColor = UIColor(hexString: badgeTextColor)
			}

			// Set badge image and border color
			leftBadgeCell.badgeImageView.image = #imageLiteral(resourceName: "message_icon")

			// Set background color
			if let badgeBackgroundColor = badges?[indexPath.row]["backgroundColor"].stringValue, badgeBackgroundColor != "" {
				leftBadgeCell.contentView.backgroundColor = UIColor(hexString: badgeBackgroundColor)
			}

			return leftBadgeCell
		}

		let rightBadgeCell:RightBadgeCell = self.tableView.dequeueReusableCell(withIdentifier: "RightBadgeCell", for: indexPath as IndexPath) as! RightBadgeCell

		// Set badge text, description and font color
		if let badgeText = badges?[indexPath.row]["text"].stringValue, badgeText != "", let badgeTextColor = badges?[indexPath.row]["textColor"].stringValue, badgeTextColor != "", let badgeDescription = badges?[indexPath.row]["description"].stringValue, badgeDescription != "" {
			rightBadgeCell.badgeTitleLabel.text = badgeText
			rightBadgeCell.badgeTitleLabel.textColor = UIColor(hexString: badgeTextColor)

			rightBadgeCell.badgeDescriptionLabel.text = badgeDescription
			rightBadgeCell.badgeDescriptionLabel.textColor = UIColor(hexString: badgeTextColor)
		}

		// Set badge image and border color
		rightBadgeCell.badgeImageView.image = #imageLiteral(resourceName: "message_icon")

		// Set background color
		if let badgeBackgroundColor = badges?[indexPath.row]["backgroundColor"].stringValue, badgeBackgroundColor != "" {
			rightBadgeCell.contentView.backgroundColor = UIColor(hexString: badgeBackgroundColor)
		}

		return rightBadgeCell
    }
}
