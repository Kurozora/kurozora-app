//
//  AchievementsTableViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 02/12/2018.
//  Copyright © 2018 Kurozora. All rights reserved.
//

import KurozoraKit
import UIKit

class AchievementsTableViewController: KTableViewController {
	// MARK: - Properties
	var achievements: [Achievement] = [] {
		didSet {
			self._prefersActivityIndicatorHidden = true
			self.tableView.reloadData {
				self.toggleEmptyDataView()
			}
		}
	}

	var user: User?

	// Activity indicator
	var _prefersActivityIndicatorHidden = false {
		didSet {
			self.setNeedsActivityIndicatorAppearanceUpdate()
		}
	}

	override var prefersActivityIndicatorHidden: Bool {
		return self._prefersActivityIndicatorHidden
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

	// MARK: - Initializers
	init() {
		super.init(style: .insetGrouped)
	}

	required init?(coder: NSCoder) {
		super.init(coder: coder)
	}

	// MARK: - View
	override func viewDidLoad() {
		super.viewDidLoad()

		self.title = Trans.achievements

		self._prefersRefreshControlDisabled = true

		self.configureView()

		self.achievements = self.user?.relationships?.achievements?.data ?? []
	}

	// MARK: - Functions
	override func configureEmptyDataView() {
		var detailString: String

		if self.user?.id == User.current?.id {
			detailString = "Achievements you earn show up here."
		} else if let user = self.user {
			detailString = "\(user.attributes.username) has not earned any achievements yet."
		} else {
			detailString = ""
		}

		self.emptyBackgroundView.configureImageView(image: .Empty.achievement)
		self.emptyBackgroundView.configureLabels(title: "No Achievements", detail: detailString)

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

	/// Configure the view.
	private func configureView() {
		self.configureViews()
	}

	/// Configure the views.
	private func configureViews() {
		self.configureTableView()
	}

	/// Configure the table view.
	private func configureTableView() {
		self.tableView.cellLayoutMarginsFollowReadableWidth = true
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
		guard let achievementTableViewCell = self.tableView.dequeueReusableCell(withIdentifier: AchievementTableViewCell.self, for: indexPath as IndexPath) else {
			fatalError("Cannot dequeue cell with reuse identifier \(AchievementTableViewCell.reuseID)")
		}
		achievementTableViewCell.configureCell(using: self.achievements[indexPath.section])
		return achievementTableViewCell
	}
}

// MARK: - KTableViewDataSource
extension AchievementsTableViewController {
	override func registerCells(for tableView: UITableView) -> [UITableViewCell.Type] {
		[
			AchievementTableViewCell.self
		]
	}
}
