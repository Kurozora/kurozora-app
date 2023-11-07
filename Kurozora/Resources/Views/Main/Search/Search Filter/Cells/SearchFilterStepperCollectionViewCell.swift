//
//  SearchFilterStepperCollectionViewCell.swift
//  Kurozora
//
//  Created by Khoren Katklian on 02/05/2023.
//  Copyright © 2023 Kurozora. All rights reserved.
//

import UIKit

class SearchFilterStepperCollectionViewCell: SearchFilterBaseCollectionViewCell {
	// MARK: - IBOutlets
	@IBOutlet weak var stepper: KStepper!

	// MARK: - Functions
	func configureCell(title: String?, selected: Double?) {
		super.configureCell(title: title)
		self.stepper.maximumValue = 100000

		self.stepper.value = selected ?? 0
	}

	// MARK: - IBactions
	@IBAction func stepperValueChanged(_ sender: KStepper) {
		let value = sender.value.isZero ? nil : sender.value
		self.delegate?.searchFilterBaseCollectionViewCell(self, didChangeValue: value)
	}
}
