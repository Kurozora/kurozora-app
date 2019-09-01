//
//  AdminTableViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 26/09/2018.
//  Copyright © 2018 Kurozora. All rights reserved.
//

import KCommonKit
import EmptyDataSet_Swift

class AdminTableViewController: UITableViewController, EmptyDataSetDelegate, EmptyDataSetSource {
	@IBOutlet weak var warningLabel: UILabel! {
		didSet {
			warningLabel.theme_textColor = KThemePicker.textColor.rawValue
			warningLabel.theme_backgroundColor = KThemePicker.backgroundColor.rawValue
		}
	}

	let kDefaultItems = GlobalVariables().KDefaults.allItems()
	let kDefaultKeys = GlobalVariables().KDefaults.allKeys()
	var kDefaultCount = GlobalVariables().KDefaults.allItems().count

	override func viewDidLoad() {
		super.viewDidLoad()
		view.theme_backgroundColor = KThemePicker.backgroundColor.rawValue

		// Setup table view
		tableView.dataSource = self
		tableView.delegate = self

		// Setup empty table view
		tableView.emptyDataSetDelegate = self
		tableView.emptyDataSetSource = self
		tableView.emptyDataSetView { (view) in
			view.titleLabelString(NSAttributedString(string: "No badges found!"))
				.shouldDisplay(true)
				.shouldFadeIn(true)
				.isTouchAllowed(true)
				.isScrollAllowed(false)
		}
	}

	override func viewWillLayoutSubviews() {
		super.viewWillLayoutSubviews()

		for cell in tableView.visibleCells {
			guard let indexPath = tableView.indexPath(for: cell) else { return }
			var rectCorner: UIRectCorner!
			var roundCorners = true
			let numberOfRows: Int = tableView.numberOfRows(inSection: indexPath.section)

			if numberOfRows == 1 {
				// single cell
				rectCorner = UIRectCorner.allCorners
			} else if indexPath.row == numberOfRows - 1 {
				// bottom cell
				rectCorner = [.bottomLeft, .bottomRight]
			} else if indexPath.row == 0 {
				// top cell
				rectCorner = [.topLeft, .topRight]
			} else {
				roundCorners = false
			}

			if roundCorners {
				tableView.cellForRow(at: indexPath)?.contentView.roundedCorners(rectCorner, radius: 10)
			}
		}
	}
}

// MARK: - UITableViewDataSource
extension AdminTableViewController {
	override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
		if editingStyle == .delete {
			let kDefaultsTableViewCell = self.tableView.cellForRow(at: indexPath) as! KDefaultsCell
			guard let key = kDefaultsTableViewCell.cellTitle?.text else {return}

			self.tableView.beginUpdates()
			try? GlobalVariables().KDefaults.remove(key)
			self.kDefaultCount = kDefaultCount - 1
			self.tableView.deleteRows(at: [indexPath], with: .automatic)
			self.tableView.endUpdates()
		}
	}

	override func numberOfSections(in tableView: UITableView) -> Int {
		return 1
	}

	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return kDefaultCount
	}

	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let kDefaultsCell = self.tableView.dequeueReusableCell(withIdentifier: "KDefaultsCell", for: indexPath) as! KDefaultsCell

		if let key = kDefaultItems[indexPath.row]["key"] as? String, !key.isEmpty {
			kDefaultsCell.cellTitle?.text = key
		}
		if let value = kDefaultItems[indexPath.row]["value"] as? String, !value.isEmpty {
			kDefaultsCell.valueTextField.text = value
		}

		return kDefaultsCell
	}
}
