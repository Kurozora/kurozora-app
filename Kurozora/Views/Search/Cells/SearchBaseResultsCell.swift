//
//  SearchBaseResultsCell.swift
//  Kurozora
//
//  Created by Khoren Katklian on 16/03/2019.
//  Copyright © 2019 Kurozora. All rights reserved.
//

import UIKit

class SearchBaseResultsCell: UICollectionViewCell {
	// MARK: - IBOutlets
	@IBOutlet weak var primaryLabel: UILabel!
	@IBOutlet weak var secondaryLabel: UILabel?
	@IBOutlet weak var actionButton: KTintedButton?
	@IBOutlet weak var searchImageView: UIImageView!
	@IBOutlet weak var separatorView: UIVisualEffectView?

	// MARK: - Functions
	/// Configure the cell with the given details.
	func configureCell() { }

	// MARK: - IBActions
	@IBAction func actionButtonPressed(_ sender: UIButton) { }
}
