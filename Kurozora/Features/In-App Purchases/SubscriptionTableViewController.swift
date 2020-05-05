//
//  SubscriptionTableViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 24/06/2019.
//  Copyright © 2019 Kurozora. All rights reserved.
//

import UIKit

class SubscriptionTableViewController: ProductTableViewController {
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

	override var serviceType: ServiceType? {
		return .subscription
	}

	// MARK: - IBActions
	@IBAction func cancelButtonPressed(_ sender: UIBarButtonItem) {
		self.dismiss(animated: true, completion: nil)
	}
}

// MARK: - UITableViewDataSource
extension SubscriptionTableViewController {
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		switch Section(rawValue: indexPath.section) {
		case .header:
			guard let productPreviewTableViewCell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.productPreviewTableViewCell, for: indexPath) else {
				fatalError("Cannot dequeue resuable cell with identifier \(R.reuseIdentifier.productPreviewTableViewCell.identifier)")
			}
			productPreviewTableViewCell.previewImages = previewImages
			return productPreviewTableViewCell
		default:
			return super.tableView(tableView, cellForRowAt: indexPath)
		}
	}
}

// MARK: -  UITableViewDelegate
extension SubscriptionTableViewController {
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
