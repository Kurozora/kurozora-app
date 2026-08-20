//
//  ReportSubject.swift
//  Kurozora
//
//  Created by Khoren Katklian on 20/08/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import Foundation
import KurozoraKit

/// A reason offered by the report sheet.
enum ReportOption: Hashable, Sendable {
	// MARK: - Cases
	/// A reason offered when reporting a parental guide entry.
	case parentalGuide(ParentalGuideReportReason)

	/// A reason offered when reporting a review or a feed message.
	case general(ReportReason)

	// MARK: - Properties
	/// The localized title of the reason.
	var title: String {
		switch self {
		case .parentalGuide(let reason):
			switch reason {
			case .inaccurate:
				return L10n.reportReasonInaccurate
			case .spoiler:
				return L10n.reportReasonSpoiler
			case .spam:
				return L10n.reportReasonSpam
			case .inappropriate:
				return L10n.reportReasonInappropriate
			case .other:
				return L10n.reportReasonOther
			}
		case .general(let reason):
			switch reason {
			case .spam:
				return L10n.reportReasonSpamOrAdvertising
			case .notAReview:
				return L10n.reportReasonNotAReview
			case .spoiler:
				return L10n.reportReasonUnmarkedSpoilers
			case .abuse:
				return L10n.reportReasonAbuse
			case .inappropriate:
				return L10n.reportReasonInappropriateContent
			case .selfHarm:
				return L10n.reportReasonSelfHarm
			case .piracy:
				return L10n.reportReasonPiracy
			case .other:
				return L10n.reportReasonSomethingElse
			}
		}
	}

	/// Whether the reason requires accompanying details.
	var requiresDetails: Bool {
		switch self {
		case .parentalGuide(let reason):
			return reason == .other
		case .general(let reason):
			return reason == .other
		}
	}
}

/// The content a report is filed against.
enum ReportSubject: Sendable {
	// MARK: - Cases
	/// A parental guide entry.
	case parentalGuideEntry(ParentalGuideEntryIdentity)

	/// A review.
	case review(ReviewIdentity)

	/// A feed message.
	case feedMessage(FeedMessageIdentity)

	// MARK: - Properties
	/// The title shown in the report sheet's navigation bar.
	var navigationTitle: String {
		switch self {
		case .parentalGuideEntry:
			return L10n.reportParentalGuideEntry
		case .review:
			return L10n.reportReview
		case .feedMessage:
			return L10n.reportMessage
		}
	}

	/// The reasons offered for the subject.
	var options: [ReportOption] {
		switch self {
		case .parentalGuideEntry:
			return ParentalGuideReportReason.allCases.map { .parentalGuide($0) }
		case .review:
			return ReportReason.offeredForReview.map { .general($0) }
		case .feedMessage:
			return ReportReason.offeredForFeedMessage.map { .general($0) }
		}
	}

	/// The title of the confirmation shown after the report has been filed.
	var successTitle: String {
		switch self {
		case .parentalGuideEntry:
			return L10n.reportSuccessTitle
		case .review:
			return L10n.reviewReportedHeadline
		case .feedMessage:
			return L10n.messageReportedHeadline
		}
	}

	/// The message of the confirmation shown after the report has been filed.
	var successMessage: String {
		switch self {
		case .parentalGuideEntry:
			return L10n.reportSuccessMessage
		case .review:
			return L10n.reviewReportedSubheadline
		case .feedMessage:
			return L10n.messageReportedSubheadline
		}
	}

	// MARK: - Functions
	/// Files the report against the subject.
	///
	/// - Parameters:
	///    - option: The selected reason.
	///    - details: The accompanying details.
	@MainActor
	func submit(option: ReportOption, details: String?) async throws {
		switch (self, option) {
		case (.parentalGuideEntry(let entryIdentity), .parentalGuide(let reason)):
			_ = try await KService.reportParentalGuideEntry(entryIdentity, reason: reason, details: details).response()

			NotificationCenter.default.post(name: .KPGEntryDidReport, object: nil, userInfo: ["entryID": entryIdentity.id])
		case (.review(let reviewIdentity), .general(let reason)):
			_ = try await KService.reportReview(reviewIdentity, reason: reason, details: details).response()
		case (.feedMessage(let messageIdentity), .general(let reason)):
			_ = try await KService.reportFeedMessage(messageIdentity, reason: reason, details: details).response()
		default:
			break
		}
	}
}
