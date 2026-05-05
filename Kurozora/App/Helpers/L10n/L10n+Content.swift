//
//  L10n+Content.swift
//  Kurozora
//
//  Created by Khoren Katklian on 29/04/2022.
//  Copyright © 2022 Kurozora. All rights reserved.
//

import Foundation

extension L10n {
	// MARK: - Library Delete
	/// The headline string for the Library Delete view.
	///
	/// - Tag: L10n-libraryDeleteHeadline
	static let libraryDeleteHeadline: String = String(
		localized: "Delete Library",
		table: "Content",
		comment: "The headline string for the Library Delete view"
	)
	/// The subheadline string for the Library Delete view.
	///
	/// - Tag: L10n-libraryDeleteSubheadline
	static let libraryDeleteSubheadline: String = String(
		localized: "Permanently delete your library.",
		table: "Content",
		comment: "The subheadline string for the Library Delete view."
	)
	/// The footer string for the Library Delete view.
	///
	/// - Tag: L10n-libraryDeleteFooter
	static let libraryDeleteFooter: String = String(
		localized: "Once your library is deleted, all of its resources and data will be permanently deleted. This includes ratings, favorites, reminders, watched episodes, and You will be asked for your password to confirm the deletion.",
		table: "Content",
		comment: "The footer string for the Library Delete view."
	)

	// MARK: - Library Import
	/// The placeholder string for selecting the import service.
	///
	/// - Tag: L10n-selectService
	static let selectService: String = String(
		localized: "Select service",
		table: "Content",
		comment: "The placeholder string for selecting the import service."
	)
	/// The placeholder string for selecting the import behavior.
	///
	/// - Tag: L10n-selectBehavior
	static let selectBehavior: String = String(
		localized: "Select behavior",
		table: "Content",
		comment: "The placeholder string for selecting the import behavior."
	)
	/// The button string for selecting a file to import.
	///
	/// - Tag: L10n-selectFile
	static let selectFile: String = String(
		localized: "Select File",
		table: "Content",
		comment: "The button string for selecting a file to import."
	)
	/// The placeholder string for the library xml file name.
	///
	/// - Tag: L10n-libraryXML
	static let libraryXML: String = String(
		localized: "Library.xml",
		table: "Content",
		comment: "The placeholder string for the library xml file name."
	)
	/// The headline string for the Library Import view.
	///
	/// - Tag: L10n-libraryImportHeadline
	static let libraryImportHeadline: String = String(
		localized: "Move From Another Service",
		table: "Content",
		comment: "The headline string for the Library Import view"
	)
	/// The subheadline string for the Library Import view.
	///
	/// - Tag: L10n-libraryImportSubheadline
	static let libraryImportSubheadline: String = String(
		localized: "If you have an export of your anime or manga library from other services, such as MyAnimeList, you can select it below.",
		table: "Content",
		comment: "The subheadline string for the Library Import view."
	)
	/// The footer string for the Library Import view.
	///
	/// - Tag: L10n-libraryImportFooter
	static let libraryImportFooter: String = String(
		localized: "Kurozora does not guarantee all shows and mangas will be imported to your library. Once the request has been processed, a notification which contains the status of the import request will be sent. Furthermore, the uploaded file is deleted as soon as the import request has been processed.\n\nSelecting \"overwrite\" will replace your Kurozora library with the imported one from the file.\nSelecting \"merge\" will add missing items to your Kurozora library. If an item exists then the tracking information in your Kurozora library will be updated with the imported one from the file.",
		table: "Content",
		comment: "The footer string for the Library Import view."
	)

	// MARK: - Episodes
	/// The string for the 'Up Next' view title.
	///
	/// - Tag: L10n-upNext
	static let upNext: String = String(
		localized: "Up Next",
		table: "Content",
		comment: "The string for the 'Up Next' view title."
	)
	/// The string for the 'Go To' bar button item.
	///
	/// - Tag: L10n-goTo
	static let goTo: String = String(
		localized: "Go To",
		table: "Content",
		comment: "The string for the 'Go To' context menu option."
	)
	/// The string for the 'Go to first episode' context menu option.
	///
	/// - Tag: L10n-goToFirstEpisode
	static let goToFirstEpisode: String = String(
		localized: "Go to first episode",
		table: "Content",
		comment: "The string for the 'Go to first episode' context menu option."
	)
	/// The string for the 'Go to last episode' context menu option.
	///
	/// - Tag: L10n-goToLastEpisode
	static let goToLastEpisode: String = String(
		localized: "Go to last episode",
		table: "Content",
		comment: "The string for the 'Go to last episode' context menu option."
	)
	/// The string for the 'Go to last watched episode' context menu option.
	///
	/// - Tag: L10n-goToLastWatchedEpisode
	static let goToLastWatchedEpisode: String = String(
		localized: "Go to last watched episode",
		table: "Content",
		comment: "The string for the 'Go to last watched episode' context menu option."
	)
	/// The string for the 'Show fillers' context menu option.
	///
	/// - Tag: L10n-showFillers
	static let showFillers: String = String(
		localized: "Show fillers",
		table: "Content",
		comment: "The string for the 'Show fillers' context menu option."
	)
	/// The string for the 'Hide fillers' context menu option.
	///
	/// - Tag: L10n-hideFillers
	static let hideFillers: String = String(
		localized: "Hide fillers",
		table: "Content",
		comment: "The string for the 'Hide fillers' context menu option."
	)

	// MARK: - Feed
	/// The placeholder string for creating a new feed message.
	///
	/// - Tag: L10n-whatsOnYourMind
	static let whatsOnYourMind: String = String(
		localized: "What’s on your mind?",
		table: "Content",
		comment: "The placeholder string for creating a new feed message."
	)
	/// The placeholder string for creating a new comment.
	///
	/// - Tag: L10n-writeAComment
	static let writeAComment: String = String(
		localized: "Write a comment...",
		table: "Content",
		comment: "The placeholder string for creating a new comment."
	)
	/// The headline string for the character limit reached error pop-up.
	///
	/// - Tag: L10n-characterLimitReachedHeadline
	static let characterLimitReachedHeadline: String = String(
		localized: "Limit Reached",
		table: "Content",
		comment: "The headline string for the character limit reached error pop-up"
	)
	/// The subheadline string for the character limit reached error pop-up.
	///
	/// - Tag: L10n-characterLimitReachedSubheadline
	static let characterLimitReachedSubheadline: String = String(
		localized: "You have exceeded the character limit for a message.",
		table: "Content",
		comment: "The subheadline string for the character limit reached error pop-up"
	)
	/// The title string for the search pop-up when trying to tag a user in a message or reply.
	///
	/// - Tag: L10n-findWhoYouAreLookingFor
	static let findWhoYouAreLookingFor: String = String(
		localized: "Find who you're looking for",
		table: "Content",
		comment: "The title string for the search pop-up when trying to tag a user in a message or reply."
	)
	/// The subtitle string for the search pop-up when trying to tag a user in a message or reply.
	///
	/// - Tag: L10n-searchForThePersonYouWantToMention
	static let searchForThePersonYouWantToMention: String = String(
		localized: "Search for the person you want to mention",
		table: "Content",
		comment: "The subtitle string for the search pop-up when trying to tag a user in a message or reply."
	)
	/// The headline string for the pin message pop-up.
	///
	/// - Tag: L10n-pinMessageHeadline
	static let pinMessageHeadline: String = String(
		localized: "Pin this message",
		table: "Content",
		comment: "The headline string for the pin message pop-up"
	)
	/// The subheadline string for the pin message pop-up.
	///
	/// - Tag: L10n-pinMessageSubheadline
	static let pinMessageSubheadline: String = String(
		localized: "This will appear at the top of your profile and replace any previously pinned message. Are you sure?",
		table: "Content",
		comment: "The subheadline string for the pin message pop-up"
	)
	/// The headline string for the unpin message pop-up.
	///
	/// - Tag: L10n-unpinMessageHeadline
	static let unpinMessageHeadline: String = String(
		localized: "Unpin from your profile",
		table: "Content",
		comment: "The headline string for the unpin message pop-up"
	)
	/// The subheadline string for the unpin message pop-up.
	///
	/// - Tag: L10n-unpinMessageSubheadline
	static let unpinMessageSubheadline: String = String(
		localized: "Are you sure?",
		table: "Content",
		comment: "The subheadline string for the unpin message pop-up"
	)
	/// The subheadline string for the delete message pop-up.
	///
	/// - Tag: L10n-deleteMessageSubheadline
	static let deleteMessageSubheadline: String = String(
		localized: "Message will be deleted permanently.",
		table: "Content",
		comment: "The subheadline string for the delete message pop-up"
	)
	/// The subheadline string for blocking a user.
	///
	/// - Tag: L10n-blockMessageSubheadline
	static let blockMessageSubheadline: String = String(
		localized: "They will be able to see your public messages, but will no longer be able to engage with them. They will also not be able to follow or message you, and you will not see notifications from them.",
		table: "Content",
		comment: "The subheadline string for the blocking a user"
	)
	/// The string for the 'Blocked' button label.
	///
	/// - Tag: L10n-blocked
	static let blocked: String = String(
		localized: "Blocked",
		table: "Content",
		comment: "The label shown on the button when the user has blocked another user"
	)
	/// Title shown when prompting the user to block another user.
	///
	/// - Parameter username: The username (with @) of the user to block.
	///
	/// - Tag: L10n-blockTitle
	static func blockTitle(_ username: String) -> String {
		return String(
			format: String(
				localized: "Block %@",
				table: "Content",
				comment: "The title prompting the user to block another user. The argument is the @username of the target user."
			),
			username
		)
	}
	/// Title shown when prompting the user to unblock another user.
	///
	/// - Parameter username: The username (with @) of the user to unblock.
	///
	/// - Tag: L10n-unblockTitle
	static func unblockTitle(_ username: String) -> String {
		return String(
			format: String(
				localized: "Unblock %@",
				table: "Content",
				comment: "The title prompting the user to unblock another user. The argument is the @username of the target user."
			),
			username
		)
	}
	/// The headline shown when the auth user has been blocked by another user.
	///
	/// - Parameter username: The username (with @) of the user who blocked them.
	///
	/// - Tag: L10n-usernameHasBlockedYou
	static func usernameHasBlockedYou(_ username: String) -> String {
		return String(
			format: String(
				localized: "%@ has blocked you",
				table: "Content",
				comment: "The headline shown when the auth user has been blocked by another user. The argument is the @username of the blocking user."
			),
			username
		)
	}
	/// The subheadline shown to the auth user when another user has blocked them.
	///
	/// - Parameter username: The username (with @) of the user who blocked them.
	///
	/// - Tag: L10n-blockedByDescription
	static func blockedByDescription(_ username: String) -> String {
		return String(
			format: String(
				localized: "You can view public posts from %@, but you are blocked from engaging with them. You also cannot follow or message %@.",
				table: "Content",
				comment: "Subheadline explaining what is restricted when the auth user has been blocked by another user. Both arguments are the @username of the blocking user."
			),
			username,
			username
		)
	}
	/// The label for the opt-in button to view a blocked user's profile.
	///
	/// - Tag: L10n-viewProfileAnyway
	static let viewProfileAnyway: String = String(
		localized: "Yes, view profile",
		table: "Content",
		comment: "The label for the opt-in button to view a blocked user's profile"
	)
	/// The label for the opt-in button to view a blocked user's posts.
	///
	/// - Tag: L10n-viewPosts
	static let viewPosts: String = String(
		localized: "View posts",
		table: "Content",
		comment: "The label for the opt-in button to view a blocked user's posts"
	)
	/// The headline shown when the auth user has blocked the profile's user.
	///
	/// - Parameter username: The @username of the blocked user.
	///
	/// - Tag: L10n-usernameIsBlocked
	static func usernameIsBlocked(_ username: String) -> String {
		return String(
			format: String(
				localized: "%@ is blocked",
				table: "Content",
				comment: "The headline shown when the auth user has blocked the profile's user. The argument is the @username of the blocked user."
			),
			username
		)
	}
	/// The subheadline prompting the auth user to opt in to viewing a blocked user's posts.
	///
	/// - Parameter username: The @username of the blocked user.
	///
	/// - Tag: L10n-viewBlockedPostsPrompt
	static func viewBlockedPostsPrompt(_ username: String) -> String {
		return String(
			format: String(
				localized: "Are you sure you want to view these posts? Viewing posts won’t unblock %@.",
				table: "Content",
				comment: "Subheadline prompting the auth user to opt in to viewing a blocked user's posts. The argument is the @username of the blocked user."
			),
			username
		)
	}
	/// The label for the Settings entry that opens the blocked users list.
	///
	/// - Tag: L10n-blockedUsers
	static let blockedUsers: String = String(
		localized: "Blocked Users",
		table: "Content",
		comment: "The label for the Settings entry that opens the blocked users list"
	)
	/// The intro string shown above the blocked users list.
	///
	/// - Tag: L10n-blockedUsersIntro
	static let blockedUsersIntro: String = String(
		localized: "When you block someone, they will be able to see your public messages, but will no longer be able to engage with them. They will also not be able to follow or message you, and you will not see notifications from them.",
		table: "Content",
		comment: "The intro string shown above the blocked users list"
	)
	/// The headline string for the report message pop-up.
	///
	/// - Tag: L10n-messageReportedHeadline
	static let messageReportedHeadline: String = String(
		localized: "Message Reported",
		table: "Content",
		comment: "The headline string for the report message pop-up"
	)
	/// The subheadline string for the report message pop-up.
	///
	/// - Tag: L10n-messageReportedSubheadline
	static let messageReportedSubheadline: String = String(
		localized: "Thank you for helping keep the community safe.",
		table: "Content",
		comment: "The subheadline string for the report message pop-up"
	)
	/// The string for the 'Show Profile' context menu option.
	///
	/// - Tag: L10n-showProfile
	static let showProfile: String = String(
		localized: "Show Profile",
		table: "Content",
		comment: "The string for the 'Show Profile' context menu option."
	)
	/// The string for the 'Reply' context menu option.
	///
	/// - Tag: L10n-reply
	static let reply: String = String(
		localized: "Reply",
		table: "Content",
		comment: "The string for the 'Reply' context menu option."
	)
	/// The string for the 'Re-share' context menu option.
	///
	/// - Tag: L10n-reshare
	static let reshare: String = String(
		localized: "Re-share",
		table: "Content",
		comment: "The string for the 'Re-share' context menu option."
	)
	/// The string for the 'Undo Re-share' context menu option.
	///
	/// - Tag: L10n-undoReshare
	static let undoReshare: String = String(
		localized: "Undo Re-share",
		table: "Content",
		comment: "The string for the 'Undo Re-share' context menu option."
	)
	/// The string for the 'Quote' context menu option.
	///
	/// - Tag: L10n-quote
	static let quote: String = String(
		localized: "Quote",
		table: "Content",
		comment: "The string for the 'Quote' context menu option."
	)
	/// The string for the 'View post activity' context menu option.
	///
	/// - Tag: L10n-viewPostActivity
	static let viewPostActivity: String = String(
		localized: "View post activity",
		table: "Content",
		comment: "The string for the 'View post activity' context menu option."
	)
	/// The string for the 'Post activity' navigation title.
	///
	/// - Tag: L10n-postActivity
	static let postActivity: String = String(
		localized: "Post activity",
		table: "Content",
		comment: "The navigation title for the post activity screen."
	)
	/// The string for the 'Quotes' tab.
	///
	/// - Tag: L10n-quotes
	static let quotes: String = String(
		localized: "Quotes",
		table: "Content",
		comment: "The string for the 'Quotes' tab on the post activity screen."
	)
	/// The string for the 'Re-shares' tab.
	///
	/// - Tag: L10n-reShares
	static let reShares: String = String(
		localized: "Re-shares",
		table: "Content",
		comment: "The string for the 'Re-shares' tab on the post activity screen."
	)
	/// The string for the re-share attribution row.
	///
	/// - Tag: L10n-reSharedBy
	static func reSharedBy(_ user: String) -> String {
		String(
			localized: "Re-shared by \(user)",
			table: "Content",
			comment: "The string for the re-share attribution row."
		)
	}
	/// The string for the auth user's re-share attribution row.
	///
	/// - Tag: L10n-youReShared
	static let youReShared: String = String(
		localized: "You re-shared",
		table: "Content",
		comment: "The string for the auth user's re-share attribution row."
	)
	/// The string for the 'Top' sort option.
	///
	/// - Tag: L10n-top
	static let top: String = String(
		localized: "Top",
		table: "Content",
		comment: "The string for the 'Top' sort option on the post activity screen."
	)
	/// The string for the 'Recent' sort option.
	///
	/// - Tag: L10n-recent
	static let recent: String = String(
		localized: "Recent",
		table: "Content",
		comment: "The string for the 'Recent' sort option on the post activity screen."
	)
	/// The empty-state headline for the Quotes tab.
	///
	/// - Tag: L10n-noQuotesHeadline
	static let noQuotesHeadline: String = String(
		localized: "No Quotes",
		table: "Content",
		comment: "The empty-state headline for the Quotes tab on the post activity screen."
	)
	/// The empty-state subheadline for the Quotes tab.
	///
	/// - Tag: L10n-noQuotesSubheadline
	static let noQuotesSubheadline: String = String(
		localized: "Add your take when sharing someone else's post and it'll show up here.",
		table: "Content",
		comment: "The empty-state subheadline for the Quotes tab on the post activity screen."
	)
	/// The empty-state headline for the Re-shares tab.
	///
	/// - Tag: L10n-amplifyPostsHeadline
	static let amplifyPostsHeadline: String = String(
		localized: "Amplify posts you like",
		table: "Content",
		comment: "The empty-state headline for the Re-shares tab on the post activity screen."
	)
	/// The empty-state subheadline for the Re-shares tab.
	///
	/// - Tag: L10n-amplifyPostsSubheadline
	static let amplifyPostsSubheadline: String = String(
		localized: "Share someone else's post on your timeline by reposting it. When you do, it'll show up here.",
		table: "Content",
		comment: "The empty-state subheadline for the Re-shares tab on the post activity screen."
	)
	/// The string for the 'Post' button.
	///
	/// - Tag: L10n-post
	static let post: String = String(
		localized: "Post",
		table: "Content",
		comment: "The string for the 'Post' context menu option."
	)
	/// The string for the 'Post Message' context menu option.
	///
	/// - Tag: L10n-postMessage
	static let postMessage: String = String(
		localized: "Post Message",
		table: "Content",
		comment: "The string for the 'Post Message' context menu option."
	)
	/// The string for the 'Delete Message' context menu option.
	///
	/// - Tag: L10n-deleteMessage
	static let deleteMessage: String = String(
		localized: "Delete Message",
		table: "Content",
		comment: "The string for the 'Delete Message' context menu option."
	)
	/// The headline string for the off-topic content warning pop-up.
	///
	/// - Tag: L10n-offTopicWarningHeadline
	static let offTopicWarningHeadline: String = String(
		localized: "Is this a 'where to watch' question?",
		table: "Content",
		comment: "The headline string for the off-topic content warning pop-up."
	)
	/// The subheadline string for the off-topic content warning pop-up.
	///
	/// - Tag: L10n-offTopicWarningSubheadline
	static let offTopicWarningSubheadline: String = String(
		localized: "Kurozora is for tracking your progress, it doesn't stream or host content. Posts asking where to watch or read often go unanswered. You can still post if you'd like.",
		table: "Content",
		comment: "The subheadline string for the off-topic content warning pop-up."
	)
	/// The action string for opening the community guidelines from the off-topic warning.
	///
	/// - Tag: L10n-offTopicViewGuidelines
	static let offTopicViewGuidelines: String = String(
		localized: "View Guidelines",
		table: "Content",
		comment: "The action string for opening the community guidelines from the off-topic warning."
	)
	/// The destructive action string for proceeding with an off-topic post anyway.
	///
	/// - Tag: L10n-offTopicPostAnyway
	static let offTopicPostAnyway: String = String(
		localized: "Post Anyway",
		table: "Content",
		comment: "The destructive action string for proceeding with an off-topic post anyway."
	)
	/// The string for the 'Show Replies' context menu option.
	///
	/// - Tag: L10n-showReplies
	static let showReplies: String = String(
		localized: "Show Replies",
		table: "Content",
		comment: "The string for the 'Show Replies' context menu option."
	)
	/// The string for the 'Share Message' context menu option.
	///
	/// - Tag: L10n-shareMessage
	static let shareMessage: String = String(
		localized: "Share Message",
		table: "Content",
		comment: "The string for the 'Share Message' context menu option."
	)
	/// The string for the 'Report Message' context menu option.
	///
	/// - Tag: L10n-reportMessage
	static let reportMessage: String = String(
		localized: "Report Message",
		table: "Content",
		comment: "The string for the 'Report Message' context menu option."
	)

	// MARK: - Review
	/// The headline string for the report review pop-up.
	///
	/// - Tag: L10n-reviewReportedHeadline
	static let reviewReportedHeadline: String = String(
		localized: "Review Reported",
		table: "Content",
		comment: "The headline string for the report review pop-up"
	)
	/// The subheadline string for the report review pop-up.
	///
	/// - Tag: L10n-reviewReportedSubheadline
	static let reviewReportedSubheadline: String = String(
		localized: "Thank you for helping keep the community safe.",
		table: "Content",
		comment: "The subheadline string for the report review pop-up"
	)
	/// The subheadline string for the delete review pop-up.
	///
	/// - Tag: L10n-deleteReviewSubheadline
	static let deleteReviewSubheadline: String = String(
		localized: "Review will be deleted permanently.",
		table: "Content",
		comment: "The subheadline string for the delete review pop-up"
	)
	/// The string for the 'Delete Review' context menu option.
	///
	/// - Tag: L10n-deleteReview
	static let deleteReview: String = String(
		localized: "Delete Review",
		table: "Content",
		comment: "The string for the 'Delete Review' context menu option."
	)
	/// The title string for the confirmation dialog when clearing a rating or deleting a review.
	///
	/// - Tag: L10n-deleteRatingConfirmationTitle
	static let deleteRatingConfirmationTitle: String = String(
		localized: "Delete Rating?",
		table: "Content",
		comment: "The title string for the confirmation dialog when the user clears their rating or deletes their review."
	)
	/// The body string for the confirmation dialog when clearing a rating or deleting a review.
	///
	/// - Tag: L10n-deleteRatingConfirmationMessage
	static let deleteRatingConfirmationMessage: String = String(
		localized: "Your rating and review will be removed.",
		table: "Content",
		comment: "The body string for the confirmation dialog when the user clears their rating or deletes their review."
	)
	/// The string for the 'Share Review' context menu option.
	///
	/// - Tag: L10n-shareReview
	static let shareReview: String = String(
		localized: "Share Review",
		table: "Content",
		comment: "The string for the 'Share Review' context menu option."
	)
	/// The string for the 'Report Review' context menu option.
	///
	/// - Tag: L10n-reportReview
	static let reportReview: String = String(
		localized: "Report Review",
		table: "Content",
		comment: "The string for the 'Report Review' context menu option."
	)

	// MARK: - Browse
	/// The string for the 'top anime' browse option.
	///
	/// - Tag: L10n-topAnime
	static let topAnime: String = String(
		localized: "Top Anime",
		table: "Content",
		comment: "The string for the 'top anime' browse option."
	)
	/// The string for the 'top airing' browse option.
	///
	/// - Tag: L10n-topAiring
	static let topAiring: String = String(
		localized: "Top Airing",
		table: "Content",
		comment: "The string for the 'top airing' browse option."
	)
	/// The string for the 'top upcoming' browse option.
	///
	/// - Tag: L10n-topUpcoming
	static let topUpcoming: String = String(
		localized: "Top Upcoming",
		table: "Content",
		comment: "The string for the 'top upcoming' browse option."
	)
	/// The string for the 'top tv series' browse option.
	///
	/// - Tag: L10n-topTVSeries
	static let topTVSeries: String = String(
		localized: "Top TV Series",
		table: "Content",
		comment: "The string for the 'top tv series' browse option."
	)
	/// The string for the 'top movies' browse option.
	///
	/// - Tag: L10n-topMovies
	static let topMovies: String = String(
		localized: "Top Movies",
		table: "Content",
		comment: "The string for the 'top movies' browse option."
	)
	/// The string for the 'top ova' browse option.
	///
	/// - Tag: L10n-topOVA
	static let topOVA: String = String(
		localized: "Top OVA",
		table: "Content",
		comment: "The string for the 'top ova' browse option."
	)
	/// The string for the 'top specials' browse option.
	///
	/// - Tag: L10n-topSpecials
	static let topSpecials: String = String(
		localized: "Top Specials",
		table: "Content",
		comment: "The string for the 'top specials' browse option."
	)
	/// The string for the 'just added' browse option.
	///
	/// - Tag: L10n-justAdded
	static let justAdded: String = String(
		localized: "Just Added",
		table: "Content",
		comment: "The string for the 'just added' browse option."
	)
	/// The string for the 'most popular' browse option.
	///
	/// - Tag: L10n-mostPopular
	static let mostPopular: String = String(
		localized: "Most Popular",
		table: "Content",
		comment: "The string for the 'most popular' browse option."
	)
	/// The string for the 'advanced search' browse option.
	///
	/// - Tag: L10n-advancedSearch
	static let advancedSearch: String = String(
		localized: "Advanced Search",
		table: "Content",
		comment: "The string for the 'advanced search' browse option."
	)

	// MARK: - Episode
	/// The string for the 'see also' section.
	///
	/// - Tag: L10n-seeAlso
	static let seeAlso: String = String(
		localized: "See Also",
		table: "Content",
		comment: "The string for the 'see also' section."
	)

	// MARK: - Rating
	/// The string for the rating failed title.
	///
	/// - Tag: L10n-ratingFailed
	static let ratingFailed: String = String(
		localized: "Rating Failed",
		table: "Content",
		comment: "The string for the 'rating failed' section."
	)
	/// The string for can't save review description.
	///
	/// - Tag: L10n-cantSaveReview
	static let cantSaveReview: String = String(
		localized: "Can’t Save Review 😔",
		table: "Content",
		comment: "The string for can't save review description."
	)
	/// The string for the rating submitted description.
	///
	/// - Tag: L10n-thankYouForRating
	static let thankYouForRating: String = String(
		localized: "Thank you for rating.",
		table: "Content",
		comment: "The string for the rating submitted description."
	)

	// MARK: - Ratings
	/// The string for the word 'ratings'.
	///
	/// - Tag: L10n-ratings
	static let ratings: String = String(
		localized: "Ratings",
		table: "Content",
		comment: "The string for the word 'ratings'."
	)
	/// The string for the word 'rating'.
	///
	/// - Tag: L10n-rating
	static let rating: String = String(
		localized: "Rating",
		table: "Content",
		comment: "The string for the word 'rating'."
	)
	/// The string for the word 'ratings & reviews'.
	///
	/// - Tag: L10n-ratingsAndReviews
	static let ratingsAndReviews: String = String(
		localized: "Ratings & Reviews",
		table: "Content",
		comment: "The string for the word 'ratings & reviews'."
	)
	/// The string for the word 'tap to rate'.
	///
	/// - Tag: L10n-tapToRate
	static let tapToRate: String = String(
		localized: "Tap to Rate:",
		table: "Content",
		comment: "The string for the word 'tap to rate'."
	)
	/// The string for the word 'click to rate'.
	///
	/// - Tag: L10n-clickToRate
	static let clickToRate: String = String(
		localized: "Click to Rate:",
		table: "Content",
		comment: "The string for the word 'click to rate'."
	)
	/// The string for the word 'write a review'.
	///
	/// - Tag: L10n-writeAReview
	static let writeAReview: String = String(
		localized: "Write a Review",
		table: "Content",
		comment: "The string for the word 'write a review'."
	)

	// MARK: - Profile Stats Labels
	/// The 'Following' label shown under the following count in the profile header.
	///
	/// - Tag: L10n-profileFollowingLabel
	static let profileFollowingLabel: String = String(
		localized: "\nFollowing",
		table: "Content",
		comment: "The 'Following' label shown under the following count in the profile header (newline prefix reserved for two-line stacked layout)."
	)
	/// The 'Followers' label shown under the follower count in the profile header.
	///
	/// - Tag: L10n-profileFollowersLabel
	static let profileFollowersLabel: String = String(
		localized: "\nFollowers",
		table: "Content",
		comment: "The 'Followers' label shown under the follower count in the profile header (newline prefix reserved for two-line stacked layout)."
	)
	/// The 'Reviews' label shown under the reviews count in the profile header.
	///
	/// - Tag: L10n-profileReviewsLabel
	static let profileReviewsLabel: String = String(
		localized: "\nReviews",
		table: "Content",
		comment: "The 'Reviews' label shown under the reviews count in the profile header (newline prefix reserved for two-line stacked layout)."
	)
	/// The 'Reputation' label shown under the reputation count in the profile header.
	///
	/// - Tag: L10n-profileReputationLabel
	static let profileReputationLabel: String = String(
		localized: "\nReputation",
		table: "Content",
		comment: "The 'Reputation' label shown under the reputation count in the profile header (newline prefix reserved for two-line stacked layout)."
	)
	/// The title shown on the reputation leaderboard screen.
	///
	/// - Tag: L10n-reputationLeaderboardTitle
	static let reputationLeaderboardTitle: String = String(
		localized: "Leaderboard",
		table: "Content",
		comment: "The title shown on the reputation leaderboard screen."
	)

	// MARK: - Follow Button
	/// The user-cell follow button title when the current user is following the target user.
	///
	/// - Tag: L10n-followingButton
	static let followingButton: String = String(
		localized: "✓ Following",
		table: "Content",
		comment: "The user-cell follow button title when the current user is following the target user."
	)
	/// The user-cell follow button title when the current user is not yet following the target user.
	///
	/// - Tag: L10n-followButton
	static let followButton: String = String(
		localized: "＋ Follow",
		table: "Content",
		comment: "The user-cell follow button title when the current user is not yet following the target user."
	)
	/// The empty-state action button shown on another user's empty followers list.
	///
	/// - Tag: L10n-followUserButton
	static func followUserButton(_ username: String) -> String {
		String(
			localized: "＋ Follow \(username)",
			table: "Content",
			comment: "The empty-state action button shown on another user's empty followers list. '%@' is the target user's display name."
		)
	}

	// MARK: - User Cell Subtitles
	/// The follow-status badge text shown after a person icon in the mention picker.
	///
	/// - Tag: L10n-userMentionFollowingBadge
	static let userMentionFollowingBadge: String = String(
		localized: "Following",
		table: "Content",
		comment: "The follow-status badge text shown after a person icon in the mention picker."
	)
	/// The user-cell secondary line for your own profile when you have no followers yet.
	///
	/// - Tag: L10n-userFollowersSelfNone
	static let userFollowersSelfNone: String = String(
		localized: "You, followed by you!",
		table: "Content",
		comment: "The user-cell secondary line for your own profile when you have no followers yet."
	)
	/// The user-cell secondary line for another user when nobody follows them yet.
	///
	/// - Tag: L10n-userFollowersBeFirst
	static let userFollowersBeFirst: String = String(
		localized: "Be the first to follow!",
		table: "Content",
		comment: "The user-cell secondary line for another user when nobody follows them yet."
	)
	/// The user-cell secondary line for your own profile when you have exactly one follower.
	///
	/// - Tag: L10n-userFollowersSelfOne
	static let userFollowersSelfOne: String = String(
		localized: "Followed by you... and one fan!",
		table: "Content",
		comment: "The user-cell secondary line for your own profile when you have exactly one follower."
	)
	/// The user-cell secondary line for another user that you already follow when their only follower is you.
	///
	/// - Tag: L10n-userFollowedByYouOnly
	static let userFollowedByYouOnly: String = String(
		localized: "Followed by you.",
		table: "Content",
		comment: "The user-cell secondary line for another user that you already follow when their only follower is you."
	)
	/// The user-cell secondary line for another user that you don't follow when they have exactly one follower.
	///
	/// - Tag: L10n-userFollowedByOneUser
	static let userFollowedByOneUser: String = String(
		localized: "Followed by one user.",
		table: "Content",
		comment: "The user-cell secondary line for another user that you don't follow when they have exactly one follower."
	)
	/// The user-cell secondary line for your own profile with a small (2–999) follower count.
	///
	/// - Tag: L10n-userFollowersSelfSmall
	static func userFollowersSelfSmall(_ count: String) -> String {
		String(
			localized: "Followed by you and \(count) fans.",
			table: "Content",
			comment: "The user-cell secondary line for your own profile with a small (2–999) follower count. '%@' is the follower count."
		)
	}
	/// The user-cell secondary line for your own profile with a large (1000+) follower count.
	///
	/// - Tag: L10n-userFollowersSelfLarge
	static func userFollowersSelfLarge(_ count: String) -> String {
		String(
			localized: "Followed by \(count) fans.",
			table: "Content",
			comment: "The user-cell secondary line for your own profile with a large (1000+) follower count. '%@' is the abbreviated follower count, e.g. '1.2K'."
		)
	}
	/// The user-cell secondary line for another user that you already follow, with the count of other followers.
	///
	/// - Tag: L10n-userFollowedByYouAndOthers
	static func userFollowedByYouAndOthers(_ count: String) -> String {
		String(
			localized: "Followed by you and \(count) users.",
			table: "Content",
			comment: "The user-cell secondary line for another user that you already follow. '%@' is the formatted count of other followers (excluding the current user)."
		)
	}
	/// The user-cell secondary line for another user that you don't follow, with the total follower count.
	///
	/// - Tag: L10n-userFollowedByOthers
	static func userFollowedByOthers(_ count: String) -> String {
		String(
			localized: "Followed by \(count) users.",
			table: "Content",
			comment: "The user-cell secondary line for another user that you don't follow. '%@' is the formatted total follower count."
		)
	}

	// MARK: - Users List Empty State
	/// The empty-state title for the followers list.
	///
	/// - Tag: L10n-usersListFollowersEmptyTitle
	static let usersListFollowersEmptyTitle: String = String(
		localized: "No Followers",
		table: "Content",
		comment: "The empty-state title for the followers list."
	)
	/// The empty-state title for the following list.
	///
	/// - Tag: L10n-usersListFollowingEmptyTitle
	static let usersListFollowingEmptyTitle: String = String(
		localized: "No Following",
		table: "Content",
		comment: "The empty-state title for the following list."
	)
	/// The empty-state title for a generic users list (search / leaderboard).
	///
	/// - Tag: L10n-usersListEmptyTitle
	static let usersListEmptyTitle: String = String(
		localized: "No Users",
		table: "Content",
		comment: "The empty-state title for a generic users list (search / leaderboard)."
	)
	/// The empty-state detail shown on your own followers list when you have none.
	///
	/// - Tag: L10n-followersEmptyDetailSelf
	static let followersEmptyDetailSelf: String = String(
		localized: "Follow other users so they will follow you back. Who knows, you might meet your next BFF!",
		table: "Content",
		comment: "The empty-state detail shown on your own followers list when you have none."
	)
	/// The empty-state detail shown on another user's followers list when nobody follows them yet.
	///
	/// - Tag: L10n-followersEmptyDetailOther
	static func followersEmptyDetailOther(_ username: String) -> String {
		String(
			localized: "Be the first to follow \(username)!",
			table: "Content",
			comment: "The empty-state detail shown on another user's followers list when nobody follows them yet. '%@' is the target user's display name."
		)
	}
	/// The empty-state detail shown on your own following list when you don't follow anyone yet.
	///
	/// - Tag: L10n-followingEmptyDetailSelf
	static let followingEmptyDetailSelf: String = String(
		localized: "Follow a user and they will show up here!",
		table: "Content",
		comment: "The empty-state detail shown on your own following list when you don't follow anyone yet."
	)
	/// The empty-state detail shown on another user's following list when they don't follow anyone yet.
	///
	/// - Tag: L10n-followingEmptyDetailOther
	static func followingEmptyDetailOther(_ username: String) -> String {
		String(
			localized: "\(username) is not following anyone yet.",
			table: "Content",
			comment: "The empty-state detail shown on another user's following list when they don't follow anyone yet. '%@' is the target user's display name."
		)
	}
	/// The empty-state detail shown when the users search returns no results or fails to load.
	///
	/// - Tag: L10n-usersListSearchEmptyDetail
	static let usersListSearchEmptyDetail: String = String(
		localized: "Can't get users list. Please reload the page or restart the app and check your WiFi connection.",
		table: "Content",
		comment: "The empty-state detail shown when the users search returns no results or fails to load."
	)
	/// The empty-state detail shown when the reputation leaderboard has no entries.
	///
	/// - Tag: L10n-leaderboardEmptyDetail
	static let leaderboardEmptyDetail: String = String(
		localized: "The leaderboard is empty. Pull to refresh or check back later.",
		table: "Content",
		comment: "The empty-state detail shown when the reputation leaderboard has no entries."
	)
	/// The fallback word used in place of a user's display name when one is unavailable, lowercase form (mid-sentence).
	///
	/// - Tag: L10n-thisUserLowercase
	static let thisUserLowercase: String = String(
		localized: "this user",
		table: "Content",
		comment: "The fallback word used in place of a user's display name when one is unavailable, lowercase form (mid-sentence)."
	)
	/// The fallback word used in place of a user's display name when one is unavailable, sentence-case form.
	///
	/// - Tag: L10n-thisUserCapitalized
	static let thisUserCapitalized: String = String(
		localized: "This user",
		table: "Content",
		comment: "The fallback word used in place of a user's display name when one is unavailable, sentence-case form."
	)

	// MARK: - Refresh Control Titles
	/// Pull-to-refresh title for the studios list.
	///
	/// - Tag: L10n-pullToRefreshStudios
	static let pullToRefreshStudios: String = String(
		localized: "Pull to refresh the studios.",
		table: "Content",
		comment: "Pull-to-refresh title for the studios list."
	)
	/// Refresh-in-progress title for the studios list.
	///
	/// - Tag: L10n-refreshingStudios
	static let refreshingStudios: String = String(
		localized: "Refreshing studios...",
		table: "Content",
		comment: "Refresh-in-progress title for the studios list."
	)
	/// Pull-to-refresh title for the cast list.
	///
	/// - Tag: L10n-pullToRefreshCast
	static let pullToRefreshCast: String = String(
		localized: "Pull to refresh the cast.",
		table: "Content",
		comment: "Pull-to-refresh title for the cast list."
	)
	/// Refresh-in-progress title for the cast list.
	///
	/// - Tag: L10n-refreshingCast
	static let refreshingCast: String = String(
		localized: "Refreshing cast...",
		table: "Content",
		comment: "Refresh-in-progress title for the cast list."
	)
	/// Pull-to-refresh title for the characters list.
	///
	/// - Tag: L10n-pullToRefreshCharacters
	static let pullToRefreshCharacters: String = String(
		localized: "Pull to refresh the characters.",
		table: "Content",
		comment: "Pull-to-refresh title for the characters list."
	)
	/// Refresh-in-progress title for the characters list.
	///
	/// - Tag: L10n-refreshingCharacters
	static let refreshingCharacters: String = String(
		localized: "Refreshing characters...",
		table: "Content",
		comment: "Refresh-in-progress title for the characters list."
	)
	/// Pull-to-refresh title for the genres list.
	///
	/// - Tag: L10n-pullToRefreshGenres
	static let pullToRefreshGenres: String = String(
		localized: "Pull to refresh genres list!",
		table: "Content",
		comment: "Pull-to-refresh title for the genres list."
	)
	/// Refresh-in-progress title for the genres list.
	///
	/// - Tag: L10n-refreshingGenres
	static let refreshingGenres: String = String(
		localized: "Refreshing genres list...",
		table: "Content",
		comment: "Refresh-in-progress title for the genres list."
	)
	/// Pull-to-refresh title for the favorites list.
	///
	/// - Tag: L10n-pullToRefreshFavorites
	static let pullToRefreshFavorites: String = String(
		localized: "Pull to refresh favorites list!",
		table: "Content",
		comment: "Pull-to-refresh title for the favorites list."
	)
	/// Refresh-in-progress title for the favorites list.
	///
	/// - Tag: L10n-refreshingFavorites
	static let refreshingFavorites: String = String(
		localized: "Refreshing favorites list...",
		table: "Content",
		comment: "Refresh-in-progress title for the favorites list."
	)
	/// Pull-to-refresh title for the episodes list.
	///
	/// - Tag: L10n-pullToRefreshEpisodes
	static let pullToRefreshEpisodes: String = String(
		localized: "Pull to refresh the episodes.",
		table: "Content",
		comment: "Pull-to-refresh title for the episodes list."
	)
	/// Refresh-in-progress title for the episodes list.
	///
	/// - Tag: L10n-refreshingEpisodes
	static let refreshingEpisodes: String = String(
		localized: "Refreshing episodes...",
		table: "Content",
		comment: "Refresh-in-progress title for the episodes list."
	)
	/// Pull-to-refresh title for the users list (follow / followers).
	///
	/// - Tag: L10n-pullToRefreshUsers
	static let pullToRefreshUsers: String = String(
		localized: "Pull to refresh the users.",
		table: "Content",
		comment: "Pull-to-refresh title for the users list (follow / followers)."
	)
	/// Refresh-in-progress title for the users list.
	///
	/// - Tag: L10n-refreshingUsers
	static let refreshingUsers: String = String(
		localized: "Refreshing users...",
		table: "Content",
		comment: "Refresh-in-progress title for the users list."
	)
	/// Pull-to-refresh title for the reputation leaderboard.
	///
	/// - Tag: L10n-pullToRefreshLeaderboard
	static let pullToRefreshLeaderboard: String = String(
		localized: "Pull to refresh the leaderboard.",
		table: "Content",
		comment: "Pull-to-refresh title for the reputation leaderboard."
	)
	/// Refresh-in-progress title for the reputation leaderboard.
	///
	/// - Tag: L10n-refreshingLeaderboard
	static let refreshingLeaderboard: String = String(
		localized: "Refreshing leaderboard...",
		table: "Content",
		comment: "Refresh-in-progress title for the reputation leaderboard."
	)
	/// Pull-to-refresh title for the profile details screen.
	///
	/// - Tag: L10n-pullToRefreshProfileDetails
	static let pullToRefreshProfileDetails: String = String(
		localized: "Pull to refresh profile details!",
		table: "Content",
		comment: "Pull-to-refresh title for the profile details screen."
	)
	/// Refresh-in-progress title for the profile details screen.
	///
	/// - Tag: L10n-refreshingProfileDetails
	static let refreshingProfileDetails: String = String(
		localized: "Refreshing profile details...",
		table: "Content",
		comment: "Refresh-in-progress title for the profile details screen."
	)
	/// Pull-to-refresh title for a user's reviews list.
	///
	/// - Tag: L10n-pullToRefreshUserReviews
	static let pullToRefreshUserReviews: String = String(
		localized: "Pull to refresh the reviews.",
		table: "Content",
		comment: "Pull-to-refresh title for a user's reviews list."
	)
	/// Refresh-in-progress title for the reviews list (shared across user and global reviews).
	///
	/// - Tag: L10n-refreshingReviews
	static let refreshingReviews: String = String(
		localized: "Refreshing reviews...",
		table: "Content",
		comment: "Refresh-in-progress title for the reviews list."
	)
	/// Pull-to-refresh title for the global reviews list on a media item.
	///
	/// - Tag: L10n-pullToRefreshReviews
	static let pullToRefreshReviews: String = String(
		localized: "Pull to refresh reviews!",
		table: "Content",
		comment: "Pull-to-refresh title for the global reviews list on a media item."
	)
	/// Pull-to-refresh title for the people list.
	///
	/// - Tag: L10n-pullToRefreshPeople
	static let pullToRefreshPeople: String = String(
		localized: "Pull to refresh the people.",
		table: "Content",
		comment: "Pull-to-refresh title for the people list."
	)
	/// Refresh-in-progress title for the people list.
	///
	/// - Tag: L10n-refreshingPeople
	static let refreshingPeople: String = String(
		localized: "Refreshing people...",
		table: "Content",
		comment: "Refresh-in-progress title for the people list."
	)
	/// Pull-to-refresh title for the seasons list.
	///
	/// - Tag: L10n-pullToRefreshSeasons
	static let pullToRefreshSeasons: String = String(
		localized: "Pull to refresh the seasons.",
		table: "Content",
		comment: "Pull-to-refresh title for the seasons list."
	)
	/// Refresh-in-progress title for the seasons list.
	///
	/// - Tag: L10n-refreshingSeasons
	static let refreshingSeasons: String = String(
		localized: "Refreshing seasons...",
		table: "Content",
		comment: "Refresh-in-progress title for the seasons list."
	)
	/// Pull-to-refresh title for the feed message details screen (thread view).
	///
	/// - Tag: L10n-pullToRefreshMessageDetails
	static let pullToRefreshMessageDetails: String = String(
		localized: "Pull to refresh message details and replies!",
		table: "Content",
		comment: "Pull-to-refresh title for the feed message details screen (thread view)."
	)
	/// Refresh-in-progress title for the feed message details top section.
	///
	/// - Tag: L10n-refreshingMessageDetails
	static let refreshingMessageDetails: String = String(
		localized: "Refreshing message details...",
		table: "Content",
		comment: "Refresh-in-progress title for the feed message details top section."
	)
	/// Refresh-in-progress title for the feed message replies list.
	///
	/// - Tag: L10n-refreshingMessageReplies
	static let refreshingMessageReplies: String = String(
		localized: "Refreshing message replies...",
		table: "Content",
		comment: "Refresh-in-progress title for the feed message replies list."
	)
	/// Pull-to-refresh title for the explore feed.
	///
	/// - Tag: L10n-pullToRefreshExploreFeed
	static let pullToRefreshExploreFeed: String = String(
		localized: "Pull to refresh your explore feed!",
		table: "Content",
		comment: "Pull-to-refresh title for the explore feed."
	)
	/// Refresh-in-progress title for the explore feed.
	///
	/// - Tag: L10n-refreshingExploreFeed
	static let refreshingExploreFeed: String = String(
		localized: "Refreshing your explore feed...",
		table: "Content",
		comment: "Refresh-in-progress title for the explore feed."
	)
	/// Pull-to-refresh title for the reminders list.
	///
	/// - Tag: L10n-pullToRefreshReminders
	static let pullToRefreshReminders: String = String(
		localized: "Pull to refresh reminders list!",
		table: "Content",
		comment: "Pull-to-refresh title for the reminders list."
	)
	/// Refresh-in-progress title for the reminders list.
	///
	/// - Tag: L10n-refreshingReminders
	static let refreshingReminders: String = String(
		localized: "Refreshing reminders list...",
		table: "Content",
		comment: "Refresh-in-progress title for the reminders list."
	)
	/// Pull-to-refresh title for the feed-message drafts list.
	///
	/// - Tag: L10n-pullToRefreshDrafts
	static let pullToRefreshDrafts: String = String(
		localized: "Pull to refresh your drafts!",
		table: "Content",
		comment: "Pull-to-refresh title for the feed-message drafts list."
	)
	/// Refresh-in-progress title for the feed-message drafts list.
	///
	/// - Tag: L10n-refreshingDrafts
	static let refreshingDrafts: String = String(
		localized: "Refreshing drafts...",
		table: "Content",
		comment: "Refresh-in-progress title for the feed-message drafts list."
	)
	/// Pull-to-refresh title for a user list variant (followers/following/…).
	///
	/// - Tag: L10n-pullToRefreshUsersList
	static func pullToRefreshUsersList(_ type: String) -> String {
		String(
			localized: "Pull to refresh the \(type).",
			table: "Content",
			comment: "Pull-to-refresh title for a user list variant. '%@' is the list kind, e.g. 'followers', 'following'."
		)
	}

	/// Refresh-in-progress title for a user list variant (followers/following/…).
	///
	/// - Tag: L10n-refreshingUsersList
	static func refreshingUsersList(_ type: String) -> String {
		String(
			localized: "Refreshing \(type)...",
			table: "Content",
			comment: "Refresh-in-progress title for a user list variant. '%@' is the lowercase list kind, e.g. 'followers', 'following'."
		)
	}

	/// Pull-to-refresh title for the library list, scoped by tracking status.
	///
	/// - Tag: L10n-pullToRefreshLibrary
	static func pullToRefreshLibrary(_ status: String) -> String {
		String(
			localized: "Pull to refresh \(status) list.",
			table: "Content",
			comment: "Pull-to-refresh title for the library list scoped by tracking status. '%@' is the lowercase status, e.g. 'watching', 'completed'."
		)
	}

	/// Refresh-in-progress title for the library list, scoped by tracking status.
	///
	/// - Tag: L10n-refreshingLibrary
	static func refreshingLibrary(_ status: String) -> String {
		String(
			localized: "Refreshing \(status) list...",
			table: "Content",
			comment: "Refresh-in-progress title for the library list scoped by tracking status. '%@' is the lowercase status, e.g. 'watching', 'completed'."
		)
	}

	// MARK: - Music Library
	/// The alert button that deep-links to the user's Apple Music library.
	///
	/// - Tag: L10n-openAppleMusicLibrary
	static let openAppleMusicLibrary: String = String(
		localized: "Open Apple Music Library",
		table: "Content",
		comment: "The alert button that deep-links to the user's Apple Music library."
	)

	// MARK: - Social actions (context menu)
	/// The string for the word 'unfollow'.
	///
	/// - Tag: L10n-unfollow
	static let unfollow: String = String(
		localized: "Unfollow",
		table: "Content",
		comment: "The string for the word 'unfollow'."
	)
	/// The string for the word 'block'.
	///
	/// - Tag: L10n-block
	static let block: String = String(
		localized: "Block",
		table: "Content",
		comment: "The string for the word 'block'."
	)
	/// The string for the word 'unblock'.
	///
	/// - Tag: L10n-unblock
	static let unblock: String = String(
		localized: "Unblock",
		table: "Content",
		comment: "The string for the word 'unblock'."
	)
	/// The string for the word 'unpin'.
	///
	/// - Tag: L10n-unpin
	static let unpin: String = String(
		localized: "Unpin",
		table: "Content",
		comment: "The string for the word 'unpin'."
	)
	/// The string for the word 'pin'.
	///
	/// - Tag: L10n-pin
	static let pin: String = String(
		localized: "Pin",
		table: "Content",
		comment: "The string for the word 'pin'."
	)
	/// The string for the word 'unlike'.
	///
	/// - Tag: L10n-unlike
	static let unlike: String = String(
		localized: "Unlike",
		table: "Content",
		comment: "The string for the word 'unlike'."
	)
	/// The string for the word 'like'.
	///
	/// - Tag: L10n-like
	static let like: String = String(
		localized: "Like",
		table: "Content",
		comment: "The string for the word 'like'."
	)
	/// The string for the word 'edit'.
	///
	/// - Tag: L10n-edit
	static let edit: String = String(
		localized: "Edit",
		table: "Content",
		comment: "The string for the word 'edit'."
	)
	/// The string for the word 'delete'.
	///
	/// - Tag: L10n-delete
	static let delete: String = String(
		localized: "Delete",
		table: "Content",
		comment: "The string for the word 'delete'."
	)
	/// The string for the word 'report'.
	///
	/// - Tag: L10n-report
	static let report: String = String(
		localized: "Report",
		table: "Content",
		comment: "The string for the word 'report'."
	)

	// MARK: - Parental Guide
	/// Title of the Parental Guide screen.
	///
	/// - Tag: L10n-parentalGuide
	static let parentalGuide: String = String(
		localized: "Parental Guide",
		table: "Content",
		comment: "The title of the Parental Guide screen."
	)
	/// The pull-to-refresh prompt on the Parental Guide screen.
	///
	/// - Tag: L10n-pullToRefreshParentalGuide
	static let pullToRefreshParentalGuide: String = String(
		localized: "Pull to refresh parental guide.",
		table: "Content",
		comment: "The pull-to-refresh prompt on the Parental Guide screen."
	)
	/// The pull-to-refresh prompt on the Parental Guide entries screen.
	///
	/// - Tag: L10n-pullToRefreshParentalGuideEntries
	static let pullToRefreshParentalGuideEntries: String = String(
		localized: "Pull to refresh entries.",
		table: "Content",
		comment: "The pull-to-refresh prompt on the Parental Guide entries screen."
	)
	/// The empty-state title on the Parental Guide screen when no entries exist yet.
	///
	/// - Tag: L10n-noParentalGuideYet
	static let noParentalGuideYet: String = String(
		localized: "No Parental Guide Yet",
		table: "Content",
		comment: "The empty-state title on the Parental Guide screen when no entries exist yet."
	)
	/// The empty-state body on the Parental Guide screen when no entries exist yet.
	///
	/// - Tag: L10n-beTheFirstToContribute
	static let beTheFirstToContribute: String = String(
		localized: "Be the first to contribute.",
		table: "Content",
		comment: "The empty-state body on the Parental Guide screen when no entries exist yet."
	)
	/// The empty-state title on a Parental Guide category screen when no entries exist.
	///
	/// - Tag: L10n-noParentalGuideEntries
	static let noParentalGuideEntries: String = String(
		localized: "No Entries",
		table: "Content",
		comment: "The empty-state title on a Parental Guide category screen when no entries exist."
	)
	/// The empty-state body on a Parental Guide category screen when no entries exist.
	///
	/// - Tag: L10n-noParentalGuideEntriesDetail
	static let noParentalGuideEntriesDetail: String = String(
		localized: "There are no entries in this category yet.",
		table: "Content",
		comment: "The empty-state body on a Parental Guide category screen when no entries exist."
	)
	/// Header for the Parental Guide summary section.
	///
	/// - Tag: L10n-parentalGuideSummary
	static let parentalGuideSummary: String = String(
		localized: "Summary",
		table: "Content",
		comment: "Header for the Parental Guide summary section."
	)
	/// Row label for the rating in the Parental Guide summary.
	///
	/// - Tag: L10n-parentalGuideRating
	static let parentalGuideRating: String = String(
		localized: "Rating",
		table: "Content",
		comment: "Row label for the rating in the Parental Guide summary."
	)
	/// Placeholder shown for an unknown rating in the Parental Guide summary.
	///
	/// - Tag: L10n-parentalGuideRatingUnknown
	static let parentalGuideRatingUnknown: String = String(
		localized: "Unknown",
		table: "Content",
		comment: "Placeholder shown for an unknown rating in the Parental Guide summary."
	)
	/// Placeholder shown for a category with no submissions in the Parental Guide summary.
	///
	/// - Tag: L10n-parentalGuideNoSubmissions
	static let parentalGuideNoSubmissions: String = String(
		localized: "None",
		table: "Content",
		comment: "Placeholder shown for a category with no submissions in the Parental Guide summary."
	)
	/// Title-line format for sharing a Parental Guide entry.
	///
	/// - Parameters:
	///    - title: The media's title.
	///    - severity: The severity rating phrase.
	///    - category: The category name.
	///
	/// - Tag: L10n-parentalGuideShareTitleFormat
	static func parentalGuideShareTitleFormat(_ title: String, _ severity: String, _ category: String) -> String {
		return String(
			format: String(
				localized: "%1$@ is rated %2$@ for %3$@",
				table: "Content",
				comment: "Title-line format for sharing a Parental Guide entry. %1 is the media title, %2 the severity rating, %3 the category name."
			),
			title, severity, category
		)
	}
	/// Sentiment subtitle under each Parental Guide category section header.
	///
	/// - Parameters:
	///    - matching: Number of users who agreed with the average rating.
	///    - total: Total number of submissions.
	///    - rating: The average rating phrase, lowercased.
	///
	/// - Tag: L10n-parentalGuideSentiment
	static func parentalGuideSentiment(_ matching: Int, _ total: Int, _ rating: String) -> String {
		return String(
			format: String(
				localized: "%1$d of %2$d found this %3$@.",
				table: "Content",
				comment: "Sentiment subtitle under each Parental Guide category section header. %1$d is matching count, %2$d is total count, %3$@ is the lowercased rating phrase."
			),
			matching,
			total,
			rating
		)
	}
	/// Title of the editor when adding a new entry for a category.
	///
	/// - Parameter displayName: The category's display name.
	///
	/// - Tag: L10n-addParentalGuideCategory
	static func addParentalGuideCategory(_ displayName: String) -> String {
		return String(
			format: String(
				localized: "Add %@",
				table: "Content",
				comment: "Title of the editor when adding a new entry for a category. The argument is the category display name."
			),
			displayName
		)
	}
	/// Title of the editor when editing an existing entry for a category.
	///
	/// - Parameter displayName: The category's display name.
	///
	/// - Tag: L10n-editParentalGuideCategory
	static func editParentalGuideCategory(_ displayName: String) -> String {
		return String(
			format: String(
				localized: "Edit %@",
				table: "Content",
				comment: "Title of the editor when editing an existing entry for a category. The argument is the category display name."
			),
			displayName
		)
	}
	/// Header for the severity section of the Parental Guide editor.
	///
	/// - Tag: L10n-parentalGuideSeverity
	static let parentalGuideSeverity: String = String(
		localized: "Severity",
		table: "Content",
		comment: "Header for the severity section of the Parental Guide editor."
	)
	/// Header for the frequency section of the Parental Guide editor.
	///
	/// - Tag: L10n-parentalGuideFrequency
	static let parentalGuideFrequency: String = String(
		localized: "Frequency",
		table: "Content",
		comment: "Header for the frequency section of the Parental Guide editor."
	)
	/// Header for the depiction section of the Parental Guide editor.
	///
	/// - Tag: L10n-parentalGuideDepiction
	static let parentalGuideDepiction: String = String(
		localized: "Depiction",
		table: "Content",
		comment: "Header for the depiction section of the Parental Guide editor."
	)
	/// Header for the reason section of the Parental Guide editor.
	///
	/// - Tag: L10n-parentalGuideReason
	static let parentalGuideReason: String = String(
		localized: "Reason",
		table: "Content",
		comment: "Header for the reason section of the Parental Guide editor."
	)
	/// Placeholder for the reason text view in the Parental Guide editor.
	///
	/// - Tag: L10n-parentalGuideReasonPlaceholder
	static let parentalGuideReasonPlaceholder: String = String(
		localized: "What stands out?",
		table: "Content",
		comment: "Placeholder for the reason text view in the Parental Guide editor."
	)
	/// Label for the spoiler toggle in the Parental Guide editor.
	///
	/// - Tag: L10n-parentalGuideSpoiler
	static let parentalGuideSpoiler: String = String(
		localized: "Spoiler",
		table: "Content",
		comment: "Label for the spoiler toggle in the Parental Guide editor."
	)
	/// Title of the destructive delete row in the Parental Guide editor.
	///
	/// - Tag: L10n-deleteThisParentalGuideEntry
	static let deleteThisParentalGuideEntry: String = String(
		localized: "Delete this entry",
		table: "Content",
		comment: "Title of the destructive delete row in the Parental Guide editor."
	)
	/// Title of the confirmation alert when deleting a Parental Guide entry.
	///
	/// - Tag: L10n-deleteParentalGuideEntryConfirmTitle
	static let deleteParentalGuideEntryConfirmTitle: String = String(
		localized: "Delete this entry?",
		table: "Content",
		comment: "Title of the confirmation alert when deleting a Parental Guide entry."
	)
	/// Body of the confirmation alert when deleting a Parental Guide entry.
	///
	/// - Tag: L10n-deleteParentalGuideEntryConfirmMessage
	static let deleteParentalGuideEntryConfirmMessage: String = String(
		localized: "This action can't be undone.",
		table: "Content",
		comment: "Body of the confirmation alert when deleting a Parental Guide entry."
	)
	/// Title of the discard-changes alert in the Parental Guide editor.
	///
	/// - Tag: L10n-discardParentalGuideChanges
	static let discardParentalGuideChanges: String = String(
		localized: "Discard changes?",
		table: "Content",
		comment: "Title of the discard-changes alert in the Parental Guide editor."
	)
	/// Cancel button on the discard-changes alert.
	///
	/// - Tag: L10n-keepEditing
	static let keepEditing: String = String(
		localized: "Keep Editing",
		table: "Content",
		comment: "Cancel button on the discard-changes alert."
	)
	/// Generic error alert title shown when a Parental Guide submission fails.
	///
	/// - Tag: L10n-parentalGuideErrorTitle
	static let parentalGuideErrorTitle: String = String(
		localized: "Something went wrong",
		table: "Content",
		comment: "Generic error alert title shown when a Parental Guide submission fails."
	)
	/// Generic OK button shown on Parental Guide alerts.
	///
	/// - Tag: L10n-okay
	static let okay: String = String(
		localized: "OK",
		table: "Content",
		comment: "Generic OK button shown on Parental Guide alerts."
	)
	/// Error message shown when the server's Parental Guide submission response is empty.
	///
	/// - Tag: L10n-parentalGuideEmptyResponse
	static let parentalGuideEmptyResponse: String = String(
		localized: "Server returned no entry.",
		table: "Content",
		comment: "Error message shown when the server's Parental Guide submission response is empty."
	)
	/// Spoiler-warning banner overlaid on a parental guide entry on touch platforms.
	///
	/// - Tag: L10n-parentalGuideReasonSpoilerTap
	static let parentalGuideReasonSpoilerTap: String = String(
		localized: "This reason contains spoilers — tap to view",
		table: "Content",
		comment: "Spoiler-warning banner overlaid on a parental guide entry on touch platforms."
	)
	/// Spoiler-warning banner overlaid on a parental guide entry on Mac Catalyst.
	///
	/// - Tag: L10n-parentalGuideReasonSpoilerClick
	static let parentalGuideReasonSpoilerClick: String = String(
		localized: "This reason contains spoilers — click to view",
		table: "Content",
		comment: "Spoiler-warning banner overlaid on a parental guide entry on Mac Catalyst."
	)

	/// Title shown in the navigation bar of the Parental Guide report sheet.
	///
	/// - Tag: L10n-reportParentalGuideEntry
	static let reportParentalGuideEntry: String = String(
		localized: "Report Entry",
		table: "Content",
		comment: "Title shown in the navigation bar of the Parental Guide report sheet."
	)

	/// Header above the reason picker in the Parental Guide report sheet.
	///
	/// - Tag: L10n-reportReasonHeader
	static let reportReasonHeader: String = String(
		localized: "Reason",
		table: "Content",
		comment: "Header above the reason picker in the Parental Guide report sheet."
	)

	/// Header above the optional details editor in the Parental Guide report sheet.
	///
	/// - Tag: L10n-reportDetailsHeader
	static let reportDetailsHeader: String = String(
		localized: "Details",
		table: "Content",
		comment: "Header above the details editor in the Parental Guide report sheet."
	)

	/// Placeholder shown in the optional details editor.
	///
	/// - Tag: L10n-reportDetailsPlaceholder
	static let reportDetailsPlaceholder: String = String(
		localized: "Tell us more (optional)",
		table: "Content",
		comment: "Placeholder shown in the details editor when optional."
	)

	/// Placeholder shown in the details editor when the reason is `Other` and details are required.
	///
	/// - Tag: L10n-reportDetailsPlaceholderRequired
	static let reportDetailsPlaceholderRequired: String = String(
		localized: "Tell us more",
		table: "Content",
		comment: "Placeholder shown in the details editor when the reason is `Other` and details are required."
	)

	/// Submit button title in the Parental Guide report sheet.
	///
	/// - Tag: L10n-reportSubmit
	static let reportSubmit: String = String(
		localized: "Submit",
		table: "Content",
		comment: "Submit button title in the Parental Guide report sheet."
	)

	/// Title of the success alert shown after a Parental Guide entry has been reported.
	///
	/// - Tag: L10n-reportSuccessTitle
	static let reportSuccessTitle: String = String(
		localized: "Reported",
		table: "Content",
		comment: "Title of the success alert shown after a Parental Guide entry has been reported."
	)

	/// Body of the success alert shown after a Parental Guide entry has been reported.
	///
	/// - Tag: L10n-reportSuccessMessage
	static let reportSuccessMessage: String = String(
		localized: "Thanks. We'll review this entry shortly.",
		table: "Content",
		comment: "Body of the success alert shown after a Parental Guide entry has been reported."
	)

	/// Display name of the `inaccurate` report reason.
	///
	/// - Tag: L10n-reportReasonInaccurate
	static let reportReasonInaccurate: String = String(
		localized: "Inaccurate",
		table: "Content",
		comment: "Display name of the `inaccurate` Parental Guide report reason."
	)

	/// Display name of the `spoiler` report reason.
	///
	/// - Tag: L10n-reportReasonSpoiler
	static let reportReasonSpoiler: String = String(
		localized: "Spoiler",
		table: "Content",
		comment: "Display name of the `spoiler` Parental Guide report reason."
	)

	/// Display name of the `spam` report reason.
	///
	/// - Tag: L10n-reportReasonSpam
	static let reportReasonSpam: String = String(
		localized: "Spam",
		table: "Content",
		comment: "Display name of the `spam` Parental Guide report reason."
	)

	/// Display name of the `inappropriate` report reason.
	///
	/// - Tag: L10n-reportReasonInappropriate
	static let reportReasonInappropriate: String = String(
		localized: "Inappropriate",
		table: "Content",
		comment: "Display name of the `inappropriate` Parental Guide report reason."
	)

	/// Display name of the `other` report reason.
	///
	/// - Tag: L10n-reportReasonOther
	static let reportReasonOther: String = String(
		localized: "Other",
		table: "Content",
		comment: "Display name of the `other` Parental Guide report reason."
	)
}
