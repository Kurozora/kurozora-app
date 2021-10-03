//
//  TipJarTableViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 06/10/2019.
//  Copyright © 2019 Kurozora. All rights reserved.
//

import StoreKit
import UIKit

class TipJarTableViewController: ProductTableViewController {
	// MARK: - Properties
	override var products: [Product] {
		return store.tips
	}

	override var serviceType: ServiceType? {
		return .tipJar
	}
}

// MARK: - UITableViewDataSource
extension TipJarTableViewController {
	override func numberOfSections(in tableView: UITableView) -> Int {
		return Section.allCases.count
	}

	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		guard let section = Section(rawValue: section) else { return 0 }
		switch section {
		case .header:
			return 1
		case .tips:
			return products.count
		case .footer:
			return 1
		}
	}

	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		switch Section(rawValue: indexPath.section) {
		case .header:
			guard let purchaseHeaderTableViewCell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.purchaseHeaderTableViewCell, for: indexPath) else {
				fatalError("Cannot dequeue resuable cell with identifier \(R.reuseIdentifier.purchaseHeaderTableViewCell.identifier)")
			}
			return purchaseHeaderTableViewCell
		case .tips:
			guard let purchaseButtonTableViewCell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.purchaseButtonTableViewCell, for: indexPath) else {
				fatalError("Cannot dequeue resuable cell with identifier \(R.reuseIdentifier.purchaseButtonTableViewCell.identifier)")
			}
			purchaseButtonTableViewCell.productNumber = indexPath.row
			purchaseButtonTableViewCell.product = products[indexPath.row]
			purchaseButtonTableViewCell.delegate = self
			return purchaseButtonTableViewCell
		default:
			guard let serviceFooterTableViewCell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.serviceFooterTableViewCell, for: indexPath) else {
				fatalError("Cannot dequeue resuable cell with identifier \(R.reuseIdentifier.serviceFooterTableViewCell.identifier)")
			}
			serviceFooterTableViewCell.delegate = self
			serviceFooterTableViewCell.serviceType = serviceType
			return serviceFooterTableViewCell
		}
	}
}

// MARK: - UITableViewDelegate
extension TipJarTableViewController {
}

// MARK: - Section
extension TipJarTableViewController {
	/**
		Set of available tip jar table view sections.
	*/
	enum Section: Int, CaseIterable {
		// MARK: - Cases
		/// The heder section of the table view.
		case header

		/// The tips section of the table view.
		case tips

		/// The heder section of the table view.
		case footer
	}
}
