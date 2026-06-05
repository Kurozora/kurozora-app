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
	static var suspendedPermanently: String {
		L10n.resolve {
			String(
				localized: "Suspended permanently",
				table: "Moderation",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "Profile banner shown for a permanent suspension."
			)
		}
	}
	/// The banner title shown for an active suspension without an explicit expiry.
	///
	/// - Tag: L10n-suspended
	static var suspended: String {
		L10n.resolve {
			String(
				localized: "Suspended",
				table: "Moderation",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "Profile banner shown for an active suspension without an expiry."
			)
		}
	}
	/// The banner title shown when a suspension is about to lift.
	///
	/// - Tag: L10n-suspensionEnding
	static var suspensionEnding: String {
		L10n.resolve {
			String(
				localized: "Suspension ending",
				table: "Moderation",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "Profile banner shown when a suspension has just ended."
			)
		}
	}
	/// The banner title showing the remaining days of a suspension.
	static func suspendedForDays(_ days: Int) -> String {
		return String(
			localized: "Suspended for \(days) day(s)",
			table: "Moderation",
			bundle: LanguageManager.shared.bundle,
			locale: LanguageManager.shared.locale,
			comment: "Profile banner showing the remaining days of a suspension."
		)
	}
	/// The banner title showing the remaining hours of a suspension.
	static func suspendedForHours(_ hours: Int) -> String {
		return String(
			localized: "Suspended for \(hours) hour(s)",
			table: "Moderation",
			bundle: LanguageManager.shared.bundle,
			locale: LanguageManager.shared.locale,
			comment: "Profile banner showing the remaining hours of a suspension."
		)
	}
	/// The banner title showing the remaining minutes of a suspension.
	static func suspendedForMinutes(_ minutes: Int) -> String {
		return String(
			localized: "Suspended for \(minutes) minute(s)",
			table: "Moderation",
			bundle: LanguageManager.shared.bundle,
			locale: LanguageManager.shared.locale,
			comment: "Profile banner showing the remaining minutes of a suspension."
		)
	}
	/// The banner title showing the remaining seconds of a suspension.
	static func suspendedForSeconds(_ seconds: Int) -> String {
		return String(
			localized: "Suspended for \(seconds) second(s)",
			table: "Moderation",
			bundle: LanguageManager.shared.bundle,
			locale: LanguageManager.shared.locale,
			comment: "Profile banner showing the remaining seconds of a suspension."
		)
	}

	// MARK: - Details view
	/// The title of the suspension details view as seen by a moderator.
	///
	/// - Tag: L10n-suspensionDetails
	static var suspensionDetails: String {
		L10n.resolve {
			String(
				localized: "Suspension Details",
				table: "Moderation",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "Title of the suspension details view as seen by a moderator."
			)
		}
	}
	/// The title of the suspension details view as seen by the suspended user.
	///
	/// - Tag: L10n-accountSuspended
	static var accountSuspended: String {
		L10n.resolve {
			String(
				localized: "Account Suspended",
				table: "Moderation",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "Title of the suspension details view as seen by the suspended user."
			)
		}
	}
	/// The button that opens the community guidelines page.
	///
	/// - Tag: L10n-communityGuidelines
	static var communityGuidelines: String {
		L10n.resolve {
			String(
				localized: "Community Guidelines",
				table: "Moderation",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "Button on the suspension details view that opens the community guidelines."
			)
		}
	}
	/// The primary action on the user-facing suspension details view when no appeal has been filed yet.
	///
	/// - Tag: L10n-contestSuspensionAction
	static var contestSuspensionAction: String {
		L10n.resolve {
			String(
				localized: "Contest this suspension",
				table: "Moderation",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "Primary action on the user-facing suspension details view."
			)
		}
	}
	/// The primary action on the user-facing suspension details view when an appeal has already been filed.
	///
	/// - Tag: L10n-editAppealAction
	static var editAppealAction: String {
		L10n.resolve {
			String(
				localized: "Edit appeal",
				table: "Moderation",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "Primary action on the user-facing suspension details view when an appeal has already been filed."
			)
		}
	}
	/// The header for the suspended user's own appeal on the suspension details view.
	///
	/// - Tag: L10n-yourAppeal
	static var yourAppeal: String {
		L10n.resolve {
			String(
				localized: "Your appeal",
				table: "Moderation",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "Section header for the suspended user's own appeal."
			)
		}
	}
	/// The header for the suspended user's appeal as seen by a moderator.
	static func appealFrom(_ displayName: String) -> String {
		return String(
			localized: "Appeal from \(displayName)",
			table: "Moderation",
			bundle: LanguageManager.shared.bundle,
			locale: LanguageManager.shared.locale,
			comment: "Section header for the suspended user's appeal as seen by a moderator."
		)
	}
	/// The footer line showing when an appeal was last submitted.
	static func appealFiled(_ date: String) -> String {
		return String(
			localized: "Filed \(date)",
			table: "Moderation",
			bundle: LanguageManager.shared.bundle,
			locale: LanguageManager.shared.locale,
			comment: "Footer line showing when an appeal was filed."
		)
	}
	/// The leading label of the reason row on the suspension details view.
	///
	/// - Tag: L10n-suspensionReasonLabel
	static var suspensionReasonLabel: String {
		L10n.resolve {
			String(
				localized: "Reason",
				table: "Moderation",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "Leading label of the reason row on the suspension details view."
			)
		}
	}
	/// The leading label of the expiry row on the suspension details view.
	///
	/// - Tag: L10n-suspensionEndsLabel
	static var suspensionEndsLabel: String {
		L10n.resolve {
			String(
				localized: "Ends",
				table: "Moderation",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "Leading label of the expiry row on the suspension details view."
			)
		}
	}
	/// The header for the moderator note on the suspension details view.
	///
	/// - Tag: L10n-moderatorNote
	static var moderatorNote: String {
		L10n.resolve {
			String(
				localized: "Moderator note",
				table: "Moderation",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "Header for the moderator note on the suspension details view."
			)
		}
	}
	/// The admin headline for a permanent suspension on another user's account.
	static func userPermanentlySuspended(_ displayName: String) -> String {
		return String(
			localized: "\(displayName) is permanently suspended.",
			table: "Moderation",
			bundle: LanguageManager.shared.bundle,
			locale: LanguageManager.shared.locale,
			comment: "Admin headline for a permanent suspension."
		)
	}
	/// The admin headline for a temporary suspension on another user's account.
	static func userCurrentlySuspended(_ displayName: String) -> String {
		return String(
			localized: "\(displayName) is currently suspended.",
			table: "Moderation",
			bundle: LanguageManager.shared.bundle,
			locale: LanguageManager.shared.locale,
			comment: "Admin headline for a temporary suspension."
		)
	}
	/// The heading shown on the suspension details view for a permanent ban on the viewer's own account.
	///
	/// - Tag: L10n-ownAccountPermanentlySuspended
	static var ownAccountPermanentlySuspended: String {
		L10n.resolve {
			String(
				localized: "Your account is permanently suspended.",
				table: "Moderation",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "Heading on the suspension details view for a permanent ban."
			)
		}
	}
	/// The heading shown on the suspension details view for a temporary suspension on the viewer's own account.
	///
	/// - Tag: L10n-ownAccountTemporarilySuspended
	static var ownAccountTemporarilySuspended: String {
		L10n.resolve {
			String(
				localized: "Your account is temporarily suspended.",
				table: "Moderation",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "Heading on the suspension details view for a temporary suspension."
			)
		}
	}
	/// The expiry line for a permanent suspension.
	///
	/// - Tag: L10n-suspensionEndsNoEndDate
	static var suspensionEndsNoEndDate: String {
		L10n.resolve {
			String(
				localized: "No end date",
				table: "Moderation",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "Expiry value for a permanent suspension."
			)
		}
	}
	/// The expiry value for a temporary suspension, showing the absolute date and the relative countdown.
	static func suspensionEndsAt(absolute: String, relative: String) -> String {
		return String(
			localized: "\(absolute) (\(relative))",
			table: "Moderation",
			bundle: LanguageManager.shared.bundle,
			locale: LanguageManager.shared.locale,
			comment: "Expiry value for a temporary suspension, showing absolute date and relative countdown."
		)
	}

	// MARK: - Contest appeal compose
	/// The title of the appeal compose view when no appeal has been filed yet.
	///
	/// - Tag: L10n-contestSuspensionTitle
	static var contestSuspensionTitle: String {
		L10n.resolve {
			String(
				localized: "Contest Suspension",
				table: "Moderation",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "Title of the appeal compose view."
			)
		}
	}
	/// The title of the appeal compose view when editing an existing appeal.
	///
	/// - Tag: L10n-editAppealTitle
	static var editAppealTitle: String {
		L10n.resolve {
			String(
				localized: "Edit Appeal",
				table: "Moderation",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "Title of the appeal compose view when editing an existing appeal."
			)
		}
	}
	/// The prompt shown above the appeal text view.
	///
	/// - Tag: L10n-contestSuspensionPrompt
	static var contestSuspensionPrompt: String {
		L10n.resolve {
			String(
				localized: "Explain why you believe your suspension should be lifted. A moderator will review your message.",
				table: "Moderation",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "Prompt above the appeal text field."
			)
		}
	}
	/// The placeholder shown inside the empty appeal text view.
	///
	/// - Tag: L10n-contestSuspensionPlaceholder
	static var contestSuspensionPlaceholder: String {
		L10n.resolve {
			String(
				localized: "Write your appeal",
				table: "Moderation",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "Placeholder inside the appeal text view."
			)
		}
	}
	/// The submit button on the appeal compose view when filing a new appeal.
	///
	/// - Tag: L10n-submitAppeal
	static var submitAppeal: String {
		L10n.resolve {
			String(
				localized: "Submit Appeal",
				table: "Moderation",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "Submit button on the appeal compose view."
			)
		}
	}
	/// The submit button on the appeal compose view when updating an existing appeal.
	///
	/// - Tag: L10n-updateAppeal
	static var updateAppeal: String {
		L10n.resolve {
			String(
				localized: "Update Appeal",
				table: "Moderation",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "Submit button on the appeal compose view when updating an existing appeal."
			)
		}
	}
	/// The error message shown when the appeal text is too short.
	///
	/// - Tag: L10n-appealTooShort
	static var appealTooShort: String {
		L10n.resolve {
			String(
				localized: "Your appeal must be at least 10 characters long.",
				table: "Moderation",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "Error shown when the appeal message is too short."
			)
		}
	}

	// MARK: - Moderator actions
	/// The label of the moderator action that opens the issue-timeout form.
	///
	/// - Tag: L10n-issueTimeout
	static var issueTimeout: String {
		L10n.resolve {
			String(
				localized: "Issue Timeout",
				table: "Moderation",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "Context menu action that opens the issue-timeout form."
			)
		}
	}
	/// The label of the moderator action that revokes an active timeout.
	///
	/// - Tag: L10n-revokeTimeout
	static var revokeTimeout: String {
		L10n.resolve {
			String(
				localized: "Revoke Timeout",
				table: "Moderation",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "Context menu action that lifts an active timeout."
			)
		}
	}
	/// The duration picker menu title.
	///
	/// - Tag: L10n-chooseDuration
	static var chooseDuration: String {
		L10n.resolve {
			String(
				localized: "Choose Duration",
				table: "Moderation",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "Menu title for the duration picker."
			)
		}
	}
	/// The reason picker menu title.
	///
	/// - Tag: L10n-chooseReason
	static var chooseReason: String {
		L10n.resolve {
			String(
				localized: "Choose Reason",
				table: "Moderation",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "Menu title for the reason picker."
			)
		}
	}
	/// The section header grouping the duration and reason pickers on the moderator issue-timeout view.
	///
	/// - Tag: L10n-issueTimeoutSectionHeader
	static var issueTimeoutSectionHeader: String {
		L10n.resolve {
			String(
				localized: "Timeout",
				table: "Moderation",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "Section header grouping the duration and reason pickers on the moderator issue-timeout view."
			)
		}
	}
	/// The leading row title for the duration picker on the moderator issue-timeout view.
	///
	/// - Tag: L10n-issueTimeoutDurationTitle
	static var issueTimeoutDurationTitle: String {
		L10n.resolve {
			String(
				localized: "Duration",
				table: "Moderation",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "Leading row title for the duration picker on the moderator issue-timeout view."
			)
		}
	}
	/// The leading row title for the reason picker on the moderator issue-timeout view.
	///
	/// - Tag: L10n-issueTimeoutReasonTitle
	static var issueTimeoutReasonTitle: String {
		L10n.resolve {
			String(
				localized: "Reason",
				table: "Moderation",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "Leading row title for the reason picker on the moderator issue-timeout view."
			)
		}
	}
	/// The section header for the optional internal note on the moderator issue-timeout view.
	///
	/// - Tag: L10n-issueTimeoutNoteHeader
	static var issueTimeoutNoteHeader: String {
		L10n.resolve {
			String(
				localized: "Note",
				table: "Moderation",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "Section header for the note field on the moderator issue-timeout view."
			)
		}
	}
	/// The placeholder for the optional internal note on the moderator issue-timeout view.
	///
	/// - Tag: L10n-issueTimeoutNotePlaceholder
	static var issueTimeoutNotePlaceholder: String {
		L10n.resolve {
			String(
				localized: "Note for the user",
				table: "Moderation",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "Placeholder for the note field on the moderator issue-timeout view."
			)
		}
	}
	/// The submit bar-button label on the moderator issue-timeout view.
	///
	/// - Tag: L10n-issueTimeoutSubmit
	static var issueTimeoutSubmit: String {
		L10n.resolve {
			String(
				localized: "Submit",
				table: "Moderation",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "Submit bar-button label on the moderator issue-timeout view."
			)
		}
	}
	/// The alert title shown when confirming a timeout revocation.
	static func confirmRevokeTimeoutTitle(_ displayName: String) -> String {
		return String(
			localized: "Revoke timeout on \(displayName)?",
			table: "Moderation",
			bundle: LanguageManager.shared.bundle,
			locale: LanguageManager.shared.locale,
			comment: "Alert title for revoking a user's active timeout."
		)
	}
	/// The alert body shown when confirming a timeout revocation.
	///
	/// - Tag: L10n-confirmRevokeTimeoutMessage
	static var confirmRevokeTimeoutMessage: String {
		L10n.resolve {
			String(
				localized: "This lifts the suspension immediately. The user will be able to post, rate, and engage again.",
				table: "Moderation",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "Alert body for revoking a user's active timeout."
			)
		}
	}

	// MARK: - Timeout duration labels
	/// The label for a one-hour timeout duration.
	///
	/// - Tag: L10n-timeoutDuration1Hour
	static var timeoutDuration1Hour: String {
		L10n.resolve {
			String(
				localized: "1 hour",
				table: "Moderation",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "Timeout duration label."
			)
		}
	}
	/// The label for a 24-hour timeout duration.
	///
	/// - Tag: L10n-timeoutDuration24Hours
	static var timeoutDuration24Hours: String {
		L10n.resolve {
			String(
				localized: "24 hours",
				table: "Moderation",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "Timeout duration label."
			)
		}
	}
	/// The label for a three-day timeout duration.
	///
	/// - Tag: L10n-timeoutDuration3Days
	static var timeoutDuration3Days: String {
		L10n.resolve {
			String(
				localized: "3 days",
				table: "Moderation",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "Timeout duration label."
			)
		}
	}
	/// The label for a seven-day timeout duration.
	///
	/// - Tag: L10n-timeoutDuration7Days
	static var timeoutDuration7Days: String {
		L10n.resolve {
			String(
				localized: "7 days",
				table: "Moderation",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "Timeout duration label."
			)
		}
	}
	/// The label for a 30-day timeout duration.
	///
	/// - Tag: L10n-timeoutDuration30Days
	static var timeoutDuration30Days: String {
		L10n.resolve {
			String(
				localized: "30 days",
				table: "Moderation",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "Timeout duration label."
			)
		}
	}
	/// The label for a permanent timeout duration.
	///
	/// - Tag: L10n-timeoutDurationPermanent
	static var timeoutDurationPermanent: String {
		L10n.resolve {
			String(
				localized: "Permanent",
				table: "Moderation",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "Timeout duration label."
			)
		}
	}

	// MARK: - Timeout reason labels
	/// The label for the `spam` timeout reason.
	///
	/// - Tag: L10n-timeoutReasonSpam
	static var timeoutReasonSpam: String {
		L10n.resolve {
			String(
				localized: "Spam",
				table: "Moderation",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "Timeout reason label."
			)
		}
	}
	/// The label for the `harassment` timeout reason.
	///
	/// - Tag: L10n-timeoutReasonHarassment
	static var timeoutReasonHarassment: String {
		L10n.resolve {
			String(
				localized: "Harassment",
				table: "Moderation",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "Timeout reason label."
			)
		}
	}
	/// The label for the `nsfw` timeout reason.
	///
	/// - Tag: L10n-timeoutReasonNSFW
	static var timeoutReasonNSFW: String {
		L10n.resolve {
			String(
				localized: "NSFW",
				table: "Moderation",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "Timeout reason label."
			)
		}
	}
	/// The label for the `impersonation` timeout reason.
	///
	/// - Tag: L10n-timeoutReasonImpersonation
	static var timeoutReasonImpersonation: String {
		L10n.resolve {
			String(
				localized: "Impersonation",
				table: "Moderation",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "Timeout reason label."
			)
		}
	}
	/// The label for the `hate` timeout reason.
	///
	/// - Tag: L10n-timeoutReasonHate
	static var timeoutReasonHate: String {
		L10n.resolve {
			String(
				localized: "Hate",
				table: "Moderation",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "Timeout reason label."
			)
		}
	}
	/// The label for the `other` timeout reason.
	///
	/// - Tag: L10n-timeoutReasonOther
	static var timeoutReasonOther: String {
		L10n.resolve {
			String(
				localized: "Other",
				table: "Moderation",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "Timeout reason label."
			)
		}
	}

	// MARK: - Self Label
	/// The title of the content warning self-label sheet.
	///
	/// - Tag: L10n-selfLabelTitle
	static var selfLabelTitle: String {
		L10n.resolve {
			String(
				localized: "Add a content warning",
				table: "Moderation",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The title of the content warning self-label sheet."
			)
		}
	}
	/// The subtitle of the content warning self-label sheet.
	///
	/// - Tag: L10n-selfLabelSubtitle
	static var selfLabelSubtitle: String {
		L10n.resolve {
			String(
				localized: "Choose self-labels that are applicable for the media you are posting. If none are selected, this post is suitable for all audiences.",
				table: "Moderation",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The subtitle of the content warning self-label sheet."
			)
		}
	}
}
