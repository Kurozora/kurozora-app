//
//  BadgesTableViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 02/12/2018.
//  Copyright © 2018 Kurozora. All rights reserved.
//

import UIKit
import KurozoraKit

class BadgesTableViewController: KTableViewController {
	// MARK: - Properties
	var badges: [Badge] = [] {
		didSet {
			_prefersActivityIndicatorHidden = true
		}
	}
	var user: User!

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

		self.badges = self.user.relationships?.badges?.data ?? []
    }

	// MARK: - Functions
	override func configureEmptyDataView() {
		tableView.emptyDataSetView { [weak self] (view) in
			guard let self = self else { return }

			let username = self.user.attributes.username
			let detailLabelString = self.user?.id != User.current?.id ? "\(username) has no badges to show." : "Badges you earn show up here."

			view.titleLabelString(NSAttributedString(string: "No Badges", attributes: [.font: UIFont.systemFont(ofSize: 16, weight: .medium), .foregroundColor: KThemePicker.textColor.colorValue]))
				.detailLabelString(NSAttributedString(string: detailLabelString, attributes: [.font: UIFont.systemFont(ofSize: 16), .foregroundColor: KThemePicker.subTextColor.colorValue]))
				.image(R.image.empty.badge())
				.imageTintColor(KThemePicker.textColor.colorValue)
				.verticalOffset(-50)
				.verticalSpace(5)
				.isScrollAllowed(true)
		}
	}
}

// MARK: - UITableViewDataSource
extension BadgesTableViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return badges.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let identifier = (indexPath.row % 2 == 0) ? R.reuseIdentifier.leftBadgeCell : R.reuseIdentifier.rightBadgeCell
		guard let badgeTableViewCell = self.tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath as IndexPath) else {
			fatalError("Cannot dequeue cell with reuse identifier \(identifier.identifier)")
		}
		return badgeTableViewCell
	}
}

// MARK: - UITableViewDelegate
extension BadgesTableViewController {
	override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
		let badgeTableViewCell = cell as? BadgeTableViewCell
		badgeTableViewCell?.badge = self.badges[indexPath.row]
	}
}
