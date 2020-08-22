//
//  OnboardingHeaderTableViewCell.swift
//  Kurozora
//
//  Created by Khoren Katklian on 22/08/2020.
//  Copyright © 2020 Kurozora. All rights reserved.
//

import UIKit

class OnboardingHeaderTableViewCell: OnboardingBaseTableViewCell {
	// MARK: - IBOutlets
	@IBOutlet weak var primaryLabel: KLabel!
	@IBOutlet weak var secondaryLabel: KLabel!

	// MARK: - Functions
	override func configureCell() {
		self.primaryLabel.text = self.accountOnboardingType.titleValue
		self.secondaryLabel.text = self.accountOnboardingType.subTextValue
	}
}
