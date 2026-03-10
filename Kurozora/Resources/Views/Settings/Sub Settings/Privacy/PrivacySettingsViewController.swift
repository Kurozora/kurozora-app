//
//  PrivacySettingsViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 31/01/2020.
//  Copyright © 2020 Kurozora. All rights reserved.
//

import UIKit

class PrivacySettingsViewController: SubSettingsViewController {
	// MARK: - Segue Identifiers
	enum SegueIdentifiers: String, SegueIdentifier {
		case legalSegue
	}

	// MARK: - Initializers
	init() {
		super.init(style: .insetGrouped)
		self.headerImage = .Icons.privacy
		self.headerTitle = Trans.privacy
		self.headerDescription = Trans.privacyHeaderDescription
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

	// MARK: - Segue
	override func makeDestination(for identifier: any SegueIdentifier) -> UIViewController? {
		guard let identifier = identifier as? SegueIdentifiers else { return nil }

		switch identifier {
		case .legalSegue:
			return LegalViewController()
		}
	}

	override func prepare(for identifier: any SegueIdentifier, destination: UIViewController, sender: Any?) {
		guard let identifier = identifier as? SegueIdentifiers else { return }

		switch identifier {
		case .legalSegue: break
		}
	}
}

// MARK: - KTableViewDataSource
extension PrivacySettingsViewController {
	override func registerCells(for tableView: UITableView) -> [UITableViewCell.Type] {
		return super.registerCells(for: tableView) + [
			SettingsCell.self
		]
	}
}

// MARK: - UITableViewDataSource
extension PrivacySettingsViewController {
	override func numberOfSections(in tableView: UITableView) -> Int {
		return Section.allCases.count + self.headerSectionOffset
	}

	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		guard let contentSection = self.contentSection(for: section) else { return 1 }
		return Section.allCases[contentSection].rows.count
	}

	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		if let headerCell = self.settingsHeaderCell(for: tableView, at: indexPath) {
			return headerCell
		}

		guard let contentSection = self.contentSection(for: indexPath.section) else { return UITableViewCell() }

		switch Section.allCases[contentSection].rows[indexPath.row] {
		case .openInSettings:
			guard let cell = tableView.dequeueReusableCell(withIdentifier: SettingsCell.self, for: indexPath) else {
				fatalError("Cannot dequeue reusable cell with identifier \(SettingsCell.reuseID)")
			}
			cell.configure(title: Trans.openInSettingsApp)
			return cell
		case .privacy:
			guard let cell = tableView.dequeueReusableCell(withIdentifier: SettingsCell.self, for: indexPath) else {
				fatalError("Cannot dequeue reusable cell with identifier \(SettingsCell.reuseID)")
			}
			cell.configure(title: Trans.privacy)
			return cell
		}
	}

	override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
		guard let contentSection = self.contentSection(for: section) else { return nil }

		switch Section.allCases[contentSection] {
		case .inAppPrivacy:
			return "This will send you to Kurozora's privacy settings in the Settings app where you can adjust the app's permissions."
		case .settingsPrivacy:
			return nil
		}
	}
}

// MARK: - UITableViewDelegate
extension PrivacySettingsViewController {
	override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
		guard let contentSection = self.contentSection(for: section) else { return .leastNormalMagnitude }
		return super.tableView(tableView, heightForHeaderInSection: contentSection)
	}

	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		guard let contentSection = self.contentSection(for: indexPath.section) else { return }

		switch Section.allCases[contentSection].rows[indexPath.row] {
		case .openInSettings:
			#if targetEnvironment(macCatalyst)
			let settingsUrl = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy")
			#else
			let settingsUrl = URL(string: UIApplication.openSettingsURLString)
			#endif

			UIApplication.shared.kOpen(nil, deepLink: settingsUrl)
		case .privacy:
			self.show(SegueIdentifiers.legalSegue, sender: nil)
		}
	}
}

// MARK: - Sections and Rows
private extension PrivacySettingsViewController {
	/// List of privacy settings sections.
	enum Section: Int, CaseIterable {
		case settingsPrivacy = 0
		case inAppPrivacy

		/// List of rows in the section.
		var rows: [Row] {
			switch self {
			case .settingsPrivacy: return [.openInSettings]
			case .inAppPrivacy: return [.privacy]
			}
		}
	}

	/// List of privacy settings rows.
	enum Row: Int, CaseIterable {
		case openInSettings = 0
		case privacy
	}
}
