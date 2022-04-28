//
//  ServiceFooter.swift
//  Kurozora
//
//  Created by Khoren Katklian on 05/05/2020.
//  Copyright © 2020 Kurozora. All rights reserved.
//

import Foundation
import SwiftTheme

/// The set of available service types.
enum ServiceType {
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
	/// The headline string value of a service type.
	var headlineStringValue: String {
		switch self {
		case .malImport:
			return ServiceHeaderString.malImportHeadline
		case .redeem:
			return ServiceHeaderString.redeemHeadline
		case .signInWithApple:
			return ServiceHeaderString.signInWithAppleHeadline
		default:
			return ""
		}
	}

	/// The subhead string value of a service type.
	var subheadStringValue: String {
		switch self {
		case .malImport:
			return ServiceHeaderString.malImportSubhead
		case .redeem:
			return ServiceHeaderString.redeemSubhead
		case .signInWithApple:
			return ServiceHeaderString.signInWithAppleSubhead
		default:
			return ""
		}
	}

	/// The footer string value of a service type.
	var footerStringValue: String {
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

	/// The attributed footer string value of a service type.
	var attributedFooterStringValue: ThemeAttributedStringPicker {
		switch self {
		case .visitPrivacyPolicy:
			return ServiceFooterString.visitPrivacyPolicy
		default:
			return ThemeAttributedStringPicker([])
		}
	}
}
