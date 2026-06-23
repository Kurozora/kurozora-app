//
//  SkipDurationSettingsViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 24/06/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import UIKit

class SkipDurationSettingsViewController: SubSettingsViewController {
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

		self.title = L10n.skipDuration
		self.tableView.cellLayoutMarginsFollowReadableWidth = true
	}
}

// MARK: - UITableViewDataSource
extension SkipDurationSettingsViewController {
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return SkipDuration.allCases.count
	}

	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		guard let cell = tableView.dequeueReusableCell(withIdentifier: IconTableViewCell.self, for: indexPath) else {
			fatalError("Cannot dequeue reusable cell with identifier \(IconTableViewCell.reuseID).")
		}
		let option = SkipDuration.allCases[indexPath.row]

		cell.configure(title: L10n.secondsCount(option.rawValue))
		cell.setSelected(option == UserSettings.musicSkipDuration)
		return cell
	}
}

// MARK: - UITableViewDelegate
extension SkipDurationSettingsViewController {
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		UserSettings.set(SkipDuration.allCases[indexPath.row].rawValue, forKey: .musicSkipDuration)
		tableView.reloadData()
	}
}

// MARK: - KTableViewDataSource
extension SkipDurationSettingsViewController {
	override func registerCells(for tableView: UITableView) -> [UITableViewCell.Type] {
		return [IconTableViewCell.self]
	}
}
