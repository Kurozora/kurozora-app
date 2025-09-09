//
//  ReviewManager.swift
//  Kurozora
//
//  Created by Khoren Katklian on 27/11/2024.
//  Copyright © 2024 Kurozora. All rights reserved.
//

import StoreKit
import KurozoraKit

final class ReviewManager {
	// MARK: - Properties
	/// The shared instance of the review manager.
	static let shared = ReviewManager()

	/// The engagement level based on app usage metrics.
	private var engagementLevel: EngagementLevel {
		switch UserSettings.sessionActionsCount {
		case 20...: return .high
		case 10..<20: return .medium
		default: return .low
		}
	}

	/// The maximum requests allowed based on user engagement.
	///
	/// Since not every try is guaranteed to show the prompt, we can try more often based on
	/// the user's engagement level. High engagement users can be prompted more often.
	/// Low engagement users should be prompted less often.
	private var maxRequests: Int {
		switch self.engagementLevel {
		case .high: return 5
		case .medium: return 3
		case .low: return 1
		}
	}

	// MARK: - Functions
	/// Checks if the review prompt should be displayed based on user activity and app engagement.
	///
	/// - Parameters:
	///    - action: The action that triggered the review request.
	@MainActor
	func requestReview(for action: ReviewAction) {
		// Ensure this is a positive moment
		guard self.isEligibleForReview(after: action) else { return }

		// Call the Apple API to display the review prompt
		if let scene = UIApplication.shared.connectedScenes.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene {
			SKStoreReviewController.requestReview(in: scene)
			self.recordReviewRequest()
		}
	}

	/// Determines eligibility for showing the review prompt.
	private func isEligibleForReview(after action: ReviewAction) -> Bool {
		let now = Date()
		let lastRequestDate = UserSettings.lastReviewRequestDate
		let daysSinceLastRequest = Calendar.current.dateComponents([.day], from: lastRequestDate, to: now).day ?? 0

		// Reset request count if it's been more than 30 days since the last prompt
		if daysSinceLastRequest >= 30 {
			UserSettings.set(0, forKey: .reviewRequestCount)
		}

		// Check against the maximum allowed requests for the current time frame
		if UserSettings.reviewRequestCount >= self.maxRequests {
			return false
		}

		// Additional conditions for specific actions
		switch action {
		case .itemAddedToLibrary(let status):
			return status != .ignored || status != .dropped || status != .onHold
		}
	}

	/// Records the review request to avoid over-prompting.
	private func recordReviewRequest() {
		UserSettings.set(Date.now, forKey: .lastReviewRequestDate)
		UserSettings.set(UserSettings.reviewRequestCount + 1, forKey: .reviewRequestCount)
	}
}

// MARK: - ReviewAction
/// The set of actions that can trigger the review request.
enum ReviewAction {
	case itemAddedToLibrary(status: KKLibrary.Status)
}

// MARK: - EngagementLevel
/// The level of user engagement with the app.
enum EngagementLevel {
	case low
	case medium
	case high
}
