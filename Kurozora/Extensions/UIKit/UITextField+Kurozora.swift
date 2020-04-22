//
//  UITextField+Kurozora.swift
//  Kurozora
//
//  Created by Khoren Katklian on 06/11/2019.
//  Copyright © 2019 Kurozora. All rights reserved.
//

import UIKit

extension UITextField {
	// MARK: - Properties
	#if targetEnvironment(macCatalyst)
	@objc(_focusRingType)
	var focusRingType: UInt {
		return 1 //NSFocusRingTypeNone
	}
	#endif
}
