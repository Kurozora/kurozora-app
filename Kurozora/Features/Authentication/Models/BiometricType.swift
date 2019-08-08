//
//  BiometricType.swift
//  Kurozora
//
//  Created by Khoren Katklian on 10/06/2019.
//  Copyright © 2019 Kurozora. All rights reserved.
//

import Foundation

/**
	List of biometric types compatible with iOS 10

	```
	case faceID
	case touchID
	case none
	```
*/
enum BiometricType {
	/// Device has `Face ID` as a biometric option.
	case faceID

	/// Device has `Touch ID` as a biometric option.
	case touchID

	/// Device has neither `Face ID` or `Touch ID` as a biometric option.
	case none
}
