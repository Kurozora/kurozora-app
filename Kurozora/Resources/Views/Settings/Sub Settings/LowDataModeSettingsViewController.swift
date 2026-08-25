//
//  LowDataModeSettingsViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 24/08/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import UIKit

class LowDataModeSettingsViewController: SubSettingsViewController, TypedSegueHandling {
	// MARK: - Enums
	enum SegueIdentifiers: String, SegueIdentifier {
		case autoplaySegue
	}

	// MARK: - Properties
	/// The sections shown in the settings.
	private var sections: [Section] {
		return Section.allCases
	}

	// MARK: - Initializers
	init() {
		super.init(style: .insetGrouped)
		self.headerImage = .Icons.wifiExclamationmark
		self.headerTitle = L10n.lowDataMode
		self.headerDescription = L10n.lowDataModeHeaderDescription
	}

	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	// MARK: - View
	override func viewDidLoad() {
		super.viewDidLoad()

		self.tableView.cellLayoutMarginsFollowReadableWidth = true
	}

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)

		self.tableView.reloadData()
	}

	// MARK: - Segue
	override func makeDestination(for identifier: any SegueIdentifier) -> UIViewController? {
		guard let identifier = identifier as? SegueIdentifiers else { return nil }

		switch identifier {
		case .autoplaySegue:
			return AutoplaySettingsViewController()
		}
	}

	override func prepare(for identifier: any SegueIdentifier, destination: UIViewController, sender: Any?) { }
}

// MARK: - KTableViewDataSource
extension LowDataModeSettingsViewController {
	override func registerCells(for tableView: UITableView) -> [UITableViewCell.Type] {
		return super.registerCells(for: tableView) + [SettingsCell.self]
	}
}

// MARK: - UITableViewDataSource
extension LowDataModeSettingsViewController {
	override func numberOfSections(in tableView: UITableView) -> Int {
		return self.sections.count + self.headerSectionOffset
	}

	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		guard
			let contentSection = self.contentSection(for: section),
			let section = self.sections[safe: contentSection]
		else { return 1 }
		return section.rows.count
	}

	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		if let headerCell = self.settingsHeaderCell(for: tableView, at: indexPath) {
			return headerCell
		}

		guard
			let contentSection = self.contentSection(for: indexPath.section),
			let section = self.sections[safe: contentSection],
			let row = section.rows[safe: indexPath.row],
			let cell = tableView.dequeueReusableCell(withIdentifier: SettingsCell.self, for: indexPath)
		else {
			return UITableViewCell()
		}

		cell.configure(title: row.title, detail: row.detail)
		cell.detailLabel?.isHidden = false
		cell.chevronImageView?.isHidden = false
		return cell
	}

	override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
		guard
			let contentSection = self.contentSection(for: section),
			let section = self.sections[safe: contentSection]
		else { return nil }
		return section.footer
	}
}

// MARK: - UITableViewDelegate
extension LowDataModeSettingsViewController {
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		guard
			let contentSection = self.contentSection(for: indexPath.section),
			let section = self.sections[safe: contentSection],
			let row = section.rows[safe: indexPath.row],
			let segueIdentifier = row.segueIdentifier
		else { return }

		self.show(segueIdentifier, sender: nil)
	}
}

// MARK: - Sections and Rows
private extension LowDataModeSettingsViewController {
	enum Section: Int, CaseIterable {
		case media = 0

		var rows: [Row] {
			switch self {
			case .media:
				return [.autoplay]
			}
		}

		var footer: String? {
			switch self {
			case .media:
				return nil
			}
		}
	}

	enum Row {
		case autoplay

		var title: String {
			switch self {
			case .autoplay:
				return L10n.autoplay
			}
		}

		var detail: String {
			switch self {
			case .autoplay:
				return UserSettings.videoAutoplayPolicy.titleValue
			}
		}

		var segueIdentifier: LowDataModeSettingsViewController.SegueIdentifiers? {
			switch self {
			case .autoplay:
				return .autoplaySegue
			}
		}
	}
}
