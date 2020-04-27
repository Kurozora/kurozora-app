//
//  KKEndpoints.swift
//  KurozoraKit
//
//  Created by Khoren Katklian on 10/03/2020.
//  Copyright © 2020 Kurozora. All rights reserved.
//

import Foundation

/**
	The object that stores information about the Kurozora API endpoints.
*/
internal struct KKEndpoints {
	// MARK: - Anime
	/// The endpoint to the details of a show.
	///
	/// **Replace:** `?` with the id of the show.
	let anime = "anime/?"

	/// The endpoint to the actors of a show.
	///
	/// **Replace:** `?` with the id of the show.
	let animeActors = "anime/?/actors"

	/// The endpoint to leave a rating on a show.
	///
	/// **Replace:** `?` with the id of the show.
	let animeRate = "anime/?/rate"

	/// The endpoint to the seasons of a show.
	///
	/// **Replace:** `?` with the id of the show.
	let animeSeasons = "anime/?/seasons"

	/// The endpoint to search for shows.
	let animeSearch = "anime/search"

	// MARK: - Anime Episode
	/// The endpoint to update the watch status of a show's episode.
	///
	/// **Replace:** `?` with the id of the episode.
	let animeEpisodesWatched = "anime-episodes/?/watched"

	// MARK: - Anime Season
	/// The endpoint to the episodes of a show's season.
	///
	/// **Replace:** `?` with the id of the season.
	let animeSeasonsEpisodes = "anime-seasons/?/episodes"

	// MARK: - Explore
	/// The endpoint to the explore page.
	let explore = "explore"

	// MARK: - Genre
	/// The endpoint to the genres.
	let genres = "genres"

	// MARK: - Feed
	/// The endpoint to the feed sections.
	let feedSection = "feed-sections"

	/// The endpoint to the posts in a feed section.
	///
	/// **Replace:** `?` with the id of the feed.
	let feedSectionPost = "feed-sections/?/posts"

	// MARK: - Forums
	/// The endpoint to the details of a thread.
	///
	/// **Replace:** `?` with the id of the thread.
	let forumsThreads = "forum-threads/?"

	/// The endpoint to the replies in a thread.
	///
	/// **Replace:** `?` with the id of the thread.
	let forumsThreadsReplies = "forum-threads/?/replies"

	/// The endpoint to update the vote on a thread.
	///
	/// **Replace:** `?` with the id of the thread.
	let forumsThreadsVote = "forum-threads/?/vote"

	/// The endpoint to lock a thread.
	///
	/// **Replace:** `?` with the id of the thread.
	let forumsThreadsLock = "forum-threads/?/lock"

	/// The endpoint to search for threads.
	let forumsThreadsSearch = "forum-threads/search"

	// MARK: - Forums Replies
	/// The endpoint to vote on a forums reply.
	///
	/// **Replace:** `?` with the id of the forums.
	let forumsRepliesVote = "forum-replies/?/vote"

	// MARK: - Forums Sections
	/// The endpoint to the forums sections.
	let forumsSections = "forum-sections"

	/// The endpoint to the threads in a forums section.
	///
	/// **Replace:** `?` with the id of the section.
	let forumsSectionsThreads = "forum-sections/?/threads"

	// MARK: - Notifications
	/// The endpoint to deleting a notification.
	///
	/// **Replace:** `?` with the id of the notification.
	let notificationsDelete = "notifications/?/delete"

	/// The endpoint to updating a notification's information.
	let notificationsUpdate = "notifications/update"

	// MARK: - Sessions
	/// The endpoint to sign in a user using email and password.
	let sessions = "sessions"

	/// The endpoint to deleting a session.
	///
	/// **Replace:** `?` with the id of the session.
	let sessionsDelete = "sessions/?/delete"

	/// The endpoint to updating a session's details.
	///
	/// **Replace:** `?` with the id of the session.
	let sessionsUpdate = "sessions/?/update"

	// MARK: - Themes
	/// The endpoint to the themes.
	let themes = "themes"

	// MARK: - Users
	/// The endpoint to register a user using email and password.
	let users = "users"

	/// The endpoint to register a user using Sign in with Apple.
	let usersRegisterSIWA = "users/register-siwa"

	/// The edpoint to reset a user's password.
	let usersResetPassword = "users/reset-password"

	/// The endpoint to the user's own details.
	let usersMe = "users/me"

	/// The endpoint to the user's profile.
	///
	/// **Replace:** `?` with the id of the user.
	let usersProfile = "users/?/profile"

	/// The endpoint to the user's sessions.
	///
	/// **Replace:** `?` with the id of the user.
	let usersSessions = "users/?/sessions"

	/// The endpoint to get and add shows to the user's library.
	///
	/// **Replace:** `?` with the id of the user.
	let usersLibrary = "users/?/library"

	/// The endpoint to the delete a show from the user's library.
	///
	/// **Replace:** `?` with the id of the user.
	let usersLibraryDelete = "users/?/library/delete"

	/// The endpoint to import an exported MAL file into the user's library.
	///
	/// **Replace:** `?` with the id of the user.
	let usersLibraryMALImport = "users/?/library/mal-import"

	/// The endpoint to search for shows in the user's library.
	///
	/// **Replace:** `?` with the id of the user.
	let animeSearchInLibrary = "users/?/library/search"

	/// The endpoint to add or remove shows from the user's favorite shows list.
	///
	/// **Replace:** `?` with the id of the user.
	let usersFavoriteAnime = "users/?/favorite-anime"

	/// The endpoint to the user's notification list.
	///
	/// **Replace:** `?` with the id of the user.
	let usersNotifications = "users/?/notifications"

	/// The endpoint to follow or unfollow a user.
	///
	/// **Replace:** `?` with the id of the user.
	let usersFolllow = "users/?/follow"

	/// The endpoint to the user's followers list.
	///
	/// **Replace:** `?` with the id of the user.
	let usersFollower = "users/?/follower"

	/// The endpoint to the user's following list.
	///
	/// **Replace:** `?` with the id of the user.
	let usersFollowing = "users/?/following"

	/// The endpoint to search for users.
	let usersSearch = "users/search"

	// MARK: - Misc
	/// The endpoint to the privacy policy.
	let privacyPolicy = "privacy-policy"
}
