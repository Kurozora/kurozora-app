//
//  WriteAReviewCollectionViewCell.swift
//  Kurozora
//
//  Created by Khoren Katklian on 24/07/2023.
//  Copyright © 2023 Kurozora. All rights reserved.
//

import UIKit

protocol WriteAReviewCollectionViewCellDelegate: AnyObject {
	func writeAReviewCollectionViewCell(_ cell: WriteAReviewCollectionViewCell, didPress button: UIButton) async
}

class WriteAReviewCollectionViewCell: UICollectionViewCell {
	// MARK: - IBOutlets
	@IBOutlet weak var primaryButton: KButton!

	// MARK: - Properties
	weak var delegate: WriteAReviewCollectionViewCellDelegate?

	// MARK: - IBActions
	@IBAction func primaryButtonPressed(_ sender: UIButton) {
		Task {
			await self.delegate?.writeAReviewCollectionViewCell(self, didPress: sender)
		}
	}
}
