//
//  AchievementsTableViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 02/12/2018.
//  Copyright © 2018 Kurozora. All rights reserved.
//

import UIKit
import KurozoraKit

class AchievementsTableViewController: KTableViewController {
	// MARK: - Properties
	var achievements: [Badge] = [] {
		didSet {
			self._prefersActivityIndicatorHidden = true
			self.tableView.reloadData {
				self.toggleEmptyDataView()
			}
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

	// Refresh control
	var _prefersRefreshControlDisabled = false {
		didSet {
			self.setNeedsRefreshControlAppearanceUpdate()
		}
	}
	override var prefersRefreshControlDisabled: Bool {
		return self._prefersRefreshControlDisabled
	}

	// MARK: - View
    override func viewDidLoad() {
        super.viewDidLoad()

		self._prefersRefreshControlDisabled = true
		self.achievements = self.user.relationships?.badges?.data ?? []
    }

	// MARK: - Functions
	override func configureEmptyDataView() {
		var detailString: String

		if self.user?.id == User.current?.id {
			detailString = "achievements you earn show up here."
		} else {
			detailString = "\(self.user.attributes.username) has not earned any achievements yet."
		}

		self.emptyBackgroundView.configureImageView(image: R.image.empty.badge()!)
		self.emptyBackgroundView.configureLabels(title: "No Badges", detail: detailString)

		self.tableView.backgroundView?.alpha = 0
	}

	/// Fades in and out the empty data view according to the number of sections.
	func toggleEmptyDataView() {
		if self.tableView.numberOfSections == 0 {
			self.tableView.backgroundView?.animateFadeIn()
		} else {
			self.tableView.backgroundView?.animateFadeOut()
		}
	}
}

// MARK: - UITableViewDataSource
extension AchievementsTableViewController {
	override func numberOfSections(in tableView: UITableView) -> Int {
		return self.achievements.count
	}

	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return 1
	}

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let identifier = (indexPath.section % 2 == 0) ? R.reuseIdentifier.leftBadgeCell : R.reuseIdentifier.rightBadgeCell
		guard let badgeTableViewCell = self.tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath as IndexPath) else {
			fatalError("Cannot dequeue cell with reuse identifier \(identifier.identifier)")
		}
		badgeTableViewCell.configureCell(using: self.achievements[indexPath.section])
		return badgeTableViewCell
	}
}
