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
	/// The headline string for the reshare message error pop-up.
	///
	/// - Tag: L10n-reshareMessageErrorHeadline
	static let reshareMessageErrorHeadline: String = String(
		localized: "Can't Re-Share",
		table: "Content",
		comment: "The headline string for the reshare message error pop-up"
	)
	/// The subheadline string for the reshare message error pop-up.
	///
	/// - Tag: L10n-reshareMessageErrorSubheadline
	static let reshareMessageErrorSubheadline: String = String(
		localized: "You are not allowed to re-share a message more than once.",
		table: "Content",
		comment: "The subheadline string for the reshare message error pop-up"
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
		localized: "They will be able to see your public messages, but will no longer be able to engange with them. They will also not be able to follow or message you, and you wil not see notifications from them.",
		table: "Content",
		comment: "The subheadline string for the blocing a user"
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
}
