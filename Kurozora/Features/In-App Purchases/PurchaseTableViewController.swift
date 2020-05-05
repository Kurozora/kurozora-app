//
//  PurchaseTableViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 24/06/2019.
//  Copyright © 2019 Kurozora. All rights reserved.
//

import UIKit

class PurchaseTableViewController: ProductTableViewController {
	// MARK: - Properties
	override var productIDs: [String] {
		return ["20000331KPLUS1M",
				"20000331KPLUS6M",
				"20000331KPLUS12M"
		]
	}

	override var previewImages: [UIImage?] {
		return [R.image.promotional.inAppPurchases.icons(), R.image.promotional.inAppPurchases.gifs()]
	}

	// MARK: - IBActions
	@IBAction func cancelButtonPressed(_ sender: UIBarButtonItem) {
		self.dismiss(animated: true, completion: nil)
	}
}

// MARK: - UITableViewDataSource
extension PurchaseTableViewController {
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		switch Section(rawValue: indexPath.section) {
		case .header: // Override first section with a product preview cell.
			guard let productPreviewTableViewCell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.productPreviewTableViewCell, for: indexPath) else {
				fatalError("Cannot dequeue resuable cell with identifier \(R.reuseIdentifier.productPreviewTableViewCell.identifier)")
			}
			return productPreviewTableViewCell
		default: // Default implementation for all other sections.
			return super.tableView(tableView, cellForRowAt: indexPath)
		}
	}
}

// MARK: -  UITableViewDelegate
extension PurchaseTableViewController {
	override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
		switch Section(rawValue: indexPath.section) {
		case .header: // Override the header section.
			let productPreviewTableViewCell = cell as? ProductPreviewTableViewCell
			productPreviewTableViewCell?.previewImages = previewImages
		default: // Default implementation for all other sections.
			super.tableView(tableView, willDisplay: cell, forRowAt: indexPath)
		}
	}

	override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		switch Section(rawValue: indexPath.section) {
		case .header:
			let cellRatio: CGFloat = UIDevice.isLandscape ? 1.5 : 3
			return view.frame.height / cellRatio
		default:
			return UITableView.automaticDimension
		}
	}

	override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
		return CGFloat.leastNormalMagnitude
	}
}
