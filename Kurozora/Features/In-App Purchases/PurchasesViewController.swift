//
//  PurchasesViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 24/06/2019.
//  Copyright © 2019 Kurozora. All rights reserved.
//

import UIKit

class PurchaseViewController: UITableViewController {
	var data = [["title": "$3,88 / Month", "subtext": ""], ["title": "$11,94 / 6 Months", "subtext": "(6 months at $1,99/mo. Save 50%)"], ["title": "$18,94 / 12 Months", "subtext": "(12 months at $1,58/mo. Save 60%)"]]

	override func viewDidLoad() {
		super.viewDidLoad()
		view.theme_backgroundColor = KThemePicker.backgroundColor.rawValue

		tableView.rowHeight = UITableView.automaticDimension
		tableView.estimatedRowHeight = UITableView.automaticDimension
	}

	// MARK: - IBActions
	@IBAction func dismissButtonPressed(_ sender: UIBarButtonItem) {
		self.dismiss(animated: true, completion: nil)
	}
}

// MARK: - UITableViewDataSource
extension PurchaseViewController {
	override func numberOfSections(in tableView: UITableView) -> Int {
		return 3
	}

	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		if section == 1 {
			return data.count
		}

		return 1
	}

	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		if indexPath.section == 0 {
			let subscriptionPreviewTableViewCell = tableView.dequeueReusableCell(withIdentifier: "SubscriptionPreviewTableViewCell", for: indexPath) as! SubscriptionPreviewTableViewCell
			return subscriptionPreviewTableViewCell
		} else if indexPath.section == 1 {
			let subscriptionButtonTableViewCell = tableView.dequeueReusableCell(withIdentifier: "SubscriptionButtonTableViewCell", for: indexPath) as! SubscriptionButtonTableViewCell
			subscriptionButtonTableViewCell.subscriptionItem = data[indexPath.row]
			return subscriptionButtonTableViewCell
		}

		let subscriptionInfoCell = tableView.dequeueReusableCell(withIdentifier: "SubscriptionInfoCell", for: indexPath) as! SubscriptionInfoCell
		return subscriptionInfoCell
	}
}

// MARK: -  UITableViewDelegate
extension PurchaseViewController {
	override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		if indexPath.section == 0 {
			return view.frame.height / 3
		}

		return UITableView.automaticDimension
	}

	override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
		return CGFloat.leastNormalMagnitude
	}

	override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
		return 20
	}
}
