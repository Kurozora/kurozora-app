//
//  PurchaseTableViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 24/06/2019.
//  Copyright © 2019 Kurozora. All rights reserved.
//

import UIKit

class PurchaseTableViewController: InAppPurchasesTableViewController {
	// MARK: - Properties
	override var productIDs: [String] {
		return ["20000331KPLUS1M",
				"20000331KPLUS6M",
				"20000331KPLUS12M"
		]
	}

	override var previewImages: [UIImage?] {
		return [R.image.promo_icons(), R.image.promo_gif()]
	}

	// MARK: - IBActions
	@IBAction func cancelButtonPressed(_ sender: UIBarButtonItem) {
		self.dismiss(animated: true, completion: nil)
	}
}

// MARK: - UITableViewDataSource
extension PurchaseTableViewController {
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		// Override first section with a product preview cell.
		if indexPath.section == 0 {
			guard let productPreviewTableViewCell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.productPreviewTableViewCell, for: indexPath) else {
				fatalError("Cannot dequeue resuable cell with identifier \(R.reuseIdentifier.productPreviewTableViewCell.identifier)")
			}
			return productPreviewTableViewCell
		}

		// Default implementation for all other sections.
		return super.tableView(tableView, cellForRowAt: indexPath)
	}
}

// MARK: -  UITableViewDelegate
extension PurchaseTableViewController {
	override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
		// Override first section a product preview cell.
		if indexPath.section == 0 {
			let productPreviewTableViewCell = cell as? ProductPreviewTableViewCell
			productPreviewTableViewCell?.previewImages = previewImages
		}

		// Default implementation for all other sections.
		super.tableView(tableView, willDisplay: cell, forRowAt: indexPath)
	}

	override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		if indexPath.section == 0 {
			let cellRatio: CGFloat = UIDevice.isLandscape ? 1.5 : 3
			return view.frame.height / cellRatio
		}

		return UITableView.automaticDimension
	}

	override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
		return CGFloat.leastNormalMagnitude
	}
}
