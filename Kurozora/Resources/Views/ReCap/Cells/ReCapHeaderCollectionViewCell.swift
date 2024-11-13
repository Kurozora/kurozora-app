//
//  ReCapHeaderCollectionViewCell.swift
//  Kurozora
//
//  Created by Khoren Katklian on 13/11/2024.
//  Copyright © 2024 Kurozora. All rights reserved.
//

import UIKit

class ReCapHeaderCollectionViewCell: UICollectionViewCell {
	// MARK: - IBOutlets
	@IBOutlet weak var primaryLabel: KLabel!

	// MARK: - Functions
	/// Configure the cell with the given details.
	func configure(using title: String) {
		self.primaryLabel.font = UIFont.preferredFont(forTextStyle: .title1).bold
		self.primaryLabel.text = title
	}
}
