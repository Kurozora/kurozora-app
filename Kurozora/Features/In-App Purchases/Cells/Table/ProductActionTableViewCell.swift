//
//  ProductActionTableViewCell.swift
//  Kurozora
//
//  Created by Khoren Katklian on 06/10/2019.
//  Copyright © 2019 Kurozora. All rights reserved.
//

import UIKit

protocol ProductActionTableViewCellDelegate: class {
	func actionButtonPressed(_ sender: UIButton)
}

class ProductActionTableViewCell: UITableViewCell {
	// MARK: - Properties
	weak var delegate: ProductActionTableViewCellDelegate?

	// MARK: - IBOutlets
	@IBOutlet weak var actionButton: KButton!
	@IBOutlet weak var actionTextField: KTextField!

	// MARK: - IBActions
	@IBAction func actionButtonPressed(_ sender: UIButton) {
		delegate?.actionButtonPressed(sender)
	}
}
