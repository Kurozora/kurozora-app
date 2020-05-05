//
//  ServiceFooter.swift
//  Kurozora
//
//  Created by Khoren Katklian on 05/05/2020.
//  Copyright © 2020 Kurozora. All rights reserved.
//

import UIKit

/**
	The set of available promotional service footer types.
*/
enum ServiceFooter {
	// MARK: - Cases
	/// Used to display information related to importing from MAL.
	case malImport

	/// Used to display information related to redeeming code.
	case redeem

	/// Used to display information related to signing in with Apple.
	case signInWithApple

	/// Used to display infromation related to paying for subscriptions.
	case subscription

	/// Used to display infromation related to tipping.
	case tipJar

	/// Used to display infomration related to visiting the privacy policy.
	case visitPrivacyPolicy

	// MARK: - Properties
	/// The string valaue of a promotional footer type.
	var stringValue: String {
		switch self {
		case .malImport:
			return ServiceFooterString.malImport
		case .redeem:
			return ServiceFooterString.redeem
		case .signInWithApple:
			return ServiceFooterString.signInWithApple
		case .subscription:
			return ServiceFooterString.subscription
		case .tipJar:
			return ServiceFooterString.tipJar
		default:
			return ""
		}
	}

	/// The attributed string value of a promotional footer type.
	var attributedStringValue: NSMutableAttributedString {
		switch self {
		case .visitPrivacyPolicy:
			return ServiceFooterString.visitPrivacyPolicy
		default:
			return NSMutableAttributedString()
		}
	}
}
