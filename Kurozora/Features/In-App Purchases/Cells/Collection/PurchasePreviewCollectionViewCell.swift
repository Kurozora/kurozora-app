//
//  PurchasePreviewCollectionViewCell.swift
//  Kurozora
//
//  Created by Khoren Katklian on 31/07/2019.
//  Copyright © 2019 Kurozora. All rights reserved.
//

import UIKit

class PurchasePreviewCollectionViewCell: UICollectionViewCell {
	// MARK: - IBOutlets
	@IBOutlet weak var previewImageView: UIImageView!

	// MARK: - Properties
	var previewItem: String? {
		didSet {
			configureCell()
		}
	}

	// MARK: - Functions
	/// Configure the cell with the given details.
	fileprivate func configureCell() {
		guard let previewItem = previewItem else { return }

		previewImageView.image = UIImage(named: previewItem)
	}
}
