//
//  ActionButtonTableViewCell.swift
//  Kurozora
//
//  Created by Khoren Katklian on 06/10/2019.
//  Copyright © 2019 Kurozora. All rights reserved.
//

import UIKit

protocol ActionButtonTableViewCellDelegate: AnyObject {
	func actionButtonTableViewCell(_ cell: ActionButtonTableViewCell, didPressButton button: UIButton)
}

class ActionButtonTableViewCell: UITableViewCell {
	// MARK: - IBOutlets
	@IBOutlet weak var actionButton: KButton!
	@IBOutlet weak var actionTextField: KTextField!

	// MARK: - Properties
	weak var delegate: ActionButtonTableViewCellDelegate?

	// MARK: - IBActions
	@IBAction func actionButtonPressed(_ sender: UIButton) {
		self.delegate?.actionButtonTableViewCell(self, didPressButton: sender)
	}
}
