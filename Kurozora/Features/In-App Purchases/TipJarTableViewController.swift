//
//  TipJarTableViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 06/10/2019.
//  Copyright © 2019 Kurozora. All rights reserved.
//

import UIKit

class TipJarTableViewController: ProductTableViewController {
	// MARK: - Properties
	override var productTitles: [String] {
		return ["Wolf tip 🐺",
				"Tiger tip 🐯",
				"Demon tip 👺",
				"Dragon tip 🐲",
				"God tip 🙏"
		]
	}
	override var productIDs: [String] {
		return ["20000331KTIPWOLF",
				"20000331KTIPTIGER",
				"20000331KTIPDEMON",
				"20000331KTIPDRAGON",
				"20000331KTIPGOD"
		]
	}
	override var serviceType: ServiceType? {
		return .tipJar
	}
}

// MARK: - UITableViewDataSource
extension TipJarTableViewController {
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		switch Section(rawValue: indexPath.section) {
		case .header:
			guard let purchaseHeaderTableViewCell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.purchaseHeaderTableViewCell, for: indexPath) else {
				fatalError("Cannot dequeue resuable cell with identifier \(R.reuseIdentifier.purchaseHeaderTableViewCell.identifier)")
			}
			return purchaseHeaderTableViewCell
		default:
			return super.tableView(tableView, cellForRowAt: indexPath)
		}
	}
}

// MARK: - UITableViewDelegate
extension TipJarTableViewController {
}
