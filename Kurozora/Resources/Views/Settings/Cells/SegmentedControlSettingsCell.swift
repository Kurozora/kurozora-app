//
//  SegmentedControlSettingsCell.swift
//  Kurozora
//
//  Created by Khoren Katklian on 12/02/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import UIKit

class SegmentedControlSettingsCell: SettingsCell {
	// MARK: - IBOutlets
	@IBOutlet weak var segmentedControl: UISegmentedControl!

	// MARK: - Functions
	func configure(title: String?, segmentTitles: [String], selectedSegmentIndex: Int, action: UIAction?) {
		super.configure(title: title)

		self.secondaryLabel?.isHidden = true
		self.chevronImageView?.isHidden = true
		self.segmentedControl.segmentTitles = segmentTitles
		self.segmentedControl.selectedSegmentIndex = (0 ..< segmentTitles.count).contains(selectedSegmentIndex) ? selectedSegmentIndex : UISegmentedControl.noSegment

		self.segmentedControl.removeTarget(nil, action: nil, for: .valueChanged)

		if let action {
			self.segmentedControl.addAction(action, for: .valueChanged)
		}
	}
}
