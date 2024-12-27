//
//  LABiometryType+Kurozora.swift
//  Kurozora
//
//  Created by Khoren Katklian on 26/12/2024.
//  Copyright © 2024 Kurozora. All rights reserved.
//

import UIKit
import LocalAuthentication

extension LABiometryType {
	/// The image value of the biometric type.
	var imageValue: UIImage? {
		switch self {
		case .faceID:
			return R.image.icons.faceid()
		case .touchID:
			return R.image.icons.touchID()
		case .opticID:
			return R.image.icons.opticID()
		case .none:
			return nil
		@unknown default:
			return R.image.icons.lock()
		}
	}

	/// The localized settings name of the biometric type.
	var localizedSettingsName: String {
		switch self {
		case .faceID:
			return Trans.faceIDPasscode
		case .touchID:
			return Trans.touchIDPasscode
		case .opticID:
			return Trans.opticIDPasscode
		case .none:
			return Trans.passcode
		@unknown default:
			return Trans.passcode
		}
	}

	/// The localized authentication settings name of the biometric type.
	var localizedAuthenticationSettingsName: String {
		switch self {
		case .faceID:
			return "Lock with Face ID & Passcode"
		case .touchID:
			return "Lock with Touch ID & Passcode"
		case .opticID:
			return "Lock with Optic ID & Passcode"
		case .none:
			return "Lock with Passcode"
		@unknown default:
			return "Lock with Passcode"
		}
	}

	/// The localized authentication settings description of the biometric type.
	var localizedAuthenticationSettingsDescription: String {
		switch self {
		case .faceID:
			return "Enable this option so that Kurozora is locked whenever you close it. You'll be asked to authenticate through Face ID or your device's passcode when you reopen the app."
		case .touchID:
			return "Enable this option so that Kurozora is locked whenever you close it. You'll be asked to authenticate through Touch ID or your device's passcode when you reopen the app."
		case .opticID:
			return "Enable this option so that Kurozora is locked whenever you close it. You'll be asked to authenticate through Optic ID or your device's passcode when you reopen the app."
		case .none:
			return "Enable this option so that Kurozora is locked whenever you close it. You'll be asked to authenticate through your device's passcode when you reopen the app."
		@unknown default:
			return "Enable this option so that Kurozora is locked whenever you close it. You'll be asked to authenticate through your device's passcode when you reopen the app."
		}
	}
}
