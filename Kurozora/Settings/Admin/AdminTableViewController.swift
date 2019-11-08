//
//  AdminTableViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 26/09/2018.
//  Copyright © 2018 Kurozora. All rights reserved.
//

import UIKit
import EmptyDataSet_Swift

class AdminTableViewController: UITableViewController {
	// MARK: - IBOutlets
	@IBOutlet weak var warningLabel: UILabel! {
		didSet {
			warningLabel.theme_textColor = KThemePicker.textColor.rawValue
			warningLabel.theme_backgroundColor = KThemePicker.backgroundColor.rawValue
		}
	}

	// MARK: - Properties
	let kDefaultItems = Kurozora.shared.KDefaults.allItems()
	let kDefaultKeys = Kurozora.shared.KDefaults.allKeys()
	var kDefaultCount = Kurozora.shared.KDefaults.allItems().count

	// MARK: - View
	override func viewDidLoad() {
		super.viewDidLoad()
		view.theme_backgroundColor = KThemePicker.backgroundColor.rawValue
		NotificationCenter.default.addObserver(self, selector: #selector(reloadEmptyDataView), name: .ThemeUpdateNotification, object: nil)

		// Setup empty data view
		setupEmptyDataView()
	}

	// MARK: - Functions
	/// Sets up the empty data view.
	func setupEmptyDataView() {
		tableView.emptyDataSetView { (view) in
			view.titleLabelString(NSAttributedString(string: "No Keys", attributes: [.font: UIFont.systemFont(ofSize: 16, weight: .medium), .foregroundColor: KThemePicker.textColor.colorValue]))
				.detailLabelString(NSAttributedString(string: "All Kurozora related keys in your keychain are removed.", attributes: [.font: UIFont.systemFont(ofSize: 16), .foregroundColor: KThemePicker.subTextColor.colorValue]))
				.image(#imageLiteral(resourceName: "empty_keychain"))
				.verticalOffset(-50)
				.verticalSpace(10)
				.isScrollAllowed(true)
		}
	}

	/// Reload the empty data view.
	@objc func reloadEmptyDataView() {
		setupEmptyDataView()
		tableView.reloadData()
	}
}

// MARK: - UITableViewDataSource
extension AdminTableViewController {
	override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
		if editingStyle == .delete {
			let kDefaultsTableViewCell = self.tableView.cellForRow(at: indexPath) as! KDefaultsCell
			guard let key = kDefaultsTableViewCell.primaryLabel?.text else {return}

			self.tableView.beginUpdates()
			try? Kurozora.shared.KDefaults.remove(key)
			self.kDefaultCount = kDefaultCount - 1
			self.tableView.deleteRows(at: [indexPath], with: .automatic)
			self.tableView.endUpdates()
		}
	}

	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return kDefaultCount
	}

	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let kDefaultsCell = self.tableView.dequeueReusableCell(withIdentifier: "KDefaultsCell", for: indexPath) as! KDefaultsCell

		if let key = kDefaultItems[indexPath.row]["key"] as? String, !key.isEmpty {
			kDefaultsCell.primaryLabel?.text = key
		}
		if let value = kDefaultItems[indexPath.row]["value"] as? String, !value.isEmpty {
			kDefaultsCell.valueTextField.text = value
		}

		return kDefaultsCell
	}
}
