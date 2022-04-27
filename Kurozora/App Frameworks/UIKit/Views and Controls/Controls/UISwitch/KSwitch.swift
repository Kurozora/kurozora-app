//
//  KSwitch.swift
//  Kurozora
//
//  Created by Khoren Katklian on 28/08/2020.
//  Copyright © 2020 Kurozora. All rights reserved.
//

import UIKit

/// A control that offers a binary choice, such as on/off.
///
/// The `KSwitch` class declares a property and a method to control its on/off state. As with UISlider, when the user manipulates the switch control (“flips” it) a [valueChanged](apple-reference-documentation://ls%2Fdocumentation%2Fuikit%2Fuicontrol%2Fevent%2F1618238-valuechanged) event is generated, which results in the control (if properly configured) sending an action message.
///
/// The appearance of the switch is customised to use the global tint for when it is on.
class KSwitch: UISwitch {
	// MARK: - Initializers
	override init(frame: CGRect) {
		super.init(frame: frame)
		sharedInit()
	}

	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		sharedInit()
	}

	// MARK: - Functions
	/// The shared settings used to initialize the switch.
	func sharedInit() {
		self.theme_onTintColor = KThemePicker.tintColor.rawValue
	}
}
