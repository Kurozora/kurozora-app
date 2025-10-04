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
	let kDefaultItems = SharedDelegate.shared.keychain.allItems()
	var kDefaultCount = SharedDelegate.shared.keychain.allItems().count

	// Refresh control
	var _prefersRefreshControlDisabled = false {
		didSet {
			self.setNeedsRefreshControlAppearanceUpdate()
		}
	}

	override var prefersRefreshControlDisabled: Bool {
		return self._prefersRefreshControlDisabled
	}

	// Activity indicator
	var _prefersActivityIndicatorHidden = false {
		didSet {
			self.setNeedsActivityIndicatorAppearanceUpdate()
		}
	}

	override var prefersActivityIndicatorHidden: Bool {
		return self._prefersActivityIndicatorHidden
	}

	// MARK: - View
	override func viewDidLoad() {
		super.viewDidLoad()

		// Stop activity indicator and disable refresh control
		self._prefersActivityIndicatorHidden = true
		self._prefersRefreshControlDisabled = true

		self.toggleEmptyDataView()
	}

	// MARK: - Functions
	override func configureEmptyDataView() {
		emptyBackgroundView.configureImageView(image: R.image.empty.keychain()!)
		emptyBackgroundView.configureLabels(title: "No Keys", detail: "All Kurozora related keys in your keychain are removed.")

		tableView.backgroundView?.alpha = 0
	}

	/// Fades in and out the empty data view according to `kDefaultCount`.
	func toggleEmptyDataView() {
		if self.kDefaultCount == 0 {
			self.tableView.backgroundView?.animateFadeIn()
		} else {
			self.tableView.backgroundView?.animateFadeOut()
		}
	}
}

// MARK: - UITableViewDataSource
extension DebugSettingsTableViewController {
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return self.kDefaultCount
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

	override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
		if editingStyle == .delete, let kDefaultsTableViewCell = self.tableView.cellForRow(at: indexPath) as? KDefaultsCell {
			guard let key = kDefaultsTableViewCell.primaryLabel?.text else { return }

			self.tableView.beginUpdates()
			try? SharedDelegate.shared.keychain.remove(key)
			self.kDefaultCount -= 1
			self.tableView.deleteRows(at: [indexPath], with: .automatic)
			self.toggleEmptyDataView()
			self.tableView.endUpdates()
		}
	}
}
