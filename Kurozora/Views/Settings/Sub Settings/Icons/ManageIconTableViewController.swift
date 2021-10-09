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
		_prefersActivityIndicatorHidden = true
	}

	// MARK: - Functions
	/// The shared settings used to initialize tab bar view.
	private func sharedInit() {
		if let path = Bundle.main.path(forResource: "App Icons", ofType: "plist"),
		   let plist = FileManager.default.contents(atPath: path) {
			self.alternativeIconsDict = (try? PropertyListSerialization.propertyList(from: plist, format: nil) as? [String: [String]]) ?? [:]
			self.alternativeIcons = AlternativeIcons(dict: alternativeIconsDict)
		} else {
			self.alternativeIconsDict = [:]
		}
	}
}

// MARK: - UITableViewDataSource
extension ManageIconTableViewController {
	override func numberOfSections(in tableView: UITableView) -> Int {
		return 3
	}

	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		switch section {
		case 0:
			guard let defaultIconsCount = alternativeIcons?.defaultIcons.count else { return 0 }
			return defaultIconsCount
		case 1:
			guard let premiumIconsCount = alternativeIcons?.premiumIcons.count else { return 0 }
			return premiumIconsCount
		case 2:
			guard let limitedIconsCount = alternativeIcons?.limitedIcons.count else { return 0 }
			return limitedIconsCount
		default:
			return 0
		}
	}

	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		guard let iconTableViewCell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.iconTableViewCell, for: indexPath) else {
			fatalError("Cannot dequeue reusable cell with identifier \(R.reuseIdentifier.iconTableViewCell.identifier)")
		}
		switch indexPath.section {
		case 0:
			iconTableViewCell.alternativeIconsElement = alternativeIcons?.defaultIcons[indexPath.row]
		case 1:
			iconTableViewCell.alternativeIconsElement = alternativeIcons?.premiumIcons[indexPath.row]
		case 2:
			iconTableViewCell.alternativeIconsElement = alternativeIcons?.limitedIcons[indexPath.row]
		default:
			iconTableViewCell.alternativeIconsElement = nil
		}
		return iconTableViewCell
	}

	override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		switch section {
		case 0:
			if alternativeIcons?.defaultIcons.count != 0 {
				return "DEFAULT"
			}
		case 1:
			if alternativeIcons?.premiumIcons.count != 0 {
				return "PREMIUM"
			}
		case 2:
			if alternativeIcons?.limitedIcons.count != 0 {
				return "LIMITED TIME"
			}
		default:
			return nil
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

			UserSettings.set(iconTableViewCell.alternativeIconsElement?.name, forKey: .appIcon)
			NotificationCenter.default.post(name: .KSAppIconDidChange, object: nil)
			tableView.reloadData()
		default:
			WorkflowController.shared.isPro {
				KThemeStyle.changeIcon(to: iconTableViewCell.alternativeIconsElement?.name)

				UserSettings.set(iconTableViewCell.alternativeIconsElement?.name, forKey: .appIcon)
				NotificationCenter.default.post(name: .KSAppIconDidChange, object: nil)
				tableView.reloadData()
			}
		}
	}
}
