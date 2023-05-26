//
//  SearchFilterSelectCollectionViewCell.swift
//  Kurozora
//
//  Created by Khoren Katklian on 02/05/2023.
//  Copyright © 2023 Kurozora. All rights reserved.
//

import UIKit

class SearchFilterSelectCollectionViewCell: SearchFilterBaseCollectionViewCell {
	// MARK: - IBOutlets
	@IBOutlet weak var popupButton: KButton!

	// MARK: - Functions
	func configureCell(title: String?, options: [String], selected: String?) {
		self.configureCell(title: title)

		var options = options
		options.prepend("Default")

		let menu = UIMenu(title: "", options: .singleSelection, children: options.map { option in
			return UIAction(title: option, state: option == selected ? .on : .off) { action in
				self.menuOptionChanged(action)
			}
		})

		self.popupButton.menu = menu
	}

	// MARK: - IBActions
	@objc
	func menuOptionChanged(_ sender: UIAction) {
		self.delegate?.searchFilterBaseCollectionViewCell(self, didChangeValue: sender.title)
	}
}
