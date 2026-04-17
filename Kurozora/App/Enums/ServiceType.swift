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
	/// Used to display information related to deleting a library.
	case libraryDelete

	/// Used to display information related to importing from other services.
	case libraryImport

	/// Used to display information related to redeeming code.
	case redeem

	/// Used to display information related to signing in with Apple.
	case signInWithApple

	/// Used to display information related to paying for subscriptions.
	case subscription

	/// Used to display information related to tipping.
	case tipJar

	/// Used to display information related to visiting the privacy policy.
	case visitPrivacyPolicy

	// MARK: - Properties
	/// The headline string value of a service type.
	var headlineStringValue: String {
		switch self {
		case .libraryDelete:
			return L10n.libraryDeleteHeadline
		case .libraryImport:
			return L10n.libraryImportHeadline
		case .redeem:
			return L10n.redeemHeadline
		case .signInWithApple:
			return L10n.signInWithAppleHeadline
		default:
			return ""
		}
	}

	/// The subhead string value of a service type.
	var subheadStringValue: String {
		switch self {
		case .libraryDelete:
			return L10n.libraryDeleteSubheadline
		case .libraryImport:
			return L10n.libraryImportSubheadline
		case .redeem:
			return L10n.redeemSubheadline
		case .signInWithApple:
			return L10n.signInWithAppleSubheadline
		default:
			return ""
		}
	}

	/// The footer string value of a service type.
	var footerStringValue: String {
		switch self {
		case .libraryDelete:
			return L10n.libraryDeleteFooter
		case .libraryImport:
			return L10n.libraryImportFooter
		case .redeem:
			return L10n.redeemFooter
		case .signInWithApple:
			return L10n.signInWithAppleFooter
		case .subscription:
			return L10n.subscriptionFooter
		case .tipJar:
			return L10n.tipJarFooter
		default:
			return ""
		}
	}

	/// The attributed footer string value of a service type.
	var attributedFooterStringValue: ThemeAttributedStringPicker {
		switch self {
		case .visitPrivacyPolicy:
			return L10n.visitPrivacyPolicy
		default:
			return ThemeAttributedStringPicker([])
		}
	}
}
