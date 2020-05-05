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
}

// MARK: - UITableViewDataSource
extension TipJarTableViewController {
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		switch Section(rawValue: indexPath.section) {
		case .header: // Override first section with an informational header cell.
			guard let purchaseHeaderTableViewCell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.purchaseHeaderTableViewCell, for: indexPath) else {
				fatalError("Cannot dequeue resuable cell with identifier \(R.reuseIdentifier.purchaseHeaderTableViewCell.identifier)")
			}
			return purchaseHeaderTableViewCell
		default: // Default implementation for all other sections.
			return super.tableView(tableView, cellForRowAt: indexPath)
		}
	}
}

// MARK: - UITableViewDelegate
extension TipJarTableViewController {
	override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
		switch Section(rawValue: indexPath.section) {
		case .footer: // Override the footer section.
			if let serviceFooterTableViewCell = cell as? ServiceFooterTableViewCell {
				serviceFooterTableViewCell.footerType = .tipJar
			}
		default: // Default implementation for all other sections.
			super.tableView(tableView, willDisplay: cell, forRowAt: indexPath)
		}
	}
}
