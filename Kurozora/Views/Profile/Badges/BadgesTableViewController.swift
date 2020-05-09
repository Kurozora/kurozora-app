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
	var badgeElements: [BadgeElement]? {
		didSet {
			_prefersActivityIndicatorHidden = true
		}
	}
	var userProfile: UserProfile? {
		didSet {
			self.badgeElements = userProfile?.badges
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
			if let username = self.userProfile?.username {
				let detailLabelString = self.userProfile?.id != User.current?.id ? "\(username) has no badges to show." : "Badges you earn show up here."
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
}

// MARK: - UITableViewDataSource
extension BadgesTableViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		guard let badgeElementsCount = badgeElements?.count else { return 0 }
        return badgeElementsCount
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
		badgeTableViewCell?.badgeElement = self.badgeElements?[indexPath.row]
	}
}
