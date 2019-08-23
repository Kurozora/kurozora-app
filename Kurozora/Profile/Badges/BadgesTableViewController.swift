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
	var badges: [BadgeElement]?

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
		let identifier = (indexPath.row % 2 == 0) ? "LeftBadgeCell" : "RightBadgeCell"
		let badgeTableViewCell = self.tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath as IndexPath) as! BadgeTableViewCell
		badgeTableViewCell.badge = self.badges?[indexPath.row]
		return badgeTableViewCell
	}
}
