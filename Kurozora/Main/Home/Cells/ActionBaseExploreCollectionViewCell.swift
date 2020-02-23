//
//  ActionBaseExploreCollectionViewCell.swift
//  Kurozora
//
//  Created by Khoren Katklian on 22/10/2019.
//  Copyright © 2019 Kurozora. All rights reserved.
//

import UIKit

class ActionBaseExploreCollectionViewCell: UICollectionViewCell {
	// MARK: - IBOutlets
	@IBOutlet weak var actionButton: KButton?

	// MARK: - Properties
	var actionItem: [String: String]? {
		didSet {
			configureCell()
		}
	}

	// MARK: - Functions
	/// Configure the cell with the given details.
	func configureCell() {
		guard let actionItem = actionItem else { return }
		actionButton?.setTitle(actionItem["title"], for: .normal)
	}

	// MARK: - IBActions
	@IBAction func actionButtonPressed(_ sender: UIButton) {
	}
}
