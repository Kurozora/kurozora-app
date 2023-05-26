//
//  SearchFilterBaseCollectionViewCell.swift
//  Kurozora
//
//  Created by Khoren Katklian on 01/05/2023.
//  Copyright © 2023 Kurozora. All rights reserved.
//

import UIKit

protocol SearchFilterBaseCollectionViewCellDelegate: AnyObject {
	func searchFilterBaseCollectionViewCell(_ cell: SearchFilterBaseCollectionViewCell, didChangeValue value: Any?)
}

class SearchFilterBaseCollectionViewCell: KCollectionViewCell {
	// MARK: - IBOutlets
	@IBOutlet weak var primaryLabel: KLabel!

	// MARK: - Properties
	weak var delegate: SearchFilterBaseCollectionViewCellDelegate?

	// MARK: - Functions
	func configureCell(title: String?) {
		self.hideSkeleton()

		self.primaryLabel.text = title
	}
}
