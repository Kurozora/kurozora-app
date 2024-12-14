//
//  DeselectableSegmentedControl.swift
//  Kurozora
//
//  Created by Khoren Katklian on 14/12/2024.
//  Copyright © 2024 Kurozora. All rights reserved.
//

import UIKit

class DeselectableSegmentedControl: UISegmentedControl {
	override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
		let previousSelectedSegmentIndex = self.selectedSegmentIndex

		super.touchesEnded(touches, with: event)

		if previousSelectedSegmentIndex == self.selectedSegmentIndex {
			self.selectedSegmentIndex = UISegmentedControl.noSegment
			let touch = touches.first!
			let touchLocation = touch.location(in: self)

			if self.bounds.contains(touchLocation) {
				self.sendActions(for: .valueChanged)
			}
		}
	}
}
