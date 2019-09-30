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
	// MARK: - Properties
	var badges: [BadgeElement]?
	var user: UserProfile? {
		didSet {
			self.badges = user?.badges
		}
	}

	// MARK: - View
    override func viewDidLoad() {
        super.viewDidLoad()
		view.theme_backgroundColor = KThemePicker.backgroundColor.rawValue
		NotificationCenter.default.addObserver(self, selector: #selector(reloadEmptyDataView), name: .ThemeUpdateNotification, object: nil)

		// Setup table view
		tableView.rowHeight = UITableView.automaticDimension
		tableView.estimatedRowHeight = UITableView.automaticDimension

		// Setup empty data view
		setupEmptyDataView()
    }

	// MARK: - Functions
	/// Sets up the empty data view.
	func setupEmptyDataView() {
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

	/// Reload the empty data view.
	@objc func reloadEmptyDataView() {
		setupEmptyDataView()
		tableView.reloadData()
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
