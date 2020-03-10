//
//  KurozoraKit.swift
//  Kurozora
//
//  Created by Khoren Katklian on 11/07/2018.
//  Copyright © 2018 Kurozora. All rights reserved.
//

import Alamofire
import TRON

struct KurozoraKit {
	// MARK: - Properties
	internal var userAuthToken: String = ""

	internal let tron = TRON(baseURL: "https://kurozora.app/api/v1/", plugins: [NetworkActivityPlugin(application: UIApplication.shared)])
	let headers: HTTPHeaders = [
		"Content-Type": "application/x-www-form-urlencoded",
		"accept": "application/json"
	]

	internal let kurozoraEndpoints: KurozoraEndpoints = KurozoraEndpoints()

	// MARK: - Initializers
	init(key: String) {
		userAuthToken = key
	}
}

internal struct KurozoraEndpoints {
	// MARK: - Anime
	let anime = "anime/?"
	let animeActors = "anime/?/actors"
	let animeEpisodesWatched = "anime-episodes/?/watched"
	let animeRate = "anime/?/rate"
	let animeSeasons = "anime/?/seasons"
	let animeSeasonsEpisodes = "anime-seasons/?/episodes"
	let animeSearch = "anime/search"

	// MARK: - Explore
	let explore = "explore"

	// MARK: - Genre
	let genres = "genres"

	// MARK: - Feed
	let feedSection = "feed-sections"
	let feedSectionPost = "feed-sections/?/posts"

	// MARK: - Forums
	let forumsRepliesVote = "forum-replies/?/vote"
	let forumsSections = "forum-sections"
	let forumsSectionsThreads = "forum-sections/?/threads"
	let forumsThreads = "forum-threads/?"
	let forumsThreadsReplies = "forum-threads/?/replies"
	let forumsThreadsVote = "forum-threads/?/vote"
	let forumsThreadsSearch = "forum-threads/search"
	let forumsThreadsLock = "forum-threads/?/lock"

	// MARK: - Notifications
	let notificationsDelete = "notifications/?/delete"
	let notificationsUpdate = "notifications/update"

	// MARK: - Sessions
	let sessions = "sessions"
	let sessionsDelete = "sessions/?/delete"
	let sessionsUpdate = "sessions/?/update"
	let sessionsValidate = "sessions/?/validate"

	// MARK: - Themes
	let themes = "themes"

	// MARK: - Users
	let users = "users"
	let usersRegisterSIWA = "users/register-siwa"
	let usersResetPassword = "users/reset-password"
	let usersProfile = "users/?/profile"
	let usersSessions = "users/?/sessions"
	let usersLibrary = "users/?/library"
	let usersLibraryDelete = "users/?/library/delete"
	let usersLibraryMALImport = "users/?/library/mal-import"
	let usersFavoriteAnime = "users/?/favorite-anime"
	let usersNotifications = "users/?/notifications"
	let usersSearch = "users/search"
	let usersFolllow = "users/?/follow"
	let usersFollower = "users/?/follower"
	let usersFollowing = "users/?/following"

	// MARK: - Misc
	let privacyPolicy = "privacy-policy"
}
