//
//  SearchFilterBaseCollectionViewCell.swift
//  Kurozora
//
//  Created by Khoren Katklian on 01/05/2023.
//  Copyright © 2023 Kurozora. All rights reserved.
//

import UIKit

protocol SearchFilterBaseCollectionViewCellDelegate: AnyObject {
	func searchFilterBaseCollectionViewCell(_ cell: SearchFilterBaseCollectionViewCell, didChangeValue value: AnyHashable?)
}

class SearchFilterBaseCollectionViewCell: KCollectionViewCell {
	// MARK: - IBOutlets
	@IBOutlet weak var primaryLabel: KLabel!

	// MARK: - Properties
	weak var delegate: SearchFilterBaseCollectionViewCellDelegate?

	// MARK: - Initializers
	override init(frame: CGRect) {
		super.init(frame: frame)
		self.sharedInit()
	}

	required init?(coder: NSCoder) {
		super.init(coder: coder)
		self.sharedInit()
	}

	// MARK: - Functions
	/// The shared settings used to initialize the table view cell.
	func sharedInit() {
		self.contentView.theme_backgroundColor = KThemePicker.tableViewCellBackgroundColor.rawValue
		self.layerCornerRadius = 10
	}

	// MARK: - Functions
	func configureCell(title: String?) {
		self.hideSkeleton()

		self.primaryLabel.text = title
	}
}
