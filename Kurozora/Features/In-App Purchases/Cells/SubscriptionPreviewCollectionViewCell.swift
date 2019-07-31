//
//  SubscriptionPreviewCollectionViewCell.swift
//  Kurozora
//
//  Created by Khoren Katklian on 31/07/2019.
//  Copyright © 2019 Kurozora. All rights reserved.
//

import UIKit

class SubscriptionPreviewCollectionViewCell: UICollectionViewCell {
	@IBOutlet weak var previewImageView: UIImageView!

	var previewItem: String? {
		didSet {
			configureCell()
		}
	}

	// MARK: - Functions
	fileprivate func configureCell() {
		guard let previewItem = previewItem else { return }

		previewImageView.image = UIImage(named: previewItem)
	}
}

