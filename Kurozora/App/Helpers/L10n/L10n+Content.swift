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
	static var libraryDeleteHeadline: String {
		L10n.resolve {
			String(
				localized: "Delete Library",
				table: "Content",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The headline string for the Library Delete view"
			)
		}
	}
	/// The subheadline string for the Library Delete view.
	///
	/// - Tag: L10n-libraryDeleteSubheadline
	static var libraryDeleteSubheadline: String {
		L10n.resolve {
			String(
				localized: "Permanently delete your library.",
				table: "Content",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The subheadline string for the Library Delete view."
			)
		}
	}
	/// The footer string for the Library Delete view.
	///
	/// - Tag: L10n-libraryDeleteFooter
	static var libraryDeleteFooter: String {
		L10n.resolve {
			String(
				localized: "Once your library is deleted, all of its resources and data will be permanently deleted. This includes ratings, favorites, reminders, watched episodes, and You will be asked for your password to confirm the deletion.",
				table: "Content",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The footer string for the Library Delete view."
			)
		}
	}

	// MARK: - Library Import
	/// The placeholder string for selecting the import service.
	///
	/// - Tag: L10n-selectService
	static var selectService: String {
		L10n.resolve {
			String(
				localized: "Select service",
				table: "Content",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The placeholder string for selecting the import service."
			)
		}
	}
	/// The placeholder string for selecting the import behavior.
	///
	/// - Tag: L10n-selectBehavior
	static var selectBehavior: String {
		L10n.resolve {
			String(
				localized: "Select behavior",
				table: "Content",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The placeholder string for selecting the import behavior."
			)
		}
	}
	/// The button string for selecting a file to import.
	///
	/// - Tag: L10n-selectFile
	static var selectFile: String {
		L10n.resolve {
			String(
				localized: "Select File",
				table: "Content",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The button string for selecting a file to import."
			)
		}
	}
	/// The placeholder string for the library xml file name.
	///
	/// - Tag: L10n-libraryXML
	static var libraryXML: String {
		L10n.resolve {
			String(
				localized: "Library.xml",
				table: "Content",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The placeholder string for the library xml file name."
			)
		}
	}
	/// The headline string for the Library Import view.
	///
	/// - Tag: L10n-libraryImportHeadline
	static var libraryImportHeadline: String {
		L10n.resolve {
			String(
				localized: "Move From Another Service",
				table: "Content",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The headline string for the Library Import view"
			)
		}
	}
	/// The subheadline string for the Library Import view.
	///
	/// - Tag: L10n-libraryImportSubheadline
	static var libraryImportSubheadline: String {
		L10n.resolve {
			String(
				localized: "If you have an export of your anime or manga library from other services, such as MyAnimeList, you can select it below.",
				table: "Content",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The subheadline string for the Library Import view."
			)
		}
	}
	/// The footer string for the Library Import view.
	///
	/// - Tag: L10n-libraryImportFooter
	static var libraryImportFooter: String {
		L10n.resolve {
			String(
				localized: "Kurozora does not guarantee all shows and mangas will be imported to your library. Once the request has been processed, a notification which contains the status of the import request will be sent. Furthermore, the uploaded file is deleted as soon as the import request has been processed.\n\nSelecting \"overwrite\" will replace your Kurozora library with the imported one from the file.\nSelecting \"merge\" will add missing items to your Kurozora library. If an item exists then the tracking information in your Kurozora library will be updated with the imported one from the file.",
				table: "Content",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The footer string for the Library Import view."
			)
		}
	}

	// MARK: - Episodes
	/// The string for the 'Up Next' view title.
	///
	/// - Tag: L10n-upNext
	static var upNext: String {
		L10n.resolve {
			String(
				localized: "Up Next",
				table: "Content",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The string for the 'Up Next' view title."
			)
		}
	}
	/// The string for the 'Go To' bar button item.
	///
	/// - Tag: L10n-goTo
	static var goTo: String {
		L10n.resolve {
			String(
				localized: "Go To",
				table: "Content",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The string for the 'Go To' context menu option."
			)
		}
	}
	/// The string for the 'Go to first episode' context menu option.
	///
	/// - Tag: L10n-goToFirstEpisode
	static var goToFirstEpisode: String {
		L10n.resolve {
			String(
				localized: "Go to first episode",
				table: "Content",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The string for the 'Go to first episode' context menu option."
			)
		}
	}
	/// The string for the 'Go to last episode' context menu option.
	///
	/// - Tag: L10n-goToLastEpisode
	static var goToLastEpisode: String {
		L10n.resolve {
			String(
				localized: "Go to last episode",
				table: "Content",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The string for the 'Go to last episode' context menu option."
			)
		}
	}
	/// The string for the 'Go to last watched episode' context menu option.
	///
	/// - Tag: L10n-goToLastWatchedEpisode
	static var goToLastWatchedEpisode: String {
		L10n.resolve {
			String(
				localized: "Go to last watched episode",
				table: "Content",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The string for the 'Go to last watched episode' context menu option."
			)
		}
	}
	/// The string for the 'Show fillers' context menu option.
	///
	/// - Tag: L10n-showFillers
	static var showFillers: String {
		L10n.resolve {
			String(
				localized: "Show fillers",
				table: "Content",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The string for the 'Show fillers' context menu option."
			)
		}
	}
	/// The string for the 'Hide fillers' context menu option.
	///
	/// - Tag: L10n-hideFillers
	static var hideFillers: String {
		L10n.resolve {
			String(
				localized: "Hide fillers",
				table: "Content",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The string for the 'Hide fillers' context menu option."
			)
		}
	}

	// MARK: - Feed
	/// The placeholder string for creating a new feed message.
	///
	/// - Tag: L10n-whatsOnYourMind
	static var whatsOnYourMind: String {
		L10n.resolve {
			String(
				localized: "What’s on your mind?",
				table: "Content",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The placeholder string for creating a new feed message."
			)
		}
	}
	/// The placeholder string for creating a new comment.
	///
	/// - Tag: L10n-writeAComment
	static var writeAComment: String {
		L10n.resolve {
			String(
				localized: "Write a comment…",
				table: "Content",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The placeholder string for creating a new comment."
			)
		}
	}
	/// The headline string for the character limit reached error pop-up.
	///
	/// - Tag: L10n-characterLimitReachedHeadline
	static var characterLimitReachedHeadline: String {
		L10n.resolve {
			String(
				localized: "Limit Reached",
				table: "Content",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The headline string for the character limit reached error pop-up"
			)
		}
	}
	/// The subheadline string for the character limit reached error pop-up.
	///
	/// - Tag: L10n-characterLimitReachedSubheadline
	static var characterLimitReachedSubheadline: String {
		L10n.resolve {
			String(
				localized: "You have exceeded the character limit for a message.",
				table: "Content",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The subheadline string for the character limit reached error pop-up"
			)
		}
	}
	/// The title string for the search pop-up when trying to tag a user in a message or reply.
	///
	/// - Tag: L10n-findWhoYouAreLookingFor
	static var findWhoYouAreLookingFor: String {
		L10n.resolve {
			String(
				localized: "Find who you're looking for",
				table: "Content",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The title string for the search pop-up when trying to tag a user in a message or reply."
			)
		}
	}
	/// The subtitle string for the search pop-up when trying to tag a user in a message or reply.
	///
	/// - Tag: L10n-searchForThePersonYouWantToMention
	static var searchForThePersonYouWantToMention: String {
		L10n.resolve {
			String(
				localized: "Search for the person you want to mention",
				table: "Content",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The subtitle string for the search pop-up when trying to tag a user in a message or reply."
			)
		}
	}
	/// The headline string for the pin message pop-up.
	///
	/// - Tag: L10n-pinMessageHeadline
	static var pinMessageHeadline: String {
		L10n.resolve {
			String(
				localized: "Pin this message",
				table: "Content",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The headline string for the pin message pop-up"
			)
		}
	}
	/// The subheadline string for the pin message pop-up.
	///
	/// - Tag: L10n-pinMessageSubheadline
	static var pinMessageSubheadline: String {
		L10n.resolve {
			String(
				localized: "This will appear at the top of your profile and replace any previously pinned message. Are you sure?",
				table: "Content",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The subheadline string for the pin message pop-up"
			)
		}
	}
	/// The headline string for the unpin message pop-up.
	///
	/// - Tag: L10n-unpinMessageHeadline
	static var unpinMessageHeadline: String {
		L10n.resolve {
			String(
				localized: "Unpin from your profile",
				table: "Content",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The headline string for the unpin message pop-up"
			)
		}
	}
	/// The subheadline string for the unpin message pop-up.
	///
	/// - Tag: L10n-unpinMessageSubheadline
	static var unpinMessageSubheadline: String {
		L10n.resolve {
			String(
				localized: "Are you sure?",
				table: "Content",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The subheadline string for the unpin message pop-up"
			)
		}
	}
	/// The subheadline string for the delete message pop-up.
	///
	/// - Tag: L10n-deleteMessageSubheadline
	static var deleteMessageSubheadline: String {
		L10n.resolve {
			String(
				localized: "Message will be deleted permanently.",
				table: "Content",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The subheadline string for the delete message pop-up"
			)
		}
	}
	/// The subheadline string for blocking a user.
	///
	/// - Tag: L10n-blockMessageSubheadline
	static var blockMessageSubheadline: String {
		L10n.resolve {
			String(
				localized: "They will be able to see your public messages, but will no longer be able to engage with them. They will also not be able to follow or message you, and you will not see notifications from them.",
				table: "Content",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The subheadline string for the blocking a user"
			)
		}
	}
	/// The string for the 'Blocked' button label.
	///
	/// - Tag: L10n-blocked
	static var blocked: String {
		L10n.resolve {
			String(
				localized: "Blocked",
				table: "Content",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The label shown on the button when the user has blocked another user"
			)
		}
	}
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
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
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
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
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
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
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
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "Subheadline explaining what is restricted when the auth user has been blocked by another user. Both arguments are the @username of the blocking user."
			),
			username,
			username
		)
	}
	/// The label for the opt-in button to view a blocked user's profile.
	///
	/// - Tag: L10n-viewProfileAnyway
	static var viewProfileAnyway: String {
		L10n.resolve {
			String(
				localized: "Yes, view profile",
				table: "Content",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The label for the opt-in button to view a blocked user's profile"
			)
		}
	}
	/// The label for the opt-in button to view a blocked user's posts.
	///
	/// - Tag: L10n-viewPosts
	static var viewPosts: String {
		L10n.resolve {
			String(
				localized: "View posts",
				table: "Content",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The label for the opt-in button to view a blocked user's posts"
			)
		}
	}
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
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
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
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "Subheadline prompting the auth user to opt in to viewing a blocked user's posts. The argument is the @username of the blocked user."
			),
			username
		)
	}
	/// The label for the Settings entry that opens the blocked users list.
	///
	/// - Tag: L10n-blockedUsers
	static var blockedUsers: String {
		L10n.resolve {
			String(
				localized: "Blocked Users",
				table: "Content",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The label for the Settings entry that opens the blocked users list"
			)
		}
	}
	/// The intro string shown above the blocked users list.
	///
	/// - Tag: L10n-blockedUsersIntro
	static var blockedUsersIntro: String {
		L10n.resolve {
			String(
				localized: "When you block someone, they will be able to see your public messages, but will no longer be able to engage with them. They will also not be able to follow or message you, and you will not see notifications from them.",
				table: "Content",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The intro string shown above the blocked users list"
			)
		}
	}
	/// The headline string for the report message pop-up.
	///
	/// - Tag: L10n-messageReportedHeadline
	static var messageReportedHeadline: String {
		L10n.resolve {
			String(
				localized: "Message Reported",
				table: "Content",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The headline string for the report message pop-up"
			)
		}
	}
	/// The subheadline string for the report message pop-up.
	///
	/// - Tag: L10n-messageReportedSubheadline
	static var messageReportedSubheadline: String {
		L10n.resolve {
			String(
				localized: "Thank you for helping keep the community safe.",
				table: "Content",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The subheadline string for the report message pop-up"
			)
		}
	}
	/// The string for the 'Show Profile' context menu option.
	///
	/// - Tag: L10n-showProfile
	static var showProfile: String {
		L10n.resolve {
			String(
				localized: "Show Profile",
				table: "Content",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The string for the 'Show Profile' context menu option."
			)
		}
	}
	/// The string for the 'Reply' context menu option.
	///
	/// - Tag: L10n-reply
	static var reply: String {
		L10n.resolve {
			String(
				localized: "Reply",
				table: "Content",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The string for the 'Reply' context menu option."
			)
		}
	}
	/// The string for the 'Re-share' context menu option.
	///
	/// - Tag: L10n-reshare
	static var reshare: String {
		L10n.resolve {
			String(
				localized: "Re-share",
				table: "Content",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The string for the 'Re-share' context menu option."
			)
		}
	}
	/// The string for the 'Undo Re-share' context menu option.
	///
	/// - Tag: L10n-undoReshare
	static var undoReshare: String {
		L10n.resolve {
			String(
				localized: "Undo Re-share",
				table: "Content",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The string for the 'Undo Re-share' context menu option."
			)
		}
	}
	/// The string for the 'Quote' context menu option.
	///
	/// - Tag: L10n-quote
	static var quote: String {
		L10n.resolve {
			String(
				localized: "Quote",
				table: "Content",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The string for the 'Quote' context menu option."
			)
		}
	}
	/// The string for the 'View post activity' context menu option.
	///
	/// - Tag: L10n-viewPostActivity
	static var viewPostActivity: String {
		L10n.resolve {
			String(
				localized: "View post activity",
				table: "Content",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The string for the 'View post activity' context menu option."
			)
		}
	}
	/// The string for the 'Post activity' navigation title.
	///
	/// - Tag: L10n-postActivity
	static var postActivity: String {
		L10n.resolve {
			String(
				localized: "Post activity",
				table: "Content",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The navigation title for the post activity screen."
			)
		}
	}
	/// The string for the 'Quotes' tab.
	///
	/// - Tag: L10n-quotes
	static var quotes: String {
		L10n.resolve {
			String(
				localized: "Quotes",
				table: "Content",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The string for the 'Quotes' tab on the post activity screen."
			)
		}
	}
	/// The string for the 'Re-shares' tab.
	///
	/// - Tag: L10n-reShares
	static var reShares: String {
		L10n.resolve {
			String(
				localized: "Re-shares",
				table: "Content",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The string for the 'Re-shares' tab on the post activity screen."
			)
		}
	}
	/// The string for the re-share attribution row.
	///
	/// - Tag: L10n-reSharedBy
	static func reSharedBy(_ user: String) -> String {
		String(
			localized: "Re-shared by \(user)",
			table: "Content",
			bundle: LanguageManager.shared.bundle,
			locale: LanguageManager.shared.locale,
			comment: "The string for the re-share attribution row."
		)
	}
	/// The string for the auth user's re-share attribution row.
	///
	/// - Tag: L10n-youReShared
	static var youReShared: String {
		L10n.resolve {
			String(
				localized: "You re-shared",
				table: "Content",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The string for the auth user's re-share attribution row."
			)
		}
	}
	/// The string for the 'Top' sort option.
	///
	/// - Tag: L10n-top
	static var top: String {
		L10n.resolve {
			String(
				localized: "Top",
				table: "Content",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The string for the 'Top' sort option on the post activity screen."
			)
		}
	}
	/// The string for the 'Recent' sort option.
	///
	/// - Tag: L10n-recent
	static var recent: String {
		L10n.resolve {
			String(
				localized: "Recent",
				table: "Content",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The string for the 'Recent' sort option on the post activity screen."
			)
		}
	}
	/// The empty-state headline for the Quotes tab.
	///
	/// - Tag: L10n-noQuotesHeadline
	static var noQuotesHeadline: String {
		L10n.resolve {
			String(
				localized: "No Quotes",
				table: "Content",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The empty-state headline for the Quotes tab on the post activity screen."
			)
		}
	}
	/// The empty-state subheadline for the Quotes tab.
	///
	/// - Tag: L10n-noQuotesSubheadline
	static var noQuotesSubheadline: String {
		L10n.resolve {
			String(
				localized: "Add your take when sharing someone else's post and it'll show up here.",
				table: "Content",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The empty-state subheadline for the Quotes tab on the post activity screen."
			)
		}
	}
	/// The empty-state headline for the Re-shares tab.
	///
	/// - Tag: L10n-amplifyPostsHeadline
	static var amplifyPostsHeadline: String {
		L10n.resolve {
			String(
				localized: "Amplify posts you like",
				table: "Content",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The empty-state headline for the Re-shares tab on the post activity screen."
			)
		}
	}
	/// The empty-state subheadline for the Re-shares tab.
	///
	/// - Tag: L10n-amplifyPostsSubheadline
	static var amplifyPostsSubheadline: String {
		L10n.resolve {
			String(
				localized: "Share someone else's post on your timeline by reposting it. When you do, it'll show up here.",
				table: "Content",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The empty-state subheadline for the Re-shares tab on the post activity screen."
			)
		}
	}
	/// The string for the 'Post' button.
	///
	/// - Tag: L10n-post
	static var post: String {
		L10n.resolve {
			String(
				localized: "Post",
				table: "Content",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The string for the 'Post' context menu option."
			)
		}
	}
	/// The string for the 'Post Message' context menu option.
	///
	/// - Tag: L10n-postMessage
	static var postMessage: String {
		L10n.resolve {
			String(
				localized: "Post Message",
				table: "Content",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The string for the 'Post Message' context menu option."
			)
		}
	}
	/// The string for the 'Delete Message' context menu option.
	///
	/// - Tag: L10n-deleteMessage
	static var deleteMessage: String {
		L10n.resolve {
			String(
				localized: "Delete Message",
				table: "Content",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The string for the 'Delete Message' context menu option."
			)
		}
	}
	/// The headline string for the off-topic content warning pop-up.
	///
	/// - Tag: L10n-offTopicWarningHeadline
	static var offTopicWarningHeadline: String {
		L10n.resolve {
			String(
				localized: "Is this a 'where to watch' question?",
				table: "Content",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The headline string for the off-topic content warning pop-up."
			)
		}
	}
	/// The subheadline string for the off-topic content warning pop-up.
	///
	/// - Tag: L10n-offTopicWarningSubheadline
	static var offTopicWarningSubheadline: String {
		L10n.resolve {
			String(
				localized: "Kurozora is for tracking your progress, it doesn't stream or host content. Posts asking where to watch or read often go unanswered. You can still post if you'd like.",
				table: "Content",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The subheadline string for the off-topic content warning pop-up."
			)
		}
	}
	/// The action string for opening the community guidelines from the off-topic warning.
	///
	/// - Tag: L10n-offTopicViewGuidelines
	static var offTopicViewGuidelines: String {
		L10n.resolve {
			String(
				localized: "View Guidelines",
				table: "Content",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The action string for opening the community guidelines from the off-topic warning."
			)
		}
	}
	/// The destructive action string for proceeding with an off-topic post anyway.
	///
	/// - Tag: L10n-offTopicPostAnyway
	static var offTopicPostAnyway: String {
		L10n.resolve {
			String(
				localized: "Post Anyway",
				table: "Content",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The destructive action string for proceeding with an off-topic post anyway."
			)
		}
	}
	/// The string for the 'Show Replies' context menu option.
	///
	/// - Tag: L10n-showReplies
	static var showReplies: String {
		L10n.resolve {
			String(
				localized: "Show Replies",
				table: "Content",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The string for the 'Show Replies' context menu option."
			)
		}
	}
	/// The string for the 'Share Message' context menu option.
	///
	/// - Tag: L10n-shareMessage
	static var shareMessage: String {
		L10n.resolve {
			String(
				localized: "Share Message",
				table: "Content",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The string for the 'Share Message' context menu option."
			)
		}
	}
	/// The string for the 'Report Message' context menu option.
	///
	/// - Tag: L10n-reportMessage
	static var reportMessage: String {
		L10n.resolve {
			String(
				localized: "Report Message",
				table: "Content",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The string for the 'Report Message' context menu option."
			)
		}
	}

	// MARK: - Review
	/// The headline string for the report review pop-up.
	///
	/// - Tag: L10n-reviewReportedHeadline
	static var reviewReportedHeadline: String {
		L10n.resolve {
			String(
				localized: "Review Reported",
				table: "Content",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The headline string for the report review pop-up"
			)
		}
	}
	/// The subheadline string for the report review pop-up.
	///
	/// - Tag: L10n-reviewReportedSubheadline
	static var reviewReportedSubheadline: String {
		L10n.resolve {
			String(
				localized: "Thank you for helping keep the community safe.",
				table: "Content",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The subheadline string for the report review pop-up"
			)
		}
	}
	/// The subheadline string for the delete review pop-up.
	///
	/// - Tag: L10n-deleteReviewSubheadline
	static var deleteReviewSubheadline: String {
		L10n.resolve {
			String(
				localized: "Review will be deleted permanently.",
				table: "Content",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The subheadline string for the delete review pop-up"
			)
		}
	}
	/// The string for the 'Delete Review' context menu option.
	///
	/// - Tag: L10n-deleteReview
	static var deleteReview: String {
		L10n.resolve {
			String(
				localized: "Delete Review",
				table: "Content",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The string for the 'Delete Review' context menu option."
			)
		}
	}
	/// The string for the 'Update Review' context menu option.
	///
	/// - Tag: L10n-updateReview
	static var updateReview: String {
		L10n.resolve {
			String(
				localized: "Update Review",
				table: "Content",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The string for the 'Update Review' context menu option."
			)
		}
	}
	/// The title string for the confirmation dialog when clearing a rating or deleting a review.
	///
	/// - Tag: L10n-deleteRatingConfirmationTitle
	static var deleteRatingConfirmationTitle: String {
		L10n.resolve {
			String(
				localized: "Delete Rating?",
				table: "Content",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The title string for the confirmation dialog when the user clears their rating or deletes their review."
			)
		}
	}
	/// The body string for the confirmation dialog when clearing a rating or deleting a review.
	///
	/// - Tag: L10n-deleteRatingConfirmationMessage
	static var deleteRatingConfirmationMessage: String {
		L10n.resolve {
			String(
				localized: "Your rating and review will be removed.",
				table: "Content",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The body string for the confirmation dialog when the user clears their rating or deletes their review."
			)
		}
	}
	/// The string for the 'Share Review' context menu option.
	///
	/// - Tag: L10n-shareReview
	static var shareReview: String {
		L10n.resolve {
			String(
				localized: "Share Review",
				table: "Content",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The string for the 'Share Review' context menu option."
			)
		}
	}
	/// The string for the 'Report Review' context menu option.
	///
	/// - Tag: L10n-reportReview
	static var reportReview: String {
		L10n.resolve {
			String(
				localized: "Report Review",
				table: "Content",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The string for the 'Report Review' context menu option."
			)
		}
	}

	// MARK: - Browse
	/// The string for the 'top anime' browse option.
	///
	/// - Tag: L10n-topAnime
	static var topAnime: String {
		L10n.resolve {
			String(
				localized: "Top Anime",
				table: "Content",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The string for the 'top anime' browse option."
			)
		}
	}
	/// The string for the 'top airing' browse option.
	///
	/// - Tag: L10n-topAiring
	static var topAiring: String {
		L10n.resolve {
			String(
				localized: "Top Airing",
				table: "Content",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The string for the 'top airing' browse option."
			)
		}
	}
	/// The string for the 'top upcoming' browse option.
	///
	/// - Tag: L10n-topUpcoming
	static var topUpcoming: String {
		L10n.resolve {
			String(
				localized: "Top Upcoming",
				table: "Content",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The string for the 'top upcoming' browse option."
			)
		}
	}
	/// The string for the 'top tv series' browse option.
	///
	/// - Tag: L10n-topTVSeries
	static var topTVSeries: String {
		L10n.resolve {
			String(
				localized: "Top TV Series",
				table: "Content",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The string for the 'top tv series' browse option."
			)
		}
	}
	/// The string for the 'top movies' browse option.
	///
	/// - Tag: L10n-topMovies
	static var topMovies: String {
		L10n.resolve {
			String(
				localized: "Top Movies",
				table: "Content",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The string for the 'top movies' browse option."
			)
		}
	}
	/// The string for the 'top ova' browse option.
	///
	/// - Tag: L10n-topOVA
	static var topOVA: String {
		L10n.resolve {
			String(
				localized: "Top OVA",
				table: "Content",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The string for the 'top ova' browse option."
			)
		}
	}
	/// The string for the 'top specials' browse option.
	///
	/// - Tag: L10n-topSpecials
	static var topSpecials: String {
		L10n.resolve {
			String(
				localized: "Top Specials",
				table: "Content",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The string for the 'top specials' browse option."
			)
		}
	}
	/// The string for the 'just added' browse option.
	///
	/// - Tag: L10n-justAdded
	static var justAdded: String {
		L10n.resolve {
			String(
				localized: "Just Added",
				table: "Content",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The string for the 'just added' browse option."
			)
		}
	}
	/// The string for the 'most popular' browse option.
	///
	/// - Tag: L10n-mostPopular
	static var mostPopular: String {
		L10n.resolve {
			String(
				localized: "Most Popular",
				table: "Content",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The string for the 'most popular' browse option."
			)
		}
	}
	/// The string for the 'trending' browse option.
	///
	/// - Tag: L10n-trending
	static var trending: String {
		L10n.resolve {
			String(
				localized: "Trending",
				table: "Content",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The string for the 'trending' browse option."
			)
		}
	}
	/// The string for the 'most anticipated' browse option.
	///
	/// - Tag: L10n-mostAnticipated
	static var mostAnticipated: String {
		L10n.resolve {
			String(
				localized: "Most Anticipated",
				table: "Content",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The string for the 'most anticipated' browse option."
			)
		}
	}
	/// The string for the 'advanced search' browse option.
	///
	/// - Tag: L10n-advancedSearch
	static var advancedSearch: String {
		L10n.resolve {
			String(
				localized: "Advanced Search",
				table: "Content",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The string for the 'advanced search' browse option."
			)
		}
	}

	// MARK: - Episode
	/// The string for the 'see also' section.
	///
	/// - Tag: L10n-seeAlso
	static var seeAlso: String {
		L10n.resolve {
			String(
				localized: "See Also",
				table: "Content",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The string for the 'see also' section."
			)
		}
	}

	// MARK: - Rating
	/// The string for the rating failed title.
	///
	/// - Tag: L10n-ratingFailed
	static var ratingFailed: String {
		L10n.resolve {
			String(
				localized: "Rating Failed",
				table: "Content",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The string for the 'rating failed' section."
			)
		}
	}
	/// The string for can't save review description.
	///
	/// - Tag: L10n-cantSaveReview
	static var cantSaveReview: String {
		L10n.resolve {
			String(
				localized: "Can’t Save Review 😔",
				table: "Content",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The string for can't save review description."
			)
		}
	}
	/// The string for the rating submitted description.
	///
	/// - Tag: L10n-thankYouForRating
	static var thankYouForRating: String {
		L10n.resolve {
			String(
				localized: "Thank you for rating.",
				table: "Content",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The string for the rating submitted description."
			)
		}
	}

	// MARK: - Ratings
	/// The string for the word 'ratings'.
	///
	/// - Tag: L10n-ratings
	static var ratings: String {
		L10n.resolve {
			String(
				localized: "Ratings",
				table: "Content",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The string for the word 'ratings'."
			)
		}
	}
	/// The string for the word 'rating'.
	///
	/// - Tag: L10n-rating
	static var rating: String {
		L10n.resolve {
			String(
				localized: "Rating",
				table: "Content",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "Noun. The user's star rating score, not the age rating."
			)
		}
	}
	/// The string for the word 'ratings & reviews'.
	///
	/// - Tag: L10n-ratingsAndReviews
	static var ratingsAndReviews: String {
		L10n.resolve {
			String(
				localized: "Ratings & Reviews",
				table: "Content",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The string for the word 'ratings & reviews'."
			)
		}
	}
	/// The string for the word 'tap to rate'.
	///
	/// - Tag: L10n-tapToRate
	static var tapToRate: String {
		L10n.resolve {
			String(
				localized: "Tap to Rate:",
				table: "Content",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The string for the word 'tap to rate'."
			)
		}
	}
	/// The string for the word 'click to rate'.
	///
	/// - Tag: L10n-clickToRate
	static var clickToRate: String {
		L10n.resolve {
			String(
				localized: "Click to Rate:",
				table: "Content",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The string for the word 'click to rate'."
			)
		}
	}
	/// The string for the word 'write a review'.
	///
	/// - Tag: L10n-writeAReview
	static var writeAReview: String {
		L10n.resolve {
			String(
				localized: "Write a Review",
				table: "Content",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The string for the word 'write a review'."
			)
		}
	}
	/// The heading of the review field.
	///
	/// - Tag: L10n-review
	static var review: String {
		L10n.resolve {
			String(
				localized: "Review",
				table: "Content",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The heading of the review field."
			)
		}
	}
	/// The heading of the private note field.
	///
	/// - Tag: L10n-privateNotes
	static var privateNotes: String {
		L10n.resolve {
			String(
				localized: "Private Notes",
				table: "Content",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The heading of the private note field."
			)
		}
	}
	/// The destructive action that removes the user's rating.
	///
	/// - Tag: L10n-deleteRating
	static var deleteRating: String {
		L10n.resolve {
			String(
				localized: "Delete Rating",
				table: "Content",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The destructive action that removes the user's rating."
			)
		}
	}
	/// The label of the negative emoji reaction.
	///
	/// - Tag: L10n-emojiScoreDisliked
	static var emojiScoreDisliked: String {
		L10n.resolve {
			String(
				localized: "Disliked it",
				table: "Content",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The label of the negative emoji reaction."
			)
		}
	}
	/// The label of the indifferent emoji reaction.
	///
	/// - Tag: L10n-emojiScoreNeutral
	static var emojiScoreNeutral: String {
		L10n.resolve {
			String(
				localized: "It was okay",
				table: "Content",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The label of the indifferent emoji reaction."
			)
		}
	}
	/// The label of the positive emoji reaction.
	///
	/// - Tag: L10n-emojiScoreLiked
	static var emojiScoreLiked: String {
		L10n.resolve {
			String(
				localized: "Loved it",
				table: "Content",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The label of the positive emoji reaction."
			)
		}
	}
	/// The score of a rating category out of ten.
	///
	/// - Tag: L10n-scoreOutOfTen
	static func scoreOutOfTen(_ score: String) -> String {
		L10n.resolve {
			String(
				localized: "ratingCategory.scoreOutOfTen",
				defaultValue: "\(score) / 10.0",
				table: "Content",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The score of a rating category out of ten."
			)
		}
	}
	/// The rating denominator shown beneath an average score.
	///
	/// - Tag: L10n-outOfFive
	static var outOfFive: String {
		L10n.resolve {
			String(
				localized: "out of 5",
				table: "Content",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The rating denominator shown beneath an average score, as in '4.2 out of 5'."
			)
		}
	}
	/// The footnote for how long ago a studio was founded.
	///
	/// - Tag: L10n-studioFoundedYearsAgo
	static func studioFoundedYearsAgo(_ years: Int) -> String {
		L10n.resolve {
			String(
				localized: "The studio was founded \(years) years ago.",
				table: "Content",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "Footnote on the studio detail header for how long ago the studio was founded."
			)
		}
	}
	/// The footnote for how long a studio has been defunct.
	///
	/// - Tag: L10n-studioDefunctForYears
	static func studioDefunctForYears(_ years: Int) -> String {
		L10n.resolve {
			String(
				localized: "The studio has been defunct for \(years) years.",
				table: "Content",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "Footnote on the studio detail header for how long the studio has been defunct."
			)
		}
	}

	// MARK: - Media Details
	/// The label for the source material of a title.
	///
	/// - Tag: L10n-source
	static var source: String {
		L10n.resolve {
			String(localized: "Source", table: "Content", bundle: LanguageManager.shared.bundle, locale: LanguageManager.shared.locale, comment: "The label for the source material of a title.")
		}
	}
	/// The label for a show's broadcast schedule.
	///
	/// - Tag: L10n-broadcast
	static var broadcast: String {
		L10n.resolve {
			String(localized: "Broadcast", table: "Content", bundle: LanguageManager.shared.bundle, locale: LanguageManager.shared.locale, comment: "The label for a show's broadcast schedule.")
		}
	}
	/// The label for a title's country of origin.
	///
	/// - Tag: L10n-countryOfOrigin
	static var countryOfOrigin: String {
		L10n.resolve {
			String(localized: "Country of Origin", table: "Content", bundle: LanguageManager.shared.bundle, locale: LanguageManager.shared.locale, comment: "The label for a title's country of origin.")
		}
	}
	/// The singular label for a title's language.
	///
	/// - Tag: L10n-languageSingular
	static var languageSingular: String {
		L10n.resolve {
			String(localized: "Language", table: "Content", bundle: LanguageManager.shared.bundle, locale: LanguageManager.shared.locale, comment: "The singular label for a title's language.")
		}
	}
	/// The label for a title's publication schedule.
	///
	/// - Tag: L10n-publication
	static var publication: String {
		L10n.resolve {
			String(localized: "Publication", table: "Content", bundle: LanguageManager.shared.bundle, locale: LanguageManager.shared.locale, comment: "The label for a title's publication schedule.")
		}
	}
	/// The label for a title's publication dates.
	///
	/// - Tag: L10n-published
	static var published: String {
		L10n.resolve {
			String(localized: "Published", table: "Content", bundle: LanguageManager.shared.bundle, locale: LanguageManager.shared.locale, comment: "The label for a title's publication dates.")
		}
	}
	/// The singular word for a manga volume.
	///
	/// - Tag: L10n-volume
	static var volume: String {
		L10n.resolve {
			String(localized: "Volume", table: "Content", bundle: LanguageManager.shared.bundle, locale: LanguageManager.shared.locale, comment: "The singular word for a manga volume.")
		}
	}
	/// The singular word for a game edition.
	///
	/// - Tag: L10n-edition
	static var edition: String {
		L10n.resolve {
			String(localized: "Edition", table: "Content", bundle: LanguageManager.shared.bundle, locale: LanguageManager.shared.locale, comment: "The singular word for a game edition.")
		}
	}
	/// The label shown when one more language is available.
	///
	/// - Tag: L10n-oneMoreLanguage
	static var oneMoreLanguage: String {
		L10n.resolve {
			String(localized: "+1 More Language", table: "Content", bundle: LanguageManager.shared.bundle, locale: LanguageManager.shared.locale, comment: "The label shown when one more language is available.")
		}
	}
	/// The label shown when several more languages are available.
	///
	/// - Tag: L10n-moreLanguages
	static func moreLanguages(_ count: Int) -> String {
		L10n.resolve {
			String(localized: "+\(count) More Languages", table: "Content", bundle: LanguageManager.shared.bundle, locale: LanguageManager.shared.locale, comment: "The label shown when several more languages are available.")
		}
	}
	/// The footnote summarizing how content is spread across units.
	///
	/// - Tag: L10n-across
	static func across(_ summary: String) -> String {
		L10n.resolve {
			String(localized: "Across \(summary).", table: "Content", bundle: LanguageManager.shared.bundle, locale: LanguageManager.shared.locale, comment: "The footnote summarizing how content is spread across units, as in 'Across 5 seasons.'.")
		}
	}
	/// The footnote stating the total duration.
	///
	/// - Tag: L10n-withTotalOf
	static func withTotalOf(_ value: String) -> String {
		L10n.resolve {
			String(localized: "With a total of \(value).", table: "Content", bundle: LanguageManager.shared.bundle, locale: LanguageManager.shared.locale, comment: "The footnote stating the total duration of a title.")
		}
	}
	/// The footnote shown when a show has finished broadcasting.
	///
	/// - Tag: L10n-broadcastEnded
	static var broadcastEnded: String {
		L10n.resolve {
			String(localized: "The broadcasting of this series has ended.", table: "Content", bundle: LanguageManager.shared.bundle, locale: LanguageManager.shared.locale, comment: "The footnote shown when a show has finished broadcasting.")
		}
	}
	/// The footnote shown when no broadcast data is available.
	///
	/// - Tag: L10n-noBroadcastData
	static var noBroadcastData: String {
		L10n.resolve {
			String(localized: "No broadcast data available at the moment.", table: "Content", bundle: LanguageManager.shared.bundle, locale: LanguageManager.shared.locale, comment: "The footnote shown when no broadcast data is available.")
		}
	}
	/// The footnote shown when a title has finished publication.
	///
	/// - Tag: L10n-publicationEnded
	static var publicationEnded: String {
		L10n.resolve {
			String(localized: "The publication of this series has ended.", table: "Content", bundle: LanguageManager.shared.bundle, locale: LanguageManager.shared.locale, comment: "The footnote shown when a title has finished publication.")
		}
	}
	/// The footnote shown when no publication data is available.
	///
	/// - Tag: L10n-noPublicationData
	static var noPublicationData: String {
		L10n.resolve {
			String(localized: "No publication data available at the moment.", table: "Content", bundle: LanguageManager.shared.bundle, locale: LanguageManager.shared.locale, comment: "The footnote shown when no publication data is available.")
		}
	}
	/// The footnote showing an episode's position in the current season.
	///
	/// - Tag: L10n-episodeInCurrentSeason
	static func episodeInCurrentSeason(_ number: Int) -> String {
		L10n.resolve {
			String(localized: "#\(number) in the current season.", table: "Content", bundle: LanguageManager.shared.bundle, locale: LanguageManager.shared.locale, comment: "The footnote showing an episode's position in the current season.")
		}
	}
	/// The footnote shown when an episode will air on its announced date.
	///
	/// - Tag: L10n-episodeWillAir
	static var episodeWillAir: String {
		L10n.resolve {
			String(localized: "The episode will air on the announced date.", table: "Content", bundle: LanguageManager.shared.bundle, locale: LanguageManager.shared.locale, comment: "The footnote shown when an episode will air on its announced date.")
		}
	}
	/// The footnote shown when an episode has finished airing.
	///
	/// - Tag: L10n-episodeFinishedAiring
	static var episodeFinishedAiring: String {
		L10n.resolve {
			String(localized: "The episode has finished airing.", table: "Content", bundle: LanguageManager.shared.bundle, locale: LanguageManager.shared.locale, comment: "The footnote shown when an episode has finished airing.")
		}
	}
	/// The footnote shown when an episode's release date is unannounced.
	///
	/// - Tag: L10n-episodeReleaseDateTBA
	static var episodeReleaseDateTBA: String {
		L10n.resolve {
			String(localized: "A release date has yet to be announced.", table: "Content", bundle: LanguageManager.shared.bundle, locale: LanguageManager.shared.locale, comment: "The footnote shown when an episode's release date is unannounced.")
		}
	}
	/// The footnote describing a character's status.
	///
	/// - Tag: L10n-characterStatusFootnote
	static func characterStatusFootnote(_ status: String) -> String {
		L10n.resolve {
			String(localized: "The character is \(status).", table: "Content", bundle: LanguageManager.shared.bundle, locale: LanguageManager.shared.locale, comment: "The footnote describing a character's status, where the placeholder is the localized status.")
		}
	}

	// MARK: - Search Filters
	/// The 'NSFW' search filter label.
	///
	/// - Tag: L10n-nsfw
	static var nsfw: String {
		L10n.resolve {
			String(localized: "NSFW", table: "Content", bundle: LanguageManager.shared.bundle, locale: LanguageManager.shared.locale, comment: "The 'NSFW' search filter label.")
		}
	}
	/// The 'Media Type' search filter label.
	///
	/// - Tag: L10n-mediaType
	static var mediaType: String {
		L10n.resolve {
			String(localized: "Media Type", table: "Content", bundle: LanguageManager.shared.bundle, locale: LanguageManager.shared.locale, comment: "The 'Media Type' search filter label.")
		}
	}
	/// The 'Publication Season' search filter label.
	///
	/// - Tag: L10n-publicationSeason
	static var publicationSeason: String {
		L10n.resolve {
			String(localized: "Publication Season", table: "Content", bundle: LanguageManager.shared.bundle, locale: LanguageManager.shared.locale, comment: "The 'Publication Season' search filter label.")
		}
	}
	/// The 'Publication Day' search filter label.
	///
	/// - Tag: L10n-publicationDay
	static var publicationDay: String {
		L10n.resolve {
			String(localized: "Publication Day", table: "Content", bundle: LanguageManager.shared.bundle, locale: LanguageManager.shared.locale, comment: "The 'Publication Day' search filter label.")
		}
	}
	/// The 'Last Aired' search filter label.
	///
	/// - Tag: L10n-lastAired
	static var lastAired: String {
		L10n.resolve {
			String(localized: "Last Aired", table: "Content", bundle: LanguageManager.shared.bundle, locale: LanguageManager.shared.locale, comment: "The 'Last Aired' search filter label.")
		}
	}
	/// The 'First Published' search filter label.
	///
	/// - Tag: L10n-firstPublished
	static var firstPublished: String {
		L10n.resolve {
			String(localized: "First Published", table: "Content", bundle: LanguageManager.shared.bundle, locale: LanguageManager.shared.locale, comment: "The 'First Published' search filter label.")
		}
	}
	/// The 'First Aired' search filter label.
	///
	/// - Tag: L10n-firstAired
	static var firstAired: String {
		L10n.resolve {
			String(localized: "First Aired", table: "Content", bundle: LanguageManager.shared.bundle, locale: LanguageManager.shared.locale, comment: "The 'First Aired' search filter label.")
		}
	}
	/// The 'Astrological Sign' search filter label.
	///
	/// - Tag: L10n-astrologicalSign
	static var astrologicalSign: String {
		L10n.resolve {
			String(localized: "Astrological Sign", table: "Content", bundle: LanguageManager.shared.bundle, locale: LanguageManager.shared.locale, comment: "The 'Astrological Sign' search filter label.")
		}
	}
	/// The 'Weight' search filter label.
	///
	/// - Tag: L10n-weight
	static var weight: String {
		L10n.resolve {
			String(localized: "Weight", table: "Content", bundle: LanguageManager.shared.bundle, locale: LanguageManager.shared.locale, comment: "The 'Weight' search filter label.")
		}
	}
	/// The 'Waist' search filter label.
	///
	/// - Tag: L10n-waist
	static var waist: String {
		L10n.resolve {
			String(localized: "Waist", table: "Content", bundle: LanguageManager.shared.bundle, locale: LanguageManager.shared.locale, comment: "The 'Waist' search filter label.")
		}
	}
	/// The 'Specials' search filter label.
	///
	/// - Tag: L10n-specials
	static var specials: String {
		L10n.resolve {
			String(localized: "Specials", table: "Content", bundle: LanguageManager.shared.bundle, locale: LanguageManager.shared.locale, comment: "The 'Specials' search filter label.")
		}
	}
	/// The 'Publication Time' search filter label.
	///
	/// - Tag: L10n-publicationTime
	static var publicationTime: String {
		L10n.resolve {
			String(localized: "Publication Time", table: "Content", bundle: LanguageManager.shared.bundle, locale: LanguageManager.shared.locale, comment: "The 'Publication Time' search filter label.")
		}
	}
	/// The 'Premieres' search filter label.
	///
	/// - Tag: L10n-premieres
	static var premieres: String {
		L10n.resolve {
			String(localized: "Premieres", table: "Content", bundle: LanguageManager.shared.bundle, locale: LanguageManager.shared.locale, comment: "The 'Premieres' search filter label.")
		}
	}
	/// The 'Pages' search filter label.
	///
	/// - Tag: L10n-pages
	static var pages: String {
		L10n.resolve {
			String(localized: "Pages", table: "Content", bundle: LanguageManager.shared.bundle, locale: LanguageManager.shared.locale, comment: "The 'Pages' search filter label.")
		}
	}
	/// The 'Number Total' search filter label.
	///
	/// - Tag: L10n-numberTotal
	static var numberTotal: String {
		L10n.resolve {
			String(localized: "Number Total", table: "Content", bundle: LanguageManager.shared.bundle, locale: LanguageManager.shared.locale, comment: "The 'Number Total' search filter label.")
		}
	}
	/// The 'Last Published' search filter label.
	///
	/// - Tag: L10n-lastPublished
	static var lastPublished: String {
		L10n.resolve {
			String(localized: "Last Published", table: "Content", bundle: LanguageManager.shared.bundle, locale: LanguageManager.shared.locale, comment: "The 'Last Published' search filter label.")
		}
	}
	/// The 'Hip' search filter label.
	///
	/// - Tag: L10n-hip
	static var hip: String {
		L10n.resolve {
			String(localized: "Hip", table: "Content", bundle: LanguageManager.shared.bundle, locale: LanguageManager.shared.locale, comment: "The 'Hip' search filter label.")
		}
	}
	/// The 'Height' search filter label.
	///
	/// - Tag: L10n-height
	static var height: String {
		L10n.resolve {
			String(localized: "Height", table: "Content", bundle: LanguageManager.shared.bundle, locale: LanguageManager.shared.locale, comment: "The 'Height' search filter label.")
		}
	}
	/// The 'Finales' search filter label.
	///
	/// - Tag: L10n-finales
	static var finales: String {
		L10n.resolve {
			String(localized: "Finales", table: "Content", bundle: LanguageManager.shared.bundle, locale: LanguageManager.shared.locale, comment: "The 'Finales' search filter label.")
		}
	}
	/// The 'Fillers' search filter label.
	///
	/// - Tag: L10n-fillers
	static var fillers: String {
		L10n.resolve {
			String(localized: "Fillers", table: "Content", bundle: LanguageManager.shared.bundle, locale: LanguageManager.shared.locale, comment: "The 'Fillers' search filter label.")
		}
	}
	/// The 'Deceased Date' search filter label.
	///
	/// - Tag: L10n-deceasedDate
	static var deceasedDate: String {
		L10n.resolve {
			String(localized: "Deceased Date", table: "Content", bundle: LanguageManager.shared.bundle, locale: LanguageManager.shared.locale, comment: "The 'Deceased Date' search filter label.")
		}
	}
	/// The 'Bust' search filter label.
	///
	/// - Tag: L10n-bust
	static var bust: String {
		L10n.resolve {
			String(localized: "Bust", table: "Content", bundle: LanguageManager.shared.bundle, locale: LanguageManager.shared.locale, comment: "The 'Bust' search filter label.")
		}
	}
	/// The 'Birth Month' search filter label.
	///
	/// - Tag: L10n-birthMonth
	static var birthMonth: String {
		L10n.resolve {
			String(localized: "Birth Month", table: "Content", bundle: LanguageManager.shared.bundle, locale: LanguageManager.shared.locale, comment: "The 'Birth Month' search filter label.")
		}
	}
	/// The 'Birth Day' search filter label.
	///
	/// - Tag: L10n-birthDay
	static var birthDay: String {
		L10n.resolve {
			String(localized: "Birth Day", table: "Content", bundle: LanguageManager.shared.bundle, locale: LanguageManager.shared.locale, comment: "The 'Birth Day' search filter label.")
		}
	}
	/// The 'Birth Date' search filter label.
	///
	/// - Tag: L10n-birthDate
	static var birthDate: String {
		L10n.resolve {
			String(localized: "Birth Date", table: "Content", bundle: LanguageManager.shared.bundle, locale: LanguageManager.shared.locale, comment: "The 'Birth Date' search filter label.")
		}
	}
	/// The 'Air Time' search filter label.
	///
	/// - Tag: L10n-airTime
	static var airTime: String {
		L10n.resolve {
			String(localized: "Air Time", table: "Content", bundle: LanguageManager.shared.bundle, locale: LanguageManager.shared.locale, comment: "The 'Air Time' search filter label.")
		}
	}
	/// The 'Air Season' search filter label.
	///
	/// - Tag: L10n-airSeason
	static var airSeason: String {
		L10n.resolve {
			String(localized: "Air Season", table: "Content", bundle: LanguageManager.shared.bundle, locale: LanguageManager.shared.locale, comment: "The 'Air Season' search filter label.")
		}
	}
	/// The 'Air Day' search filter label.
	///
	/// - Tag: L10n-airDay
	static var airDay: String {
		L10n.resolve {
			String(localized: "Air Day", table: "Content", bundle: LanguageManager.shared.bundle, locale: LanguageManager.shared.locale, comment: "The 'Air Day' search filter label.")
		}
	}
	/// The 'Age (years)' search filter label.
	///
	/// - Tag: L10n-ageYears
	static var ageYears: String {
		L10n.resolve {
			String(localized: "Age (years)", table: "Content", bundle: LanguageManager.shared.bundle, locale: LanguageManager.shared.locale, comment: "The 'Age (years)' search filter label.")
		}
	}
	/// The 'Address' search filter label.
	///
	/// - Tag: L10n-address
	static var address: String {
		L10n.resolve {
			String(localized: "Address", table: "Content", bundle: LanguageManager.shared.bundle, locale: LanguageManager.shared.locale, comment: "The 'Address' search filter label.")
		}
	}
	/// The 'Duration (minutes)' search filter label.
	///
	/// - Tag: L10n-durationMinutes
	static var durationMinutes: String {
		L10n.resolve {
			String(localized: "Duration (minutes)", table: "Content", bundle: LanguageManager.shared.bundle, locale: LanguageManager.shared.locale, comment: "The 'Duration (minutes)' search filter label.")
		}
	}
	/// The 'Shown' filter option label.
	///
	/// - Tag: L10n-shown
	static var shown: String {
		L10n.resolve {
			String(localized: "Shown", table: "Content", bundle: LanguageManager.shared.bundle, locale: LanguageManager.shared.locale, comment: "The 'Shown' filter option label.")
		}
	}
	/// The 'Hidden' filter option label.
	///
	/// - Tag: L10n-hidden
	static var hidden: String {
		L10n.resolve {
			String(localized: "Hidden", table: "Content", bundle: LanguageManager.shared.bundle, locale: LanguageManager.shared.locale, comment: "The 'Hidden' filter option label.")
		}
	}

	// MARK: - Enum Values
	/// The display value 'To Be Announced'.
	///
	/// - Tag: L10n-toBeAnnounced
	static var toBeAnnounced: String {
		L10n.resolve {
			String(localized: "To Be Announced", table: "Content", bundle: LanguageManager.shared.bundle, locale: LanguageManager.shared.locale, comment: "The display value 'To Be Announced'.")
		}
	}
	/// The display value 'Not Airing Yet'.
	///
	/// - Tag: L10n-notAiringYet
	static var notAiringYet: String {
		L10n.resolve {
			String(localized: "Not Airing Yet", table: "Content", bundle: LanguageManager.shared.bundle, locale: LanguageManager.shared.locale, comment: "The display value 'Not Airing Yet'.")
		}
	}
	/// The display value 'Currently Airing'.
	///
	/// - Tag: L10n-currentlyAiring
	static var currentlyAiring: String {
		L10n.resolve {
			String(localized: "Currently Airing", table: "Content", bundle: LanguageManager.shared.bundle, locale: LanguageManager.shared.locale, comment: "The display value 'Currently Airing'.")
		}
	}
	/// The display value 'Finished Airing'.
	///
	/// - Tag: L10n-finishedAiring
	static var finishedAiring: String {
		L10n.resolve {
			String(localized: "Finished Airing", table: "Content", bundle: LanguageManager.shared.bundle, locale: LanguageManager.shared.locale, comment: "The display value 'Finished Airing'.")
		}
	}
	/// The display value 'On Hiatus'.
	///
	/// - Tag: L10n-onHiatus
	static var onHiatus: String {
		L10n.resolve {
			String(localized: "On Hiatus", table: "Content", bundle: LanguageManager.shared.bundle, locale: LanguageManager.shared.locale, comment: "The display value 'On Hiatus'.")
		}
	}
	/// The display value 'Discontinued'.
	///
	/// - Tag: L10n-discontinued
	static var discontinued: String {
		L10n.resolve {
			String(localized: "Discontinued", table: "Content", bundle: LanguageManager.shared.bundle, locale: LanguageManager.shared.locale, comment: "The display value 'Discontinued'.")
		}
	}
	/// The display value 'Not Published Yet'.
	///
	/// - Tag: L10n-notPublishedYet
	static var notPublishedYet: String {
		L10n.resolve {
			String(localized: "Not Published Yet", table: "Content", bundle: LanguageManager.shared.bundle, locale: LanguageManager.shared.locale, comment: "The display value 'Not Published Yet'.")
		}
	}
	/// The display value 'Currently Publishing'.
	///
	/// - Tag: L10n-currentlyPublishing
	static var currentlyPublishing: String {
		L10n.resolve {
			String(localized: "Currently Publishing", table: "Content", bundle: LanguageManager.shared.bundle, locale: LanguageManager.shared.locale, comment: "The display value 'Currently Publishing'.")
		}
	}
	/// The display value 'Finished Publishing'.
	///
	/// - Tag: L10n-finishedPublishing
	static var finishedPublishing: String {
		L10n.resolve {
			String(localized: "Finished Publishing", table: "Content", bundle: LanguageManager.shared.bundle, locale: LanguageManager.shared.locale, comment: "The display value 'Finished Publishing'.")
		}
	}
	/// The display value 'Alive'.
	///
	/// - Tag: L10n-alive
	static var alive: String {
		L10n.resolve {
			String(localized: "Alive", table: "Content", bundle: LanguageManager.shared.bundle, locale: LanguageManager.shared.locale, comment: "The display value 'Alive'.")
		}
	}
	/// The display value 'Deceased'.
	///
	/// - Tag: L10n-deceased
	static var deceased: String {
		L10n.resolve {
			String(localized: "Deceased", table: "Content", bundle: LanguageManager.shared.bundle, locale: LanguageManager.shared.locale, comment: "The display value 'Deceased'.")
		}
	}
	/// The display value 'Missing'.
	///
	/// - Tag: L10n-missing
	static var missing: String {
		L10n.resolve {
			String(localized: "Missing", table: "Content", bundle: LanguageManager.shared.bundle, locale: LanguageManager.shared.locale, comment: "The display value 'Missing'.")
		}
	}
	/// The display value 'TV'.
	///
	/// - Tag: L10n-tv
	static var tv: String {
		L10n.resolve {
			String(localized: "TV", table: "Content", bundle: LanguageManager.shared.bundle, locale: LanguageManager.shared.locale, comment: "The display value 'TV'.")
		}
	}
	/// The display value 'OVA'.
	///
	/// - Tag: L10n-ova
	static var ova: String {
		L10n.resolve {
			String(localized: "OVA", table: "Content", bundle: LanguageManager.shared.bundle, locale: LanguageManager.shared.locale, comment: "The display value 'OVA'.")
		}
	}
	/// The display value 'Movie'.
	///
	/// - Tag: L10n-movie
	static var movie: String {
		L10n.resolve {
			String(localized: "Movie", table: "Content", bundle: LanguageManager.shared.bundle, locale: LanguageManager.shared.locale, comment: "The display value 'Movie'.")
		}
	}
	/// The display value 'Special'.
	///
	/// - Tag: L10n-special
	static var special: String {
		L10n.resolve {
			String(localized: "Special", table: "Content", bundle: LanguageManager.shared.bundle, locale: LanguageManager.shared.locale, comment: "The display value 'Special'.")
		}
	}
	/// The display value 'ONA'.
	///
	/// - Tag: L10n-ona
	static var ona: String {
		L10n.resolve {
			String(localized: "ONA", table: "Content", bundle: LanguageManager.shared.bundle, locale: LanguageManager.shared.locale, comment: "The display value 'ONA'.")
		}
	}
	/// The display value 'Music'.
	///
	/// - Tag: L10n-music
	static var music: String {
		L10n.resolve {
			String(localized: "Music", table: "Content", bundle: LanguageManager.shared.bundle, locale: LanguageManager.shared.locale, comment: "The display value 'Music'.")
		}
	}
	/// The display value 'DLC'.
	///
	/// - Tag: L10n-dlc
	static var dlc: String {
		L10n.resolve {
			String(localized: "DLC", table: "Content", bundle: LanguageManager.shared.bundle, locale: LanguageManager.shared.locale, comment: "The display value 'DLC'.")
		}
	}
	/// The display value 'MOD'.
	///
	/// - Tag: L10n-mod
	static var mod: String {
		L10n.resolve {
			String(localized: "MOD", table: "Content", bundle: LanguageManager.shared.bundle, locale: LanguageManager.shared.locale, comment: "The display value 'MOD'.")
		}
	}
	/// The display value 'Full Game'.
	///
	/// - Tag: L10n-fullGame
	static var fullGame: String {
		L10n.resolve {
			String(localized: "Full Game", table: "Content", bundle: LanguageManager.shared.bundle, locale: LanguageManager.shared.locale, comment: "The display value 'Full Game'.")
		}
	}
	/// The display value 'Manga'.
	///
	/// - Tag: L10n-manga
	static var manga: String {
		L10n.resolve {
			String(localized: "Manga", table: "Content", bundle: LanguageManager.shared.bundle, locale: LanguageManager.shared.locale, comment: "The display value 'Manga'.")
		}
	}
	/// The display value 'Game'.
	///
	/// - Tag: L10n-game
	static var game: String {
		L10n.resolve {
			String(localized: "Game", table: "Content", bundle: LanguageManager.shared.bundle, locale: LanguageManager.shared.locale, comment: "The display value 'Game'.")
		}
	}
	/// The display value 'Act'.
	///
	/// - Tag: L10n-act
	static var act: String {
		L10n.resolve {
			String(localized: "Act", table: "Content", bundle: LanguageManager.shared.bundle, locale: LanguageManager.shared.locale, comment: "The display value 'Act'.")
		}
	}
	/// The display value 'Record'.
	///
	/// - Tag: L10n-record
	static var record: String {
		L10n.resolve {
			String(localized: "Record", table: "Content", bundle: LanguageManager.shared.bundle, locale: LanguageManager.shared.locale, comment: "The display value 'Record'.")
		}
	}
	/// The display value 'Original'.
	///
	/// - Tag: L10n-original
	static var original: String {
		L10n.resolve {
			String(localized: "Original", table: "Content", bundle: LanguageManager.shared.bundle, locale: LanguageManager.shared.locale, comment: "The display value 'Original'.")
		}
	}
	/// The display value 'Book'.
	///
	/// - Tag: L10n-book
	static var book: String {
		L10n.resolve {
			String(localized: "Book", table: "Content", bundle: LanguageManager.shared.bundle, locale: LanguageManager.shared.locale, comment: "The display value 'Book'.")
		}
	}
	/// The display value 'Picture Book'.
	///
	/// - Tag: L10n-pictureBook
	static var pictureBook: String {
		L10n.resolve {
			String(localized: "Picture Book", table: "Content", bundle: LanguageManager.shared.bundle, locale: LanguageManager.shared.locale, comment: "The display value 'Picture Book'.")
		}
	}
	/// The display value 'Digital Manga'.
	///
	/// - Tag: L10n-digitalManga
	static var digitalManga: String {
		L10n.resolve {
			String(localized: "Digital Manga", table: "Content", bundle: LanguageManager.shared.bundle, locale: LanguageManager.shared.locale, comment: "The display value 'Digital Manga'.")
		}
	}
	/// The display value '4-Koma Manga'.
	///
	/// - Tag: L10n-fourKomaManga
	static var fourKomaManga: String {
		L10n.resolve {
			String(localized: "4-Koma Manga", table: "Content", bundle: LanguageManager.shared.bundle, locale: LanguageManager.shared.locale, comment: "The display value '4-Koma Manga'.")
		}
	}
	/// The display value 'Web Manga'.
	///
	/// - Tag: L10n-webManga
	static var webManga: String {
		L10n.resolve {
			String(localized: "Web Manga", table: "Content", bundle: LanguageManager.shared.bundle, locale: LanguageManager.shared.locale, comment: "The display value 'Web Manga'.")
		}
	}
	/// The display value 'Novel'.
	///
	/// - Tag: L10n-novel
	static var novel: String {
		L10n.resolve {
			String(localized: "Novel", table: "Content", bundle: LanguageManager.shared.bundle, locale: LanguageManager.shared.locale, comment: "The display value 'Novel'.")
		}
	}
	/// The display value 'Light Novel'.
	///
	/// - Tag: L10n-lightNovel
	static var lightNovel: String {
		L10n.resolve {
			String(localized: "Light Novel", table: "Content", bundle: LanguageManager.shared.bundle, locale: LanguageManager.shared.locale, comment: "The display value 'Light Novel'.")
		}
	}
	/// The display value 'Visual Novel'.
	///
	/// - Tag: L10n-visualNovel
	static var visualNovel: String {
		L10n.resolve {
			String(localized: "Visual Novel", table: "Content", bundle: LanguageManager.shared.bundle, locale: LanguageManager.shared.locale, comment: "The display value 'Visual Novel'.")
		}
	}
	/// The display value 'Card Game'.
	///
	/// - Tag: L10n-cardGame
	static var cardGame: String {
		L10n.resolve {
			String(localized: "Card Game", table: "Content", bundle: LanguageManager.shared.bundle, locale: LanguageManager.shared.locale, comment: "The display value 'Card Game'.")
		}
	}
	/// The display value 'Radio'.
	///
	/// - Tag: L10n-radio
	static var radio: String {
		L10n.resolve {
			String(localized: "Radio", table: "Content", bundle: LanguageManager.shared.bundle, locale: LanguageManager.shared.locale, comment: "The display value 'Radio'.")
		}
	}
	/// The display value 'Web novel'.
	///
	/// - Tag: L10n-webNovel
	static var webNovel: String {
		L10n.resolve {
			String(localized: "Web novel", table: "Content", bundle: LanguageManager.shared.bundle, locale: LanguageManager.shared.locale, comment: "The display value 'Web novel'.")
		}
	}
	/// The display value 'Mixed media'.
	///
	/// - Tag: L10n-mixedMedia
	static var mixedMedia: String {
		L10n.resolve {
			String(localized: "Mixed media", table: "Content", bundle: LanguageManager.shared.bundle, locale: LanguageManager.shared.locale, comment: "The display value 'Mixed media'.")
		}
	}
	/// The display value 'Aries'.
	///
	/// - Tag: L10n-aries
	static var aries: String {
		L10n.resolve {
			String(localized: "Aries", table: "Content", bundle: LanguageManager.shared.bundle, locale: LanguageManager.shared.locale, comment: "The display value 'Aries'.")
		}
	}
	/// The display value 'Taurus'.
	///
	/// - Tag: L10n-taurus
	static var taurus: String {
		L10n.resolve {
			String(localized: "Taurus", table: "Content", bundle: LanguageManager.shared.bundle, locale: LanguageManager.shared.locale, comment: "The display value 'Taurus'.")
		}
	}
	/// The display value 'Gemini'.
	///
	/// - Tag: L10n-gemini
	static var gemini: String {
		L10n.resolve {
			String(localized: "Gemini", table: "Content", bundle: LanguageManager.shared.bundle, locale: LanguageManager.shared.locale, comment: "The display value 'Gemini'.")
		}
	}
	/// The display value 'Cancer'.
	///
	/// - Tag: L10n-cancer
	static var cancer: String {
		L10n.resolve {
			String(localized: "Cancer", table: "Content", bundle: LanguageManager.shared.bundle, locale: LanguageManager.shared.locale, comment: "The display value 'Cancer'.")
		}
	}
	/// The display value 'Leo'.
	///
	/// - Tag: L10n-leo
	static var leo: String {
		L10n.resolve {
			String(localized: "Leo", table: "Content", bundle: LanguageManager.shared.bundle, locale: LanguageManager.shared.locale, comment: "The display value 'Leo'.")
		}
	}
	/// The display value 'Virgo'.
	///
	/// - Tag: L10n-virgo
	static var virgo: String {
		L10n.resolve {
			String(localized: "Virgo", table: "Content", bundle: LanguageManager.shared.bundle, locale: LanguageManager.shared.locale, comment: "The display value 'Virgo'.")
		}
	}
	/// The display value 'Libra'.
	///
	/// - Tag: L10n-libra
	static var libra: String {
		L10n.resolve {
			String(localized: "Libra", table: "Content", bundle: LanguageManager.shared.bundle, locale: LanguageManager.shared.locale, comment: "The display value 'Libra'.")
		}
	}
	/// The display value 'Scorpio'.
	///
	/// - Tag: L10n-scorpio
	static var scorpio: String {
		L10n.resolve {
			String(localized: "Scorpio", table: "Content", bundle: LanguageManager.shared.bundle, locale: LanguageManager.shared.locale, comment: "The display value 'Scorpio'.")
		}
	}
	/// The display value 'Sagittarius'.
	///
	/// - Tag: L10n-sagittarius
	static var sagittarius: String {
		L10n.resolve {
			String(localized: "Sagittarius", table: "Content", bundle: LanguageManager.shared.bundle, locale: LanguageManager.shared.locale, comment: "The display value 'Sagittarius'.")
		}
	}
	/// The display value 'Capricorn'.
	///
	/// - Tag: L10n-capricorn
	static var capricorn: String {
		L10n.resolve {
			String(localized: "Capricorn", table: "Content", bundle: LanguageManager.shared.bundle, locale: LanguageManager.shared.locale, comment: "The display value 'Capricorn'.")
		}
	}
	/// The display value 'Aquarius'.
	///
	/// - Tag: L10n-aquarius
	static var aquarius: String {
		L10n.resolve {
			String(localized: "Aquarius", table: "Content", bundle: LanguageManager.shared.bundle, locale: LanguageManager.shared.locale, comment: "The display value 'Aquarius'.")
		}
	}
	/// The display value 'Pisces'.
	///
	/// - Tag: L10n-pisces
	static var pisces: String {
		L10n.resolve {
			String(localized: "Pisces", table: "Content", bundle: LanguageManager.shared.bundle, locale: LanguageManager.shared.locale, comment: "The display value 'Pisces'.")
		}
	}
	/// The display value 'Detailed'.
	///
	/// - Tag: L10n-detailed
	static var detailed: String {
		L10n.resolve {
			String(localized: "Detailed", table: "Content", bundle: LanguageManager.shared.bundle, locale: LanguageManager.shared.locale, comment: "The display value 'Detailed'.")
		}
	}
	/// The display value 'Compact'.
	///
	/// - Tag: L10n-compact
	static var compact: String {
		L10n.resolve {
			String(localized: "Compact", table: "Content", bundle: LanguageManager.shared.bundle, locale: LanguageManager.shared.locale, comment: "The display value 'Compact'.")
		}
	}
	/// The display value 'List'.
	///
	/// - Tag: L10n-list
	static var list: String {
		L10n.resolve {
			String(localized: "List", table: "Content", bundle: LanguageManager.shared.bundle, locale: LanguageManager.shared.locale, comment: "The display value 'List'.")
		}
	}
	/// The display value 'Table'.
	///
	/// - Tag: L10n-table
	static var table: String {
		L10n.resolve {
			String(localized: "Table", table: "Content", bundle: LanguageManager.shared.bundle, locale: LanguageManager.shared.locale, comment: "The display value 'Table'.")
		}
	}
	/// The display value 'Disabled'.
	///
	/// - Tag: L10n-disabled
	static var disabled: String {
		L10n.resolve {
			String(localized: "Disabled", table: "Content", bundle: LanguageManager.shared.bundle, locale: LanguageManager.shared.locale, comment: "The display value 'Disabled'.")
		}
	}
	/// The display value 'Shake'.
	///
	/// - Tag: L10n-shake
	static var shake: String {
		L10n.resolve {
			String(localized: "Shake", table: "Content", bundle: LanguageManager.shared.bundle, locale: LanguageManager.shared.locale, comment: "The display value 'Shake'.")
		}
	}
	/// The display value 'Scale'.
	///
	/// - Tag: L10n-scale
	static var scale: String {
		L10n.resolve {
			String(localized: "Scale", table: "Content", bundle: LanguageManager.shared.bundle, locale: LanguageManager.shared.locale, comment: "The display value 'Scale'.")
		}
	}
	/// The display value 'Anvil'.
	///
	/// - Tag: L10n-anvil
	static var anvil: String {
		L10n.resolve {
			String(localized: "Anvil", table: "Content", bundle: LanguageManager.shared.bundle, locale: LanguageManager.shared.locale, comment: "The display value 'Anvil'.")
		}
	}
	/// The display value 'Spin'.
	///
	/// - Tag: L10n-spin
	static var spin: String {
		L10n.resolve {
			String(localized: "Spin", table: "Content", bundle: LanguageManager.shared.bundle, locale: LanguageManager.shared.locale, comment: "The display value 'Spin'.")
		}
	}
	/// The display value 'Heartbeat'.
	///
	/// - Tag: L10n-heartbeat
	static var heartbeat: String {
		L10n.resolve {
			String(localized: "Heartbeat", table: "Content", bundle: LanguageManager.shared.bundle, locale: LanguageManager.shared.locale, comment: "The display value 'Heartbeat'.")
		}
	}
	/// The display value 'Bounce'.
	///
	/// - Tag: L10n-bounce
	static var bounce: String {
		L10n.resolve {
			String(localized: "Bounce", table: "Content", bundle: LanguageManager.shared.bundle, locale: LanguageManager.shared.locale, comment: "The display value 'Bounce'.")
		}
	}

	// MARK: - Model Actions & Sharing
	/// The alert title shown when favoriting fails.
	static var cantFavorite: String {
		L10n.resolve {
			String(localized: "Can't Favorite", table: "Content", bundle: LanguageManager.shared.bundle, locale: LanguageManager.shared.locale, comment: "The alert title shown when favoriting fails.")
		}
	}
	/// The alert title shown when adding a reminder fails.
	static var cantAddReminder: String {
		L10n.resolve {
			String(localized: "Can't Add Reminder", table: "Content", bundle: LanguageManager.shared.bundle, locale: LanguageManager.shared.locale, comment: "The alert title shown when adding a reminder fails.")
		}
	}
	/// The context-menu action that removes a notification.
	static var removeNotification: String {
		L10n.resolve {
			String(localized: "Remove Notification", table: "Content", bundle: LanguageManager.shared.bundle, locale: LanguageManager.shared.locale, comment: "The context-menu action that removes a notification.")
		}
	}
	/// The context-menu action that marks a notification as read.
	static var markNotificationRead: String {
		L10n.resolve {
			String(localized: "Mark as Read", table: "Content", bundle: LanguageManager.shared.bundle, locale: LanguageManager.shared.locale, comment: "The context-menu action that marks a notification as read.")
		}
	}
	/// The context-menu action that marks a notification as unread.
	static var markNotificationUnread: String {
		L10n.resolve {
			String(localized: "Mark as Unread", table: "Content", bundle: LanguageManager.shared.bundle, locale: LanguageManager.shared.locale, comment: "The context-menu action that marks a notification as unread.")
		}
	}
	/// The alert title explaining how to remove a song from Apple Music.
	static var howToRemove: String {
		L10n.resolve {
			String(localized: "How to Remove", table: "Content", bundle: LanguageManager.shared.bundle, locale: LanguageManager.shared.locale, comment: "The alert title explaining how to remove a song from Apple Music.")
		}
	}
	/// The alert message explaining how to remove a song from Apple Music.
	static var songRemovalMessage: String {
		L10n.resolve {
			String(localized: "Songs added to your Apple Music Library cannot be removed from Kurozora due to API limitations. Please remove the song from your library manually in the Music app.", table: "Content", bundle: LanguageManager.shared.bundle, locale: LanguageManager.shared.locale, comment: "The alert message explaining how to remove a song from Apple Music.")
		}
	}
	/// The menu action shown when a song is already in the Apple Music library.
	static var inAppleMusicLibrary: String {
		L10n.resolve {
			String(localized: "In Apple Music Library", table: "Content", bundle: LanguageManager.shared.bundle, locale: LanguageManager.shared.locale, comment: "The menu action shown when a song is already in the Apple Music library.")
		}
	}
	/// The menu action that adds a song to the Apple Music library.
	static var addToAppleMusic: String {
		L10n.resolve {
			String(localized: "Add to Apple Music", table: "Content", bundle: LanguageManager.shared.bundle, locale: LanguageManager.shared.locale, comment: "The menu action that adds a song to the Apple Music library.")
		}
	}
	/// The share text for a show.
	static func shareShow(_ title: String) -> String {
		L10n.resolve {
			String(localized: "Track your progress of \"\(title)\" via @KurozoraApp", table: "Content", bundle: LanguageManager.shared.bundle, locale: LanguageManager.shared.locale, comment: "The share text for a show, where the placeholder is the title.")
		}
	}
	/// The share text for a literature.
	static func shareLiterature(_ title: String) -> String {
		L10n.resolve {
			String(localized: "Track your reading progress of \"\(title)\" via @KurozoraApp", table: "Content", bundle: LanguageManager.shared.bundle, locale: LanguageManager.shared.locale, comment: "The share text for a literature, where the placeholder is the title.")
		}
	}
	/// The share text for a game.
	static func shareGame(_ title: String) -> String {
		L10n.resolve {
			String(localized: "Track your playing progress of \"\(title)\" via @KurozoraApp", table: "Content", bundle: LanguageManager.shared.bundle, locale: LanguageManager.shared.locale, comment: "The share text for a game, where the placeholder is the title.")
		}
	}
	/// The share text for an episode.
	static func shareEpisode(_ title: String) -> String {
		L10n.resolve {
			String(localized: "Track your watch progress of \"\(title)\" via @KurozoraApp", table: "Content", bundle: LanguageManager.shared.bundle, locale: LanguageManager.shared.locale, comment: "The share text for an episode, where the placeholder is the title.")
		}
	}
	/// The share text for a season.
	static func shareSeason(_ title: String) -> String {
		L10n.resolve {
			String(localized: "You should watch \"\(title)\" season via @KurozoraApp", table: "Content", bundle: LanguageManager.shared.bundle, locale: LanguageManager.shared.locale, comment: "The share text for a season, where the placeholder is the title.")
		}
	}
	/// The share text for a studio.
	static func shareStudio(_ name: String) -> String {
		L10n.resolve {
			String(localized: "Check out shows made by \"\(name)\" via @KurozoraApp", table: "Content", bundle: LanguageManager.shared.bundle, locale: LanguageManager.shared.locale, comment: "The share text for a studio, where the placeholder is the name.")
		}
	}
	/// The share text for a person.
	static func sharePerson(_ name: String) -> String {
		L10n.resolve {
			String(localized: "Check out \"\(name)\" via @KurozoraApp", table: "Content", bundle: LanguageManager.shared.bundle, locale: LanguageManager.shared.locale, comment: "The share text for a person, where the placeholder is the name.")
		}
	}
	/// The share text for a character.
	static func shareCharacter(_ name: String) -> String {
		L10n.resolve {
			String(localized: "You should check out \"\(name)\" via @KurozoraApp", table: "Content", bundle: LanguageManager.shared.bundle, locale: LanguageManager.shared.locale, comment: "The share text for a character, where the placeholder is the name.")
		}
	}
	/// The share text for a voice actor and the character they voice.
	static func shareCast(_ person: String, _ character: String) -> String {
		L10n.resolve {
			String(localized: "TIL, \(person) is the voice actor of \(character) via @KurozoraApp", table: "Content", bundle: LanguageManager.shared.bundle, locale: LanguageManager.shared.locale, comment: "The share text for a voice actor and the character they voice.")
		}
	}
	/// The share text for a song.
	static func shareSong(_ title: String, _ artist: String) -> String {
		L10n.resolve {
			String(localized: "Listen to \"\(title)\" by \"\(artist)\" on @KurozoraApp", table: "Content", bundle: LanguageManager.shared.bundle, locale: LanguageManager.shared.locale, comment: "The share text for a song, where the placeholders are the title and the artist.")
		}
	}
	/// The share text for a genre or theme.
	static func shareDiscover(_ name: String) -> String {
		L10n.resolve {
			String(localized: "Discover \(name) shows via @KurozoraApp.", table: "Content", bundle: LanguageManager.shared.bundle, locale: LanguageManager.shared.locale, comment: "The share text for a genre or theme, where the placeholder is the name.")
		}
	}
	/// The share text inviting others to follow a user.
	static func shareFollowUser(_ username: String) -> String {
		L10n.resolve {
			String(localized: "Follow \(username) via @KurozoraApp", table: "Content", bundle: LanguageManager.shared.bundle, locale: LanguageManager.shared.locale, comment: "The share text inviting others to follow a user.")
		}
	}
	/// The share text for a user's library.
	static func shareUserLibrary(_ username: String) -> String {
		L10n.resolve {
			String(localized: "Check out \(username)’s library via @KurozoraApp", table: "Content", bundle: LanguageManager.shared.bundle, locale: LanguageManager.shared.locale, comment: "The share text for a user's library.")
		}
	}

	/// The title shown on the reputation leaderboard screen.
	///
	/// - Tag: L10n-reputationLeaderboardTitle
	static var reputationLeaderboardTitle: String {
		L10n.resolve {
			String(
				localized: "Leaderboard",
				table: "Content",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The title shown on the reputation leaderboard screen."
			)
		}
	}

	// MARK: - Follow Button
	/// The user-cell follow button title when the current user is following the target user.
	///
	/// - Tag: L10n-followingButton
	static var followingButton: String {
		L10n.resolve {
			String(
				localized: "✓ Following",
				table: "Content",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The user-cell follow button title when the current user is following the target user."
			)
		}
	}
	/// The user-cell follow button title when the current user is not yet following the target user.
	///
	/// - Tag: L10n-followButton
	static var followButton: String {
		L10n.resolve {
			String(
				localized: "＋ Follow",
				table: "Content",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The user-cell follow button title when the current user is not yet following the target user."
			)
		}
	}
	/// The empty-state action button shown on another user's empty followers list.
	///
	/// - Tag: L10n-followUserButton
	static func followUserButton(_ username: String) -> String {
		String(
			localized: "＋ Follow \(username)",
			table: "Content",
			bundle: LanguageManager.shared.bundle,
			locale: LanguageManager.shared.locale,
			comment: "The empty-state action button shown on another user's empty followers list. '%@' is the target user's display name."
		)
	}

	// MARK: - User Cell Subtitles
	/// The user-cell secondary line for your own profile when you have no followers yet.
	///
	/// - Tag: L10n-userFollowersSelfNone
	static var userFollowersSelfNone: String {
		L10n.resolve {
			String(
				localized: "You, followed by you!",
				table: "Content",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The user-cell secondary line for your own profile when you have no followers yet."
			)
		}
	}
	/// The user-cell secondary line for another user when nobody follows them yet.
	///
	/// - Tag: L10n-userFollowersBeFirst
	static var userFollowersBeFirst: String {
		L10n.resolve {
			String(
				localized: "Be the first to follow!",
				table: "Content",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The user-cell secondary line for another user when nobody follows them yet."
			)
		}
	}
	/// The user-cell secondary line for your own profile when you have exactly one follower.
	///
	/// - Tag: L10n-userFollowersSelfOne
	static var userFollowersSelfOne: String {
		L10n.resolve {
			String(
				localized: "Followed by you… and one fan!",
				table: "Content",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The user-cell secondary line for your own profile when you have exactly one follower."
			)
		}
	}
	/// The user-cell secondary line for another user that you already follow when their only follower is you.
	///
	/// - Tag: L10n-userFollowedByYouOnly
	static var userFollowedByYouOnly: String {
		L10n.resolve {
			String(
				localized: "Followed by you.",
				table: "Content",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The user-cell secondary line for another user that you already follow when their only follower is you."
			)
		}
	}
	/// The user-cell secondary line for another user that you don't follow when they have exactly one follower.
	///
	/// - Tag: L10n-userFollowedByOneUser
	static var userFollowedByOneUser: String {
		L10n.resolve {
			String(
				localized: "Followed by one user.",
				table: "Content",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The user-cell secondary line for another user that you don't follow when they have exactly one follower."
			)
		}
	}
	/// The user-cell secondary line for your own profile with a small (2–999) follower count.
	///
	/// - Tag: L10n-userFollowersSelfSmall
	static func userFollowersSelfSmall(_ count: String) -> String {
		String(
			localized: "Followed by you and \(count) fans.",
			table: "Content",
			bundle: LanguageManager.shared.bundle,
			locale: LanguageManager.shared.locale,
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
			bundle: LanguageManager.shared.bundle,
			locale: LanguageManager.shared.locale,
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
			bundle: LanguageManager.shared.bundle,
			locale: LanguageManager.shared.locale,
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
			bundle: LanguageManager.shared.bundle,
			locale: LanguageManager.shared.locale,
			comment: "The user-cell secondary line for another user that you don't follow. '%@' is the formatted total follower count."
		)
	}

	// MARK: - Users List Empty State
	/// The empty-state title for the followers list.
	///
	/// - Tag: L10n-usersListFollowersEmptyTitle
	static var usersListFollowersEmptyTitle: String {
		L10n.resolve {
			String(
				localized: "No Followers",
				table: "Content",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The empty-state title for the followers list."
			)
		}
	}
	/// The empty-state title for the following list.
	///
	/// - Tag: L10n-usersListFollowingEmptyTitle
	static var usersListFollowingEmptyTitle: String {
		L10n.resolve {
			String(
				localized: "No Following",
				table: "Content",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The empty-state title for the following list."
			)
		}
	}
	/// The empty-state title for a generic users list (search / leaderboard).
	///
	/// - Tag: L10n-usersListEmptyTitle
	static var usersListEmptyTitle: String {
		L10n.resolve {
			String(
				localized: "No Users",
				table: "Content",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The empty-state title for a generic users list (search / leaderboard)."
			)
		}
	}
	/// The empty-state detail shown on your own followers list when you have none.
	///
	/// - Tag: L10n-followersEmptyDetailSelf
	static var followersEmptyDetailSelf: String {
		L10n.resolve {
			String(
				localized: "Follow other users so they will follow you back. Who knows, you might meet your next BFF!",
				table: "Content",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The empty-state detail shown on your own followers list when you have none."
			)
		}
	}
	/// The empty-state detail shown on another user's followers list when nobody follows them yet.
	///
	/// - Tag: L10n-followersEmptyDetailOther
	static func followersEmptyDetailOther(_ username: String) -> String {
		String(
			localized: "Be the first to follow \(username)!",
			table: "Content",
			bundle: LanguageManager.shared.bundle,
			locale: LanguageManager.shared.locale,
			comment: "The empty-state detail shown on another user's followers list when nobody follows them yet. '%@' is the target user's display name."
		)
	}
	/// The empty-state detail shown on your own following list when you don't follow anyone yet.
	///
	/// - Tag: L10n-followingEmptyDetailSelf
	static var followingEmptyDetailSelf: String {
		L10n.resolve {
			String(
				localized: "Follow a user and they will show up here!",
				table: "Content",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The empty-state detail shown on your own following list when you don't follow anyone yet."
			)
		}
	}
	/// The empty-state detail shown on another user's following list when they don't follow anyone yet.
	///
	/// - Tag: L10n-followingEmptyDetailOther
	static func followingEmptyDetailOther(_ username: String) -> String {
		String(
			localized: "\(username) is not following anyone yet.",
			table: "Content",
			bundle: LanguageManager.shared.bundle,
			locale: LanguageManager.shared.locale,
			comment: "The empty-state detail shown on another user's following list when they don't follow anyone yet. '%@' is the target user's display name."
		)
	}
	/// The empty-state detail shown when the users search returns no results or fails to load.
	///
	/// - Tag: L10n-usersListSearchEmptyDetail
	static var usersListSearchEmptyDetail: String {
		L10n.resolve {
			String(
				localized: "Can't get users list. Please reload the page or restart the app and check your WiFi connection.",
				table: "Content",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The empty-state detail shown when the users search returns no results or fails to load."
			)
		}
	}
	/// The empty-state detail shown when the reputation leaderboard has no entries.
	///
	/// - Tag: L10n-leaderboardEmptyDetail
	static var leaderboardEmptyDetail: String {
		L10n.resolve {
			String(
				localized: "The leaderboard is empty. Pull to refresh or check back later.",
				table: "Content",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The empty-state detail shown when the reputation leaderboard has no entries."
			)
		}
	}
	/// The fallback for an unavailable display name.
	///
	/// - Tag: L10n-thisUser
	static var thisUser: String {
		L10n.resolve {
			String(
				localized: "This user",
				table: "Content",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "Fallback used in place of a user's display name when one is unavailable."
			)
		}
	}

	// MARK: - Refresh Control Titles
	/// Pull-to-refresh title for a list of the specified items.
	///
	/// - Parameter items: The localized noun naming the list (e.g. `L10n.achievements`).
	///
	/// - Tag: L10n-pullToRefreshItems
	static func pullToRefreshItems(_ items: String) -> String {
		return String(
			localized: "pullToRefreshItems",
			defaultValue: "Pull to refresh \(items)…",
			table: "Content",
			bundle: LanguageManager.shared.bundle,
			locale: LanguageManager.shared.locale,
			comment: "Pull-to-refresh title for a list. The parameter is the localized noun for the list type (e.g. 'reviews', 'achievements')."
		)
	}
	/// Refresh-in-progress title for a list of the specified items.
	///
	/// - Parameter items: The localized noun naming the list (e.g. `L10n.achievements`).
	///
	/// - Tag: L10n-refreshingItems
	static func refreshingItems(_ items: String) -> String {
		return String(
			localized: "refreshingItems",
			defaultValue: "Refreshing \(items)…",
			table: "Content",
			bundle: LanguageManager.shared.bundle,
			locale: LanguageManager.shared.locale,
			comment: "Refresh-in-progress title for a list. The parameter is the localized noun for the list type (e.g. 'reviews', 'achievements')."
		)
	}
	/// Empty-state title for the achievements list.
	///
	/// - Tag: L10n-noAchievementsTitle
	static var noAchievementsTitle: String {
		L10n.resolve {
			String(
				localized: "No Achievements",
				table: "Content",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "Empty-state title for the achievements list."
			)
		}
	}
	/// Empty-state detail for the achievements list when viewing your own profile.
	///
	/// - Tag: L10n-noAchievementsCurrentUserDetail
	static var noAchievementsCurrentUserDetail: String {
		L10n.resolve {
			String(
				localized: "Achievements you earn show up here.",
				table: "Content",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "Empty-state detail for the achievements list when viewing your own profile."
			)
		}
	}
	/// Empty-state detail for the achievements list when viewing someone else's profile.
	///
	/// - Tag: L10n-noAchievementsOtherUserDetail
	static func noAchievementsOtherUserDetail(_ username: String) -> String {
		return String(
			localized: "noAchievements.otherUserDetail",
			defaultValue: "\(username) has not earned any achievements yet.",
			table: "Content",
			bundle: LanguageManager.shared.bundle,
			locale: LanguageManager.shared.locale,
			comment: "Empty-state detail for the achievements list when viewing someone else's profile."
		)
	}

	// MARK: - Empty States
	/// The generic empty-state title for a list of the specified items.
	///
	/// - Parameter items: The localized noun naming the list (e.g. `L10n.genres`).
	///
	/// - Tag: L10n-noItemsTitle
	static func noItemsTitle(_ items: String) -> String {
		String(
			localized: "No \(items)",
			table: "Content",
			bundle: LanguageManager.shared.bundle,
			locale: LanguageManager.shared.locale,
			comment: "The generic empty-state title for a list."
		)
	}
	/// The empty-state detail shown when a list could not be fetched.
	///
	/// - Parameter items: The localized lowercase noun naming the list (e.g. `L10n.genres.localizedLowercase`).
	///
	/// - Tag: L10n-cantGetListDetail
	static func cantGetListDetail(_ items: String) -> String {
		String(
			localized: "Can't get \(items) list. Please reload the page or restart the app and check your WiFi connection.",
			table: "Content",
			bundle: LanguageManager.shared.bundle,
			locale: LanguageManager.shared.locale,
			comment: "The empty-state detail shown when a list could not be fetched."
		)
	}
	/// The empty-state detail shown when a screen has no details yet.
	static func noDetailsYet(_ kind: String) -> String {
		L10n.resolve {
			String(localized: "This \(kind) doesn't have details yet. Please check back again later.", table: "Content", bundle: LanguageManager.shared.bundle, locale: LanguageManager.shared.locale, comment: "The empty-state detail shown when a screen has no details yet.")
		}
	}
	/// The empty-state detail shown when a container has no items of a kind yet.
	static func noItemsYet(_ container: String, _ items: String) -> String {
		L10n.resolve {
			String(localized: "This \(container) doesn't have \(items) yet. Please check back again later.", table: "Content", bundle: LanguageManager.shared.bundle, locale: LanguageManager.shared.locale, comment: "The empty-state detail shown when a container has no items of a kind yet.")
		}
	}
	/// The empty-state detail shown when a title has no casts yet.
	static func noCastsYet(_ kind: String) -> String {
		L10n.resolve {
			String(localized: "This \(kind) doesn't have casts yet. Please check back again later.", table: "Content", bundle: LanguageManager.shared.bundle, locale: LanguageManager.shared.locale, comment: "The empty-state detail shown when a title has no casts yet.")
		}
	}
	/// The empty-state detail shown when a list could not be fetched, asking to refresh.
	static func cantGetListRefresh(_ items: String) -> String {
		L10n.resolve {
			String(localized: "Can't get \(items) list. Please refresh the page or restart the app and check your WiFi connection.", table: "Content", bundle: LanguageManager.shared.bundle, locale: LanguageManager.shared.locale, comment: "The empty-state detail shown when a list could not be fetched, asking to refresh.")
		}
	}
	/// The empty-state detail shown when there are no trailers to list.
	static var noTrailersDetail: String {
		L10n.resolve {
			String(localized: "There are no trailers here yet.", table: "Content", bundle: LanguageManager.shared.bundle, locale: LanguageManager.shared.locale, comment: "The empty-state detail shown when there are no trailers to list.")
		}
	}
	/// The empty-state title for the show songs list.
	static var noShowSongs: String {
		L10n.resolve {
			String(localized: "No show songs", table: "Content", bundle: LanguageManager.shared.bundle, locale: LanguageManager.shared.locale, comment: "The empty-state title for the show songs list.")
		}
	}
	/// The empty-state detail shown when the show songs list could not be fetched.
	static var cantGetShowSongs: String {
		L10n.resolve {
			String(localized: "Can't get show songs list. Please reload the page or restart the app and check your WiFi connection.", table: "Content", bundle: LanguageManager.shared.bundle, locale: LanguageManager.shared.locale, comment: "The empty-state detail shown when the show songs list could not be fetched.")
		}
	}
	/// The singular word 'show'.
	static var show: String {
		L10n.resolve {
			String(localized: "Show", table: "Content", bundle: LanguageManager.shared.bundle, locale: LanguageManager.shared.locale, comment: "The singular word 'show' as a media type.")
		}
	}
	/// The singular word 'literature'.
	static var literature: String {
		L10n.resolve {
			String(localized: "Literature", table: "Content", bundle: LanguageManager.shared.bundle, locale: LanguageManager.shared.locale, comment: "The singular word 'literature' as a media type.")
		}
	}
	/// The singular word 'episode'.
	static var episode: String {
		L10n.resolve {
			String(localized: "Episode", table: "Content", bundle: LanguageManager.shared.bundle, locale: LanguageManager.shared.locale, comment: "The singular word 'episode'.")
		}
	}
	/// The singular word 'character'.
	static var character: String {
		L10n.resolve {
			String(localized: "Character", table: "Content", bundle: LanguageManager.shared.bundle, locale: LanguageManager.shared.locale, comment: "The singular word 'character'.")
		}
	}
	/// The singular word 'person'.
	static var person: String {
		L10n.resolve {
			String(localized: "Person", table: "Content", bundle: LanguageManager.shared.bundle, locale: LanguageManager.shared.locale, comment: "The singular word 'person'.")
		}
	}
	/// The singular word 'song'.
	static var song: String {
		L10n.resolve {
			String(localized: "Song", table: "Content", bundle: LanguageManager.shared.bundle, locale: LanguageManager.shared.locale, comment: "The singular word 'song'.")
		}
	}

	// MARK: - Empty States
	/// The notifications empty-state detail when signed in.
	static var notificationsEmptyDetail: String {
		L10n.resolve {
			String(localized: "When you have notifications, you will see them here!", table: "Content", bundle: LanguageManager.shared.bundle, locale: LanguageManager.shared.locale, comment: "The notifications empty-state detail when signed in.")
		}
	}
	/// The notifications empty-state detail when signed out.
	static var notificationsSignedOutDetail: String {
		L10n.resolve {
			String(localized: "Notifications are only available to registered Kurozora users.", table: "Content", bundle: LanguageManager.shared.bundle, locale: LanguageManager.shared.locale, comment: "The notifications empty-state detail when signed out.")
		}
	}
	/// The library empty-state prompt to add an item to a list.
	static func addItemToList(_ kind: String, _ status: String) -> String {
		L10n.resolve {
			String(localized: "Add a \(kind) to your \(status) list and it will show up here.", table: "Content", bundle: LanguageManager.shared.bundle, locale: LanguageManager.shared.locale, comment: "The library empty-state prompt to add an item to a list.")
		}
	}
	/// The library empty-state detail for another user's empty list.
	static func userHasNoInList(_ username: String, _ items: String, _ status: String) -> String {
		L10n.resolve {
			String(localized: "\(username) has no \(items) in their \(status) list.", table: "Content", bundle: LanguageManager.shared.bundle, locale: LanguageManager.shared.locale, comment: "The library empty-state detail for another user's empty list.")
		}
	}
	/// The library empty-state detail shown when signed out.
	static var librarySignedOutDetail: String {
		L10n.resolve {
			String(localized: "Library is currently available to registered Kurozora users only.", table: "Content", bundle: LanguageManager.shared.bundle, locale: LanguageManager.shared.locale, comment: "The library empty-state detail shown when signed out.")
		}
	}
	/// The profile feed empty-state detail for your own profile.
	static var feedEmptyDetailSelf: String {
		L10n.resolve {
			String(localized: "There are no messages on your feed!", table: "Content", bundle: LanguageManager.shared.bundle, locale: LanguageManager.shared.locale, comment: "The profile feed empty-state detail for your own profile.")
		}
	}
	/// The profile feed empty-state detail for another user's profile.
	static var feedEmptyDetailOther: String {
		L10n.resolve {
			String(localized: "There are no messages on this feed!", table: "Content", bundle: LanguageManager.shared.bundle, locale: LanguageManager.shared.locale, comment: "The profile feed empty-state detail for another user's profile.")
		}
	}
	/// The reviews empty-state detail for your own profile.
	static var reviewsEmptySelfDetail: String {
		L10n.resolve {
			String(localized: "Ratings and reviews you submit will appear here. ", table: "Content", bundle: LanguageManager.shared.bundle, locale: LanguageManager.shared.locale, comment: "The reviews empty-state detail for your own profile.")
		}
	}
	/// The reviews empty-state detail for another user's profile.
	static func reviewsEmptyOtherDetail(_ username: String) -> String {
		L10n.resolve {
			String(localized: "\(username) has not submitted any reviews yet. Check back later.", table: "Content", bundle: LanguageManager.shared.bundle, locale: LanguageManager.shared.locale, comment: "The reviews empty-state detail for another user's profile.")
		}
	}
	/// The reviews list empty-state detail.
	static var beFirstToReview: String {
		L10n.resolve {
			String(localized: "Be the first to place a review!", table: "Content", bundle: LanguageManager.shared.bundle, locale: LanguageManager.shared.locale, comment: "The reviews list empty-state detail.")
		}
	}
	/// The alert message shown when an action is unavailable for a media type.
	static var notAvailableForType: String {
		L10n.resolve {
			String(localized: "Not available yet for this type.", table: "Content", bundle: LanguageManager.shared.bundle, locale: LanguageManager.shared.locale, comment: "The alert message shown when an action is unavailable for a media type.")
		}
	}
	/// The favorites empty-state detail for your own profile.
	static func favoritedWillShowUp(_ items: String) -> String {
		L10n.resolve {
			String(localized: "Favorited \(items) will show up on this page!", table: "Content", bundle: LanguageManager.shared.bundle, locale: LanguageManager.shared.locale, comment: "The favorites empty-state detail for your own profile.")
		}
	}
	/// The favorites empty-state detail for another user's profile.
	static func userHasntFavorited(_ username: String, _ items: String) -> String {
		L10n.resolve {
			String(localized: "\(username) hasn't favorited \(items) yet.", table: "Content", bundle: LanguageManager.shared.bundle, locale: LanguageManager.shared.locale, comment: "The favorites empty-state detail for another user's profile.")
		}
	}

	// MARK: - Digest
	/// The title of the weekly digest screen.
	static var digest: String {
		L10n.resolve {
			String(localized: "Your Week", table: "Content", bundle: LanguageManager.shared.bundle, locale: LanguageManager.shared.locale, comment: "The title of the weekly digest screen.")
		}
	}
	/// The digest stat for the user's watch streak.
	static func digestWeekStreak(_ weeks: Int) -> String {
		L10n.resolve {
			String(localized: "On a \(weeks)-week watch streak!", table: "Content", bundle: LanguageManager.shared.bundle, locale: LanguageManager.shared.locale, comment: "The digest stat for the user's watch streak.")
		}
	}
	/// The digest stat for the user's next watched-episode milestone.
	static func digestMilestone(_ remaining: Int, _ milestone: Int) -> String {
		L10n.resolve {
			String(localized: "Only \(remaining) episodes to \(milestone) watched episodes!", table: "Content", bundle: LanguageManager.shared.bundle, locale: LanguageManager.shared.locale, comment: "The digest stat for the user's next watched-episode milestone.")
		}
	}
	/// The digest momentum caption above the week's stats.
	static var digestMomentumCaption: String {
		L10n.resolve {
			String(localized: "Your week in numbers", table: "Content", bundle: LanguageManager.shared.bundle, locale: LanguageManager.shared.locale, comment: "The digest momentum caption above the week's stats.")
		}
	}
	/// The digest momentum label under the watched-episodes count.
	static var digestMomentumEpisodesLabel: String {
		L10n.resolve {
			String(localized: "episodes watched", table: "Content", bundle: LanguageManager.shared.bundle, locale: LanguageManager.shared.locale, comment: "The digest momentum label under the watched-episodes count.")
		}
	}
	/// The digest momentum label under the amount of time watched.
	static var digestMomentumTimeLabel: String {
		L10n.resolve {
			String(localized: "watched", table: "Content", bundle: LanguageManager.shared.bundle, locale: LanguageManager.shared.locale, comment: "The digest momentum label under the amount of time watched.")
		}
	}
	/// The digest momentum label under the finished-titles count.
	static var digestMomentumFinishedLabel: String {
		L10n.resolve {
			String(localized: "titles finished", table: "Content", bundle: LanguageManager.shared.bundle, locale: LanguageManager.shared.locale, comment: "The digest momentum label under the finished-titles count.")
		}
	}
	/// The digest momentum button linking to the user's Re:CAP.
	static var digestSeeReCap: String {
		L10n.resolve {
			String(localized: "See your Re:CAP", table: "Content", bundle: LanguageManager.shared.bundle, locale: LanguageManager.shared.locale, comment: "The digest momentum button linking to the user's Re:CAP.")
		}
	}

	// MARK: - ReCap, Parental Guide, Feed, Library
	/// The ReCap in-progress header shown in December.
	static func recapInProgressWeek(_ month: String) -> String {
		L10n.resolve {
			String(localized: "\(month) Re:CAP is still in progress. Check back in a week.", table: "Content", bundle: LanguageManager.shared.bundle, locale: LanguageManager.shared.locale, comment: "The ReCap in-progress header shown in December.")
		}
	}
	/// The ReCap in-progress header for a given month.
	static func recapInProgressMonth(_ month: String, _ next: String) -> String {
		L10n.resolve {
			String(localized: "\(month) Re:CAP is still in progress. Check back in early \(next).", table: "Content", bundle: LanguageManager.shared.bundle, locale: LanguageManager.shared.locale, comment: "The ReCap in-progress header for a given month.")
		}
	}
	/// The generic ReCap in-progress header.
	static var recapInProgressGeneric: String {
		L10n.resolve {
			String(localized: "Re:CAP is still in progress. Check back early next month.", table: "Content", bundle: LanguageManager.shared.bundle, locale: LanguageManager.shared.locale, comment: "The generic ReCap in-progress header.")
		}
	}
	/// The ReCap header for the defining series of a month.
	static func recapDefiningSeries(_ month: String) -> String {
		L10n.resolve {
			String(localized: "Series that defined your arc in \(month)", table: "Content", bundle: LanguageManager.shared.bundle, locale: LanguageManager.shared.locale, comment: "The ReCap header for the defining series of a month.")
		}
	}
	/// The ReCap header for finale milestones.
	static var recapFinaleMilestones: String {
		L10n.resolve {
			String(localized: "These milestones marked your season finale", table: "Content", bundle: LanguageManager.shared.bundle, locale: LanguageManager.shared.locale, comment: "The ReCap header for finale milestones.")
		}
	}
	/// The ReCap milestone noun phrase for shows.
	static var animeWatchers: String {
		L10n.resolve {
			String(localized: "anime watchers", table: "Content", bundle: LanguageManager.shared.bundle, locale: LanguageManager.shared.locale, comment: "The ReCap milestone noun phrase for shows.")
		}
	}
	/// The ReCap milestone noun phrase for games.
	static var gamePlayers: String {
		L10n.resolve {
			String(localized: "game players", table: "Content", bundle: LanguageManager.shared.bundle, locale: LanguageManager.shared.locale, comment: "The ReCap milestone noun phrase for games.")
		}
	}
	/// The ReCap milestone noun phrase for literatures.
	static var mangaReaders: String {
		L10n.resolve {
			String(localized: "manga readers", table: "Content", bundle: LanguageManager.shared.bundle, locale: LanguageManager.shared.locale, comment: "The ReCap milestone noun phrase for literatures.")
		}
	}
	/// The Parental Guide category 'Sex & Nudity'.
	static var pgSexAndNudity: String {
		L10n.resolve {
			String(localized: "Sex & Nudity", table: "Content", bundle: LanguageManager.shared.bundle, locale: LanguageManager.shared.locale, comment: "The Parental Guide category 'Sex & Nudity'.")
		}
	}
	/// The Parental Guide category 'Violence & Gore'.
	static var pgViolenceAndGore: String {
		L10n.resolve {
			String(localized: "Violence & Gore", table: "Content", bundle: LanguageManager.shared.bundle, locale: LanguageManager.shared.locale, comment: "The Parental Guide category 'Violence & Gore'.")
		}
	}
	/// The Parental Guide category 'Profanity'.
	static var pgProfanity: String {
		L10n.resolve {
			String(localized: "Profanity", table: "Content", bundle: LanguageManager.shared.bundle, locale: LanguageManager.shared.locale, comment: "The Parental Guide category 'Profanity'.")
		}
	}
	/// The Parental Guide category 'Alcohol, Drugs & Smoking'.
	static var pgAlcoholDrugsAndSmoking: String {
		L10n.resolve {
			String(localized: "Alcohol, Drugs & Smoking", table: "Content", bundle: LanguageManager.shared.bundle, locale: LanguageManager.shared.locale, comment: "The Parental Guide category 'Alcohol, Drugs & Smoking'.")
		}
	}
	/// The Parental Guide category 'Frightening & Intense Scenes'.
	static var pgFrighteningAndIntenseScenes: String {
		L10n.resolve {
			String(localized: "Frightening & Intense Scenes", table: "Content", bundle: LanguageManager.shared.bundle, locale: LanguageManager.shared.locale, comment: "The Parental Guide category 'Frightening & Intense Scenes'.")
		}
	}
	/// The Parental Guide empty-category message.
	static var pgNoEvaluation: String {
		L10n.resolve {
			String(localized: "It looks like we don't have an evaluation for this category yet.", table: "Content", bundle: LanguageManager.shared.bundle, locale: LanguageManager.shared.locale, comment: "The Parental Guide empty-category message.")
		}
	}
	/// The self-label option 'Both'.
	static var both: String {
		L10n.resolve {
			String(localized: "Both", table: "Content", bundle: LanguageManager.shared.bundle, locale: LanguageManager.shared.locale, comment: "The self-label option 'Both'.")
		}
	}
	/// The library status 'Watching' for shows.
	static var watching: String {
		L10n.resolve {
			String(localized: "Watching", table: "Content", bundle: LanguageManager.shared.bundle, locale: LanguageManager.shared.locale, comment: "The library status 'Watching' for shows.")
		}
	}
	/// The library status 'Reading' for literatures.
	static var reading: String {
		L10n.resolve {
			String(localized: "Reading", table: "Content", bundle: LanguageManager.shared.bundle, locale: LanguageManager.shared.locale, comment: "The library status 'Reading' for literatures.")
		}
	}
	/// The library status 'Playing' for games.
	static var playing: String {
		L10n.resolve {
			String(localized: "Playing", table: "Content", bundle: LanguageManager.shared.bundle, locale: LanguageManager.shared.locale, comment: "The library status 'Playing' for games.")
		}
	}
	/// The alert title shown when a hashtag is detected.
	static func tagDetected(_ tagType: String) -> String {
		L10n.resolve {
			String(localized: "\(tagType) tag detected", table: "Content", bundle: LanguageManager.shared.bundle, locale: LanguageManager.shared.locale, comment: "The alert title shown when a hashtag is detected.")
		}
	}
	/// The Home 'Quick Links' section header.
	static var quickLinks: String {
		L10n.resolve {
			String(localized: "Quick Links", table: "Content", bundle: LanguageManager.shared.bundle, locale: LanguageManager.shared.locale, comment: "The Home 'Quick Links' section header.")
		}
	}
	/// The re-share attribution for your own repost.
	static var youReposted: String {
		L10n.resolve {
			String(localized: "You reposted this", table: "Content", bundle: LanguageManager.shared.bundle, locale: LanguageManager.shared.locale, comment: "The re-share attribution for your own repost.")
		}
	}
	/// The re-share attribution for another user's repost.
	static func userReposted(_ username: String) -> String {
		L10n.resolve {
			String(localized: "\(username) reposted this", table: "Content", bundle: LanguageManager.shared.bundle, locale: LanguageManager.shared.locale, comment: "The re-share attribution for another user's repost.")
		}
	}
	/// The library media-type breakdown line.
	static func libraryStatsBreakdown(_ tv: Int, _ movie: Int, _ ova: Int, _ other: Int) -> String {
		L10n.resolve {
			String(localized: "\(tv) TV · \(movie) Movie · \(ova) OVA · \(other) Music/ONA/Specials", table: "Content", bundle: LanguageManager.shared.bundle, locale: LanguageManager.shared.locale, comment: "The library media-type breakdown line.")
		}
	}
	/// The edit-profile bio placeholder.
	static var describeYourself: String {
		L10n.resolve {
			String(localized: "Describe yourself!", table: "Content", bundle: LanguageManager.shared.bundle, locale: LanguageManager.shared.locale, comment: "The edit-profile bio placeholder.")
		}
	}
	/// The monogram style 'Rounded'.
	static var rounded: String {
		L10n.resolve {
			String(localized: "Rounded", table: "Content", bundle: LanguageManager.shared.bundle, locale: LanguageManager.shared.locale, comment: "The monogram style 'Rounded'.")
		}
	}
	/// The monogram style 'Serif'.
	static var serif: String {
		L10n.resolve {
			String(localized: "Serif", table: "Content", bundle: LanguageManager.shared.bundle, locale: LanguageManager.shared.locale, comment: "The monogram style 'Serif'.")
		}
	}
	/// The monogram style 'Compressed'.
	static var compressed: String {
		L10n.resolve {
			String(localized: "Compressed", table: "Content", bundle: LanguageManager.shared.bundle, locale: LanguageManager.shared.locale, comment: "The monogram style 'Compressed'.")
		}
	}

	// MARK: - Authentication Lock
	/// The authentication settings name for Face ID.
	static var lockWithFaceID: String {
		L10n.resolve {
			String(localized: "Lock with Face ID & Passcode", table: "Content", bundle: LanguageManager.shared.bundle, locale: LanguageManager.shared.locale, comment: "The authentication settings name for Face ID.")
		}
	}
	/// The authentication settings name for Touch ID.
	static var lockWithTouchID: String {
		L10n.resolve {
			String(localized: "Lock with Touch ID & Passcode", table: "Content", bundle: LanguageManager.shared.bundle, locale: LanguageManager.shared.locale, comment: "The authentication settings name for Touch ID.")
		}
	}
	/// The authentication settings name for Optic ID.
	static var lockWithOpticID: String {
		L10n.resolve {
			String(localized: "Lock with Optic ID & Passcode", table: "Content", bundle: LanguageManager.shared.bundle, locale: LanguageManager.shared.locale, comment: "The authentication settings name for Optic ID.")
		}
	}
	/// The authentication settings name for passcode only.
	static var lockWithPasscode: String {
		L10n.resolve {
			String(localized: "Lock with Passcode", table: "Content", bundle: LanguageManager.shared.bundle, locale: LanguageManager.shared.locale, comment: "The authentication settings name for passcode only.")
		}
	}
	/// The authentication settings description for Face ID.
	static var lockDescriptionFaceID: String {
		L10n.resolve {
			String(localized: "Enable this option so that Kurozora is locked whenever you close it. You'll be asked to authenticate through Face ID or your device's passcode when you reopen the app.", table: "Content", bundle: LanguageManager.shared.bundle, locale: LanguageManager.shared.locale, comment: "The authentication settings description for Face ID.")
		}
	}
	/// The authentication settings description for Touch ID.
	static var lockDescriptionTouchID: String {
		L10n.resolve {
			String(localized: "Enable this option so that Kurozora is locked whenever you close it. You'll be asked to authenticate through Touch ID or your device's passcode when you reopen the app.", table: "Content", bundle: LanguageManager.shared.bundle, locale: LanguageManager.shared.locale, comment: "The authentication settings description for Touch ID.")
		}
	}
	/// The authentication settings description for Optic ID.
	static var lockDescriptionOpticID: String {
		L10n.resolve {
			String(localized: "Enable this option so that Kurozora is locked whenever you close it. You'll be asked to authenticate through Optic ID or your device's passcode when you reopen the app.", table: "Content", bundle: LanguageManager.shared.bundle, locale: LanguageManager.shared.locale, comment: "The authentication settings description for Optic ID.")
		}
	}
	/// The authentication settings description for passcode only.
	static var lockDescriptionPasscode: String {
		L10n.resolve {
			String(localized: "Enable this option so that Kurozora is locked whenever you close it. You'll be asked to authenticate through your device's passcode when you reopen the app.", table: "Content", bundle: LanguageManager.shared.bundle, locale: LanguageManager.shared.locale, comment: "The authentication settings description for passcode only.")
		}
	}
	/// The static descriptor label for a voice actor in the cast cell.
	static var voiceActor: String {
		L10n.resolve {
			String(localized: "Voice actor", table: "Content", bundle: LanguageManager.shared.bundle, locale: LanguageManager.shared.locale, comment: "The static descriptor label for a voice actor in the cast cell.")
		}
	}

	// MARK: - Literature Types & Calendar
	/// The literature type 'Doujinshi'.
	static var doujinshi: String {
		L10n.resolve {
			String(localized: "Doujinshi", table: "Content", bundle: LanguageManager.shared.bundle, locale: LanguageManager.shared.locale, comment: "The literature type 'Doujinshi'.")
		}
	}
	/// The literature type 'Manhwa'.
	static var manhwa: String {
		L10n.resolve {
			String(localized: "Manhwa", table: "Content", bundle: LanguageManager.shared.bundle, locale: LanguageManager.shared.locale, comment: "The literature type 'Manhwa'.")
		}
	}
	/// The literature type 'Manhua'.
	static var manhua: String {
		L10n.resolve {
			String(localized: "Manhua", table: "Content", bundle: LanguageManager.shared.bundle, locale: LanguageManager.shared.locale, comment: "The literature type 'Manhua'.")
		}
	}
	/// The literature type 'OEL' (original English-language).
	static var oel: String {
		L10n.resolve {
			String(localized: "OEL", table: "Content", bundle: LanguageManager.shared.bundle, locale: LanguageManager.shared.locale, comment: "The literature type 'OEL' (original English-language).")
		}
	}
	/// The literature type 'One-shot'.
	static var oneShot: String {
		L10n.resolve {
			String(localized: "One-shot", table: "Content", bundle: LanguageManager.shared.bundle, locale: LanguageManager.shared.locale, comment: "The literature type 'One-shot'.")
		}
	}
	/// The Apple Calendar app destination.
	static var calendar: String {
		L10n.resolve {
			String(localized: "Calendar", table: "Content", bundle: LanguageManager.shared.bundle, locale: LanguageManager.shared.locale, comment: "The Apple Calendar app destination.")
		}
	}

	// MARK: - Media Information Line
	/// The episode count shown in a media information line.
	static func episodeCount(_ count: Int) -> String {
		L10n.resolve {
			String(localized: "\(count) episodes", table: "Content", bundle: LanguageManager.shared.bundle, locale: LanguageManager.shared.locale, comment: "The episode count shown in a media information line.")
		}
	}
	/// The volume count shown in a media information line.
	static func volumeCount(_ count: Int) -> String {
		L10n.resolve {
			String(localized: "\(count) volumes", table: "Content", bundle: LanguageManager.shared.bundle, locale: LanguageManager.shared.locale, comment: "The volume count shown in a media information line.")
		}
	}
	/// The edition count shown in a media information line.
	static func editionCount(_ count: Int) -> String {
		L10n.resolve {
			String(localized: "\(count) editions", table: "Content", bundle: LanguageManager.shared.bundle, locale: LanguageManager.shared.locale, comment: "The edition count shown in a media information line.")
		}
	}
	/// A broadcast or publication schedule line pairing a weekday with a time.
	static func scheduleDayTime(_ day: String, _ time: String) -> String {
		L10n.resolve {
			String(localized: "\(day) at \(time)", table: "Content", bundle: LanguageManager.shared.bundle, locale: LanguageManager.shared.locale, comment: "A broadcast or publication schedule line pairing a weekday with a time.")
		}
	}
	/// The studio's Japanese name alias.
	static func studioAliasJapanese(_ name: String) -> String {
		L10n.resolve {
			String(localized: "Japanese: \(name)", table: "Content", bundle: LanguageManager.shared.bundle, locale: LanguageManager.shared.locale, comment: "The studio's Japanese name alias, where the placeholder is the name.")
		}
	}
	/// The studio's synonym aliases.
	static func studioAliasSynonyms(_ names: String) -> String {
		L10n.resolve {
			String(localized: "Synonyms: \(names)", table: "Content", bundle: LanguageManager.shared.bundle, locale: LanguageManager.shared.locale, comment: "The studio's synonym aliases, where the placeholder is the comma-separated names.")
		}
	}
	/// The badge label for the company that took over from a studio.
	///
	/// - Tag: L10n-studioSuccessor
	static var studioSuccessor: String {
		L10n.resolve {
			String(
				localized: "studioSuccessor",
				defaultValue: "Successor",
				table: "Content",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The badge label for the company that took over from a studio, not a sequel."
			)
		}
	}
	/// The badge label for the company a studio grew out of.
	///
	/// - Tag: L10n-studioPredecessor
	static var studioPredecessor: String {
		L10n.resolve {
			String(
				localized: "studioPredecessor",
				defaultValue: "Predecessor",
				table: "Content",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The badge label for the company a studio grew out of, not a prequel."
			)
		}
	}

	// MARK: - Broadcast Countdown
	/// The compact month count in a broadcast countdown.
	static func countdownMonths(_ count: Int) -> String {
		L10n.resolve {
			String(localized: "\(count)M", table: "Content", bundle: LanguageManager.shared.bundle, locale: LanguageManager.shared.locale, comment: "The compact month count in a broadcast countdown.")
		}
	}
	/// The compact day count in a broadcast countdown.
	static func countdownDays(_ count: Int) -> String {
		L10n.resolve {
			String(localized: "\(count)d", table: "Content", bundle: LanguageManager.shared.bundle, locale: LanguageManager.shared.locale, comment: "The compact day count in a broadcast countdown.")
		}
	}
	/// The compact hour count in a broadcast countdown.
	static func countdownHours(_ count: Int) -> String {
		L10n.resolve {
			String(localized: "\(count)h", table: "Content", bundle: LanguageManager.shared.bundle, locale: LanguageManager.shared.locale, comment: "The compact hour count in a broadcast countdown.")
		}
	}
	/// The compact minute count in a broadcast countdown.
	static func countdownMinutes(_ count: Int) -> String {
		L10n.resolve {
			String(localized: "\(count)m", table: "Content", bundle: LanguageManager.shared.bundle, locale: LanguageManager.shared.locale, comment: "The compact minute count in a broadcast countdown.")
		}
	}
	/// The compact second count in a broadcast countdown.
	static func countdownSeconds(_ count: Int) -> String {
		L10n.resolve {
			String(localized: "\(count)s", table: "Content", bundle: LanguageManager.shared.bundle, locale: LanguageManager.shared.locale, comment: "The compact second count in a broadcast countdown.")
		}
	}
	/// A broadcast countdown ending in the future.
	static func timeFromNow(_ duration: String) -> String {
		L10n.resolve {
			String(localized: "\(duration) from now", table: "Content", bundle: LanguageManager.shared.bundle, locale: LanguageManager.shared.locale, comment: "A broadcast countdown ending in the future, where the placeholder is the remaining duration.")
		}
	}
	/// A broadcast countdown that already started.
	static func timeAgo(_ duration: String) -> String {
		L10n.resolve {
			String(localized: "\(duration) ago", table: "Content", bundle: LanguageManager.shared.bundle, locale: LanguageManager.shared.locale, comment: "A broadcast countdown that already started, where the placeholder is the elapsed duration.")
		}
	}

	// MARK: - Siri Invocation Phrases
	/// The suggested Siri phrase for opening a title.
	static func openTitle(_ title: String) -> String {
		L10n.resolve {
			String(localized: "Open \(title)", table: "Content", bundle: LanguageManager.shared.bundle, locale: LanguageManager.shared.locale, comment: "The suggested Siri phrase for opening a title, where the placeholder is the title.")
		}
	}
	/// The suggested Siri phrase for opening a user's profile.
	static func openUserProfile(_ username: String) -> String {
		L10n.resolve {
			String(localized: "Open \(username)’s profile", table: "Content", bundle: LanguageManager.shared.bundle, locale: LanguageManager.shared.locale, comment: "The suggested Siri phrase for opening a user's profile, where the placeholder is the display name.")
		}
	}

	// MARK: - Profile Image Editor
	/// The accessibility label for the edit initials action.
	static var editInitials: String {
		L10n.resolve {
			String(localized: "Edit Initials", table: "Content", bundle: LanguageManager.shared.bundle, locale: LanguageManager.shared.locale, comment: "The accessibility label for the edit initials action.")
		}
	}
	/// The accessibility label for the font and width action.
	static var fontAndWidth: String {
		L10n.resolve {
			String(localized: "Font & Width", table: "Content", bundle: LanguageManager.shared.bundle, locale: LanguageManager.shared.locale, comment: "The accessibility label for the font and width action.")
		}
	}
	/// The accessibility label for the color action.
	static var color: String {
		L10n.resolve {
			String(localized: "Color", table: "Content", bundle: LanguageManager.shared.bundle, locale: LanguageManager.shared.locale, comment: "The accessibility label for the color action.")
		}
	}
	/// The accessibility label for the character search action.
	static var characterSearch: String {
		L10n.resolve {
			String(localized: "Character Search", table: "Content", bundle: LanguageManager.shared.bundle, locale: LanguageManager.shared.locale, comment: "The accessibility label for the character search action.")
		}
	}
	/// The accessibility label for the crop action.
	static var crop: String {
		L10n.resolve {
			String(localized: "Crop", table: "Content", bundle: LanguageManager.shared.bundle, locale: LanguageManager.shared.locale, comment: "The accessibility label for the crop action.")
		}
	}
	/// The accessibility label for the change emoji action.
	static var changeEmoji: String {
		L10n.resolve {
			String(localized: "Change Emoji", table: "Content", bundle: LanguageManager.shared.bundle, locale: LanguageManager.shared.locale, comment: "The accessibility label for the change emoji action.")
		}
	}
	/// The accessibility label for the change kaomoji action.
	static var changeKaomoji: String {
		L10n.resolve {
			String(localized: "Change Kaomoji", table: "Content", bundle: LanguageManager.shared.bundle, locale: LanguageManager.shared.locale, comment: "The accessibility label for the change kaomoji action.")
		}
	}
	/// The empty-state detail for a feed message that has no replies yet.
	///
	/// - Tag: L10n-noRepliesDetail
	static var noRepliesDetail: String {
		L10n.resolve {
			String(
				localized: "Be the first to reply to this message!",
				table: "Content",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The empty-state detail for a feed message that has no replies yet."
			)
		}
	}
	/// The empty-state detail for a character search with no results.
	///
	/// - Tag: L10n-noCharactersSearchDetail
	static var noCharactersSearchDetail: String {
		L10n.resolve {
			String(
				localized: "There are no characters matching your search. Please try a different query or check your WiFi connection.",
				table: "Content",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The empty-state detail for a character search with no results."
			)
		}
	}

	// MARK: - Counts
	/// The reply count shown as a feed message details title.
	///
	/// - Parameters:
	///   - formattedCount: The display-formatted reply count.
	///   - count: The number of replies.
	///
	/// - Tag: L10n-repliesCount
	static func repliesCount(_ formattedCount: String, count: Int) -> String {
		String(
			localized: "feedMessage.repliesCount",
			defaultValue: "\(formattedCount) \(count) replies",
			table: "Content",
			bundle: LanguageManager.shared.bundle,
			locale: LanguageManager.shared.locale,
			comment: "The reply count shown as a feed message details title."
		)
	}
	/// Pull-to-refresh title for a user list variant (followers/following/…).
	///
	/// - Tag: L10n-pullToRefreshUsersList
	static func pullToRefreshUsersList(_ type: String) -> String {
		String(
			localized: "Pull to refresh the \(type).",
			table: "Content",
			bundle: LanguageManager.shared.bundle,
			locale: LanguageManager.shared.locale,
			comment: "Pull-to-refresh title for a user list variant. '%@' is the list kind, e.g. 'followers', 'following'."
		)
	}

	/// Refresh-in-progress title for a user list variant (followers/following/…).
	///
	/// - Tag: L10n-refreshingUsersList
	static func refreshingUsersList(_ type: String) -> String {
		String(
			localized: "Refreshing \(type)…",
			table: "Content",
			bundle: LanguageManager.shared.bundle,
			locale: LanguageManager.shared.locale,
			comment: "Refresh-in-progress title for a user list variant. '%@' is the lowercase list kind, e.g. 'followers', 'following'."
		)
	}

	/// Pull-to-refresh title for the library list, scoped by tracking status.
	///
	/// - Tag: L10n-pullToRefreshLibrary
	static func pullToRefreshLibrary(_ status: String) -> String {
		String(
			localized: "Pull to refresh \(status) list…",
			table: "Content",
			bundle: LanguageManager.shared.bundle,
			locale: LanguageManager.shared.locale,
			comment: "Pull-to-refresh title for the library list scoped by tracking status. '%@' is the lowercase status, e.g. 'watching', 'completed'."
		)
	}

	/// Refresh-in-progress title for the library list, scoped by tracking status.
	///
	/// - Tag: L10n-refreshingLibrary
	static func refreshingLibrary(_ status: String) -> String {
		String(
			localized: "Refreshing \(status) list…",
			table: "Content",
			bundle: LanguageManager.shared.bundle,
			locale: LanguageManager.shared.locale,
			comment: "Refresh-in-progress title for the library list scoped by tracking status. '%@' is the lowercase status, e.g. 'watching', 'completed'."
		)
	}

	// MARK: - Music Library
	/// The alert button that deep-links to the user's Apple Music library.
	///
	/// - Tag: L10n-openAppleMusicLibrary
	static var openAppleMusicLibrary: String {
		L10n.resolve {
			String(
				localized: "Open Apple Music Library",
				table: "Content",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The alert button that deep-links to the user's Apple Music library."
			)
		}
	}

	// MARK: - Social actions (context menu)
	/// The string for the word 'unfollow'.
	///
	/// - Tag: L10n-unfollow
	static var unfollow: String {
		L10n.resolve {
			String(
				localized: "Unfollow",
				table: "Content",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The string for the word 'unfollow'."
			)
		}
	}
	/// The string for the word 'block'.
	///
	/// - Tag: L10n-block
	static var block: String {
		L10n.resolve {
			String(
				localized: "Block",
				table: "Content",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The string for the word 'block'."
			)
		}
	}
	/// The string for the word 'unblock'.
	///
	/// - Tag: L10n-unblock
	static var unblock: String {
		L10n.resolve {
			String(
				localized: "Unblock",
				table: "Content",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The string for the word 'unblock'."
			)
		}
	}
	/// The string for the word 'unpin'.
	///
	/// - Tag: L10n-unpin
	static var unpin: String {
		L10n.resolve {
			String(
				localized: "Unpin",
				table: "Content",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The string for the word 'unpin'."
			)
		}
	}
	/// The string for the word 'pin'.
	///
	/// - Tag: L10n-pin
	static var pin: String {
		L10n.resolve {
			String(
				localized: "Pin",
				table: "Content",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The string for the word 'pin'."
			)
		}
	}
	/// The string for the word 'unlike'.
	///
	/// - Tag: L10n-unlike
	static var unlike: String {
		L10n.resolve {
			String(
				localized: "Unlike",
				table: "Content",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The string for the word 'unlike'."
			)
		}
	}
	/// The string for the word 'like'.
	///
	/// - Tag: L10n-like
	static var like: String {
		L10n.resolve {
			String(
				localized: "Like",
				table: "Content",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The string for the word 'like'."
			)
		}
	}
	/// The string for the word 'edit'.
	///
	/// - Tag: L10n-edit
	static var edit: String {
		L10n.resolve {
			String(
				localized: "Edit",
				table: "Content",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The string for the word 'edit'."
			)
		}
	}
	/// The string for the word 'delete'.
	///
	/// - Tag: L10n-delete
	static var delete: String {
		L10n.resolve {
			String(
				localized: "Delete",
				table: "Content",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The string for the word 'delete'."
			)
		}
	}
	/// The string for the word 'report'.
	///
	/// - Tag: L10n-report
	static var report: String {
		L10n.resolve {
			String(
				localized: "Report",
				table: "Content",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The string for the word 'report'."
			)
		}
	}

	// MARK: - Parental Guide
	/// Title of the Parental Guide screen.
	///
	/// - Tag: L10n-parentalGuide
	static var parentalGuide: String {
		L10n.resolve {
			String(
				localized: "Parental Guide",
				table: "Content",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The title of the Parental Guide screen."
			)
		}
	}
	/// The empty-state title on the Parental Guide screen when no entries exist yet.
	///
	/// - Tag: L10n-noParentalGuideYet
	static var noParentalGuideYet: String {
		L10n.resolve {
			String(
				localized: "No Parental Guide Yet",
				table: "Content",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The empty-state title on the Parental Guide screen when no entries exist yet."
			)
		}
	}
	/// The empty-state body on the Parental Guide screen when no entries exist yet.
	///
	/// - Tag: L10n-beTheFirstToContribute
	static var beTheFirstToContribute: String {
		L10n.resolve {
			String(
				localized: "Be the first to contribute.",
				table: "Content",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The empty-state body on the Parental Guide screen when no entries exist yet."
			)
		}
	}
	/// The empty-state title on a Parental Guide category screen when no entries exist.
	///
	/// - Tag: L10n-noParentalGuideEntries
	static var noParentalGuideEntries: String {
		L10n.resolve {
			String(
				localized: "No Entries",
				table: "Content",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The empty-state title on a Parental Guide category screen when no entries exist."
			)
		}
	}
	/// The empty-state body on a Parental Guide category screen when no entries exist.
	///
	/// - Tag: L10n-noParentalGuideEntriesDetail
	static var noParentalGuideEntriesDetail: String {
		L10n.resolve {
			String(
				localized: "There are no entries in this category yet.",
				table: "Content",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The empty-state body on a Parental Guide category screen when no entries exist."
			)
		}
	}
	/// Header for the Parental Guide summary section.
	///
	/// - Tag: L10n-parentalGuideSummary
	static var parentalGuideSummary: String {
		L10n.resolve {
			String(
				localized: "Summary",
				table: "Content",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "Header for the Parental Guide summary section."
			)
		}
	}
	/// Row label for the rating in the Parental Guide summary.
	///
	/// - Tag: L10n-parentalGuideRating
	static var parentalGuideRating: String {
		L10n.resolve {
			String(
				localized: "Rating",
				table: "Content",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "Row label for the rating in the Parental Guide summary."
			)
		}
	}
	/// Placeholder shown for an unknown rating in the Parental Guide summary.
	///
	/// - Tag: L10n-parentalGuideRatingUnknown
	static var parentalGuideRatingUnknown: String {
		L10n.resolve {
			String(
				localized: "Unknown",
				table: "Content",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "Placeholder shown for an unknown rating in the Parental Guide summary."
			)
		}
	}
	/// Placeholder shown for a category with no submissions in the Parental Guide summary.
	///
	/// - Tag: L10n-parentalGuideNoSubmissions
	static var parentalGuideNoSubmissions: String {
		L10n.resolve {
			String(
				localized: "None",
				table: "Content",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "Placeholder shown for a category with no submissions in the Parental Guide summary."
			)
		}
	}
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
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
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
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
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
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
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
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "Title of the editor when editing an existing entry for a category. The argument is the category display name."
			),
			displayName
		)
	}
	/// Header for the severity section of the Parental Guide editor.
	///
	/// - Tag: L10n-parentalGuideSeverity
	static var parentalGuideSeverity: String {
		L10n.resolve {
			String(
				localized: "Severity",
				table: "Content",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "Header for the severity section of the Parental Guide editor."
			)
		}
	}
	/// Header for the frequency section of the Parental Guide editor.
	///
	/// - Tag: L10n-parentalGuideFrequency
	static var parentalGuideFrequency: String {
		L10n.resolve {
			String(
				localized: "Frequency",
				table: "Content",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "Header for the frequency section of the Parental Guide editor."
			)
		}
	}
	/// Header for the depiction section of the Parental Guide editor.
	///
	/// - Tag: L10n-parentalGuideDepiction
	static var parentalGuideDepiction: String {
		L10n.resolve {
			String(
				localized: "Depiction",
				table: "Content",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "Header for the depiction section of the Parental Guide editor."
			)
		}
	}
	/// Header for the reason section of the Parental Guide editor.
	///
	/// - Tag: L10n-parentalGuideReason
	static var parentalGuideReason: String {
		L10n.resolve {
			String(
				localized: "Reason",
				table: "Content",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "Header for the reason section of the Parental Guide editor."
			)
		}
	}
	/// The placeholder string for the reason text view in the Parental Guide editor.
	///
	/// - Tag: L10n-whatStandsOut
	static var whatStandsOut: String {
		L10n.resolve {
			String(
				localized: "What stands out?",
				table: "Content",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The placeholder string for the reason text view in the Parental Guide editor."
			)
		}
	}
	/// Label for a spoiler toggle.
	///
	/// - Tag: L10n-spoiler
	static var spoiler: String {
		L10n.resolve {
			String(
				localized: "Spoiler",
				table: "Content",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "Label for the spoiler toggle in the Parental Guide editor."
			)
		}
	}
	/// Title of the destructive delete row in the Parental Guide editor.
	///
	/// - Tag: L10n-deleteThisParentalGuideEntry
	static var deleteThisParentalGuideEntry: String {
		L10n.resolve {
			String(
				localized: "Delete this entry",
				table: "Content",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "Title of the destructive delete row in the Parental Guide editor."
			)
		}
	}
	/// Title of the confirmation alert when deleting a Parental Guide entry.
	///
	/// - Tag: L10n-deleteParentalGuideEntryConfirmTitle
	static var deleteParentalGuideEntryConfirmTitle: String {
		L10n.resolve {
			String(
				localized: "Delete this entry?",
				table: "Content",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "Title of the confirmation alert when deleting a Parental Guide entry."
			)
		}
	}
	/// Body of the confirmation alert when deleting a Parental Guide entry.
	///
	/// - Tag: L10n-deleteParentalGuideEntryConfirmMessage
	static var deleteParentalGuideEntryConfirmMessage: String {
		L10n.resolve {
			String(
				localized: "This action can't be undone.",
				table: "Content",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "Body of the confirmation alert when deleting a Parental Guide entry."
			)
		}
	}
	/// Title of the discard-changes alert in the Parental Guide editor.
	///
	/// - Tag: L10n-discardParentalGuideChanges
	static var discardParentalGuideChanges: String {
		L10n.resolve {
			String(
				localized: "Discard changes?",
				table: "Content",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "Title of the discard-changes alert in the Parental Guide editor."
			)
		}
	}
	/// Cancel button on the discard-changes alert.
	///
	/// - Tag: L10n-keepEditing
	static var keepEditing: String {
		L10n.resolve {
			String(
				localized: "Keep Editing",
				table: "Content",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "Cancel button on the discard-changes alert."
			)
		}
	}
	/// Generic error alert title shown when a Parental Guide submission fails.
	///
	/// - Tag: L10n-parentalGuideErrorTitle
	static var parentalGuideErrorTitle: String {
		L10n.resolve {
			String(
				localized: "Something went wrong",
				table: "Content",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "Generic error alert title shown when a Parental Guide submission fails."
			)
		}
	}
	/// Generic OK button shown on Parental Guide alerts.
	///
	/// - Tag: L10n-okay
	static var okay: String {
		L10n.resolve {
			String(
				localized: "OK",
				table: "Content",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "Generic OK button shown on Parental Guide alerts."
			)
		}
	}
	/// Error message shown when the server's Parental Guide submission response is empty.
	///
	/// - Tag: L10n-parentalGuideEmptyResponse
	static var parentalGuideEmptyResponse: String {
		L10n.resolve {
			String(
				localized: "Server returned no entry.",
				table: "Content",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "Error message shown when the server's Parental Guide submission response is empty."
			)
		}
	}
	/// Spoiler-warning banner overlaid on a parental guide entry on touch platforms.
	///
	/// - Tag: L10n-parentalGuideReasonSpoilerTap
	static var parentalGuideReasonSpoilerTap: String {
		L10n.resolve {
			String(
				localized: "This reason contains spoilers — tap to view",
				table: "Content",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "Spoiler-warning banner overlaid on a parental guide entry on touch platforms."
			)
		}
	}
	/// Spoiler-warning banner overlaid on a parental guide entry on Mac Catalyst.
	///
	/// - Tag: L10n-parentalGuideReasonSpoilerClick
	static var parentalGuideReasonSpoilerClick: String {
		L10n.resolve {
			String(
				localized: "This reason contains spoilers — click to view",
				table: "Content",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "Spoiler-warning banner overlaid on a parental guide entry on Mac Catalyst."
			)
		}
	}
	/// Spoiler-warning banner overlaid on a review on touch platforms.
	///
	/// - Tag: L10n-reviewSpoilerTap
	static var reviewSpoilerTap: String {
		L10n.resolve {
			String(
				localized: "This review contains spoilers. Tap to view",
				table: "Content",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "Spoiler-warning banner overlaid on a review on touch platforms."
			)
		}
	}
	/// Spoiler-warning banner overlaid on a review on pointer platforms.
	///
	/// - Tag: L10n-reviewSpoilerClick
	static var reviewSpoilerClick: String {
		L10n.resolve {
			String(
				localized: "This review contains spoilers. Click to view",
				table: "Content",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "Spoiler-warning banner overlaid on a review on pointer platforms."
			)
		}
	}
	/// Button that reveals the reviews sorted to the bottom.
	///
	/// - Tag: L10n-reviewsShowShort
	static var reviewsShowShort: String {
		L10n.resolve {
			String(
				localized: "Show short reviews",
				table: "Content",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "Button that reveals the reviews sorted to the bottom."
			)
		}
	}
	/// Button that hides the reviews sorted to the bottom.
	///
	/// - Tag: L10n-reviewsHideShort
	static var reviewsHideShort: String {
		L10n.resolve {
			String(
				localized: "Hide short reviews",
				table: "Content",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "Button that hides the reviews sorted to the bottom."
			)
		}
	}
	/// Button that reveals the earlier versions of a review.
	///
	/// - Tag: L10n-reviewsShowEarlier
	static func reviewsShowEarlier(_ count: String) -> String {
		L10n.resolve {
			String(
				format: String(
					localized: "Show earlier versions (%@)",
					table: "Content",
					bundle: LanguageManager.shared.bundle,
					locale: LanguageManager.shared.locale,
					comment: "Button that reveals the earlier versions of a review."
				),
				count
			)
		}
	}
	/// Button that hides the earlier versions of a review.
	///
	/// - Tag: L10n-reviewsHideEarlier
	static var reviewsHideEarlier: String {
		L10n.resolve {
			String(
				localized: "Hide earlier versions",
				table: "Content",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "Button that hides the earlier versions of a review."
			)
		}
	}
	/// Marker on a review whose text was rewritten.
	///
	/// - Tag: L10n-reviewEdited
	static var reviewEdited: String {
		L10n.resolve {
			String(
				localized: "Edited",
				table: "Content",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "Marker on a review whose text was rewritten."
			)
		}
	}
	/// Segment title for a review that recommends the item.
	///
	/// - Tag: L10n-reviewRecommended
	static var reviewRecommended: String {
		L10n.resolve {
			String(
				localized: "Recommended",
				table: "Content",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "Segment title for a review that recommends the item."
			)
		}
	}
	/// Segment title for a review with mixed feelings about the item.
	///
	/// - Tag: L10n-reviewMixedFeelings
	static var reviewMixedFeelings: String {
		L10n.resolve {
			String(
				localized: "Mixed Feelings",
				table: "Content",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "Segment title for a review with mixed feelings about the item."
			)
		}
	}
	/// Segment title for a review that does not recommend the item.
	///
	/// - Tag: L10n-reviewNotRecommended
	static var reviewNotRecommended: String {
		L10n.resolve {
			String(
				localized: "Not Recommended",
				table: "Content",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "Segment title for a review that does not recommend the item."
			)
		}
	}
	/// Section title for the reviewer's recommendation.
	///
	/// - Tag: L10n-reviewRecommendation
	static var reviewRecommendation: String {
		L10n.resolve {
			String(
				localized: "Recommendation",
				table: "Content",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "Section title for the reviewer's recommendation."
			)
		}
	}
	/// Badge showing how far the reviewer had watched when they wrote the review.
	///
	/// - Tag: L10n-reviewProgressEpisode
	static func reviewProgressEpisode(_ progress: String, _ total: String) -> String {
		L10n.resolve {
			String(
				format: String(
					localized: "Ep %1$@/%2$@",
					table: "Content",
					bundle: LanguageManager.shared.bundle,
					locale: LanguageManager.shared.locale,
					comment: "Badge showing how far the reviewer had watched when they wrote the review."
				),
				progress, total
			)
		}
	}
	/// Badge showing how far the reviewer had watched, when the total is unknown.
	///
	/// - Tag: L10n-reviewProgressEpisodeOnly
	static func reviewProgressEpisodeOnly(_ progress: String) -> String {
		L10n.resolve {
			String(
				format: String(
					localized: "Ep %@",
					table: "Content",
					bundle: LanguageManager.shared.bundle,
					locale: LanguageManager.shared.locale,
					comment: "Badge showing how far the reviewer had watched, when the total is unknown."
				),
				progress
			)
		}
	}
	/// Heading on the app's own editorial endorsement of an item.
	///
	/// - Tag: L10n-editorsChoice
	static var editorsChoice: String {
		L10n.resolve {
			String(
				localized: "Editor’s Choice",
				table: "Content",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "Heading on the app's own editorial endorsement of an item."
			)
		}
	}
	/// Byline shown when an editorial credits the app itself.
	///
	/// - Tag: L10n-kurozoraEditors
	static var kurozoraEditors: String {
		L10n.resolve {
			String(
				localized: "The Kurozora Editors",
				table: "Content",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "Byline shown when an editorial credits the app itself."
			)
		}
	}
	/// Marker on a user review the staff elevated.
	///
	/// - Tag: L10n-communityPick
	static var communityPick: String {
		L10n.resolve {
			String(
				localized: "Community Pick",
				table: "Content",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "Marker on a user review the staff elevated."
			)
		}
	}
	/// Context-menu action that makes a review the item's Community Pick.
	///
	/// - Tag: L10n-markAsCommunityPick
	static var markAsCommunityPick: String {
		L10n.resolve {
			String(
				localized: "Mark as Community Pick",
				table: "Content",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "Context-menu action that makes a review the item's Community Pick."
			)
		}
	}
	/// Context-menu action that takes the Community Pick marker off a review.
	///
	/// - Tag: L10n-removeCommunityPick
	static var removeCommunityPick: String {
		L10n.resolve {
			String(
				localized: "Remove Community Pick",
				table: "Content",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "Context-menu action that makes a review the item's Community Pick."
			)
		}
	}

	/// Title shown in the navigation bar of the Parental Guide report sheet.
	///
	/// - Tag: L10n-reportParentalGuideEntry
	static var reportParentalGuideEntry: String {
		L10n.resolve {
			String(
				localized: "Report Entry",
				table: "Content",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "Title shown in the navigation bar of the Parental Guide report sheet."
			)
		}
	}

	/// Header above the reason picker in the Parental Guide report sheet.
	///
	/// - Tag: L10n-reportReasonHeader
	static var reportReasonHeader: String {
		L10n.resolve {
			String(
				localized: "Reason",
				table: "Content",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "Header above the reason picker in the Parental Guide report sheet."
			)
		}
	}

	/// Header above the optional details editor in the Parental Guide report sheet.
	///
	/// - Tag: L10n-reportDetailsHeader
	static var reportDetailsHeader: String {
		L10n.resolve {
			String(
				localized: "Details",
				table: "Content",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "Header above the details editor in the Parental Guide report sheet."
			)
		}
	}

	/// Placeholder shown in the optional details editor.
	///
	/// - Tag: L10n-reportDetailsPlaceholder
	static var reportDetailsPlaceholder: String {
		L10n.resolve {
			String(
				localized: "Tell us more (optional)",
				table: "Content",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "Placeholder shown in the details editor when optional."
			)
		}
	}

	/// Placeholder shown in the details editor when the reason is `Other` and details are required.
	///
	/// - Tag: L10n-reportDetailsPlaceholderRequired
	static var reportDetailsPlaceholderRequired: String {
		L10n.resolve {
			String(
				localized: "Tell us more",
				table: "Content",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "Placeholder shown in the details editor when the reason is `Other` and details are required."
			)
		}
	}

	/// Submit button title in the Parental Guide report sheet.
	///
	/// - Tag: L10n-reportSubmit
	static var reportSubmit: String {
		L10n.resolve {
			String(
				localized: "Submit",
				table: "Content",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "Submit button title in the Parental Guide report sheet."
			)
		}
	}

	/// Title of the success alert shown after a Parental Guide entry has been reported.
	///
	/// - Tag: L10n-reportSuccessTitle
	static var reportSuccessTitle: String {
		L10n.resolve {
			String(
				localized: "Reported",
				table: "Content",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "Title of the success alert shown after a Parental Guide entry has been reported."
			)
		}
	}

	/// Body of the success alert shown after a Parental Guide entry has been reported.
	///
	/// - Tag: L10n-reportSuccessMessage
	static var reportSuccessMessage: String {
		L10n.resolve {
			String(
				localized: "Thanks. We'll review this entry shortly.",
				table: "Content",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "Body of the success alert shown after a Parental Guide entry has been reported."
			)
		}
	}

	/// Display name of the `inaccurate` report reason.
	///
	/// - Tag: L10n-reportReasonInaccurate
	static var reportReasonInaccurate: String {
		L10n.resolve {
			String(
				localized: "Inaccurate",
				table: "Content",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "Display name of the `inaccurate` Parental Guide report reason."
			)
		}
	}

	/// Display name of the `spoiler` report reason.
	///
	/// - Tag: L10n-reportReasonSpoiler
	static var reportReasonSpoiler: String {
		L10n.resolve {
			String(
				localized: "Spoiler",
				table: "Content",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "Display name of the `spoiler` Parental Guide report reason."
			)
		}
	}

	/// Display name of the `spam` report reason.
	///
	/// - Tag: L10n-reportReasonSpam
	static var reportReasonSpam: String {
		L10n.resolve {
			String(
				localized: "Spam",
				table: "Content",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "Display name of the `spam` Parental Guide report reason."
			)
		}
	}

	/// Display name of the `inappropriate` report reason.
	///
	/// - Tag: L10n-reportReasonInappropriate
	static var reportReasonInappropriate: String {
		L10n.resolve {
			String(
				localized: "Inappropriate",
				table: "Content",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "Display name of the `inappropriate` Parental Guide report reason."
			)
		}
	}

	/// Display name of the `other` report reason.
	///
	/// - Tag: L10n-reportReasonOther
	static var reportReasonOther: String {
		L10n.resolve {
			String(
				localized: "Other",
				table: "Content",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "Display name of the `other` Parental Guide report reason."
			)
		}
	}

	/// Display name of the `spam` report reason.
	///
	/// - Tag: L10n-reportReasonSpamOrAdvertising
	static var reportReasonSpamOrAdvertising: String {
		L10n.resolve {
			String(
				localized: "Spam or advertising",
				table: "Content",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "Display name of the `spam` report reason."
			)
		}
	}

	/// Display name of the `notAReview` report reason.
	///
	/// - Tag: L10n-reportReasonNotAReview
	static var reportReasonNotAReview: String {
		L10n.resolve {
			String(
				localized: "Not a real review",
				table: "Content",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "Display name of the `notAReview` report reason."
			)
		}
	}

	/// Display name of the `spoiler` report reason.
	///
	/// - Tag: L10n-reportReasonUnmarkedSpoilers
	static var reportReasonUnmarkedSpoilers: String {
		L10n.resolve {
			String(
				localized: "Unmarked spoilers",
				table: "Content",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "Display name of the `spoiler` report reason."
			)
		}
	}

	/// Display name of the `abuse` report reason.
	///
	/// - Tag: L10n-reportReasonAbuse
	static var reportReasonAbuse: String {
		L10n.resolve {
			String(
				localized: "Hate, harassment or threats",
				table: "Content",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "Display name of the `abuse` report reason."
			)
		}
	}

	/// Display name of the `inappropriate` report reason.
	///
	/// - Tag: L10n-reportReasonInappropriateContent
	static var reportReasonInappropriateContent: String {
		L10n.resolve {
			String(
				localized: "Inappropriate content",
				table: "Content",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "Display name of the `inappropriate` report reason."
			)
		}
	}

	/// Display name of the `selfHarm` report reason.
	///
	/// - Tag: L10n-reportReasonSelfHarm
	static var reportReasonSelfHarm: String {
		L10n.resolve {
			String(
				localized: "Suicide or self-harm",
				table: "Content",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "Display name of the `selfHarm` report reason."
			)
		}
	}

	/// Display name of the `piracy` report reason.
	///
	/// - Tag: L10n-reportReasonPiracy
	static var reportReasonPiracy: String {
		L10n.resolve {
			String(
				localized: "Unauthorized links",
				table: "Content",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "Display name of the `piracy` report reason."
			)
		}
	}

	/// Display name of the `other` report reason offered for reviews and feed messages.
	///
	/// - Tag: L10n-reportReasonSomethingElse
	static var reportReasonSomethingElse: String {
		L10n.resolve {
			String(
				localized: "Something else",
				table: "Content",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "Display name of the `other` report reason offered for reviews and feed messages."
			)
		}
	}

	// MARK: - TV Rating Descriptions
	/// The descriptive label for the 'Not Rated' TV rating.
	///
	/// - Tag: L10n-tvRatingNotRated
	static var tvRatingNotRated: String {
		L10n.resolve {
			String(
				localized: "Not Rated",
				table: "Content",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The descriptive label for the 'Not Rated' TV rating."
			)
		}
	}
	/// The descriptive label for the 'All Ages' TV rating.
	///
	/// - Tag: L10n-tvRatingAllAges
	static var tvRatingAllAges: String {
		L10n.resolve {
			String(
				localized: "All Ages",
				table: "Content",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The descriptive label for the 'All Ages' TV rating."
			)
		}
	}
	/// The descriptive label for the 'Parental Guidance Suggested' TV rating.
	///
	/// - Tag: L10n-tvRatingParentalGuidance
	static var tvRatingParentalGuidance: String {
		L10n.resolve {
			String(
				localized: "Parental Guidance Suggested",
				table: "Content",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The descriptive label for the 'Parental Guidance Suggested' TV rating."
			)
		}
	}
	/// The descriptive label for the 'Violence & Profanity' TV rating.
	///
	/// - Tag: L10n-tvRatingViolenceProfanity
	static var tvRatingViolenceProfanity: String {
		L10n.resolve {
			String(
				localized: "Violence & Profanity",
				table: "Content",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The descriptive label for the 'Violence & Profanity' TV rating."
			)
		}
	}
	/// The descriptive label for the 'Adults Only' TV rating.
	///
	/// - Tag: L10n-tvRatingAdultsOnly
	static var tvRatingAdultsOnly: String {
		L10n.resolve {
			String(
				localized: "Adults Only",
				table: "Content",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The descriptive label for the 'Adults Only' TV rating."
			)
		}
	}

	// MARK: - Country of Origin
	/// The localized country name for China.
	///
	/// - Tag: L10n-countryChina
	static var countryChina: String {
		L10n.resolve {
			String(
				localized: "China",
				table: "Content",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The localized country name for China."
			)
		}
	}
	/// The localized country name for Japan.
	///
	/// - Tag: L10n-countryJapan
	static var countryJapan: String {
		L10n.resolve {
			String(
				localized: "Japan",
				table: "Content",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The localized country name for Japan."
			)
		}
	}
	/// The localized country name for Korea.
	///
	/// - Tag: L10n-countryKorea
	static var countryKorea: String {
		L10n.resolve {
			String(
				localized: "Korea",
				table: "Content",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The localized country name for Korea."
			)
		}
	}
	/// The localized country name for the United States.
	///
	/// - Tag: L10n-countryUnitedStates
	static var countryUnitedStates: String {
		L10n.resolve {
			String(
				localized: "United States",
				table: "Content",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The localized country name for the United States."
			)
		}
	}

	// MARK: - Milestone Kinds
	/// The label for the 'minutes watched' milestone.
	///
	/// - Tag: L10n-milestoneMinutesWatched
	static var milestoneMinutesWatched: String {
		L10n.resolve {
			String(
				localized: "Minutes Watched",
				table: "Content",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The label for the 'minutes watched' milestone."
			)
		}
	}
	/// The label for the 'episodes watched' milestone.
	///
	/// - Tag: L10n-milestoneEpisodesWatched
	static var milestoneEpisodesWatched: String {
		L10n.resolve {
			String(
				localized: "Episodes Watched",
				table: "Content",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The label for the 'episodes watched' milestone."
			)
		}
	}
	/// The label for the 'minutes read' milestone.
	///
	/// - Tag: L10n-milestoneMinutesRead
	static var milestoneMinutesRead: String {
		L10n.resolve {
			String(
				localized: "Minutes Read",
				table: "Content",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The label for the 'minutes read' milestone."
			)
		}
	}
	/// The label for the 'chapters read' milestone.
	///
	/// - Tag: L10n-milestoneChaptersRead
	static var milestoneChaptersRead: String {
		L10n.resolve {
			String(
				localized: "Chapters Read",
				table: "Content",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The label for the 'chapters read' milestone."
			)
		}
	}
	/// The label for the 'minutes played' milestone.
	///
	/// - Tag: L10n-milestoneMinutesPlayed
	static var milestoneMinutesPlayed: String {
		L10n.resolve {
			String(
				localized: "Minutes Played",
				table: "Content",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The label for the 'minutes played' milestone."
			)
		}
	}
	/// The label for the 'games played' milestone.
	///
	/// - Tag: L10n-milestoneGamesPlayed
	static var milestoneGamesPlayed: String {
		L10n.resolve {
			String(
				localized: "Games Played",
				table: "Content",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The label for the 'games played' milestone."
			)
		}
	}
	/// The label for the 'top percentile' milestone.
	///
	/// - Tag: L10n-milestoneTopPercentile
	static var milestoneTopPercentile: String {
		L10n.resolve {
			String(
				localized: "Top Percentile",
				table: "Content",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The label for the 'top percentile' milestone."
			)
		}
	}
	/// The 'minutes' unit label for a milestone value.
	///
	/// - Tag: L10n-unitMinutes
	static var unitMinutes: String {
		L10n.resolve {
			String(
				localized: "Minutes",
				table: "Content",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The 'minutes' unit label for a milestone value."
			)
		}
	}
	/// The 'percentile' unit label for a milestone value.
	///
	/// - Tag: L10n-unitPercentile
	static var unitPercentile: String {
		L10n.resolve {
			String(
				localized: "Percentile",
				table: "Content",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The 'percentile' unit label for a milestone value."
			)
		}
	}

	// MARK: - Profile Badges
	/// The title shown on the new-user profile badge.
	///
	/// - Tag: L10n-badgeNewUserTitle
	static var badgeNewUserTitle: String {
		L10n.resolve {
			String(
				localized: "I'm new here!",
				table: "Content",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The title shown on the new-user profile badge."
			)
		}
	}
	/// The title shown on the developer profile badge.
	///
	/// - Tag: L10n-badgeDeveloperTitle
	static var badgeDeveloperTitle: String {
		L10n.resolve {
			String(
				localized: "Active Developer",
				table: "Content",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The title shown on the developer profile badge."
			)
		}
	}
	/// The title shown on the early-supporter profile badge.
	///
	/// - Tag: L10n-badgeEarlySupporterTitle
	static var badgeEarlySupporterTitle: String {
		L10n.resolve {
			String(
				localized: "Early Supporter",
				table: "Content",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The title shown on the early-supporter profile badge."
			)
		}
	}
	/// The title shown on the staff profile badge.
	///
	/// - Tag: L10n-badgeStaffTitle
	static var badgeStaffTitle: String {
		L10n.resolve {
			String(
				localized: "Staff",
				table: "Content",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The title shown on the staff profile badge."
			)
		}
	}
	/// The title shown on the verified profile badge.
	///
	/// - Tag: L10n-badgeVerifiedTitle
	static var badgeVerifiedTitle: String {
		L10n.resolve {
			String(
				localized: "Verified",
				table: "Content",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The title shown on the verified profile badge."
			)
		}
	}
	/// The new-user badge description shown on your own profile.
	///
	/// - Tag: L10n-badgeNewUserCurrentUserDescription
	static var badgeNewUserCurrentUserDescription: String {
		L10n.resolve {
			String(
				localized: "Welcome to Kurozora! Introduce yourself to get started (^_^)/",
				table: "Content",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The new-user badge description shown on your own profile."
			)
		}
	}
	/// The new-user badge description shown on another user's profile.
	///
	/// - Parameter username: The display name of the user.
	///
	/// - Tag: L10n-badgeNewUserDescription
	static func badgeNewUserDescription(_ username: String) -> String {
		String(
			localized: "\(username) is new to Kurozora. Say hi to them (^o^)/",
			table: "Content",
			bundle: LanguageManager.shared.bundle,
			locale: LanguageManager.shared.locale,
			comment: "The new-user badge description shown on another user's profile."
		)
	}
	/// The developer badge description.
	///
	/// - Parameter username: The display name of the user.
	///
	/// - Tag: L10n-badgeDeveloperDescription
	static func badgeDeveloperDescription(_ username: String) -> String {
		String(
			localized: "\(username) is an active developer.",
			table: "Content",
			bundle: LanguageManager.shared.bundle,
			locale: LanguageManager.shared.locale,
			comment: "The developer badge description."
		)
	}
	/// The early-supporter badge description.
	///
	/// - Parameter username: The display name of the user.
	///
	/// - Tag: L10n-badgeEarlySupporterDescription
	static func badgeEarlySupporterDescription(_ username: String) -> String {
		String(
			localized: "\(username) is an early supporter of Kurozora.",
			table: "Content",
			bundle: LanguageManager.shared.bundle,
			locale: LanguageManager.shared.locale,
			comment: "The early-supporter badge description."
		)
	}
	/// The staff badge description.
	///
	/// - Parameter username: The display name of the user.
	///
	/// - Tag: L10n-badgeStaffDescription
	static func badgeStaffDescription(_ username: String) -> String {
		String(
			localized: "\(username) is a staff member.",
			table: "Content",
			bundle: LanguageManager.shared.bundle,
			locale: LanguageManager.shared.locale,
			comment: "The staff badge description."
		)
	}
	/// The Pro badge description.
	///
	/// - Parameter username: The display name of the user.
	///
	/// - Tag: L10n-badgeProDescription
	static func badgeProDescription(_ username: String) -> String {
		String(
			localized: "\(username) is a Pro user.",
			table: "Content",
			bundle: LanguageManager.shared.bundle,
			locale: LanguageManager.shared.locale,
			comment: "The Pro badge description."
		)
	}
	/// The subscriber badge description.
	///
	/// - Parameters:
	///   - username: The display name of the user.
	///   - date: The localized date the user subscribed.
	///
	/// - Tag: L10n-badgeSubscriberDescription
	static func badgeSubscriberDescription(_ username: String, since date: String) -> String {
		String(
			localized: "\(username) is a Kurozora+ subscriber since \(date).",
			table: "Content",
			bundle: LanguageManager.shared.bundle,
			locale: LanguageManager.shared.locale,
			comment: "The subscriber badge description."
		)
	}
	/// The verified badge description.
	///
	/// - Parameter username: The display name of the user.
	///
	/// - Tag: L10n-badgeVerifiedDescription
	static func badgeVerifiedDescription(_ username: String) -> String {
		String(
			localized: "\(username) is verified because they are notable in animators, voice actors, entertainment studios, or another designated category.",
			table: "Content",
			bundle: LanguageManager.shared.bundle,
			locale: LanguageManager.shared.locale,
			comment: "The verified badge description."
		)
	}
	/// The action button on the new-user badge that mentions the user.
	///
	/// - Tag: L10n-badgeMentionUser
	static var badgeMentionUser: String {
		L10n.resolve {
			String(
				localized: "Mention User",
				table: "Content",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The action button on the new-user badge that mentions the user."
			)
		}
	}
	/// The action button on the developer badge.
	///
	/// - Tag: L10n-badgeBecomeDeveloper
	static var badgeBecomeDeveloper: String {
		L10n.resolve {
			String(
				localized: "Become a Developer",
				table: "Content",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The action button on the developer badge."
			)
		}
	}
	/// The action button on the staff badge.
	///
	/// - Tag: L10n-badgeJoinStaff
	static var badgeJoinStaff: String {
		L10n.resolve {
			String(
				localized: "Join Kurozora Staff",
				table: "Content",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The action button on the staff badge."
			)
		}
	}
	/// The action button on the Pro badge.
	///
	/// - Tag: L10n-badgeBecomePro
	static var badgeBecomePro: String {
		L10n.resolve {
			String(
				localized: "Become a Pro User",
				table: "Content",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The action button on the Pro badge."
			)
		}
	}
	/// The action button on the verified badge.
	///
	/// - Tag: L10n-badgeGetVerified
	static var badgeGetVerified: String {
		L10n.resolve {
			String(
				localized: "Get Verified",
				table: "Content",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The action button on the verified badge."
			)
		}
	}

	/// The ratings count shown on a show's rating bar.
	///
	/// - Parameters:
	///   - formattedCount: The display-formatted rating count.
	///   - count: The number of ratings.
	///
	/// - Tag: L10n-ratingsCount
	static func ratingsCount(_ formattedCount: String, count: Int) -> String {
		String(
			localized: "show.ratingsCount",
			defaultValue: "\(formattedCount) \(count) Ratings",
			table: "Content",
			bundle: LanguageManager.shared.bundle,
			locale: LanguageManager.shared.locale,
			comment: "The ratings count shown on a show's rating bar."
		)
	}
	/// The library item count shown as a navigation subtitle.
	///
	/// - Parameter count: The number of items.
	///
	/// - Tag: L10n-itemsCount
	static func itemsCount(_ count: Int) -> String {
		String(
			localized: "\(count) Items",
			table: "Content",
			bundle: LanguageManager.shared.bundle,
			locale: LanguageManager.shared.locale,
			comment: "The library item count shown as a navigation subtitle."
		)
	}
	/// The syncing item count shown as a navigation subtitle.
	///
	/// - Parameter count: The number of items being synced.
	///
	/// - Tag: L10n-syncingItemsCount
	static func syncingItemsCount(_ count: Int) -> String {
		String(
			localized: "Syncing \(count) Items…",
			table: "Content",
			bundle: LanguageManager.shared.bundle,
			locale: LanguageManager.shared.locale,
			comment: "The syncing item count shown as a navigation subtitle."
		)
	}
	/// The label naming the sort type and option in use.
	///
	/// - Parameters:
	///   - type: The localized sort type.
	///   - option: The localized sort option.
	///
	/// - Tag: L10n-sortingBy
	static func sortingBy(_ type: String, option: String) -> String {
		String(
			localized: "Sorting by \(type) (\(option))",
			table: "Content",
			bundle: LanguageManager.shared.bundle,
			locale: LanguageManager.shared.locale,
			comment: "The label naming the sort type and option in use."
		)
	}
	/// The menu action that stops sorting the library.
	///
	/// - Tag: L10n-stopSorting
	static var stopSorting: String {
		L10n.resolve {
			String(
				localized: "Stop sorting",
				table: "Content",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The menu action that stops sorting the library."
			)
		}
	}

	// MARK: - Feed Message
	/// The status label shown on a pinned feed message.
	///
	/// - Tag: L10n-messagePinned
	static var messagePinned: String {
		L10n.resolve {
			String(
				localized: "Pinned",
				table: "Content",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The status label shown on a pinned feed message."
			)
		}
	}
	/// The warning shown over a message that is NSFW and contains spoilers.
	///
	/// - Tag: L10n-messageWarningNsfwSpoilers
	static var messageWarningNsfwSpoilers: String {
		L10n.resolve {
			String(
				localized: "This message is NSFW and contains spoilers - tap to view",
				table: "Content",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The warning shown over a message that is NSFW and contains spoilers."
			)
		}
	}
	/// The warning shown over a message that is NSFW.
	///
	/// - Tag: L10n-messageWarningNsfw
	static var messageWarningNsfw: String {
		L10n.resolve {
			String(
				localized: "This message is NSFW - tap to view",
				table: "Content",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The warning shown over a message that is NSFW."
			)
		}
	}
	/// The warning shown over a message that contains spoilers.
	///
	/// - Tag: L10n-messageWarningSpoilers
	static var messageWarningSpoilers: String {
		L10n.resolve {
			String(
				localized: "The message contains spoilers - tap to view",
				table: "Content",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The warning shown over a message that contains spoilers."
			)
		}
	}

	// MARK: - Translation
	/// The action that translates content into the reader's language.
	///
	/// - Tag: L10n-translationShowTranslation
	static var translationShowTranslation: String {
		L10n.resolve {
			String(
				localized: "Show translation",
				table: "Content",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The action that translates content into the reader's language."
			)
		}
	}
	/// The action that restores translated content to the language it was written in.
	///
	/// - Tag: L10n-translationShowOriginal
	static var translationShowOriginal: String {
		L10n.resolve {
			String(
				localized: "Show original",
				table: "Content",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The action that restores translated content to the language it was written in."
			)
		}
	}
	/// The status shown while content is being translated.
	///
	/// - Tag: L10n-translationInProgress
	static var translationInProgress: String {
		L10n.resolve {
			String(
				localized: "Translating…",
				table: "Content",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The status shown while content is being translated."
			)
		}
	}
	/// The status shown when content could not be translated.
	///
	/// - Tag: L10n-translationFailed
	static var translationFailed: String {
		L10n.resolve {
			String(
				localized: "Couldn't translate",
				table: "Content",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The status shown when content could not be translated."
			)
		}
	}
	/// The status naming the language content was translated from.
	///
	/// - Parameter language: The name of the language the content was written in.
	///
	/// - Tag: L10n-translationTranslatedFrom
	static func translationTranslatedFrom(_ language: String) -> String {
		String(
			localized: "Translated from \(language)",
			table: "Content",
			bundle: LanguageManager.shared.bundle,
			locale: LanguageManager.shared.locale,
			comment: "The status naming the language content was translated from."
		)
	}
	/// The title of the translation settings sheet.
	///
	/// - Tag: L10n-translationSettingsTitle
	static var translationSettingsTitle: String {
		L10n.resolve {
			String(
				localized: "Translation",
				table: "Content",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The title of the translation settings sheet."
			)
		}
	}
	/// The subtitle of the translation settings sheet.
	///
	/// - Tag: L10n-translationSettingsSubtitle
	static var translationSettingsSubtitle: String {
		L10n.resolve {
			String(
				localized: "Content is translated on this device, so nothing is sent anywhere.",
				table: "Content",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The subtitle of the translation settings sheet."
			)
		}
	}
	/// The label of the control choosing which language content is translated into.
	///
	/// - Tag: L10n-translationSettingsTranslateInto
	static var translationSettingsTranslateInto: String {
		L10n.resolve {
			String(
				localized: "Translate into",
				table: "Content",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The label of the control choosing which language content is translated into."
			)
		}
	}
	/// The toggle that translates a language without being asked.
	///
	/// - Parameter language: The name of the language to translate automatically.
	///
	/// - Tag: L10n-translationSettingsAutomaticallyTranslate
	static func translationSettingsAutomaticallyTranslate(_ language: String) -> String {
		String(
			localized: "Automatically translate \(language)",
			table: "Content",
			bundle: LanguageManager.shared.bundle,
			locale: LanguageManager.shared.locale,
			comment: "The toggle that translates a language without being asked."
		)
	}

	// MARK: - Cast
	/// The label naming the character a cast member voices.
	///
	/// - Parameter name: The character name.
	///
	/// - Tag: L10n-castCharacterAs
	static func castCharacterAs(_ name: String) -> String {
		String(
			localized: "as \(name)",
			table: "Content",
			bundle: LanguageManager.shared.bundle,
			locale: LanguageManager.shared.locale,
			comment: "The label naming the character a cast member voices."
		)
	}

	// MARK: - ReCap
	/// The milestone label for a user's top percentile in a category.
	///
	/// - Parameters:
	///   - percentile: The top percentile.
	///   - category: The category name.
	///
	/// - Tag: L10n-recapTopPercentile
	static func recapTopPercentile(_ percentile: String, of category: String) -> String {
		String(
			localized: "You were in the top \(percentile)% of \(category) this year.",
			table: "Content",
			bundle: LanguageManager.shared.bundle,
			locale: LanguageManager.shared.locale,
			comment: "The milestone label for a user's top percentile in a category."
		)
	}

	// MARK: - Seasons
	/// The label naming a season by its number.
	///
	/// - Parameter number: The season number.
	///
	/// - Tag: L10n-seasonNumber
	static func seasonNumber(_ number: Int) -> String {
		String(
			localized: "Season \(number)",
			table: "Content",
			bundle: LanguageManager.shared.bundle,
			locale: LanguageManager.shared.locale,
			comment: "The label naming a season by its number."
		)
	}

	// MARK: - Parental Guide Actions
	/// The context-menu action that marks a Parental Guide entry as helpful.
	///
	/// - Tag: L10n-helpful
	static var helpful: String {
		L10n.resolve {
			String(
				localized: "Helpful",
				table: "Content",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The context-menu action that marks a Parental Guide entry as helpful."
			)
		}
	}
	/// The context-menu action that marks a Parental Guide entry as unhelpful.
	///
	/// - Tag: L10n-unhelpful
	static var unhelpful: String {
		L10n.resolve {
			String(
				localized: "Unhelpful",
				table: "Content",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The context-menu action that marks a Parental Guide entry as unhelpful."
			)
		}
	}
	/// The confirmation message shown before deleting a Parental Guide entry.
	///
	/// - Tag: L10n-deleteEntryConfirmMessage
	static var deleteEntryConfirmMessage: String {
		L10n.resolve {
			String(
				localized: "Are you sure you want to delete this entry?",
				table: "Content",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The confirmation message shown before deleting a Parental Guide entry."
			)
		}
	}

	// MARK: - Review Actions
	/// The context-menu action that opens a reviewer's profile.
	///
	/// - Parameter username: The reviewer's display name.
	///
	/// - Tag: L10n-showUserProfile
	static func showUserProfile(_ username: String) -> String {
		String(
			localized: "Show \(username)'s Profile",
			table: "Content",
			bundle: LanguageManager.shared.bundle,
			locale: LanguageManager.shared.locale,
			comment: "The context-menu action that opens a reviewer's profile."
		)
	}

	// MARK: - Music
	/// The label naming the episodes a song appears in.
	///
	/// - Parameter value: The episode descriptor.
	///
	/// - Tag: L10n-episodeLabel
	static func episodeLabel(_ value: String) -> String {
		String(
			localized: "Episode: \(value)",
			table: "Content",
			bundle: LanguageManager.shared.bundle,
			locale: LanguageManager.shared.locale,
			comment: "The label naming the episodes a song appears in."
		)
	}

	// MARK: - Ratings
	/// The label shown in place of the rating count when a title has too few ratings.
	///
	/// - Tag: L10n-notEnoughRatings
	static var notEnoughRatings: String {
		L10n.resolve {
			String(
				localized: "Not enough ratings",
				table: "Content",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The label shown in place of the rating count when a title has too few ratings."
			)
		}
	}
	// MARK: - Kotodama
	/// The name of the Kotodama minigame.
	///
	/// - Tag: L10n-kotodama
	static var kotodama: String {
		L10n.resolve {
			String(
				localized: "Kotodama",
				table: "Content",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The name of the Kotodama minigame."
			)
		}
	}
	/// The tagline describing how the Kotodama minigame is played.
	///
	/// - Tag: L10n-kotodamaTagline
	static var kotodamaTagline: String {
		L10n.resolve {
			String(
				localized: "Guess the hidden anime word in six tries.",
				table: "Content",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The tagline describing how the Kotodama minigame is played."
			)
		}
	}
	// MARK: - Kotodama Hub
	/// The title of a Kotodama daily puzzle, followed by its number.
	///
	/// - Tag: L10n-kotodamaDailyPuzzleNumber
	static var kotodamaDailyPuzzleNumber: String {
		L10n.resolve {
			String(
				localized: "Daily #%lld",
				table: "Content",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The title of a Kotodama daily puzzle, followed by its number."
			)
		}
	}
	/// The button for starting a Kotodama puzzle.
	///
	/// - Tag: L10n-kotodamaPlay
	static var kotodamaPlay: String {
		L10n.resolve {
			String(
				localized: "kotodamaPlay",
				defaultValue: "Play",
				table: "Content",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The button for starting a Kotodama puzzle."
			)
		}
	}
	/// The button for reviewing a finished Kotodama puzzle.
	///
	/// - Tag: L10n-kotodamaViewResult
	static var kotodamaViewResult: String {
		L10n.resolve {
			String(
				localized: "View Result",
				table: "Content",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The button for reviewing a finished Kotodama puzzle."
			)
		}
	}
	/// The countdown to the next Kotodama daily puzzle, shown on the hub once today's is finished.
	///
	/// - Tag: L10n-kotodamaNextIn
	static var kotodamaNextIn: String {
		L10n.resolve {
			String(
				localized: "Next Kotodama in %@",
				table: "Content",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The countdown to the next Kotodama daily puzzle, shown on the hub once today's is finished."
			)
		}
	}
	/// The title of the Kotodama mode that can be replayed without limit.
	///
	/// - Tag: L10n-kotodamaUnlimited
	static var kotodamaUnlimited: String {
		L10n.resolve {
			String(
				localized: "Unlimited",
				table: "Content",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The title of the Kotodama mode that can be replayed without limit."
			)
		}
	}
	/// The description of the Kotodama mode that can be replayed without limit.
	///
	/// - Tag: L10n-kotodamaUnlimitedDescription
	static var kotodamaUnlimitedDescription: String {
		L10n.resolve {
			String(
				localized: "Practice with a random word.",
				table: "Content",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The description of the Kotodama mode that can be replayed without limit."
			)
		}
	}
	/// The title of the Kotodama archive of past puzzles.
	///
	/// - Tag: L10n-kotodamaArchive
	static var kotodamaArchive: String {
		L10n.resolve {
			String(
				localized: "Archive",
				table: "Content",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The title of the Kotodama archive of past puzzles."
			)
		}
	}
	/// The description of the Kotodama archive of past puzzles.
	///
	/// - Tag: L10n-kotodamaArchiveDescription
	static var kotodamaArchiveDescription: String {
		L10n.resolve {
			String(
				localized: "Replay past puzzles.",
				table: "Content",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The description of the Kotodama archive of past puzzles."
			)
		}
	}
	/// The title of the Kotodama leaderboards.
	///
	/// - Tag: L10n-kotodamaLeaderboards
	static var kotodamaLeaderboards: String {
		L10n.resolve {
			String(
				localized: "Leaderboards",
				table: "Content",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The title of the Kotodama leaderboards."
			)
		}
	}
	/// The description of the Kotodama leaderboards.
	///
	/// - Tag: L10n-kotodamaLeaderboardsDescription
	static var kotodamaLeaderboardsDescription: String {
		L10n.resolve {
			String(
				localized: "See who solved it fastest.",
				table: "Content",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The description of the Kotodama leaderboards."
			)
		}
	}
	/// The title of the signed-in player's Kotodama record.
	///
	/// - Tag: L10n-kotodamaStats
	static var kotodamaStats: String {
		L10n.resolve {
			String(
				localized: "My Stats",
				table: "Content",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The title of the signed-in player's Kotodama record."
			)
		}
	}
	/// The description of the signed-in player's Kotodama record.
	///
	/// - Tag: L10n-kotodamaStatsDescription
	static var kotodamaStatsDescription: String {
		L10n.resolve {
			String(
				localized: "Your streak, wins and guess spread.",
				table: "Content",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The description of the signed-in player's Kotodama record."
			)
		}
	}
	// MARK: - Kotodama Game
	/// The accessibility label of the Kotodama keyboard key that submits a guess.
	///
	/// - Tag: L10n-kotodamaSubmitGuess
	static var kotodamaSubmitGuess: String {
		L10n.resolve {
			String(
				localized: "Submit guess",
				table: "Content",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The accessibility label of the Kotodama keyboard key that submits a guess."
			)
		}
	}
	/// The accessibility label of the Kotodama keyboard key that removes the last letter.
	///
	/// - Tag: L10n-kotodamaDeleteLetter
	static var kotodamaDeleteLetter: String {
		L10n.resolve {
			String(
				localized: "Delete letter",
				table: "Content",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The accessibility label of the Kotodama keyboard key that removes the last letter."
			)
		}
	}
	/// The message shown when a Kotodama guess is submitted with empty tiles.
	///
	/// - Tag: L10n-kotodamaIncompleteGuess
	static var kotodamaIncompleteGuess: String {
		L10n.resolve {
			String(
				localized: "Fill every tile before submitting.",
				table: "Content",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The message shown when a Kotodama guess is submitted with empty tiles."
			)
		}
	}
	/// The result of a won Kotodama game, showing guesses spent out of guesses allowed.
	///
	/// - Tag: L10n-kotodamaSolved
	static var kotodamaSolved: String {
		L10n.resolve {
			String(
				localized: "Solved in %1$lld/%2$lld",
				table: "Content",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The result of a won Kotodama game, showing guesses spent out of guesses allowed."
			)
		}
	}
	/// The result of a lost Kotodama game.
	///
	/// - Tag: L10n-kotodamaUnsolved
	static var kotodamaUnsolved: String {
		L10n.resolve {
			String(
				localized: "Out of guesses",
				table: "Content",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The result of a lost Kotodama game."
			)
		}
	}
	/// The result of a lost Kotodama game, showing its uppercased answer.
	///
	/// - Tag: L10n-kotodamaUnsolvedAnswer
	static var kotodamaUnsolvedAnswer: String {
		L10n.resolve {
			String(
				localized: "Out of guesses. The answer was \"%@\".",
				table: "Content",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The result of a lost Kotodama game, showing its uppercased answer."
			)
		}
	}
	/// The hint shown beneath the outcome of a finished Kotodama game.
	///
	/// - Tag: L10n-kotodamaHintLabel
	static var kotodamaHintLabel: String {
		L10n.resolve {
			String(
				localized: "Hint: %@",
				table: "Content",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The hint shown beneath the outcome of a finished Kotodama game."
			)
		}
	}
	/// The category shown above the Kotodama board for an answer that is a term rather than a catalog entry.
	///
	/// - Tag: L10n-kotodamaSubjectWord
	static var kotodamaSubjectWord: String {
		L10n.resolve {
			String(
				localized: "Word",
				table: "Content",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The category shown above the Kotodama board for an answer that is a term rather than a catalog entry."
			)
		}
	}
	/// The first line of a shared Kotodama daily result, naming the puzzle and the score.
	///
	/// - Tag: L10n-kotodamaShareGridDailyHeader
	static var kotodamaShareGridDailyHeader: String {
		L10n.resolve {
			String(
				localized: "Kurozora Kotodama #%1$lld %2$@",
				table: "Content",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The first line of a shared Kotodama daily result, naming the puzzle and the score."
			)
		}
	}
	/// The first line of a shared Kotodama result outside the daily puzzle, naming the score.
	///
	/// - Tag: L10n-kotodamaShareGridHeader
	static var kotodamaShareGridHeader: String {
		L10n.resolve {
			String(
				localized: "Kurozora Kotodama %@",
				table: "Content",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The first line of a shared Kotodama result outside the daily puzzle, naming the score."
			)
		}
	}
	/// The button for sharing the outcome of a finished Kotodama game.
	///
	/// - Tag: L10n-kotodamaShareResult
	static var kotodamaShareResult: String {
		L10n.resolve {
			String(
				localized: "Share Result",
				table: "Content",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The button for sharing the outcome of a finished Kotodama game."
			)
		}
	}
	/// The button for starting another Kotodama practice game.
	///
	/// - Tag: L10n-kotodamaNewWord
	static var kotodamaNewWord: String {
		L10n.resolve {
			String(
				localized: "New Word",
				table: "Content",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The button for starting another Kotodama practice game."
			)
		}
	}
	/// The button for starting an unlimited Kotodama practice game from a finished result.
	///
	/// - Tag: L10n-kotodamaPlayUnlimited
	static var kotodamaPlayUnlimited: String {
		L10n.resolve {
			String(
				localized: "Play Unlimited",
				table: "Content",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The button for starting an unlimited Kotodama practice game from a finished result."
			)
		}
	}
	/// The title shown when no Kotodama daily puzzle is scheduled.
	///
	/// - Tag: L10n-kotodamaNoPuzzleToday
	static var kotodamaNoPuzzleToday: String {
		L10n.resolve {
			String(
				localized: "No puzzle today",
				table: "Content",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The title shown when no Kotodama daily puzzle is scheduled."
			)
		}
	}
	/// The description shown when no Kotodama daily puzzle is scheduled.
	///
	/// - Tag: L10n-kotodamaNoPuzzleTodayDescription
	static var kotodamaNoPuzzleTodayDescription: String {
		L10n.resolve {
			String(
				localized: "Come back tomorrow for a new word.",
				table: "Content",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The description shown when no Kotodama daily puzzle is scheduled."
			)
		}
	}
	// MARK: - Kotodama Stats
	/// The number of consecutive Kotodama dailies the player has solved.
	///
	/// - Tag: L10n-kotodamaCurrentStreak
	static var kotodamaCurrentStreak: String {
		L10n.resolve {
			String(
				localized: "Current streak",
				table: "Content",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The number of consecutive Kotodama dailies the player has solved."
			)
		}
	}
	/// The player's active Kotodama streak, shown with its length.
	///
	/// - Tag: L10n-kotodamaStreakValue
	static var kotodamaStreakValue: String {
		L10n.resolve {
			String(
				localized: "Streak: %lld",
				table: "Content",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The player's active Kotodama streak, shown with its length."
			)
		}
	}
	/// The player's longest run of consecutive Kotodama dailies solved.
	///
	/// - Tag: L10n-kotodamaBestStreak
	static var kotodamaBestStreak: String {
		L10n.resolve {
			String(
				localized: "Max streak",
				table: "Content",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The player's longest run of consecutive Kotodama dailies solved."
			)
		}
	}
	/// The number of Kotodama games the player has finished.
	///
	/// - Tag: L10n-kotodamaGamesPlayed
	static var kotodamaGamesPlayed: String {
		L10n.resolve {
			String(
				localized: "Games played",
				table: "Content",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The number of Kotodama games the player has finished."
			)
		}
	}
	/// The share of Kotodama games the player has won.
	///
	/// - Tag: L10n-kotodamaWinRate
	static var kotodamaWinRate: String {
		L10n.resolve {
			String(
				localized: "Win rate",
				table: "Content",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The share of Kotodama games the player has won."
			)
		}
	}
	/// The breakdown of how many guesses the player's Kotodama wins took.
	///
	/// - Tag: L10n-kotodamaGuessDistribution
	static var kotodamaGuessDistribution: String {
		L10n.resolve {
			String(
				localized: "Guess distribution",
				table: "Content",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The breakdown of how many guesses the player's Kotodama wins took."
			)
		}
	}
	/// The player's average number of Kotodama guesses, shown with its value.
	///
	/// - Tag: L10n-kotodamaAverageGuessesValue
	static var kotodamaAverageGuessesValue: String {
		L10n.resolve {
			String(
				localized: "Avg guesses: %@",
				table: "Content",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The player's average number of Kotodama guesses, shown with its value."
			)
		}
	}
	/// The title shown when the player has no Kotodama record.
	///
	/// - Tag: L10n-kotodamaNoStats
	static var kotodamaNoStats: String {
		L10n.resolve {
			String(
				localized: "No games yet",
				table: "Content",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The title shown when the player has no Kotodama record."
			)
		}
	}
	/// The description shown when the player has no Kotodama record.
	///
	/// - Tag: L10n-kotodamaNoStatsDescription
	static var kotodamaNoStatsDescription: String {
		L10n.resolve {
			String(
				localized: "Solve today's puzzle to start your streak.",
				table: "Content",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The description shown when the player has no Kotodama record."
			)
		}
	}
	// MARK: - Kotodama Leaderboards
	/// The Kotodama leaderboard of the longest streaks.
	///
	/// - Tag: L10n-kotodamaLeaderboardStreaks
	static var kotodamaLeaderboardStreaks: String {
		L10n.resolve {
			String(
				localized: "Streaks",
				table: "Content",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The Kotodama leaderboard of the longest streaks."
			)
		}
	}
	/// The title shown when nobody has solved today's Kotodama puzzle.
	///
	/// - Tag: L10n-kotodamaNoSolves
	static var kotodamaNoSolves: String {
		L10n.resolve {
			String(
				localized: "No solves yet",
				table: "Content",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The title shown when nobody has solved today's Kotodama puzzle."
			)
		}
	}
	/// The description shown when nobody has solved today's Kotodama puzzle.
	///
	/// - Tag: L10n-kotodamaNoSolvesDescription
	static var kotodamaNoSolvesDescription: String {
		L10n.resolve {
			String(
				localized: "Be the first to solve today's puzzle.",
				table: "Content",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The description shown when nobody has solved today's Kotodama puzzle."
			)
		}
	}
	/// The title shown when no player has a Kotodama streak.
	///
	/// - Tag: L10n-kotodamaNoStreaks
	static var kotodamaNoStreaks: String {
		L10n.resolve {
			String(
				localized: "No streaks yet",
				table: "Content",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The title shown when no player has a Kotodama streak."
			)
		}
	}
	/// The description shown when no player has a Kotodama streak.
	///
	/// - Tag: L10n-kotodamaNoStreaksDescription
	static var kotodamaNoStreaksDescription: String {
		L10n.resolve {
			String(
				localized: "Streaks appear once players start solving dailies.",
				table: "Content",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The description shown when no player has a Kotodama streak."
			)
		}
	}
	// MARK: - Kotodama Archive
	/// The title shown when the Kotodama archive is empty.
	///
	/// - Tag: L10n-kotodamaNoArchive
	static var kotodamaNoArchive: String {
		L10n.resolve {
			String(
				localized: "No past puzzles",
				table: "Content",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The title shown when the Kotodama archive is empty."
			)
		}
	}
	/// The description shown when the Kotodama archive is empty.
	///
	/// - Tag: L10n-kotodamaNoArchiveDescription
	static var kotodamaNoArchiveDescription: String {
		L10n.resolve {
			String(
				localized: "Puzzles join the archive the day after they run.",
				table: "Content",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The description shown when the Kotodama archive is empty."
			)
		}
	}
	/// The badge marking a Kotodama archive puzzle the player has solved.
	///
	/// - Tag: L10n-kotodamaSolvedBadge
	static var kotodamaSolvedBadge: String {
		L10n.resolve {
			String(
				localized: "Solved",
				table: "Content",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The badge marking a Kotodama archive puzzle the player has solved."
			)
		}
	}
	// MARK: - Kotodama Access
	/// The title shown when Kotodama is opened without being signed in.
	///
	/// - Tag: L10n-kotodamaSignInRequired
	static var kotodamaSignInRequired: String {
		L10n.resolve {
			String(
				localized: "Sign in to play",
				table: "Content",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The title shown when Kotodama is opened without being signed in."
			)
		}
	}
	/// The description shown when Kotodama is opened without being signed in.
	///
	/// - Tag: L10n-kotodamaSignInRequiredDescription
	static var kotodamaSignInRequiredDescription: String {
		L10n.resolve {
			String(
				localized: "Kotodama keeps your streak and stats on your account.",
				table: "Content",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The description shown when Kotodama is opened without being signed in."
			)
		}
	}
	/// The button that leaves a Kotodama leaderboard for today's puzzle.
	///
	/// - Tag: L10n-kotodamaPlayToday
	static var kotodamaPlayToday: String {
		L10n.resolve {
			String(
				localized: "Play Today's Kotodama",
				table: "Content",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The button that leaves a Kotodama leaderboard for today's puzzle."
			)
		}
	}
	// MARK: - Kotodama Streak
	/// The badge shown on an archive tile for a puzzle already played but not solved.
	///
	/// - Tag: L10n-kotodamaPlayed
	static var kotodamaPlayed: String {
		L10n.resolve {
			String(
				localized: "Played",
				table: "Content",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The badge shown on an archive tile for a puzzle already played but not solved."
			)
		}
	}
	/// The heading of the fastest solves of today's Kotodama puzzle.
	///
	/// - Tag: L10n-kotodamaTodaysFastest
	static var kotodamaTodaysFastest: String {
		L10n.resolve {
			String(
				localized: "Today's Fastest",
				table: "Content",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The heading of the fastest solves of today's Kotodama puzzle."
			)
		}
	}
	/// The message shown when today's Kotodama puzzle has no solves.
	///
	/// - Tag: L10n-kotodamaNobodySolvedToday
	static var kotodamaNobodySolvedToday: String {
		L10n.resolve {
			String(
				localized: "Nobody has solved today's puzzle yet.",
				table: "Content",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The message shown when today's Kotodama puzzle has no solves."
			)
		}
	}
	/// The guesses a player spent out of the guesses allowed.
	///
	/// - Tag: L10n-kotodamaGuessesSpent
	static var kotodamaGuessesSpent: String {
		L10n.resolve {
			String(
				localized: "%1$lld/%2$lld",
				table: "Content",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The guesses a player spent out of the guesses allowed."
			)
		}
	}
	/// The guesses spent followed by the seconds taken.
	///
	/// - Tag: L10n-kotodamaGuessesAndSeconds
	static var kotodamaGuessesAndSeconds: String {
		L10n.resolve {
			String(
				localized: "%1$@ · %2$@ s",
				table: "Content",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The guesses spent followed by the seconds taken."
			)
		}
	}
	/// A player's longest and current Kotodama streaks.
	///
	/// - Tag: L10n-kotodamaStreakDetail
	static var kotodamaStreakDetail: String {
		L10n.resolve {
			String(
				localized: "Best %1$lld · Current %2$lld",
				table: "Content",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "A player's longest and current Kotodama streaks."
			)
		}
	}
	// MARK: - Kotodama How to Play
	/// The title of the Kotodama how-to-play screen.
	///
	/// - Tag: L10n-kotodamaHowToPlay
	static var kotodamaHowToPlay: String {
		L10n.resolve {
			String(
				localized: "How to Play",
				table: "Content",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The title of the Kotodama how-to-play screen."
			)
		}
	}
	/// The introductory paragraph of the Kotodama how-to-play screen.
	///
	/// - Tag: L10n-kotodamaHowToPlayIntro
	static var kotodamaHowToPlayIntro: String {
		L10n.resolve {
			String(
				localized: "Guess the hidden word in six tries. Every answer is five letters long and pulled straight from the Kurozora catalog: anime, manga, game and song titles, plus characters, people and studios.",
				table: "Content",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The introductory paragraph of the Kotodama how-to-play screen."
			)
		}
	}
	/// The paragraph explaining how to submit a guess on the Kotodama how-to-play screen.
	///
	/// - Tag: L10n-kotodamaHowToPlayGuessing
	static var kotodamaHowToPlayGuessing: String {
		L10n.resolve {
			String(
				localized: "Type a guess and press the return key. The tiles change color after every guess to show how close you are.",
				table: "Content",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The paragraph explaining how to submit a guess on the Kotodama how-to-play screen."
			)
		}
	}
	/// The heading introducing the tile color legend on the Kotodama how-to-play screen.
	///
	/// - Tag: L10n-kotodamaHowToPlayColorsTitle
	static var kotodamaHowToPlayColorsTitle: String {
		L10n.resolve {
			String(
				localized: "What the colors mean",
				table: "Content",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The heading introducing the tile color legend on the Kotodama how-to-play screen."
			)
		}
	}
	/// The legend description of a Kotodama hit tile.
	///
	/// - Tag: L10n-kotodamaHowToPlayHit
	static var kotodamaHowToPlayHit: String {
		L10n.resolve {
			String(
				localized: "The letter is in the word, right where you put it.",
				table: "Content",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The legend description of a Kotodama hit tile."
			)
		}
	}
	/// The legend description of a Kotodama present tile.
	///
	/// - Tag: L10n-kotodamaHowToPlayPresent
	static var kotodamaHowToPlayPresent: String {
		L10n.resolve {
			String(
				localized: "The letter is in the word, but somewhere else.",
				table: "Content",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The legend description of a Kotodama present tile."
			)
		}
	}
	/// The legend description of a Kotodama miss tile.
	///
	/// - Tag: L10n-kotodamaHowToPlayMiss
	static var kotodamaHowToPlayMiss: String {
		L10n.resolve {
			String(
				localized: "The letter is not in the word at all.",
				table: "Content",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The legend description of a Kotodama miss tile."
			)
		}
	}
	/// The paragraph explaining Kotodama's hints on the how-to-play screen.
	///
	/// - Tag: L10n-kotodamaHowToPlayHints
	static var kotodamaHowToPlayHints: String {
		L10n.resolve {
			String(
				localized: "Need a nudge? A hint shows up after your third guess. From the fifth guess on you also get a picture.",
				table: "Content",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The paragraph explaining Kotodama's hints on the how-to-play screen."
			)
		}
	}
	/// The paragraph explaining Kotodama's daily puzzle and archive on the how-to-play screen.
	///
	/// - Tag: L10n-kotodamaHowToPlayDaily
	static var kotodamaHowToPlayDaily: String {
		L10n.resolve {
			String(
				localized: "A new puzzle drops every day at midnight. Solve it to keep your streak going, and replay older puzzles from the archive whenever you like.",
				table: "Content",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The paragraph explaining Kotodama's daily puzzle and archive on the how-to-play screen."
			)
		}
	}
}
