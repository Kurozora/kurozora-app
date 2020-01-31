//
//  ManageIconTableViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 05/06/2019.
//  Copyright © 2019 Kurozora. All rights reserved.
//

import UIKit
import SwiftyJSON

class ManageIconTableViewController: SubSettingsViewController {
	// MARK: - Properties
	var alternativeIcons: AlternativeIcons? {
		didSet {
			_prefersActivityIndicatorHidden = true
			tableView.reloadData()
		}
	}
	var alternativeIconsArray = JSON()

	// MARK: - View
	override func viewDidLoad() {
		super.viewDidLoad()

		_prefersActivityIndicatorHidden = false

		DispatchQueue.global(qos: .background).async {
			if let path = Bundle.main.path(forResource: "app-icons", ofType: "json") {
				do {
					let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .alwaysMapped)
					self.alternativeIconsArray = try JSON(data: data)

					DispatchQueue.main.async {
						self.alternativeIcons = try? AlternativeIcons(json: self.alternativeIconsArray)
					}
				} catch let error {
					print("Parse error: \(error.localizedDescription)")
				}
			} else {
				print("Invalid filename/path.")
			}
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

		return iconTableViewCell
	}

	override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
		if let iconTableViewCell = cell as? IconTableViewCell {
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
		}
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
		default:
			return nil
		}
		return nil
	}
}

// MARK: - UITableViewDelegate
extension ManageIconTableViewController {
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		if let iconTableViewCell = tableView.cellForRow(at: indexPath) as? IconTableViewCell {
			if indexPath == [0, 0] {
				KThemeStyle.changeIcon(to: nil)
			} else {
				KThemeStyle.changeIcon(to: iconTableViewCell.alternativeIconsElement?.name)
			}

			UserSettings.set(iconTableViewCell.alternativeIconsElement?.image, forKey: .appIcon)
			NotificationCenter.default.post(name: .KSAppIconDidChange, object: nil)
			tableView.reloadData()
		}
	}
}
