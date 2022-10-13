//
//  ManageIconTableViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 05/06/2019.
//  Copyright © 2019 Kurozora. All rights reserved.
//

import UIKit

class ManageIconTableViewController: SubSettingsViewController {
	// MARK: - Properties
	var alternativeIcons: AlternativeIcons?
	private var alternativeIconsDict: [String: [String]] = [:]

	// MARK: - Initializers
	override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
		super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
		self.sharedInit()
	}

	required init?(coder: NSCoder) {
		super.init(coder: coder)
		self.sharedInit()
	}

	// MARK: - View
	override func viewDidLoad() {
		super.viewDidLoad()

		// Disable activity indicator
		self._prefersActivityIndicatorHidden = true
	}

	// MARK: - Functions
	/// The shared settings used to initialize tab bar view.
	private func sharedInit() {
		if let path = Bundle.main.path(forResource: "App Icons", ofType: "plist"),
		   let plist = FileManager.default.contents(atPath: path) {
			self.alternativeIconsDict = (try? PropertyListSerialization.propertyList(from: plist, format: nil) as? [String: [String]]) ?? [:]
			self.alternativeIcons = AlternativeIcons(dict: self.alternativeIconsDict)
		} else {
			self.alternativeIconsDict = [:]
		}
	}
}

// MARK: - UITableViewDataSource
extension ManageIconTableViewController {
	override func numberOfSections(in tableView: UITableView) -> Int {
		return 4
	}

	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		switch section {
		case 0:
			guard let defaultIconsCount = self.alternativeIcons?.defaultIcons.count else { return 0 }
			return defaultIconsCount
		case 1:
			guard let natureIconsCount = self.alternativeIcons?.natureIcons.count else { return 0 }
			return natureIconsCount
		case 2:
			guard let premiumIconsCount = self.alternativeIcons?.premiumIcons.count else { return 0 }
			return premiumIconsCount
		case 3:
			guard let limitedIconsCount = self.alternativeIcons?.limitedIcons.count else { return 0 }
			return limitedIconsCount
		default:
			return 0
		}
	}

	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		guard let iconTableViewCell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.iconTableViewCell, for: indexPath) else {
			fatalError("Cannot dequeue reusable cell with identifier \(R.reuseIdentifier.iconTableViewCell.identifier)")
		}
		var alternativeIconsElement: AlternativeIconsElement? = nil
		switch indexPath.section {
		case 0:
			alternativeIconsElement = self.alternativeIcons?.defaultIcons[indexPath.row]
		case 1:
			alternativeIconsElement = self.alternativeIcons?.natureIcons[indexPath.row]
		case 2:
			alternativeIconsElement = self.alternativeIcons?.premiumIcons[indexPath.row]
		case 3:
			alternativeIconsElement = self.alternativeIcons?.limitedIcons[indexPath.row]
		default: break
		}
		iconTableViewCell.configureCell(using: alternativeIconsElement)
		iconTableViewCell.setSelected(alternativeIconsElement?.name == UserSettings.appIcon)
		return iconTableViewCell
	}

	override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		switch section {
		case 0:
			if self.alternativeIcons?.defaultIcons.count != 0 {
				return "DEFAULT"
			}
		case 1:
			if self.alternativeIcons?.premiumIcons.count != 0 {
				return "NATURE"
			}
		case 2:
			if self.alternativeIcons?.premiumIcons.count != 0 {
				return "PREMIUM"
			}
		case 3:
			if self.alternativeIcons?.limitedIcons.count != 0 {
				return "LIMITED TIME"
			}
		default: break
		}
		return nil
	}
}

// MARK: - UITableViewDelegate
extension ManageIconTableViewController {
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		guard let iconTableViewCell = tableView.cellForRow(at: indexPath) as? IconTableViewCell else { return }
		switch indexPath.section {
		case 0:
			if indexPath.row == 0 {
				KThemeStyle.changeIcon(to: nil)
			} else {
				KThemeStyle.changeIcon(to: iconTableViewCell.alternativeIconsElement?.name)
			}

			self.changeIcon(tableView: tableView, iconTableViewCell: iconTableViewCell)
		default:
			Task {
				if await WorkflowController.shared.isProOrSubscribed() {
				    KThemeStyle.changeIcon(to: iconTableViewCell.alternativeIconsElement?.name)
					self.changeIcon(tableView: tableView, iconTableViewCell: iconTableViewCell)
				}
			}
		}
	}

	func changeIcon(tableView: UITableView, iconTableViewCell: IconTableViewCell) {
		UserSettings.set(iconTableViewCell.alternativeIconsElement?.name, forKey: .appIcon)
		NotificationCenter.default.post(name: .KSAppIconDidChange, object: nil)
		tableView.reloadData()
	}
}

// MARK: - KTableViewDataSource
extension ManageIconTableViewController {
	override func registerCells(for tableView: UITableView) -> [UITableViewCell.Type] {
		return [IconTableViewCell.self]
	}
}
