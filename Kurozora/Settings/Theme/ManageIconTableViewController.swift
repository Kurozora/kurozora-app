//
//  ManageIconTableViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 05/06/2019.
//  Copyright © 2019 Kurozora. All rights reserved.
//

import KCommonKit
import SwiftyJSON

class ManageIconTableViewController: UITableViewController {
	var alternativeIcons: AlternativeIcons? {
		didSet {
			tableView.reloadData()
		}
	}

	var alternativeIconsArray = JSON()

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)

		self.alternativeIcons = try? AlternativeIcons(json: alternativeIconsArray)
	}

	override func viewDidLoad() {
		super.viewDidLoad()
		view.theme_backgroundColor = KThemePicker.backgroundColor.rawValue

		if let path = Bundle.main.path(forResource: "app-icons", ofType: "json") {
			do {
				let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .alwaysMapped)
				alternativeIconsArray = try JSON(data: data)
			} catch let error {
				print("parse error: \(error.localizedDescription)")
			}
		} else {
			print("Invalid filename/path.")
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
			guard let defaultIconsCount = alternativeIcons?.defaultIcons?.count else { return 0 }
			return defaultIconsCount
		case 1:
			guard let premiumIconsCount = alternativeIcons?.premiumIcons?.count else { return 0 }
			return premiumIconsCount
		case 2:
			guard let limitedIconsCount = alternativeIcons?.limitedIcons?.count else { return 0 }
			return limitedIconsCount
		default:
			return 0
		}
	}

	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let iconTableViewCell = tableView.dequeueReusableCell(withIdentifier: "IconTableViewCell", for: indexPath) as! IconTableViewCell

		switch indexPath.section {
		case 0:
			iconTableViewCell.alternativeIconsElement = alternativeIcons?.defaultIcons?[indexPath.row]
		case 1:
			iconTableViewCell.alternativeIconsElement = alternativeIcons?.premiumIcons?[indexPath.row]
		case 2:
			iconTableViewCell.alternativeIconsElement = alternativeIcons?.limitedIcons?[indexPath.row]
		default:
			iconTableViewCell.alternativeIconsElement = nil
		}

		return iconTableViewCell
	}

	override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		switch section {
		case 0:
			if alternativeIcons?.defaultIcons?.count != 0 {
				return "DEFAULT"
			}
		case 1:
			if alternativeIcons?.premiumIcons?.count != 0 {
				return "PREMIUM"
			}
		case 2:
			if alternativeIcons?.limitedIcons?.count != 0 {
				return "LIMITED TIME"
			}
		default: return nil
		}

		return nil
	}
}

// MARK: - UITableViewDelegate
extension ManageIconTableViewController {
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		tableView.deselectRow(at: indexPath, animated: true)
		let iconTableViewCell = tableView.cellForRow(at: indexPath) as! IconTableViewCell

		if indexPath == [0,0] {
			KThemeStyle.changeIcon(to: nil)
		} else {
			KThemeStyle.changeIcon(to: iconTableViewCell.alternativeIconsElement?.name)
		}

		UserSettings.set(iconTableViewCell.alternativeIconsElement?.image, forKey: .appIcon)
		NotificationCenter.default.post(name: .KSAppIconDidChange, object: nil)
		tableView.reloadData()
	}

	override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
		if let headerView = view as? UITableViewHeaderFooterView {
			headerView.textLabel?.theme_textColor = KThemePicker.subTextColor.rawValue
			headerView.textLabel?.font = .systemFont(ofSize: 15, weight: .medium)
		}
	}

	override func tableView(_ tableView: UITableView, didHighlightRowAt indexPath: IndexPath) {
		if let iconTableViewCell = tableView.cellForRow(at: indexPath) as? IconTableViewCell {
			iconTableViewCell.selectedView?.theme_backgroundColor = KThemePicker.tableViewCellSelectedBackgroundColor.rawValue
			iconTableViewCell.iconTitleLabel?.theme_textColor = KThemePicker.tableViewCellSelectedTitleTextColor.rawValue
		}
	}

	override func tableView(_ tableView: UITableView, didUnhighlightRowAt indexPath: IndexPath) {
		if let iconTableViewCell = tableView.cellForRow(at: indexPath) as? IconTableViewCell {
			iconTableViewCell.selectedView?.theme_backgroundColor = KThemePicker.tableViewCellBackgroundColor.rawValue
			iconTableViewCell.iconTitleLabel?.theme_textColor = KThemePicker.tableViewCellTitleTextColor.rawValue
		}
	}
}
