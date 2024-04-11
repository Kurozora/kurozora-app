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
	var alternativeIcons: [AlternativeIcons] = []

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
			let alternativeIconsDict = (try? PropertyListSerialization.propertyList(from: plist, format: nil) as? [[String: Any]]) ?? []
			alternativeIconsDict.forEach { alternativeIconPack in
				guard let title = alternativeIconPack["title"] as? String,
					  let icons = alternativeIconPack["icons"] as? [String]
				else { return }

				self.alternativeIcons.append(AlternativeIcons(title: title, icons: icons))
			}
		}
	}
}

// MARK: - UITableViewDataSource
extension ManageIconTableViewController {
	override func numberOfSections(in tableView: UITableView) -> Int {
		return self.alternativeIcons.count
	}

	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return self.alternativeIcons[section].icons.count
	}

	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		guard let iconTableViewCell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.iconTableViewCell, for: indexPath) else {
			fatalError("Cannot dequeue reusable cell with identifier \(R.reuseIdentifier.iconTableViewCell.identifier)")
		}
		let alternativeIconsElement = self.alternativeIcons[indexPath.section].icons[indexPath.row]
		iconTableViewCell.configureCell(using: alternativeIconsElement)
		iconTableViewCell.setSelected(alternativeIconsElement.name == UserSettings.appIcon)
		return iconTableViewCell
	}

	override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		if self.alternativeIcons[section].icons.count != 0 {
			return self.alternativeIcons[section].title.uppercased()
		}

		return nil
	}
}

// MARK: - UITableViewDelegate
extension ManageIconTableViewController {
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		let alternativeIconsElement = self.alternativeIcons[indexPath.section].icons[indexPath.item]

		switch indexPath.section {
		case 0:
			if indexPath.row == 0 {
				KThemeStyle.changeIcon(to: nil)
			} else {
				KThemeStyle.changeIcon(to: alternativeIconsElement.name)
			}

			self.changeIcon(tableView: tableView, alternativeIconsElement: alternativeIconsElement)
		default:
			Task {
				if await WorkflowController.shared.isProOrSubscribed(on: self) {
					KThemeStyle.changeIcon(to: alternativeIconsElement.name)
					self.changeIcon(tableView: tableView, alternativeIconsElement: alternativeIconsElement)
				}
			}
		}
	}

	fileprivate func changeIcon(tableView: UITableView, alternativeIconsElement: AlternativeIconsElement) {
		UserSettings.set(alternativeIconsElement.name, forKey: .appIcon)
		NotificationCenter.default.post(name: .KSAppIconDidChange, object: nil)
		tableView.reloadData()
	}

	override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
		if self.alternativeIcons[section].icons.isEmpty {
			return .leastNormalMagnitude
		}

		return UITableView.automaticDimension
	}

	override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
		if self.alternativeIcons[section].icons.isEmpty {
			return .leastNormalMagnitude
		}

		return UITableView.automaticDimension
	}
}

// MARK: - KTableViewDataSource
extension ManageIconTableViewController {
	override func registerCells(for tableView: UITableView) -> [UITableViewCell.Type] {
		return [IconTableViewCell.self]
	}
}
