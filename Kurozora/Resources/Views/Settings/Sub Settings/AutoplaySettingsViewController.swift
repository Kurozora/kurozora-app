//
//  AutoplaySettingsViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 24/08/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import UIKit

class AutoplaySettingsViewController: SubSettingsViewController {
	// MARK: - Properties
	/// The policies offered, ordered from most to least permissive.
	private let policies: [VideoAutoplayPolicy] = [.wifiAndCellular, .wifiOnly, .never]

	// MARK: - Initializers
	init() {
		super.init(style: .insetGrouped)
	}

	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	// MARK: - View
	override func viewDidLoad() {
		super.viewDidLoad()

		self.title = L10n.autoplay
		self.tableView.cellLayoutMarginsFollowReadableWidth = true
	}
}

// MARK: - UITableViewDataSource
extension AutoplaySettingsViewController {
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return self.policies.count
	}

	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		guard let cell = tableView.dequeueReusableCell(withIdentifier: IconTableViewCell.self, for: indexPath) else {
			fatalError("Cannot dequeue reusable cell with identifier \(IconTableViewCell.reuseID).")
		}
		let policy = self.policies[indexPath.row]

		cell.configure(title: policy.titleValue)
		cell.setSelected(policy == UserSettings.videoAutoplayPolicy)
		return cell
	}

	override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
		return L10n.autoplayFooter
	}
}

// MARK: - UITableViewDelegate
extension AutoplaySettingsViewController {
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		UserSettings.set(self.policies[indexPath.row].rawValue, forKey: .videoAutoplayPolicy)
		tableView.reloadData()
	}
}

// MARK: - KTableViewDataSource
extension AutoplaySettingsViewController {
	override func registerCells(for tableView: UITableView) -> [UITableViewCell.Type] {
		return [IconTableViewCell.self]
	}
}
