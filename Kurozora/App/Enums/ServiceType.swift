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
	/// Used to display information related to importing from other services.
	case libraryImport

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
		case .libraryImport:
			return Trans.libraryImportHeadline
		case .redeem:
			return Trans.redeemHeadline
		case .signInWithApple:
			return Trans.signInWithAppleHeadline
		default:
			return ""
		}
	}

	/// The subhead string value of a service type.
	var subheadStringValue: String {
		switch self {
		case .libraryImport:
			return Trans.libraryImportSubheadline
		case .redeem:
			return Trans.redeemSubheadline
		case .signInWithApple:
			return Trans.signInWithAppleSubheadline
		default:
			return ""
		}
	}

	/// The footer string value of a service type.
	var footerStringValue: String {
		switch self {
		case .libraryImport:
			return Trans.libraryImportFooter
		case .redeem:
			return Trans.redeemFooter
		case .signInWithApple:
			return Trans.signInWithAppleFooter
		case .subscription:
			return Trans.subscriptionFooter
		case .tipJar:
			return Trans.tipJarFooter
		default:
			return ""
		}
	}

	/// The attributed footer string value of a service type.
	var attributedFooterStringValue: ThemeAttributedStringPicker {
		switch self {
		case .visitPrivacyPolicy:
			return Trans.visitPrivacyPolicy
		default:
			return ThemeAttributedStringPicker([])
		}
	}
}
