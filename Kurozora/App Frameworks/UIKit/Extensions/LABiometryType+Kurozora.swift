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
            return .Icons.faceid
		case .touchID:
            return .Icons.touchID
		case .opticID:
            return .Icons.opticID
		case .none:
			return .Icons.lock
		@unknown default:
            return .Icons.lock
		}
	}

	/// The localized settings name of the biometric type.
	var localizedSettingsName: String {
		switch self {
		case .faceID:
			return L10n.faceIDPasscode
		case .touchID:
			return L10n.touchIDPasscode
		case .opticID:
			return L10n.opticIDPasscode
		case .none:
			return L10n.passcode
		@unknown default:
			return L10n.passcode
		}
	}

	/// The localized authentication settings name of the biometric type.
	var localizedAuthenticationSettingsName: String {
		switch self {
		case .faceID:
			return L10n.lockWithFaceID
		case .touchID:
			return L10n.lockWithTouchID
		case .opticID:
			return L10n.lockWithOpticID
		case .none:
			return L10n.lockWithPasscode
		@unknown default:
			return L10n.lockWithPasscode
		}
	}

	/// The localized authentication settings description of the biometric type.
	var localizedAuthenticationSettingsDescription: String {
		switch self {
		case .faceID:
			return L10n.lockDescriptionFaceID
		case .touchID:
			return L10n.lockDescriptionTouchID
		case .opticID:
			return L10n.lockDescriptionOpticID
		case .none:
			return L10n.lockDescriptionPasscode
		@unknown default:
			return L10n.lockDescriptionPasscode
		}
	}
}
