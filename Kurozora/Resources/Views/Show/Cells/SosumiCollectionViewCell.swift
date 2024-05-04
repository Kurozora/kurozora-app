//
//  SosumiCollectionViewCell.swift
//  Kurozora
//
//  Created by Khoren Katklian on 30/06/2020.
//  Copyright © 2020 Kurozora. All rights reserved.
//

import UIKit

class SosumiCollectionViewCell: UICollectionViewCell {
	// MARK: - IBOutlets
	@IBOutlet weak var copyrightLabel: KSecondaryLabel!
	@IBOutlet weak var separatorView: SeparatorView!

	// MARK: - Properties
	var copyrightText: String? {
		didSet {
			self.configureCell()
		}
	}

	// MARK: - Functions
	private func configureCell() {
		self.copyrightLabel.numberOfLines = 0
		self.copyrightLabel.text = copyrightText
	}
}
