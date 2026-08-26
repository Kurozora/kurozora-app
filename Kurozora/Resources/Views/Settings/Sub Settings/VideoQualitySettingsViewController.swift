//
//  VideoQualitySettingsViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 28/08/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import UIKit

class VideoQualitySettingsViewController: SubSettingsViewController {
	// MARK: - Properties
	/// A Boolean value indicating whether the picker sets the cellular quality.
	private let isCellular: Bool

	/// The qualities offered, ordered from adaptive to lowest.
	private let qualities: [VideoQuality] = VideoQuality.allCases

	/// The quality currently chosen for the picker's network.
	private var chosenQuality: VideoQuality {
		self.isCellular ? UserSettings.cellularVideoQuality : UserSettings.wifiVideoQuality
	}

	// MARK: - Initializers
	/// Creates a picker for the given network's quality.
	///
	/// - Parameter isCellular: Whether the picker sets the cellular quality.
	init(isCellular: Bool) {
		self.isCellular = isCellular
		super.init(style: .insetGrouped)
	}

	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	// MARK: - View
	override func viewDidLoad() {
		super.viewDidLoad()

		self.title = self.isCellular ? L10n.cellularQuality : L10n.wifiQuality
		self.tableView.cellLayoutMarginsFollowReadableWidth = true
	}
}

// MARK: - UITableViewDataSource
extension VideoQualitySettingsViewController {
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return self.qualities.count
	}

	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		guard let cell = tableView.dequeueReusableCell(withIdentifier: IconTableViewCell.self, for: indexPath) else {
			fatalError("Cannot dequeue reusable cell with identifier \(IconTableViewCell.reuseID).")
		}
		let quality = self.qualities[indexPath.row]

		cell.configure(title: quality.titleValue)
		cell.setSelected(quality == self.chosenQuality)
		return cell
	}

	override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
		return L10n.videoQualityFooter
	}
}

// MARK: - UITableViewDelegate
extension VideoQualitySettingsViewController {
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		UserSettings.set(self.qualities[indexPath.row].rawValue, forKey: self.isCellular ? .cellularVideoQuality : .wifiVideoQuality)
		tableView.reloadData()
	}
}

// MARK: - KTableViewDataSource
extension VideoQualitySettingsViewController {
	override func registerCells(for tableView: UITableView) -> [UITableViewCell.Type] {
		return [IconTableViewCell.self]
	}
}
