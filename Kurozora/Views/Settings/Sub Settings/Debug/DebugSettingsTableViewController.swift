//
//  DebugSettingsTableViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 26/09/2018.
//  Copyright © 2018 Kurozora. All rights reserved.
//

import UIKit

class DebugSettingsTableViewController: KTableViewController {
	// MARK: - IBOutlets
	@IBOutlet weak var warningLabel: KLabel!

	// MARK: - Properties
	let kDefaultItems = KurozoraDelegate.shared.keychain.allItems()
	var kDefaultCount = KurozoraDelegate.shared.keychain.allItems().count

	// Activity indicator
	var _prefersActivityIndicatorHidden = false {
		didSet {
			self.setNeedsActivityIndicatorAppearanceUpdate()
		}
	}
	override var prefersActivityIndicatorHidden: Bool {
		return _prefersActivityIndicatorHidden
	}

	// MARK: - View
	override func viewDidLoad() {
		super.viewDidLoad()

		_prefersActivityIndicatorHidden = true
	}

	// MARK: - Functions
	override func setupEmptyDataSetView() {
		tableView.emptyDataSetView { (view) in
			view.titleLabelString(NSAttributedString(string: "No Keys", attributes: [.font: UIFont.systemFont(ofSize: 16, weight: .medium), .foregroundColor: KThemePicker.textColor.colorValue]))
				.detailLabelString(NSAttributedString(string: "All Kurozora related keys in your keychain are removed.", attributes: [.font: UIFont.systemFont(ofSize: 16), .foregroundColor: KThemePicker.subTextColor.colorValue]))
				.image(R.image.empty.keychain())
				.verticalOffset(-50)
				.verticalSpace(5)
				.isScrollAllowed(true)
		}
	}
}

// MARK: - UITableViewDataSource
extension DebugSettingsTableViewController {
	override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
		if editingStyle == .delete {
			let kDefaultsTableViewCell = self.tableView.cellForRow(at: indexPath) as! KDefaultsCell
			guard let key = kDefaultsTableViewCell.primaryLabel?.text else {return}

			self.tableView.beginUpdates()
			try? KurozoraDelegate.shared.keychain.remove(key)
			self.kDefaultCount = kDefaultCount - 1
			self.tableView.deleteRows(at: [indexPath], with: .automatic)
			self.tableView.endUpdates()
		}
	}

	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return kDefaultCount
	}

	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		guard let kDefaultsCell = self.tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.kDefaultsCell, for: indexPath) else {
			fatalError("Cannot dequeue reusable cell with identifier \(R.reuseIdentifier.kDefaultsCell.identifier)")
		}

		if let key = kDefaultItems[indexPath.row]["key"] as? String, !key.isEmpty {
			kDefaultsCell.primaryLabel?.text = key
		}
		if let value = kDefaultItems[indexPath.row]["value"] as? String, !value.isEmpty {
			kDefaultsCell.valueTextField.text = value
		}

		return kDefaultsCell
	}
}
