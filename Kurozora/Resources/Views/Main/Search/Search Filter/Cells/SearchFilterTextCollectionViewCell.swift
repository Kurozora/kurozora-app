//
//  SearchFilterTextCollectionViewCell.swift
//  Kurozora
//
//  Created by Khoren Katklian on 02/05/2023.
//  Copyright © 2023 Kurozora. All rights reserved.
//

import UIKit

class SearchFilterTextCollectionViewCell: SearchFilterBaseCollectionViewCell {
	// MARK: - IBOutlets
	@IBOutlet weak var textField: KTextField!

	// MARK: - Functions
	func configureCell(title: String?, placeholder: String?, selected: String?) {
		super.configureCell(title: title)

		self.textField.placeholder = placeholder
		self.textField.text = selected
		self.textField.textAlignment = .right
	}

	// MARK: - IBActions
	@IBAction func textChanged(_ sender: UITextField) {
		self.delegate?.searchFilterBaseCollectionViewCell(self, didChangeValue: sender.text)
	}
}
