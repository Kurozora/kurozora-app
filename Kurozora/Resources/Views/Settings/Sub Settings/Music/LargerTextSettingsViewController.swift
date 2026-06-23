//
//  LargerTextSettingsViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 24/06/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import UIKit

class LargerTextSettingsViewController: SubSettingsViewController {
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

		self.title = L10n.largerText
		self.tableView.cellLayoutMarginsFollowReadableWidth = true
	}
}

// MARK: - UITableViewDataSource
extension LargerTextSettingsViewController {
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return LyricsLargerText.allCases.count
	}

	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		guard let cell = tableView.dequeueReusableCell(withIdentifier: IconTableViewCell.self, for: indexPath) else {
			fatalError("Cannot dequeue reusable cell with identifier \(IconTableViewCell.reuseID).")
		}
		let option = LyricsLargerText.allCases[indexPath.row]

		cell.configure(title: option.stringValue)
		cell.setSelected(option == UserSettings.lyricsLargerText)
		return cell
	}
}

// MARK: - UITableViewDelegate
extension LargerTextSettingsViewController {
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		UserSettings.set(LyricsLargerText.allCases[indexPath.row].rawValue, forKey: .lyricsLargerText)
		tableView.reloadData()
	}
}

// MARK: - KTableViewDataSource
extension LargerTextSettingsViewController {
	override func registerCells(for tableView: UITableView) -> [UITableViewCell.Type] {
		return [IconTableViewCell.self]
	}
}
