//
//  L10n+Moderation.swift
//  Kurozora
//
//  Created by Khoren Katklian on 26/05/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import Foundation

extension L10n {
	// MARK: - Banner
	/// The banner title shown for a permanent suspension.
	///
	/// - Tag: L10n-suspendedPermanently
	static let suspendedPermanently: String = String(
		localized: "Suspended permanently",
		table: "Moderation",
		comment: "Profile banner shown for a permanent suspension."
	)
	/// The banner title shown for an active suspension without an explicit expiry.
	///
	/// - Tag: L10n-suspended
	static let suspended: String = String(
		localized: "Suspended",
		table: "Moderation",
		comment: "Profile banner shown for an active suspension without an expiry."
	)
	/// The banner title shown when a suspension is about to lift.
	///
	/// - Tag: L10n-suspensionEnding
	static let suspensionEnding: String = String(
		localized: "Suspension ending",
		table: "Moderation",
		comment: "Profile banner shown when a suspension has just ended."
	)
	/// The banner title showing the remaining days of a suspension.
	static func suspendedForDays(_ days: Int) -> String {
		return String(
			localized: "Suspended for \(days) day(s)",
			table: "Moderation",
			comment: "Profile banner showing the remaining days of a suspension."
		)
	}
	/// The banner title showing the remaining hours of a suspension.
	static func suspendedForHours(_ hours: Int) -> String {
		return String(
			localized: "Suspended for \(hours) hour(s)",
			table: "Moderation",
			comment: "Profile banner showing the remaining hours of a suspension."
		)
	}
	/// The banner title showing the remaining minutes of a suspension.
	static func suspendedForMinutes(_ minutes: Int) -> String {
		return String(
			localized: "Suspended for \(minutes) minute(s)",
			table: "Moderation",
			comment: "Profile banner showing the remaining minutes of a suspension."
		)
	}
	/// The banner title showing the remaining seconds of a suspension.
	static func suspendedForSeconds(_ seconds: Int) -> String {
		return String(
			localized: "Suspended for \(seconds) second(s)",
			table: "Moderation",
			comment: "Profile banner showing the remaining seconds of a suspension."
		)
	}

	// MARK: - Details view
	/// The title of the suspension details view as seen by a moderator.
	///
	/// - Tag: L10n-suspensionDetails
	static let suspensionDetails: String = String(
		localized: "Suspension Details",
		table: "Moderation",
		comment: "Title of the suspension details view as seen by a moderator."
	)
	/// The title of the suspension details view as seen by the suspended user.
	///
	/// - Tag: L10n-accountSuspended
	static let accountSuspended: String = String(
		localized: "Account Suspended",
		table: "Moderation",
		comment: "Title of the suspension details view as seen by the suspended user."
	)
	/// The button that opens the community guidelines page.
	///
	/// - Tag: L10n-communityGuidelines
	static let communityGuidelines: String = String(
		localized: "Community Guidelines",
		table: "Moderation",
		comment: "Button on the suspension details view that opens the community guidelines."
	)
	/// The primary action on the user-facing suspension details view when no appeal has been filed yet.
	///
	/// - Tag: L10n-contestSuspensionAction
	static let contestSuspensionAction: String = String(
		localized: "Contest this suspension",
		table: "Moderation",
		comment: "Primary action on the user-facing suspension details view."
	)
	/// The primary action on the user-facing suspension details view when an appeal has already been filed.
	///
	/// - Tag: L10n-editAppealAction
	static let editAppealAction: String = String(
		localized: "Edit appeal",
		table: "Moderation",
		comment: "Primary action on the user-facing suspension details view when an appeal has already been filed."
	)
	/// The header for the suspended user's own appeal on the suspension details view.
	///
	/// - Tag: L10n-yourAppeal
	static let yourAppeal: String = String(
		localized: "Your appeal",
		table: "Moderation",
		comment: "Section header for the suspended user's own appeal."
	)
	/// The header for the suspended user's appeal as seen by a moderator.
	static func appealFrom(_ displayName: String) -> String {
		return String(
			localized: "Appeal from \(displayName)",
			table: "Moderation",
			comment: "Section header for the suspended user's appeal as seen by a moderator."
		)
	}
	/// The footer line showing when an appeal was last submitted.
	static func appealFiled(_ date: String) -> String {
		return String(
			localized: "Filed \(date)",
			table: "Moderation",
			comment: "Footer line showing when an appeal was filed."
		)
	}
	/// The leading label of the reason row on the suspension details view.
	///
	/// - Tag: L10n-suspensionReasonLabel
	static let suspensionReasonLabel: String = String(
		localized: "Reason",
		table: "Moderation",
		comment: "Leading label of the reason row on the suspension details view."
	)
	/// The leading label of the expiry row on the suspension details view.
	///
	/// - Tag: L10n-suspensionEndsLabel
	static let suspensionEndsLabel: String = String(
		localized: "Ends",
		table: "Moderation",
		comment: "Leading label of the expiry row on the suspension details view."
	)
	/// The header for the moderator note on the suspension details view.
	///
	/// - Tag: L10n-moderatorNote
	static let moderatorNote: String = String(
		localized: "Moderator note",
		table: "Moderation",
		comment: "Header for the moderator note on the suspension details view."
	)
	/// The admin headline for a permanent suspension on another user's account.
	static func userPermanentlySuspended(_ displayName: String) -> String {
		return String(
			localized: "\(displayName) is permanently suspended.",
			table: "Moderation",
			comment: "Admin headline for a permanent suspension."
		)
	}
	/// The admin headline for a temporary suspension on another user's account.
	static func userCurrentlySuspended(_ displayName: String) -> String {
		return String(
			localized: "\(displayName) is currently suspended.",
			table: "Moderation",
			comment: "Admin headline for a temporary suspension."
		)
	}
	/// The heading shown on the suspension details view for a permanent ban on the viewer's own account.
	///
	/// - Tag: L10n-ownAccountPermanentlySuspended
	static let ownAccountPermanentlySuspended: String = String(
		localized: "Your account is permanently suspended.",
		table: "Moderation",
		comment: "Heading on the suspension details view for a permanent ban."
	)
	/// The heading shown on the suspension details view for a temporary suspension on the viewer's own account.
	///
	/// - Tag: L10n-ownAccountTemporarilySuspended
	static let ownAccountTemporarilySuspended: String = String(
		localized: "Your account is temporarily suspended.",
		table: "Moderation",
		comment: "Heading on the suspension details view for a temporary suspension."
	)
	/// The expiry line for a permanent suspension.
	///
	/// - Tag: L10n-suspensionEndsNoEndDate
	static let suspensionEndsNoEndDate: String = String(
		localized: "No end date",
		table: "Moderation",
		comment: "Expiry value for a permanent suspension."
	)
	/// The expiry value for a temporary suspension, showing the absolute date and the relative countdown.
	static func suspensionEndsAt(absolute: String, relative: String) -> String {
		return String(
			localized: "\(absolute) (\(relative))",
			table: "Moderation",
			comment: "Expiry value for a temporary suspension, showing absolute date and relative countdown."
		)
	}

	// MARK: - Contest appeal compose
	/// The title of the appeal compose view when no appeal has been filed yet.
	///
	/// - Tag: L10n-contestSuspensionTitle
	static let contestSuspensionTitle: String = String(
		localized: "Contest Suspension",
		table: "Moderation",
		comment: "Title of the appeal compose view."
	)
	/// The title of the appeal compose view when editing an existing appeal.
	///
	/// - Tag: L10n-editAppealTitle
	static let editAppealTitle: String = String(
		localized: "Edit Appeal",
		table: "Moderation",
		comment: "Title of the appeal compose view when editing an existing appeal."
	)
	/// The prompt shown above the appeal text view.
	///
	/// - Tag: L10n-contestSuspensionPrompt
	static let contestSuspensionPrompt: String = String(
		localized: "Explain why you believe your suspension should be lifted. A moderator will review your message.",
		table: "Moderation",
		comment: "Prompt above the appeal text field."
	)
	/// The placeholder shown inside the empty appeal text view.
	///
	/// - Tag: L10n-contestSuspensionPlaceholder
	static let contestSuspensionPlaceholder: String = String(
		localized: "Write your appeal",
		table: "Moderation",
		comment: "Placeholder inside the appeal text view."
	)
	/// The submit button on the appeal compose view when filing a new appeal.
	///
	/// - Tag: L10n-submitAppeal
	static let submitAppeal: String = String(
		localized: "Submit Appeal",
		table: "Moderation",
		comment: "Submit button on the appeal compose view."
	)
	/// The submit button on the appeal compose view when updating an existing appeal.
	///
	/// - Tag: L10n-updateAppeal
	static let updateAppeal: String = String(
		localized: "Update Appeal",
		table: "Moderation",
		comment: "Submit button on the appeal compose view when updating an existing appeal."
	)
	/// The error message shown when the appeal text is too short.
	///
	/// - Tag: L10n-appealTooShort
	static let appealTooShort: String = String(
		localized: "Your appeal must be at least 10 characters long.",
		table: "Moderation",
		comment: "Error shown when the appeal message is too short."
	)

	// MARK: - Moderator actions
	/// The label of the moderator action that opens the issue-timeout form.
	///
	/// - Tag: L10n-issueTimeout
	static let issueTimeout: String = String(
		localized: "Issue Timeout",
		table: "Moderation",
		comment: "Context menu action that opens the issue-timeout form."
	)
	/// The label of the moderator action that revokes an active timeout.
	///
	/// - Tag: L10n-revokeTimeout
	static let revokeTimeout: String = String(
		localized: "Revoke Timeout",
		table: "Moderation",
		comment: "Context menu action that lifts an active timeout."
	)
	/// The duration picker menu title.
	///
	/// - Tag: L10n-chooseDuration
	static let chooseDuration: String = String(
		localized: "Choose Duration",
		table: "Moderation",
		comment: "Menu title for the duration picker."
	)
	/// The reason picker menu title.
	///
	/// - Tag: L10n-chooseReason
	static let chooseReason: String = String(
		localized: "Choose Reason",
		table: "Moderation",
		comment: "Menu title for the reason picker."
	)
	/// The section header grouping the duration and reason pickers on the moderator issue-timeout view.
	///
	/// - Tag: L10n-issueTimeoutSectionHeader
	static let issueTimeoutSectionHeader: String = String(
		localized: "Timeout",
		table: "Moderation",
		comment: "Section header grouping the duration and reason pickers on the moderator issue-timeout view."
	)
	/// The leading row title for the duration picker on the moderator issue-timeout view.
	///
	/// - Tag: L10n-issueTimeoutDurationTitle
	static let issueTimeoutDurationTitle: String = String(
		localized: "Duration",
		table: "Moderation",
		comment: "Leading row title for the duration picker on the moderator issue-timeout view."
	)
	/// The leading row title for the reason picker on the moderator issue-timeout view.
	///
	/// - Tag: L10n-issueTimeoutReasonTitle
	static let issueTimeoutReasonTitle: String = String(
		localized: "Reason",
		table: "Moderation",
		comment: "Leading row title for the reason picker on the moderator issue-timeout view."
	)
	/// The section header for the optional internal note on the moderator issue-timeout view.
	///
	/// - Tag: L10n-issueTimeoutNoteHeader
	static let issueTimeoutNoteHeader: String = String(
		localized: "Note",
		table: "Moderation",
		comment: "Section header for the note field on the moderator issue-timeout view."
	)
	/// The placeholder for the optional internal note on the moderator issue-timeout view.
	///
	/// - Tag: L10n-issueTimeoutNotePlaceholder
	static let issueTimeoutNotePlaceholder: String = String(
		localized: "Note for the user",
		table: "Moderation",
		comment: "Placeholder for the note field on the moderator issue-timeout view."
	)
	/// The submit bar-button label on the moderator issue-timeout view.
	///
	/// - Tag: L10n-issueTimeoutSubmit
	static let issueTimeoutSubmit: String = String(
		localized: "Submit",
		table: "Moderation",
		comment: "Submit bar-button label on the moderator issue-timeout view."
	)
	/// The alert title shown when confirming a timeout revocation.
	static func confirmRevokeTimeoutTitle(_ displayName: String) -> String {
		return String(
			localized: "Revoke timeout on \(displayName)?",
			table: "Moderation",
			comment: "Alert title for revoking a user's active timeout."
		)
	}
	/// The alert body shown when confirming a timeout revocation.
	///
	/// - Tag: L10n-confirmRevokeTimeoutMessage
	static let confirmRevokeTimeoutMessage: String = String(
		localized: "This lifts the suspension immediately. The user will be able to post, rate, and engage again.",
		table: "Moderation",
		comment: "Alert body for revoking a user's active timeout."
	)

	// MARK: - Timeout duration labels
	/// The label for a one-hour timeout duration.
	///
	/// - Tag: L10n-timeoutDuration1Hour
	static let timeoutDuration1Hour: String = String(
		localized: "1 hour",
		table: "Moderation",
		comment: "Timeout duration label."
	)
	/// The label for a 24-hour timeout duration.
	///
	/// - Tag: L10n-timeoutDuration24Hours
	static let timeoutDuration24Hours: String = String(
		localized: "24 hours",
		table: "Moderation",
		comment: "Timeout duration label."
	)
	/// The label for a three-day timeout duration.
	///
	/// - Tag: L10n-timeoutDuration3Days
	static let timeoutDuration3Days: String = String(
		localized: "3 days",
		table: "Moderation",
		comment: "Timeout duration label."
	)
	/// The label for a seven-day timeout duration.
	///
	/// - Tag: L10n-timeoutDuration7Days
	static let timeoutDuration7Days: String = String(
		localized: "7 days",
		table: "Moderation",
		comment: "Timeout duration label."
	)
	/// The label for a 30-day timeout duration.
	///
	/// - Tag: L10n-timeoutDuration30Days
	static let timeoutDuration30Days: String = String(
		localized: "30 days",
		table: "Moderation",
		comment: "Timeout duration label."
	)
	/// The label for a permanent timeout duration.
	///
	/// - Tag: L10n-timeoutDurationPermanent
	static let timeoutDurationPermanent: String = String(
		localized: "Permanent",
		table: "Moderation",
		comment: "Timeout duration label."
	)

	// MARK: - Timeout reason labels
	/// The label for the `spam` timeout reason.
	///
	/// - Tag: L10n-timeoutReasonSpam
	static let timeoutReasonSpam: String = String(
		localized: "Spam",
		table: "Moderation",
		comment: "Timeout reason label."
	)
	/// The label for the `harassment` timeout reason.
	///
	/// - Tag: L10n-timeoutReasonHarassment
	static let timeoutReasonHarassment: String = String(
		localized: "Harassment",
		table: "Moderation",
		comment: "Timeout reason label."
	)
	/// The label for the `nsfw` timeout reason.
	///
	/// - Tag: L10n-timeoutReasonNSFW
	static let timeoutReasonNSFW: String = String(
		localized: "NSFW",
		table: "Moderation",
		comment: "Timeout reason label."
	)
	/// The label for the `impersonation` timeout reason.
	///
	/// - Tag: L10n-timeoutReasonImpersonation
	static let timeoutReasonImpersonation: String = String(
		localized: "Impersonation",
		table: "Moderation",
		comment: "Timeout reason label."
	)
	/// The label for the `hate` timeout reason.
	///
	/// - Tag: L10n-timeoutReasonHate
	static let timeoutReasonHate: String = String(
		localized: "Hate",
		table: "Moderation",
		comment: "Timeout reason label."
	)
	/// The label for the `other` timeout reason.
	///
	/// - Tag: L10n-timeoutReasonOther
	static let timeoutReasonOther: String = String(
		localized: "Other",
		table: "Moderation",
		comment: "Timeout reason label."
	)

	// MARK: - Self Label
	/// The title of the content warning self-label sheet.
	///
	/// - Tag: L10n-selfLabelTitle
	static let selfLabelTitle: String = String(
		localized: "Add a content warning",
		table: "Moderation",
		comment: "The title of the content warning self-label sheet."
	)
	/// The subtitle of the content warning self-label sheet.
	///
	/// - Tag: L10n-selfLabelSubtitle
	static let selfLabelSubtitle: String = String(
		localized: "Choose self-labels that are applicable for the media you are posting. If none are selected, this post is suitable for all audiences.",
		table: "Moderation",
		comment: "The subtitle of the content warning self-label sheet."
	)
}
