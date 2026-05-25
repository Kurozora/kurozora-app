//
//  UserTimeout+UIKit.swift
//  Kurozora
//
//  Created by Khoren Katklian on 26/05/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import KurozoraKit
import UIKit

extension UserTimeout.Attributes {
	// MARK: - Banner
	/// Returns the profile-banner title for the given remaining time.
	///
	/// - Parameter remaining: The seconds left until the suspension lifts.
	///
	/// - Returns: A localized banner title.
	func suspensionBannerTitle(forRemaining remaining: TimeInterval?) -> String {
		if self.isPermanent {
			return L10n.suspendedPermanently
		}

		guard let remaining = remaining else {
			return L10n.suspended
		}

		if remaining <= 0 {
			return L10n.suspensionEnding
		}

		if remaining >= 86_400 {
			return L10n.suspendedForDays(Int(remaining / 86_400))
		}

		if remaining >= 3_600 {
			return L10n.suspendedForHours(Int(remaining / 3_600))
		}

		if remaining >= 60 {
			return L10n.suspendedForMinutes(Int(remaining / 60))
		}

		return L10n.suspendedForSeconds(Int(remaining))
	}

	// MARK: - Details
	/// Returns the suspension headline for the given viewer.
	///
	/// - Parameters:
	///    - displayName: The display name of the suspended user.
	///    - isAdminView: Whether a moderator is inspecting another user's suspension.
	///
	/// - Returns: A localized headline.
	func suspensionHeadline(displayName: String, isAdminView: Bool) -> String {
		if isAdminView {
			return self.isPermanent
				? L10n.userPermanentlySuspended(displayName)
				: L10n.userCurrentlySuspended(displayName)
		}

		return self.isPermanent
			? L10n.ownAccountPermanentlySuspended
			: L10n.ownAccountTemporarilySuspended
	}

	/// Returns the expiry value shown on the suspension details view.
	///
	/// - Returns: A localized expiry value.
	func suspensionExpiryValue() -> String {
		guard !self.isPermanent, let expiresAt = self.expiresAt else {
			return L10n.suspensionEndsNoEndDate
		}

		let relativeFormatter = RelativeDateTimeFormatter()
		relativeFormatter.unitsStyle = .full

		let absolute = expiresAt.formatted(date: .abbreviated, time: .shortened)
		let relative = relativeFormatter.localizedString(for: expiresAt, relativeTo: Date())

		return L10n.suspensionEndsAt(absolute: absolute, relative: relative)
	}
}
