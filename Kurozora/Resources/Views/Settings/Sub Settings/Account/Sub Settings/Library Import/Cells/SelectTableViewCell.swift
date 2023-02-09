//
//  SelectTableViewCell.swift
//  Kurozora
//
//  Created by Khoren Katklian on 27/01/2023.
//  Copyright © 2023 Kurozora. All rights reserved.
//

import UIKit

protocol SelectTableViewCellDelegate: AnyObject {
	func selectTableViewCell(_ cell: SelectTableViewCell, didPressButton selectButton: UIButton)
}

class SelectTableViewCell: UITableViewCell {
	// MARK: - IBOutlets
	@IBOutlet weak var selectButton: KButton!

	// MARK: - Properties
	weak var delegate: SelectTableViewCellDelegate?

	// MARK: - Functions
	func configureCell(using buttonTitle: String, buttonTag: Int) {
		self.selectButton.setTitle(buttonTitle, for: .normal)
		self.selectButton.tag = buttonTag
	}

	// MARK: - IBActions
	@IBAction func didPressSelectButton(_ sender: UIButton) {
		self.delegate?.selectTableViewCell(self, didPressButton: sender)
	}
}
