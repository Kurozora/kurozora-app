//
//  KTintedLabel.swift
//  Kurozora
//
//  Created by Khoren Katklian on 05/05/2020.
//  Copyright © 2020 Kurozora. All rights reserved.
//

import UIKit

/**
	A themed view that displays one or more lines of read-only text, often used in conjunction with controls to describe their intended purpose.

	The color of the labels matches with the currently selected theme's tint color.
	You can add labels to your interface programmatically or by using Interface Builder.
*/
class KTintedLabel: KLabel {
	// MARK: - Functions
	override func sharedInit() {
		self.theme_textColor = KThemePicker.tintColor.rawValue
	}
}
