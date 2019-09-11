//
//  Service.swift
//  Kurozora
//
//  Created by Khoren Katklian on 11/07/2018.
//  Copyright © 2018 Kurozora. All rights reserved.
//

import KCommonKit
import Alamofire
import SwiftyJSON
import SCLAlertView
import TRON

struct Service {
	let tron = TRON(baseURL: "https://kurozora.app/api/v1/", plugins: [NetworkActivityPlugin(application: UIApplication.shared)])

	fileprivate let headers: HTTPHeaders = [
		"Content-Type": "application/x-www-form-urlencoded"
	]

	static let shared = Service()

// MARK: - User
// All user related endpoints
	/**
		Register a new account with the given details.

		- Parameter username: The new user's username.
		- Parameter password: The new user's password.
		- Parameter email: The new user's email.
		- Parameter profileImage: The new user's avatar image.
		- Parameter successHandler: A closure returning a boolean indicating whether registration is successful.
		- Parameter isSuccess: A boolean value indicating whether registration is successful.
	*/
	func register(withUsername username: String?, email: String?, password: String?, profileImage image: UIImage?, withSuccess successHandler: @escaping (_ isSuccess: Bool) -> Void) {
		guard let username = username else { return }
		guard let email = email else { return }
		guard let password = password else { return }

		let request: UploadAPIRequest<User, JSONError> = tron.swiftyJSON.uploadMultipart("users") { (formData) in
			if let profileImage = image?.jpegData(compressionQuality: 0.1) {
				formData.append(profileImage, withName: "profileImage", fileName: "ProfilePicture.png", mimeType: "image/png")
			}
		}
		request.headers = headers
		request.method = .post
		request.parameters = [
			"username": username,
			"email": email,
			"password": password
		]
		request.perform(withSuccess: { reset in
			if let success = reset.success {
				if success {
					successHandler(success)
				}
			}
		}, failure: { error in
			UIView().endEditing(true)
			SCLAlertView().showError("Can't register account 😔", subTitle: error.message)

			print("Received reset password error: \(error)")
		})
	}

	/**
		Request a password reset link for the given email.

		- Parameter email: The email address to which the reset link should be sent.
		- Parameter successHandler: A closure returning a boolean indicating whether reset password request is successful.
		- Parameter isSuccess: A boolean value indicating whether reset password request is successful.
	*/
	func resetPassword(_ email: String?, withSuccess successHandler: @escaping (_ isSuccess: Bool) -> Void) {
		guard let email = email else { return }

		let request: APIRequest<User, JSONError> = tron.swiftyJSON.request("users/reset-password")
		request.headers = headers
		request.method = .post
		request.parameters = [
			"email": email
		]
		request.perform(withSuccess: { reset in
			if let success = reset.success {
				if success {
					successHandler(success)
				}
			}
		}, failure: { error in
			UIView().endEditing(true)
			SCLAlertView().showError("Can't send reset link 😔", subTitle: error.message)

			print("Received reset password error: \(error)")
		})
	}

	/**
		Update the current user's profile information.

		- Parameter bio: The new biography to set.
		- Parameter image: The new user's avatar image.
		- Parameter successHandler: A closure returning a boolean indicating whether information update is successful.
		- Parameter isSuccess: A boolean value indicating whether information update is successful.
	*/
	func updateInformation(withBio bio: String?, profileImage image: UIImage?, withSuccess successHandler: @escaping (_ isSuccess: Bool) -> Void) {
		guard let userID = User.currentID else { return }
		guard let bio = bio else { return }

		let request: UploadAPIRequest<User, JSONError> = tron.swiftyJSON.uploadMultipart("users/\(userID)/profile") { (formData) in
			if let profileImage = image?.jpegData(compressionQuality: 0.1) {
				formData.append(profileImage, withName: "profileImage", fileName: "ProfilePicture.png", mimeType: "image/png")
			}
		}
		request.headers = [
			"Content-Type": "multipart/form-data",
			"kuro-auth": User.authToken
		]
		request.method = .post
		request.parameters = [
			"biography": bio
		]

		request.perform(withSuccess: { (update) in
			if let success = update.success {
				if success {
					successHandler(success)
					if let message = update.message {
						SCLAlertView().showSuccess("Settings updated ☺️", subTitle: message)
					}
				}
			}
		}, failure: { error in
			UIView().endEditing(true)
			SCLAlertView().showError("Can't update information 😔", subTitle: error.message)

			print("Received update information error: \(error)")
		})
	}

	/**
		Fetch the list of sessions for the current user.

		- Parameter successHandler: A closure returning a UserSessions object.
		- Parameter userSessions: The returned UserSessions object.
	*/
	func getSessions(withSuccess successHandler: @escaping (_ userSessions: UserSessions?) -> Void) {
		guard let userID = User.currentID else { return }

		let request: APIRequest<UserSessions, JSONError> = tron.swiftyJSON.request("users/\(userID)/sessions")
		request.headers = [
			"Content-Type": "application/x-www-form-urlencoded",
			"kuro-auth": User.authToken
		]
		request.method = .get
		request.perform(withSuccess: { session in
			if let success = session.success {
				if success {
					successHandler(session)
				}
			}
		}, failure: { error in
			SCLAlertView().showError("Can't get session 😔", subTitle: error.message)

			print("Received get session error: \(error)")
		})
	}

	/**
		Fetch the list of shows with the given show status in the current user's library.

		- Parameter status: The status to retrieve the library items for.
		- Parameter successHandler: A closure returning a LibraryElement array.
		- Parameter library: The returned LibraryElement array.
	*/
	func getLibrary(withStatus status: String?, withSuccess successHandler: @escaping (_ library: [LibraryElement]?) -> Void) {
		guard let status = status else { return }
		guard let userID = User.currentID else { return }

		let request: APIRequest<Library, JSONError> = tron.swiftyJSON.request("users/\(userID)/library")
		request.headers = [
			"Content-Type": "application/x-www-form-urlencoded",
			"kuro-auth": User.authToken
		]
		request.method = .get
		request.parameters = [
			"status": status
		]
		request.perform(withSuccess: { library in
			if let success = library.success {
				if success {
					successHandler(library.library)
				}
			}
		}, failure: { error in
			SCLAlertView().showError("Can't get your library 😔", subTitle: error.message)

			print("Received get library error: \(error)")
		})
	}

	/**
		Add a show with the given show id to the current user's library.

		- Parameter status: The watch status to assign to the Anime.
		- Parameter showID: The id of the show to add.
		- Parameter successHandler: A closure returning a boolean indicating whether adding show to library is successful.
		- Parameter isSuccess: A boolean value indicating whether adding show to library is successful.
	*/
	func addToLibrary(withStatus status: String?, showID: Int?, withSuccess successHandler: @escaping (_ isSuccess: Bool) -> Void) {
		guard let status = status else { return }
		guard let showID = showID else { return }
		guard let userID = User.currentID else { return }

		let request: APIRequest<Library, JSONError> = tron.swiftyJSON.request("users/\(userID)/library")
		request.headers = [
			"Content-Type": "application/x-www-form-urlencoded",
			"kuro-auth": User.authToken
		]
		request.method = .post
		request.parameters = [
			"status": status,
			"anime_id": showID
		]
		request.perform(withSuccess: { library in
			if let success = library.success {
				if success {
					successHandler(success)
				}
			}
		}, failure: { error in
			SCLAlertView().showError("Can't add to your library 😔", subTitle: error.message)

			print("Received add library error: \(error)")
		})
	}

	/**
		Remove a show with the given show id from the current user's library.

		- Parameter showID: The id of the show to delete.
		- Parameter successHandler: A closure returning a boolean indicating whether removing show from library is successful.
		- Parameter isSuccess: A boolean value indicating whether removing show from library is successful.
	*/
	func removeFromLibrary(withID showID: Int?, withSuccess successHandler: @escaping (_ isSuccess: Bool) -> Void) {
		guard let showID = showID else { return }
		guard let userID = User.currentID else { return }

		let request: APIRequest<Library, JSONError> = tron.swiftyJSON.request("users/\(userID)/library/delete")
		request.headers = [
			"Content-Type": "application/x-www-form-urlencoded",
			"kuro-auth": User.authToken
		]
		request.method = .post
		request.parameters = [
			"anime_id": showID
		]
		request.perform(withSuccess: { library in
			if let success = library.success {
				if success {
					successHandler(success)
				}
			}
		}, failure: { error in
			SCLAlertView().showError("Can't remove from your library 😔", subTitle: error.message)

			print("Received remove library error: \(error)")
		})
	}

	/**
		Fetch the profile details of the given user id.

		- Parameter userID: The id of the user whose profile details should be fetched.
		- Parameter successHandler: A closure returning a User object.
		- Parameter user: The returned User object.
	*/
	func getUserProfile(_ userID: Int?, withSuccess successHandler: @escaping (_ user: User?) -> Void) {
		guard let userID = userID else { return }

		let request: APIRequest<User, JSONError> = tron.swiftyJSON.request("users/\(userID)/profile")
		request.headers = [
			"Content-Type": "application/x-www-form-urlencoded",
			"kuro-auth": User.authToken
		]
		request.method = .get
		request.perform(withSuccess: { userProfile in
			if let success = userProfile.success {
				if success {
					successHandler(userProfile)
				}
			}
		}, failure: { error in
			SCLAlertView().showError("Can't get user details 😔", subTitle: error.message)

			print("Received user profile error: \(error)")
		})
	}

	/**
		Fetch the list of notifications for the current user.

		- Parameter successHandler: A closure returning a UserNotificationsElement array.
		- Parameter userNotifications: The returned UserNotificationsElement array.
	*/
	func getNotifications(withSuccess successHandler: @escaping (_ userNotifications: [UserNotificationsElement]?) -> Void) {
		guard let userID = User.currentID else { return }

		let request: APIRequest<UserNotification, JSONError> = tron.swiftyJSON.request("users/\(userID)/notifications")
		request.headers = [
			"Content-Type": "application/x-www-form-urlencoded",
			"kuro-auth": User.authToken
		]
		request.method = .get
		request.perform(withSuccess: { userNotifications in
			if let success = userNotifications.success {
				if success {
					successHandler(userNotifications.notifications)
				}
			}
		}, failure: { error in
			SCLAlertView().showError("Can't get your notifications 😔", subTitle: error.message)

			print("Received get notifications error: \(error)")
		})
	}

	/**
		Fetch a list of users matching the search query.

		- Parameter user: The search query by which the search list should be fetched.
		- Parameter successHandler: A closure returning a SearchElement array.
		- Parameter search: The returned SearchElement array.
	*/
	func search(forUser user: String?, withSuccess successHandler: @escaping (_ search: [SearchElement]?) -> Void) {
		guard let user = user else { return }

		let request: APIRequest<Search, JSONError> = tron.swiftyJSON.request("users/search")
		request.headers = [
			"Content-Type": "application/x-www-form-urlencoded",
			"kuro-auth": User.authToken
		]
		request.method = .get
		request.parameters = [
			"query": user
		]
		request.perform(withSuccess: { search in
			if let success = search.success {
				if success {
					successHandler(search.results)
				}
			}
		}, failure: { error in
			SCLAlertView().showError("Can't get search results 😔", subTitle: error.message)

			print("Received user search error: \(error)")
		})
	}

	/**
		Follow or unfollow a user with the given user id.

		- Parameter follow: The integer indicating whether to follow or unfollow.
		- Parameter userID: The id of the user to follow/unfollow.
		- Parameter successHandler: A closure returning a boolean indicating whether follow/unfollow is successful.
		- Parameter isSuccess: A boolean value indicating whether follow/unfollow is successful.
	*/
	func follow(_ follow: Int?, user userID: Int?, withSuccess successHandler: @escaping (Bool) -> Void) {
		guard let follow = follow else { return }
		guard let userID = userID else { return }

		let request: APIRequest<UserFollow, JSONError> = tron.swiftyJSON.request("users/\(userID)/follow")
		request.headers = [
			"Content-Type": "application/x-www-form-urlencoded",
			"kuro-auth": User.authToken
		]
		request.method = .post
		request.parameters = [
			"follow": follow
		]
		request.perform(withSuccess: { follow in
			if let success = follow.success {
				if success {
					successHandler(success)
				}
			}
		}, failure: { error in
			SCLAlertView().showError("Can't follow user 😔", subTitle: error.message)

			print("Received follow user error: \(error)")
		})
	}

// MARK: - Notifications
// All notifications related endpoints
	/**
		Delete the notification for the given notification id.

		- Parameter notificationID: The id of the notification to be deleted.
		- Parameter successHandler: A closure returning a boolean indicating whether notification deletion is successful.
		- Parameter isSuccess: A boolean value indicating whether notification deletion is successful.
	*/
	func deleteNotification(with notificationID: Int?, withSuccess successHandler: @escaping (_ isSuccess: Bool) -> Void) {
		guard let notificationID = notificationID else { return }

		let request: APIRequest<UserNotification, JSONError> = tron.swiftyJSON.request("user-notifications/\(notificationID)/delete")
		request.headers = [
			"Content-Type": "application/x-www-form-urlencoded",
			"kuro-auth": User.authToken
		]
		request.method = .post
		request.perform(withSuccess: { notification in
			if let success = notification.success {
				if success {
					successHandler(success)
				}
			}
		}, failure: { error in
			SCLAlertView().showError("Can't delete notification 😔", subTitle: error.message)

			print("Received delete notification error: \(error)")
		})
	}

	/**
		Update the read status for the given notification id.

		- Parameter notificationID: The id of the notification to be updated. Accepts array of id's or `all`.
		- Parameter read: Mark notification as `read` or `unread`.
		- Parameter successHandler: A closure returning a boolean indicating whether notification deletion is successful.
		- Parameter isSuccess: A boolean value indicating whether notification deletion is successful.
	*/
	func updateNotification(for notificationID: String?, withStatus read: Int?, withSuccess successHandler: @escaping (Bool) -> Void) {
		guard let notificationID = notificationID else { return }
		guard let read = read else { return }

		let request: APIRequest<UserNotificationsElement, JSONError> = tron.swiftyJSON.request("user-notifications/update")

		request.headers = [
			"Content-Type": "application/x-www-form-urlencoded",
			"kuro-auth": User.authToken
		]
		request.method = .post
		request.parameters = [
			"notification": notificationID,
			"read": read
		]
		request.perform(withSuccess: { notification in
			if let read = notification.read {
				successHandler(read)
			}
		}, failure: { error in
			SCLAlertView().showError("Can't update notification 😔", subTitle: error.message)

			print("Received update notification error: \(error)")
		})
	}

// MARK: - Show
// All show related endpoints
	/**
		Fetch the explore page content.

		- Parameter successHandler: A closure returning an Explore object.
		- Parameter explore: The returned Explore object.
	*/
	func getExplore(withSuccess successHandler: @escaping (_ explore: Explore?) -> Void) {
		let request: APIRequest<Explore, JSONError> = tron.swiftyJSON.request("explore")
		request.headers = [
			"Content-Type": "application/x-www-form-urlencoded",
			"kuro-auth": User.authToken
		]
		request.method = .get
		request.perform(withSuccess: { explore in
			if let success = explore.success {
				if success {
					successHandler(explore)
				}
			}
		}, failure: { error in
			SCLAlertView().showError("Can't get explore page 😔", subTitle: error.message)

			print("Received explore error: \(error)")
		})
	}

	/**
		Fetch the show details for the given show id.

		- Parameter showID: The id of the show for which the details should be fetched.
		- Parameter successHandler: A closure returning a ShowDetailsElement object.
		- Parameter showDetailsElement: The returned ShowDetailsElement object.
	*/
	func getDetails(forShow showID: Int?, withSuccess successHandler: @escaping (_ showDetailsElement: ShowDetailsElement) -> Void) {
		guard let showID = showID else { return }

		let request: APIRequest<ShowDetails, JSONError> = tron.swiftyJSON.request("anime/\(showID)")
		request.headers = [
			"Content-Type": "application/x-www-form-urlencoded",
			"kuro-auth": User.authToken
		]
		request.method = .get
		request.perform(withSuccess: { showDetails in
			DispatchQueue.main.async {
				if let showDetailsElement = showDetails.showDetailsElement {
					successHandler(showDetailsElement)
				}
			}
		}, failure: { error in
			SCLAlertView().showError("Can't get show details 😔", subTitle: error.message)

			print("Received get details error: \(error)")
		})
	}

	/**
		Fetch the cast details for the given show id.

		- Parameter showID: The show id for which the cast details should be fetched.
		- Parameter successHandler: A closure returning an ActorsElement array.
		- Parameter actors: The returned ActorsElement array.
	*/
	func getCastFor(_ showID: Int?, withSuccess successHandler: @escaping (_ actors: [ActorsElement]?) -> Void) {
		guard let showID = showID else { return }

		let request: APIRequest<Actors, JSONError> = tron.swiftyJSON.request("anime/\(showID)/actors")
		request.headers = headers
		request.method = .get
		request.perform(withSuccess: { actors in
			if let success = actors.success {
				if success {
					successHandler(actors.actors)
				}
			}
		}, failure: { error in
			SCLAlertView().showError("Can't get casts list 😔", subTitle: error.message)

			print("Received get cast error: \(error)")
		})
	}

	/**
		Fetch the seasons for a the given show id.

		- Parameter showID: The show id for which the seasons should be fetched.
		- Parameter successHandler: A closure returning a SeasonsElement array.
		- Parameter seasons: The returned SeasonsElement array.
	*/
	func getSeasonsFor(_ showID: Int?, withSuccess successHandler: @escaping (_ seasons: [SeasonsElement]?) -> Void) {
		guard let showID = showID else { return }

		let request: APIRequest<Seasons, JSONError> = tron.swiftyJSON.request("anime/\(showID)/seasons")
		request.headers = headers
		request.method = .get
		request.perform(withSuccess: { seasons in
			if let success = seasons.success {
				if success {
					successHandler(seasons.seasons)
				}
			}
		}, failure: { error in
			SCLAlertView().showError("Can't get seasons list 😔", subTitle: error.message)

			print("Received get show seasons error: \(error)")
		})
	}

	/**
		Rate the show with the given show id.

		- Parameter showID: The id of the show which should be rated.
		- Parameter score: The rating to leave.
		- Parameter successHandler: A closure returning a boolean indicating whether rating is successful.
		- Parameter isSuccess: A boolean value indicating whether rating is successful.
	*/
	func rateShow(_ showID: Int?, with score: Double?, withSuccess successHandler: @escaping (_ isSuccess: Bool) -> Void) {
		guard let rating = score else { return }
		guard let showID = showID else { return }

		let request: APIRequest<User, JSONError> = tron.swiftyJSON.request("anime/\(showID)/rate")
		request.headers = [
			"Content-Type": "application/x-www-form-urlencoded",
			"kuro-auth": User.authToken
		]
		request.method = .post
		request.parameters = [
			"rating": rating
		]
		request.perform(withSuccess: { user in
			if let success = user.success {
				if success {
					successHandler(success)
				}
			}
		}, failure: { error in
			SCLAlertView().showError("Can't rate this show 😔", subTitle: error.message)

			print("Received rating error: \(error)")
		})
	}

	/**
		Fetch a list of shows matching the search query.

		- Parameter show: The search query by which the search list should be fetched.
		- Parameter successHandler: A closure returning a SearchElement array.
		- Parameter search: The returned SearchElement array.
	*/
	func search(forShow show: String?, withSuccess successHandler: @escaping (_ search: [SearchElement]?) -> Void) {
		guard let show = show else { return }

		let request: APIRequest<Search, JSONError> = tron.swiftyJSON.request("anime/search")
		request.headers = [
			"Content-Type": "application/x-www-form-urlencoded",
			"kuro-auth": User.authToken
		]
		request.method = .get
		request.parameters = [
			"query": show
		]
		request.perform(withSuccess: { search in
			if let success = search.success {
				if success {
					successHandler(search.results)
				}
			}
		}, failure: { error in
			SCLAlertView().showError("Can't get search results 😔", subTitle: error.message)

			print("Received show search error: \(error)")
		})
	}

// MARK: - Anime Seasons
// All show seasons related endpoints
	/**
		Fetch the episodes for the given season id.

		- Parameter seasonID: The id of the season for which the episodes should be fetched.
		- Parameter successHandler: A closure returning an Episodes object.
		- Parameter episodes: The returned Episodes object.
	*/
	func getEpisodes(forSeason seasonID: Int?, withSuccess successHandler: @escaping (_ episodes: Episodes?) -> Void) {
		guard let seasonID = seasonID else { return }

		let request: APIRequest<Episodes, JSONError> = tron.swiftyJSON.request("anime-seasons/\(seasonID)/episodes")
		request.headers = [
			"Content-Type": "application/x-www-form-urlencoded",
			"kuro-auth": User.authToken
		]
		request.method = .get
		request.perform(withSuccess: { episodes in
			if let success = episodes.success {
				if success {
					successHandler(episodes)
				}
			}
		}, failure: { error in
			SCLAlertView().showError("Can't get episodes list 😔", subTitle: error.message)

			print("Received get show episodes error: \(error)")
		})
	}

// MARK: - Anime Episodes
// All episode related endpoints
	/**
		Watch or unwatch an episode with the given episode id.

		- Parameter watched: The integer indicating whether to mark the episode as watched or not watched. (0 = not watched, 1 = watched)
		- Parameter episodeID: The id of the episode that should be marked as watched/unwatched.
		- Parameter successHandler: A closure returning a boolean indicating whether watch/unwatch is successful.
		- Parameter isSuccess: A boolean value indicating whether watch/unwatch is successful.
	*/
	func mark(asWatched watched: Int?, forEpisode episodeID: Int?, withSuccess successHandler: @escaping (_ isSuccess: Bool) -> Void) {
		guard let episodeID = episodeID else { return }
		guard let watched = watched else { return }

		let request: APIRequest<EpisodesUserDetails, JSONError> = tron.swiftyJSON.request("anime-episodes/\(episodeID)/watched")
		request.headers = [
			"Content-Type": "application/x-www-form-urlencoded",
			"kuro-auth": User.authToken
		]
		request.method = .post
		request.parameters = [
			"watched": watched
		]
		request.perform(withSuccess: { episode in
			if let watchedStatus = episode.watched {
				successHandler(watchedStatus)
			}
		}, failure: { error in
			SCLAlertView().showError("Can't update episode 😔", subTitle: error.message)

			print("Received mark episode error: \(error)")
		})
	}

// MARK: - Genres
// All genre related endpoints
	/**
		Fetch the list of genres.

		- Parameter successHandler: A closure returning a GenreElement array.
		- Parameter genres: The returned GenreElement array.
	*/
	func getGenres(withSuccess successHandler: @escaping (_ genres: [GenreElement]?) -> Void) {
		let request: APIRequest<Genres, JSONError> = tron.swiftyJSON.request("genres")
		request.headers = headers
		request.method = .get
		request.perform(withSuccess: { genres in
			if let success = genres.success {
				if success {
					successHandler(genres.genres)
				}
			}
		}, failure: { error in
			SCLAlertView().showError("Can't get genres list 😔", subTitle: error.message)

			print("Received get genres error: \(error)")
		})
	}

// MARK: - Feed
// All feed related endpoints
	/**
		Fetch the list of feed sections.

		- Parameter successHandler: A closure returning a FeedSectionsElement array.
		- Parameter feedSections: The returned FeedSectionsElement array.
	*/
	func getFeedSections(withSuccess successHandler: @escaping (_ feedSections: [FeedSectionsElement]?) -> Void) {
		let request: APIRequest<FeedSections, JSONError> = tron.swiftyJSON.request("feed-sections")
		request.headers = headers
		request.method = .get
		request.perform(withSuccess: { sections in
			if let success = sections.success {
				if success {
					successHandler(sections.sections)
				}
			}
		}, failure: { error in
			SCLAlertView().showError("Can't get feed sections 😔", subTitle: error.message)

			print("Received get feed sections error: \(error)")
		})
	}

	/**
		Fetch a list of feed posts for the given feed section id.

		- Parameter sectionID: The id of the feed section for which the posts should be fetched.
		- Parameter page: The page to retrieve posts from. (starts at 0)
		- Parameter successHandler: A closure returning a FeedPosts array.
		- Parameter feedPosts: The returned FeedPosts array.
	*/
	func getFeedPosts(for sectionID: Int?, page: Int?, withSuccess successHandler: @escaping (_ feedPosts: FeedPosts?) -> Void) {
		guard let sectionID = sectionID else { return }
		guard let page = page else { return }

		let request: APIRequest<FeedPosts, JSONError> = tron.swiftyJSON.request("feed-sections/\(sectionID)/posts")
		request.headers = headers
		request.method = .get
		request.parameters = [
			"page": page
		]
		request.perform(withSuccess: { threads in
			if let success = threads.success {
				if success {
					successHandler(threads)
				}
			}
		}, failure: { error in
			SCLAlertView().showError("Can't get feed posts 😔", subTitle: error.message)

			print("Received get feed posts error: \(error)")
		})
	}

// MARK: - Forums
// All forum related endpoints
	/**
		Fetch the list of forum sections.

		- Parameter successHandler: A closure returning a ForumSectionsElement array.
		- Parameter forumSections: The returned ForumSectionElement array.
	*/
	func getForumSections(withSuccess successHandler: @escaping (_ forumSections: [ForumSectionsElement]?) -> Void) {
		let request: APIRequest<ForumSections, JSONError> = tron.swiftyJSON.request("forum-sections")
		request.headers = headers
		request.method = .get
		request.perform(withSuccess: { sections in
			if let success = sections.success {
				if success {
					successHandler(sections.sections)
				}
			}
		}, failure: { error in
			SCLAlertView().showError("Can't get forum sections 😔", subTitle: error.message)

			print("Received get forum sections error: \(error)")
		})
	}

	/**
		Fetch a list of forum threads for the given forum section id.

		- Parameter sectionID: The id of the forum section for which the forum threads should be fetched.
		- Parameter order: The method by which the threads should be ordered. Currently "top" and "recent".
		- Parameter page: The page to retrieve threads from. (starts at 0)
		- Parameter successHandler: A closure returning a ForumThreads array.
		- Parameter forumThreads: The returned ForumThreads array.
	*/
	func getForumThreads(for sectionID: Int?, order: String?, page: Int?, withSuccess successHandler: @escaping (_ forumThreads: ForumThreads?) -> Void) {
		guard let sectionID = sectionID else { return }
		guard let order = order else { return }
		guard let page = page else { return }

		let request: APIRequest<ForumThreads, JSONError> = tron.swiftyJSON.request("forum-sections/\(sectionID)/threads")
		request.headers = headers
		request.method = .get
		request.parameters = [
			"order": order,
			"page": page
		]
		request.perform(withSuccess: { threads in
			if let success = threads.success {
				if success {
						successHandler(threads)
				}
			}
		}, failure: { error in
			SCLAlertView().showError("Can't get forum thread 😔", subTitle: error.message)

			print("Received get forum threads error: \(error)")
		})
	}

	/**
		Post a new thread to the given forum section id.

		- Parameter title: The title of the thread.
		- Parameter content: The content of the thread.
		- Parameter sectionID: The id of the forum section where the thread is posted.
		- Parameter successHandler: A closure returning the newly created thread id.
		- Parameter threadID: The id of the newly created thread.
	*/
	func postThread(inSection sectionID: Int?, withTitle title: String?, content: String?, withSuccess successHandler: @escaping (_ threadID: Int) -> Void) {
		guard let title = title else { return }
		guard let content = content else { return }
		guard let sectionID = sectionID else { return }

		let request: APIRequest<ThreadPost, JSONError> = tron.swiftyJSON.request("forum-sections/\(sectionID)/threads")
		request.headers = [
			"Content-Type": "application/x-www-form-urlencoded",
			"kuro-auth": User.authToken
		]
		request.method = .post
		request.parameters = [
			"title": title,
			"content": content
		]
		request.perform(withSuccess: { thread in
			if let success = thread.success {
				if success, let threadID = thread.threadID {
					successHandler(threadID)
				}
			}
		}, failure: { error in
			SCLAlertView().showError("Can't submit your thread 😔", subTitle: error.message)

			print("Received post thread error: \(error)")
		})
	}

// MARK: - Forum threads
// All forum threads related endpoints
	/**
		Fetch the details of the given thread id.

		- Parameter threadID: The id of the thread for which the details should be fetched.
		- Parameter successHandler: A closure returning a ForumThreadElement object.
		- Parameter thread: The returned ForumTheadElement object.
	*/
	func getDetails(forThread threadID: Int?, withSuccess successHandler: @escaping (_ thread: ForumThreadElement?) -> Void) {
		guard let threadID = threadID else { return }

		let request: APIRequest<ForumThread, JSONError> = tron.swiftyJSON.request("forum-threads/\(threadID)")
		request.headers = [
			"Content-Type": "application/x-www-form-urlencoded",
			"kuro-auth": User.authToken
		]
		request.method = .get
		request.perform(withSuccess: { thread in
			if let success = thread.success {
				if success {
					successHandler(thread.thread)
				}
			}
		}, failure: { error in
			SCLAlertView().showError("Can't get thread details 😔", subTitle: error.message)

			print("Received get thread error: \(error)")
		})
	}

	/**
		Upvote or downvote a thread with the given thread id.

		- Parameter threadID: The id of the thread that should be up upvoted/downvoted.
		- Parameter vote: An intgere indicating whether the thread is upvoted or downvoted. (0 = downvote, 1 = upvote)
		- Parameter successHandler: A closure returning an intiger indicating whether the thread is upvoted or downvoted.
		- Parameter action: The integer indicating whether the thead is upvoted or downvoted.
	*/
	func vote(forThread threadID: Int?, vote: Int?, withSuccess successHandler: @escaping (_ action: Int) -> Void) {
		guard let threadID = threadID else { return }
		guard let vote = vote else { return }

		let request: APIRequest<VoteThread, JSONError> = tron.swiftyJSON.request("forum-threads/\(threadID)/vote")
		request.headers = [
			"Content-Type": "application/x-www-form-urlencoded",
			"kuro-auth": User.authToken
		]
		request.method = .post
		request.parameters = [
			"vote": vote
		]
		request.perform(withSuccess: { vote in
			if let success = vote.success {
				if success, let action = vote.action {
					successHandler(action)
				}
			}
		}, failure: { error in
			SCLAlertView().showError("Can't vote on this thread 😔", subTitle: error.message)

			print("Received vote thread error: \(error)")
		})
	}

	/**
		Fetch the replies for the given thread id.

		- Parameter threadID: The id of the thread for which the replies should be fetched.
		- Parameter order: The method by which the replies should be ordered. Current options are "top" and "recent".
		- Parameter page: The page to retrieve replies from. (starts at 0)
		- Parameter successHandler: A closure returning a ThreadReplies object.
		- Parameter threadReplies: The returned ThreadReplies object.
	*/
	func getReplies(forThread threadID: Int?, order: String?, page: Int?, withSuccess successHandler: @escaping (_ threadReplies: ThreadReplies) -> Void) {
		guard let threadID = threadID else { return }
		guard let order = order else { return }
		guard let page = page else { return }

		let request: APIRequest<ThreadReplies, JSONError> = tron.swiftyJSON.request("forum-threads/\(threadID)/replies")
		request.headers = [
			"Content-Type": "application/x-www-form-urlencoded",
			"kuro-auth": User.authToken
		]
		request.method = .get
		request.parameters = [
			"order": order,
			"page": page
		]
		request.perform(withSuccess: { replies in
			if let success = replies.success {
				if success {
					successHandler(replies)
				}
			}
		}, failure: { error in
			SCLAlertView().showError("Can't get replies 😔", subTitle: error.message)

			print("Received get replies error: \(error)")
		})
	}

	/**
		Post a new reply to the given thread id.

		- Parameter comment: The content of the reply.
		- Parameter threadID: The id of the forum thread where the reply is posted.
		- Parameter successHandler: A closure returning the newly created reply id.
		- Parameter replyID: The id of the newly created reply.
	*/
	func postReply(inThread threadID: Int?, withComment comment: String?, withSuccess successHandler: @escaping (_ replyID: Int) -> Void) {
		guard let threadID = threadID else { return }
		guard let comment = comment else { return }

		let request: APIRequest<ThreadReply, JSONError> = tron.swiftyJSON.request("forum-threads/\(threadID)/replies")
		request.headers = [
			"Content-Type": "application/x-www-form-urlencoded",
			"kuro-auth": User.authToken
		]
		request.method = .post
		request.parameters = [
			"content": comment
		]
		request.perform(withSuccess: { reply in
			if let success = reply.success {
				if success, let replyID = reply.replyID {
					successHandler(replyID)
				}
			}
		}, failure: { error in
			SCLAlertView().showError("Can't reply 😔", subTitle: error.message)

			print("Received post reply error: \(error)")
		})
	}

	/**
		Fetch a list of threads matching the search query.

		- Parameter thread: The search query.
		- Parameter successHandler: A closure returning a SearchElement array.
		- Parameter search: The returned SearchElement array.
	*/
	func search(forThread thread: String?, withSuccess successHandler: @escaping (_ search: [SearchElement]?) -> Void) {
		guard let thread = thread else { return }

		let request: APIRequest<Search, JSONError> = tron.swiftyJSON.request("forum-threads/search")
		request.headers = [
			"Content-Type": "application/x-www-form-urlencoded",
			"kuro-auth": User.authToken
		]
		request.method = .get
		request.parameters = [
			"query": thread
		]
		request.perform(withSuccess: { search in
			if let success = search.success {
				if success {
					successHandler(search.results)
				}
			}
		}, failure: { error in
			SCLAlertView().showError("Can't get search results 😔", subTitle: error.message)

			print("Received thread search error: \(error)")
		})
	}

	/**
		Lock or unlock a thread with the given thread id.

		- Parameter threadID: The id of the forum thread to be locked/unlocked.
		- Parameter lock: The integer indicating whether to lock or unlock a thread. (0 = unlock, 1 = lock)
		- Parameter successHandler: A closure returning a boolean indicating whether thread lock/unlock is successful.
		- Parameter isSuccess: A boolean value indicating whether thread lock/unlock is successful.
	*/
	func lockThread(withID threadID: Int?, lock: Int?, withSuccess successHandler: @escaping (_ isSuccess: Bool) -> Void) {
		guard let threadID = threadID else { return }
		guard let lock = lock else { return }

		let request: APIRequest<ForumThread, JSONError> = tron.swiftyJSON.request("forum-threads/\(threadID)/lock")
		request.headers = [
			"Content-Type": "application/x-www-form-urlencoded",
			"kuro-auth": User.authToken
		]
		request.method = .post
		request.parameters = [
			"lock": lock
		]
		request.perform(withSuccess: { lock in
			if let success = lock.success {
				if success, let locked = lock.thread?.locked {
					successHandler(locked)
				}
			}
		}, failure: { error in
			SCLAlertView().showError("Can't lock thread 😔", subTitle: error.message)

			print("Received thread lock error: \(error)")
		})
	}

// MARK: - Forum Replies
// All forum replies related endpoints
	/**
		Upvote or downvote a reply with the given reply id.

		- Parameter replyID: The id of the thread reply to be upvoted/downvoted.
		- Parameter vote: An integer indicating whether the reply is upvoted or downvoted. (0 = downvote, 1 = upvote)
		- Parameter successHandler: A closure returning an integer indicating whether the reply is upvoted or downvoted.
		- Parameter action: The integer indicating whether the reply is upvoted or downvoted.
	*/
	func vote(forReply replyID: Int?, vote: Int?, withSuccess successHandler: @escaping (_ action: Int) -> Void) {
		guard let replyID = replyID else { return }
		guard let vote = vote else { return }

		let request: APIRequest<VoteThread, JSONError> = tron.swiftyJSON.request("forum-replies/\(replyID)/vote")
		request.headers = [
			"Content-Type": "application/x-www-form-urlencoded",
			"kuro-auth": User.authToken
		]
		request.method = .post
		request.parameters = [
			"vote": vote
		]
		request.perform(withSuccess: { vote in
			if let success = vote.success {
				if success, let action = vote.action {
					successHandler(action)
				}
			}
		}, failure: { error in
			SCLAlertView().showError("Can't vote on this reply 😔", subTitle: error.message)

			print("Received vote reply error: \(error)")
		})
	}

// MARK: - Sessions
// All sessions related endpoints
	/**
		Create a new session a.k.a login.

		- Parameter username: The username of the user to be logged in.
		- Parameter password: The password of the user to be logged in.
		- Parameter device: The name of the device the login is occuring from.
		- Parameter successHandler: A closure returning a boolean indicating whether login is successful.
		- Parameter isSuccess: A boolean value indicating whether login is successful.
	*/
	func login(_ username: String?, _ password: String?, _ device: String?, withSuccess successHandler: @escaping (_ isSuccess: Bool) -> Void) {
		guard let username = username else { return }
		guard let password = password else { return }
		guard let device = device else { return }

		let request: APIRequest<User, JSONError> = tron.swiftyJSON.request("sessions")
		request.headers = headers
		request.method = .post
		request.parameters = [
			"username": username,
			"password": password,
			"device": device
		]
		request.perform(withSuccess: { user in
			if let success = user.success {
				if success {
					if let userId = user.profile?.id {
						try? GlobalVariables().KDefaults.set(String(userId), key: "user_id")
					}

					try? GlobalVariables().KDefaults.set(username, key: "username")

					if let authToken = user.profile?.authToken {
						try? GlobalVariables().KDefaults.set(authToken, key: "auth_token")
					}

					if let sessionID = user.profile?.sessionID {
						try? GlobalVariables().KDefaults.set(String(sessionID), key: "session_id")
					}

					if let role = user.profile?.role {
						try? GlobalVariables().KDefaults.set(String(role), key: "user_role")
					}
					successHandler(success)
				}
			}
		}, failure: { error in
			SCLAlertView().showError("Can't login 😔", subTitle: error.message)
			successHandler(false)

			print("Received login error: \(error)")
		})
	}

	/**
		Check if the current session is valid.

		- Parameter successHandler: A closure returning a boolean indicating whether session validation is successful.
		- Parameter isSuccess: A boolean value indicating whether session validation is successful.
	*/
	func validateSession(withSuccess successHandler: @escaping (_ isSuccess: Bool) -> Void) {
		if !User.authToken.isEmpty && User.currentID != nil {
			guard let sessionID = User.currentSessionID else { return }
			let request: APIRequest<User, JSONError> = tron.swiftyJSON.request("sessions/\(sessionID)/validate")
			request.headers = [
				"Content-Type": "application/x-www-form-urlencoded",
				"kuro-auth": User.authToken
			]
			request.method = .post
			request.perform(withSuccess: { user in
				if let success = user.success {
					successHandler(success)
				}
			}, failure: { error in
				WorkflowController.logoutUser()
				SCLAlertView().showError("Can't validate session 😔", subTitle: error.message)
				NotificationCenter.default.post(name: .KHeartAttackShouldHappen, object: nil)

				print("Received validate session error: \(error)")
			})
		} else {
			successHandler(false)
		}
	}

	/**
		Delete a session with the given session id.

		- Parameter sessionID: The id of the session to be deleted.
		- Parameter successHandler: A closure returning a boolean indicating whether session delete is successful.
		- Parameter isSuccess: A boolean value indicating whether session delete is successful.
	*/
	func deleteSession(with sessionID: Int?, withSuccess successHandler: @escaping (_ isSuccess: Bool) -> Void) {
		guard let sessionID = sessionID else { return }

		let request: APIRequest<UserSessions, JSONError> = tron.swiftyJSON.request("sessions/\(sessionID)/delete")
		request.headers = [
			"Content-Type": "application/x-www-form-urlencoded",
			"kuro-auth": User.authToken
		]
		request.method = .post
		request.perform(withSuccess: { session in
			if let success = session.success {
				if success {
					successHandler(success)
				}
			}
		}, failure: { error in
			SCLAlertView().showError("Can't delete session 😔", subTitle: error.message)

			print("Received delete session error: \(error)")
		})
	}

	/**
		Logout the current user by deleting the current session.

		- Parameter successHandler: A closure returning a boolean indicating whether logout is successful.
		- Parameter isSuccess: A boolean value indicating whether logout is successful.
	*/
	func logout(withSuccess successHandler: ((_ isSuccess: Bool) -> Void)?) {
		guard let sessionID = User.currentSessionID else { return }

		let request: APIRequest<User, JSONError> = tron.swiftyJSON.request("sessions/\(sessionID)/delete")
		request.headers = [
			"Content-Type": "application/x-www-form-urlencoded",
			"kuro-auth": User.authToken
		]
		request.method = .post
		request.perform(withSuccess: { user in
			if let success = user.success {
				if success {
					WorkflowController.logoutUser()
					successHandler?(success)
				}
			}
		}, failure: { error in
			SCLAlertView().showError("Can't logout 😔", subTitle: error.message)

			print("Received logout error: \(error)")
		})
	}

// MARK: - Misc
// All misc related enpoints
	/**
		Fetch the latest privacy policy.

		- Parameter successHandler: A closure returning a PrivacyPolicyElement object.
		- Parameter privacyPolicy: The returned PrivacyPolicyElement object.
	*/
	func getPrivacyPolicy(withSuccess successHandler: @escaping (_ privacyPolicy: PrivacyPolicyElement?) -> Void) {
		let request: APIRequest<PrivacyPolicy, JSONError> = tron.swiftyJSON.request("privacy-policy")
		request.headers = headers
		request.method = .get
		request.perform(withSuccess: { privacyPolicy in
			if let success = privacyPolicy.success {
				if success {
					successHandler(privacyPolicy.privacyPolicy)
				}
			}
		}, failure: { error in
			SCLAlertView().showError("Can't get privacy policy 😔", subTitle: error.message)

			print("Received privacy policy error: \(error)")
		})
	}

// MARK: - Theme Store
	/**
		Fetch the list of themes.

		- Parameter successHandler: A closure returning a ThemesElement array.
		- Parameter themes: The returned ThemesElement array.
	*/
	func getThemes(withSuccess successHandler: @escaping (_ themes: [ThemesElement]?) -> Void) {
		let request: APIRequest<Themes, JSONError> = tron.swiftyJSON.request("themes")
		request.headers = headers
		request.method = .get
		request.perform(withSuccess: { themes in
			if let success = themes.success {
				if success {
					successHandler(themes.themes)
				}
			}
		}, failure: { error in
			SCLAlertView().showError("Can't get themes 😔", subTitle: error.message)

			print("Received get themes error: \(error)")
		})
	}
}
