//
//  ProductActionTableViewCell.swift
//  Kurozora
//
//  Created by Khoren Katklian on 06/10/2019.
//  Copyright © 2019 Kurozora. All rights reserved.
//

import UIKit

protocol ProductActionTableViewCellDelegate: AnyObject {
	func productActionTableViewCell(_ cell: ProductActionTableViewCell, didPressButton button: UIButton)
}

class ProductActionTableViewCell: UITableViewCell {
	// MARK: - IBOutlets
	@IBOutlet weak var actionButton: KButton!
	@IBOutlet weak var actionTextField: KTextField!

	// MARK: - Properties
	weak var delegate: ProductActionTableViewCellDelegate?

	// MARK: - IBActions
	@IBAction func actionButtonPressed(_ sender: UIButton) {
		self.delegate?.productActionTableViewCell(self, didPressButton: sender)
	}
}
