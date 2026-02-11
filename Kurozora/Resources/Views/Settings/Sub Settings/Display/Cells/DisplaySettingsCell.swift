//
//  DisplaySettingsCell.swift
//  Kurozora
//
//  Created by Khoren Katklian on 24/06/2019.
//  Copyright © 2019 Kurozora. All rights reserved.
//

import UIKit

protocol DisplaySettingsCellDelegate: AnyObject {
	func displaySettingsCell(_ cell: DisplaySettingsCell, didSelectOptionWithIdentifier identifier: Int)
}

class DisplaySettingsCell: SettingsCell {
	struct Option {
		let identifier: Int
		let title: String
		let image: UIImage?
	}

	// MARK: - IBOutlets
	@IBOutlet weak var optionsStackView: UIStackView!

	// MARK: - Properties
	weak var delegate: DisplaySettingsCellDelegate?
	private var optionViewsByIdentifier: [Int: DisplayAppearanceOptionView] = [:]

	// MARK: - Functions
	func configure(options: [Option], selectedIdentifier: Int, isEnabled: Bool) {
		self.rebuildOptions(using: options)
		self.updateSelectedOption(identifier: selectedIdentifier)
		self.setOptionsEnabled(isEnabled)
	}

	func updateSelectedOption(identifier: Int) {
		for (optionIdentifier, optionView) in self.optionViewsByIdentifier {
			optionView.setSelected(optionIdentifier == identifier)
		}
	}

	func setOptionsEnabled(_ isEnabled: Bool) {
		self.optionViewsByIdentifier.values.forEach { $0.isOptionEnabled = isEnabled }
	}

	private func rebuildOptions(using options: [Option]) {
		self.optionViewsByIdentifier.removeAll(keepingCapacity: true)
		self.optionsStackView.arrangedSubviews.forEach { arrangedSubview in
			self.optionsStackView.removeArrangedSubview(arrangedSubview)
			arrangedSubview.removeFromSuperview()
		}

		for option in options {
			let optionView = DisplayAppearanceOptionView()
			optionView.configure(title: option.title, image: option.image, isSelected: false)
			optionView.didSelect = { [weak self] in
				guard let self = self else { return }
				self.delegate?.displaySettingsCell(self, didSelectOptionWithIdentifier: option.identifier)
			}

			self.optionViewsByIdentifier[option.identifier] = optionView
			self.optionsStackView.addArrangedSubview(optionView)
		}
	}
}
