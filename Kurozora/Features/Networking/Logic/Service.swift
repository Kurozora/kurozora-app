//
//  Service.swift
//  Kurozora
//
//  Created by Khoren Katklian on 11/07/2018.
//  Copyright © 2018 Kurozora. All rights reserved.
//

import KCommonKit
import TRON
import SwiftyJSON
import SCLAlertView

struct Service {
	let tron = TRON(baseURL: "https://kurozora.app/api/v1/", plugins: [NetworkActivityPlugin(application: UIApplication.shared)])

	fileprivate let headers = [
		"Content-Type": "application/x-www-form-urlencoded"
	]

	static let shared = Service()
    
// MARK: - User
// All user related endpoints
	/**
		Register a new account

		- Parameter username: The new user's username.
		- Parameter password: The new user's password.
		- Parameter email: the new user's email.
		- Parameter profileImage: The new user's avatar image.
		- Parameter successHandler: Returns true if the request finishes with no errors.
	**/
	func register(withUsername username: String?, email: String?, password: String?, withSuccess successHandler:@escaping (Bool) -> Void)  {
		guard let username = username else { return }
		guard let email = email else { return }
		guard let password = password else { return }

		let request : APIRequest<User,JSONError> = tron.swiftyJSON.request("users")
		request.headers = headers
		request.authorizationRequirement = .required
		request.method = .post
		request.parameters = [
			"username": username,
			"email": email,
			"password": password,
		]
		request.perform(withSuccess: { reset in
			if let success = reset.success {
				if success {
					successHandler(success)
				}
			}
		}, failure: { error in
			if let responseMessage = error.errorModel?.message {
				UIView().endEditing(true)
				SCLAlertView().showError("Can't register account 😔", subTitle: responseMessage)
			}

			print("Received reset password error: \(error)")
		})
	}

	/**
		Reset password request

		- Parameter successHandler: Returns true if the request finishes with no errors.
	**/
    func resetPassword(_ email: String?, withSuccess successHandler:@escaping (Bool) -> Void)  {
		guard let email = email else { return }

		let request : APIRequest<User,JSONError> = tron.swiftyJSON.request("users/reset-password")
        request.headers = headers
        request.authorizationRequirement = .required
        request.method = .post
        request.parameters = [
            "email": email,
        ]
        request.perform(withSuccess: { reset in
            if let success = reset.success {
                if success {
                    successHandler(success)
                }
            }
        }, failure: { error in
			if let responseMessage = error.errorModel?.message {
				UIView().endEditing(true)
				SCLAlertView().showError("Can't send reset link 😔", subTitle: responseMessage)
			}

            print("Received reset password error: \(error)")
        })
    }

	/**
		Update a user's information

		- Parameter bio: The new biography to set.
		- Parameter profileImage: The new user's avatar image.
		- Parameter successHandler: Returns true if the request finishes with no errors.
	**/
	func updateInformation(withBio bio: String?, profileImage: UIImage?, withSuccess successHandler:@escaping (Bool) -> Void)  {
		guard let bio = bio else { return }
		guard let profileImage = profileImage else { return }
		guard let userID = User.currentID() else { return }

		let request : UploadAPIRequest<User,JSONError> = tron.swiftyJSON.uploadMultipart("users/\(userID)/profile") { (formData) in
			if let profileImage = profileImage.jpegData(compressionQuality: 0.1) {
				formData.append(profileImage, withName: "profileImage", fileName: "ProfilePicture.png", mimeType: "image/png")
			}
		}

		request.headers = [
			"Content-Type": "multipart/form-data",
			"kuro-auth": User.authToken()
		]
		request.authorizationRequirement = .required
		request.method = .post
		request.parameters = [
			"biography": bio
		]

		request.performMultipart(withSuccess: { (update) in
			if let success = update.success {
				if success {
					successHandler(success)
					if let message = update.message {
						SCLAlertView().showSuccess("Settings updated ☺️", subTitle: message)
					}
				}
			}
		}, failure: { error in
			if let responseMessage = error.errorModel?.message {
				UIView().endEditing(true)
				SCLAlertView().showError("Can't update information 😔", subTitle: responseMessage)
			}

			print("Received update information error: \(error)")
		})
	}

	/**
		Get a list of sessions for the current user

		- Parameter successHandler: Returns an object of type UserSessions.
	**/
	func getSessions(withSuccess successHandler:@escaping (UserSessions?) -> Void){
		guard let userID = User.currentID() else { return }

		let request : APIRequest<UserSessions,JSONError> = tron.swiftyJSON.request("users/\(userID)/sessions")
		request.headers = [
			"Content-Type": "application/x-www-form-urlencoded",
			"kuro-auth": User.authToken()
		]
		request.authorizationRequirement = .required
		request.method = .get
		request.perform(withSuccess: { session in
			if let success = session.success {
				if success {
					successHandler(session)
				}
			}
		}, failure: { error in
			if let responseMessage = error.errorModel?.message {
				SCLAlertView().showError("Can't get session 😔", subTitle: responseMessage)
			}

			print("Received get session error: \(error)")
		})
	}

	/**
		Get a list of items for the current user's library

		- Parameter status: The status to retrieve the library items for.
		- Parameter successHandler: Returns an array of type LibraryElement.
	**/
	func getLibrary(withStatus status: String?, withSuccess successHandler:@escaping ([LibraryElement]?) -> Void) {
		guard let status = status else { return }
		guard let userID = User.currentID() else { return }

		let request: APIRequest<Library,JSONError> = tron.swiftyJSON.request("users/\(userID)/library")
		request.headers = [
			"Content-Type": "application/x-www-form-urlencoded",
			"kuro-auth": User.authToken()
		]
		request.authorizationRequirement = .required
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
			if let responseMessage = error.errorModel?.message {
				SCLAlertView().showError("Can't get your library 😔", subTitle: responseMessage)
			}

			print("Received get library error: \(error)")
		})
	}

	/**
		Add an item to the current user's library

		- Parameter status: The watch status to assign to the Anime.
		- Parameter showID: The ID of the Anime to add.
		- Parameter successHandler: Returns true if the request finishes with no errors.
	**/
	func addToLibrary(withStatus status: String?, showID: Int?,withSuccess successHandler:@escaping (Bool) -> Void) {
		guard let status = status else { return }
		guard let showID = showID else { return }
		guard let userID = User.currentID() else { return }

		let request: APIRequest<Library,JSONError> = tron.swiftyJSON.request("users/\(userID)/library")
		request.headers = [
			"Content-Type": "application/x-www-form-urlencoded",
			"kuro-auth": User.authToken()
		]
		request.authorizationRequirement = .required
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
			if let responseMessage = error.errorModel?.message {
				SCLAlertView().showError("Can't add to your library 😔", subTitle: responseMessage)
			}

			print("Received add library error: \(error)")
		})
	}

	/**
		Remove an item from the current user's library

		- Parameter showID: ID of the user.
		- Parameter successHandler: Returns true if the request finishes with no errors.
	**/
	func removeFromLibrary(withID showID: Int?, withSuccess successHandler:@escaping (Bool) -> Void) {
		guard let showID = showID else { return }
		guard let userID = User.currentID() else { return }

		let request: APIRequest<Library,JSONError> = tron.swiftyJSON.request("users/\(userID)/library/delete")
		request.headers = [
			"Content-Type": "application/x-www-form-urlencoded",
			"kuro-auth": User.authToken()
		]
		request.authorizationRequirement = .required
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
			if let responseMessage = error.errorModel?.message {
				SCLAlertView().showError("Can't remove from your library 😔", subTitle: responseMessage)
			}

			print("Received remove library error: \(error)")
		})
	}

	/**
		Get a user's profile details

		- Parameter successHandler: Returns an object of type User.
	**/
    func getUserProfile(_ userID:Int?, withSuccess successHandler:@escaping (User?) -> Void)  {
		guard let userID = userID else { return }

        let request : APIRequest<User,JSONError> = tron.swiftyJSON.request("users/\(userID)/profile")
        request.headers = [
			"Content-Type": "application/x-www-form-urlencoded",
			"kuro-auth": User.authToken()
		]
        request.authorizationRequirement = .required
        request.method = .get
        request.perform(withSuccess: { userProfile in
            if let success = userProfile.success {
                if success {
                    successHandler(userProfile)
                }
            }
        }, failure: { error in
			if let responseMessage = error.errorModel?.message {
				SCLAlertView().showError("Can't get user details 😔", subTitle: responseMessage)
			}

            print("Received user profile error: \(error)")
        })
    }

	/**
		Get a list of notifications for the current user

		- Parameter successHandler: Returns an array of type UserNotificationsElement.
	**/
	func getNotifications(withSuccess successHandler:@escaping ([UserNotificationsElement]?) -> Void){
		guard let userID = User.currentID() else { return }

		let request : APIRequest<UserNotification,JSONError> = tron.swiftyJSON.request("users/\(userID)/notifications")
		request.headers = [
			"Content-Type": "application/x-www-form-urlencoded",
			"kuro-auth": User.authToken()
		]
		request.authorizationRequirement = .required
		request.method = .get
		request.perform(withSuccess: { userNotifications in
			if let success = userNotifications.success {
				if success {
					successHandler(userNotifications.notifications)
				}
			}
		}, failure: { error in
			if let responseMessage = error.errorModel?.message {
				SCLAlertView().showError("Can't get your notifications 😔", subTitle: responseMessage)
			}

			print("Received get notifications error: \(error)")
		})
	}

	/**
		Search for a user

		- Parameter user: The search query.
		- Parameter successHandler: Returns an object of type SearchElement.
	**/
	func search(forUser user: String?, withSuccess successHandler:@escaping ([SearchElement]?) -> Void) {
		guard let user = user else { return }

		let request: APIRequest<Search,JSONError> = tron.swiftyJSON.request("users/search")
		request.headers = headers
		request.authorizationRequirement = .required
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
			if let responseMessage = error.errorModel?.message {
				SCLAlertView().showError("Can't get search results 😔", subTitle: responseMessage)
			}

			print("Received user search error: \(error)")
		})
	}

	/**
		Follow or unfollow a user

		- Parameter userID: ID of the user.
		- Parameter successHandler: Returns true if the request finishes with no errors.
	**/
	func follow(_ follow: Int?, user userID: Int?, withSuccess successHandler:@escaping (Bool) -> Void) {
		guard let follow = follow else { return }
		guard let userID = userID else { return }

		let request : APIRequest<UserFollow,JSONError> = tron.swiftyJSON.request("users/\(userID)/follow")
		request.headers = [
			"Content-Type": "application/x-www-form-urlencoded",
			"kuro-auth": User.authToken()
		]
		request.authorizationRequirement = .required
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
			if let responseMessage = error.errorModel?.message {
				SCLAlertView().showError("Can't follow user 😔", subTitle: responseMessage)
			}

			print("Received follow user error: \(error)")
		})
	}


// MARK: - Notifications
// All notifications related endpoints
	/**
		Delete a notification

		- Parameter notificationID: ID of the notification to be deleted.
		- Parameter successHandler: Returns true if the request finishes with no errors.
	**/
	func deleteNotification(with notificationID: Int?, withSuccess successHandler:@escaping (Bool) -> Void) {
		guard let notificationID = notificationID else { return }

		let request : APIRequest<UserNotification,JSONError> = tron.swiftyJSON.request("user-notifications/\(notificationID)/delete")

		request.headers = [
			"Content-Type": "application/x-www-form-urlencoded",
			"kuro-auth": User.authToken()
		]
		request.authorizationRequirement = .required
		request.method = .post

		request.perform(withSuccess: { notification in
			if let success = notification.success {
				if success {
					successHandler(success)
				}
			}
		}, failure: { error in
			if let responseMessage = error.errorModel?.message {
				SCLAlertView().showError("Can't delete notification 😔", subTitle: responseMessage)
			}

			print("Received delete notification error: \(error)")
		})
	}

// MARK: - Show
// All show related endpoints
	/**
		Get explore page content

		- Parameter successHandler: Returns an object of type Explore.
	**/
	func getExplore(withSuccess successHandler: @escaping (Explore?) -> Void) {
		let request: APIRequest<Explore,JSONError> = tron.swiftyJSON.request("anime")
		request.headers = headers
		request.method = .get
		request.perform(withSuccess: { explore in
			if let success = explore.success {
				if success {
					successHandler(explore)
				}
			}
		}, failure: { error in
			if let responseMessage = error.errorModel?.message {
				SCLAlertView().showError("Can't get explore page 😔", subTitle: responseMessage)
			}

			print("Received explore error: \(error)")
		})
	}

	/**
		Get show detail

		- Parameter showID: ID of the anime.
		- Parameter completionHandler: Returns an object of type ShowDetails.
	**/
	func getDetails(forShow showID: Int?, completionHandler: @escaping (ShowDetails) -> Void) {
		guard let showID = showID else { return }

		let request : APIRequest<ShowDetails,JSONError> = tron.swiftyJSON.request("anime/\(showID)")
		request.headers = [
			"Content-Type": "application/x-www-form-urlencoded",
			"kuro-auth": User.authToken()
		]
		request.authorizationRequirement = .required
		request.method = .get
		request.perform(withSuccess: { showDetails in
			DispatchQueue.main.async {
				completionHandler(showDetails)
			}
		}, failure: { error in
			if let responseMessage = error.errorModel?.message {
				SCLAlertView().showError("Can't get show details 😔", subTitle: responseMessage)
			}

			print("Received get details error: \(error)")
		})
	}

	/**
		Get cast details for a show

		- Parameter successHandler: Returns an array of type ActorsElement.
	**/
	func getCastFor(_ showID: Int?, withSuccess successHandler:@escaping ([ActorsElement]?) -> Void) {
		guard let showID = showID else { return }

		let request: APIRequest<Actors,JSONError> = tron.swiftyJSON.request("anime/\(showID)/actors")
		request.headers = headers
		request.method = .get
		request.perform(withSuccess: { actors in
			if let success = actors.success {
				if success {
					successHandler(actors.actors)
				}
			}
		}, failure: { error in
			if let responseMessage = error.errorModel?.message {
				SCLAlertView().showError("Can't get casts list 😔", subTitle: responseMessage)
			}

			print("Received get cast error: \(error)")
		})
	}

	/**
		Get season details for a show

		- Parameter successHandler: Returns an array of type SeasonsElement.
	**/
	func getSeasonFor(_ showID: Int?, withSuccess successHandler:@escaping ([SeasonsElement]?) -> Void) {
		guard let showID = showID else { return }

		let request : APIRequest<Seasons,JSONError> = tron.swiftyJSON.request("anime/\(showID)/seasons")
		request.headers = headers
		request.authorizationRequirement = .required
		request.method = .get
		request.perform(withSuccess: { seasons in
			if let success = seasons.success {
				if success {
					successHandler(seasons.seasons)
				}
			}
		}, failure: { error in
			if let responseMessage = error.errorModel?.message {
				SCLAlertView().showError("Can't get seasons list 😔", subTitle: responseMessage)
			}

			print("Received get show seasons error: \(error)")
		})
	}

	/**
		Rate a show

		- Parameter showID: ID of the anime.
		- Parameter score: The rating to leave.
		- Parameter successHandler: Returns true if the request finishes with no errors.
	**/
	func rate(showID: Int?, score: Double?, withSuccess successHandler:@escaping (Bool) -> Void) {
		guard let rating = score else { return }
		guard let showID = showID else { return }

		let request: APIRequest<User,JSONError> = tron.swiftyJSON.request("anime/\(showID)/rate")
		request.headers = [
			"Content-Type": "application/x-www-form-urlencoded",
			"kuro-auth": User.authToken()
		]
		request.authorizationRequirement = .required
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
			if let responseMessage = error.errorModel?.message {
				SCLAlertView().showError("Can't rate this show 😔", subTitle: responseMessage)
			}

			print("Received rating error: \(error)")
		})
	}

	/**
		Search for a show

		- Parameter show: The search query.
		- Parameter successHandler: Returns an array of type SearchElement.
	**/
	func search(forShow show: String?, withSuccess successHandler:@escaping ([SearchElement]?) -> Void) {
		guard let show = show else { return }

		let request: APIRequest<Search,JSONError> = tron.swiftyJSON.request("anime/search")
		request.headers = headers
		request.authorizationRequirement = .required
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
			if let responseMessage = error.errorModel?.message {
				SCLAlertView().showError("Can't get search results 😔", subTitle: responseMessage)
			}

			print("Received show search error: \(error)")
		})
	}

// MARK: - Anime Seasons
// All show seasons related endpoints
	/**
		Get episode details for a show season

		- Parameter seasonID: ID of the season.
		- Parameter successHandler: Returns an object of type Episodes.
	**/
	func getEpisodes(forSeason seasonID: Int?, withSuccess successHandler:@escaping (Episodes?) -> Void) {
		guard let seasonID = seasonID else { return }

		let request : APIRequest<Episodes,JSONError> = tron.swiftyJSON.request("anime-seasons/\(seasonID)/episodes")
		request.headers = [
			"Content-Type": "application/x-www-form-urlencoded",
			"kuro-auth": User.authToken()
		]
		request.authorizationRequirement = .required
		request.method = .get
		request.perform(withSuccess: { episodes in
			if let success = episodes.success {
				if success {
					successHandler(episodes)
				}
			}
		}, failure: { error in
			if let responseMessage = error.errorModel?.message {
				SCLAlertView().showError("Can't get episodes list 😔", subTitle: responseMessage)
			}

			print("Received get show episodes error: \(error)")
		})
	}

// MARK: - Anime Episodes
// All episode related endpoints
	/**
		Mark an episode status

		- Parameter watched: Mark episode watched or not. (0 = not watched, 1 = watched)
		- Parameter episodeID: ID of the episode.
		- Parameter successHandler: Returns true if the request finishes with no errors.
	**/
	func mark(asWatched watched: Int?, forEpisode episodeID: Int?, withSuccess successHandler:@escaping (Bool) -> Void) {
		guard let episodeID = episodeID else { return }
		guard let watched = watched else { return }

		let request : APIRequest<EpisodesWatched,JSONError> = tron.swiftyJSON.request("anime-episodes/\(episodeID)/watched")
		request.headers = [
			"Content-Type": "application/x-www-form-urlencoded",
			"kuro-auth": User.authToken()
		]
		request.authorizationRequirement = .required
		request.method = .post
		request.parameters = [
			"watched": watched
		]
		request.perform(withSuccess: { watched in
			if let success = watched.success {
				successHandler(success)
			}
		}, failure: { error in
			if let responseMessage = error.errorModel?.message {
				SCLAlertView().showError("Can't update episode 😔", subTitle: responseMessage)
			}

			print("Received mark episode error: \(error)")
		})
	}

// MARK: - Genres
// All genre related endpoints
	/**
		Get a list of genres

		- Parameter successHandler: Returns an array of type GenresElement.
	**/
	func getGenres(withSuccess successHandler:@escaping ([GenresElement]?) -> Void) {
		let request : APIRequest<Genres,JSONError> = tron.swiftyJSON.request("genres")
		request.headers = headers
		request.authorizationRequirement = .required
		request.method = .get
		request.perform(withSuccess: { genres in
			if let success = genres.success {
				if success {
					successHandler(genres.genres)
				}
			}
		}, failure: { error in
			if let responseMessage = error.errorModel?.message {
				SCLAlertView().showError("Can't get genres list 😔", subTitle: responseMessage)
			}

			print("Received get genres error: \(error)")
		})
	}

// MARK: - Forums
// All forum related endpoints
	/**
		Get a list of forum sections

		- Parameter successHandler: Returns an array of type ForumSectionsElement.
	**/
	func getForumSections(withSuccess successHandler:@escaping ([ForumSectionsElement]?) -> Void) {
		let request : APIRequest<ForumSections,JSONError> = tron.swiftyJSON.request("forum-sections")
		request.headers = headers
		request.authorizationRequirement = .required
		request.method = .get
		request.perform(withSuccess: { sections in
			if let success = sections.success {
				if success {
					successHandler(sections.sections)
				}
			}
		}, failure: { error in
			if let responseMessage = error.errorModel?.message {
				SCLAlertView().showError("Can't get forum sections 😔", subTitle: responseMessage)
			}

			print("Received get forum sections error: \(error)")
		})
	}

	/**
		Get a list of forum threads for a section

		- Parameter sectionID: ID of the forum section.
		- Parameter order: The method of ordering the threads. Currently "top" and "recent".
		- Parameter page: The page to retrieve threads from. (starts at 0)
		- Parameter successHandler: Returns an object of type ForumThreads.
	**/
	func getForumThreads(for sectionID: Int?, order: String?, page: Int?, withSuccess successHandler:@escaping (ForumThreads?) -> Void) {
		guard let sectionID = sectionID else { return }
		guard let order = order else { return }
		guard let page = page else { return }

		let request : APIRequest<ForumThreads,JSONError> = tron.swiftyJSON.request("forum-sections/\(sectionID)/threads")
		request.headers = headers
		request.authorizationRequirement = .required
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
			if let responseMessage = error.errorModel?.message {
				SCLAlertView().showError("Can't get forum thread 😔", subTitle: responseMessage)
			}

			print("Received get forum threads error: \(error)")
		})
	}

	/**
		Post a new thread to a section

		- Parameter title: The title of the thread.
		- Parameter content: Content of the thread.
		- Parameter sectionID: ID of the forum section.
		- Parameter successHandler: Returns thread ID if the request finishes with no errors.
	**/
	func postThread(withTitle title: String?, content: String?, forSection sectionID: Int?, withSuccess successHandler:@escaping (Int) -> Void){
		guard let title = title else { return }
		guard let content = content else { return }
		guard let sectionID = sectionID else { return }

		let request : APIRequest<ThreadPost,JSONError> = tron.swiftyJSON.request("forum-sections/\(sectionID)/threads")
		request.headers = [
			"Content-Type": "application/x-www-form-urlencoded",
			"kuro-auth": User.authToken()
		]
		request.authorizationRequirement = .required
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
			if let responseMessage = error.errorModel?.message {
				SCLAlertView().showError("Can't submit your thread 😔", subTitle: responseMessage)
			}

			print("Received post thread error: \(error)")
		})
	}

// MARK: - Forum threads
// All forum threads related endpoints
	/**
		Get the details of a forum thread

		- Parameter threadID: ID of the forum thread.
		- Parameter successHandler: Returns an object of type ForumThreadElement.
	**/
	func getDetails(forThread threadID: Int?, withSuccess successHandler:@escaping (ForumThreadElement?) -> Void){
		guard let threadID = threadID else { return }

		let request : APIRequest<ForumThread,JSONError> = tron.swiftyJSON.request("forum-threads/\(threadID)")
		request.headers = headers
		request.authorizationRequirement = .required
		request.method = .get
		request.perform(withSuccess: { thread in
			if let success = thread.success {
				if success {
					successHandler(thread.thread)
				}
			}
		}, failure: { error in
			if let responseMessage = error.errorModel?.message {
				SCLAlertView().showError("Can't get thread details 😔", subTitle: responseMessage)
			}

			print("Received get thread error: \(error)")
		})
	}

	/**
		Upvote or downvote a thread

		- Parameter threadID: ID of the forum thread.
		- Parameter vote: The vote to submit. (0 = downvote, 1 = upvote)
		- Parameter successHandler: Returns true if the request finishes with no errors.
	**/
	func vote(forThread threadID: Int?, vote: Int?, withSuccess successHandler:@escaping (Int) -> Void) {
		guard let threadID = threadID else { return }
		guard let vote = vote else { return }

		let request : APIRequest<VoteThread,JSONError> = tron.swiftyJSON.request("forum-threads/\(threadID)/vote")
		request.headers = [
			"Content-Type": "application/x-www-form-urlencoded",
			"kuro-auth": User.authToken()
		]
		request.authorizationRequirement = .required
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
			if let responseMessage = error.errorModel?.message {
				SCLAlertView().showError("Can't vote on this thread 😔", subTitle: responseMessage)
			}

			print("Received vote thread error: \(error)")
		})
	}

	/**
		Get the replies of a forum thread

		- Parameter threadID: ID of the forum thread.
		- Parameter order: The method of ordering the results. Current options are "top" and "recent".
		- Parameter page: The page to retrieve threads from. (starts at 0)
		- Parameter successHandler: Returns an array of type ThreadRepliesElement.
	**/
	func getReplies(forThread threadID: Int?, order: String?, page: Int?, withSuccess successHandler:@escaping (ThreadReplies) -> Void) {
		guard let threadID = threadID else { return }
		guard let order = order else { return }
		guard let page = page else { return }

		let request : APIRequest<ThreadReplies,JSONError> = tron.swiftyJSON.request("forum-threads/\(threadID)/replies")
		request.headers = [
			"Content-Type": "application/x-www-form-urlencoded",
			"kuro-auth": User.authToken()
		]
		request.authorizationRequirement = .required
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
			if let responseMessage = error.errorModel?.message {
				SCLAlertView().showError("Can't get replies 😔", subTitle: responseMessage)
			}

			print("Received vote thread error: \(error)")
		})
	}

	/**
		Submit a new thread to a section.

		- Parameter threadID: ID of the forum thread.
		- Parameter comment: The content of the reply.
		- Parameter successHandler: Returns reply ID if the request finishes without errors.
	**/
	func postReply(withComment comment: String?, forThread threadID: Int?, withSuccess successHandler:@escaping (Int) -> Void){
		guard let comment = comment else { return }
		guard let threadID = threadID else { return }

		let request : APIRequest<ThreadReply,JSONError> = tron.swiftyJSON.request("forum-threads/\(threadID)/replies")
		request.headers = [
			"Content-Type": "application/x-www-form-urlencoded",
			"kuro-auth": User.authToken()
		]
		request.authorizationRequirement = .required
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
			if let responseMessage = error.errorModel?.message {
				SCLAlertView().showError("Can't reply 😔", subTitle: responseMessage)
			}

			print("Received post reply error: \(error)")
		})
	}

	/**
		Search for a thread

		- Parameter thread: The search query.
		- Parameter successHandler: Returns an object of type SearchElement.
	**/
	func search(forThread thread: String?, withSuccess successHandler:@escaping ([SearchElement]?) -> Void) {
		guard let thread = thread else { return }

		let request: APIRequest<Search,JSONError> = tron.swiftyJSON.request("forum-threads/search")
		request.headers = headers
		request.authorizationRequirement = .required
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
			if let responseMessage = error.errorModel?.message {
				SCLAlertView().showError("Can't get search results 😔", subTitle: responseMessage)
			}

			print("Received thread search error: \(error)")
		})
	}

	/**
		Lock or unlock a thread.

		- Parameter threadID: ID of the forum thread.
		- Parameter successHandler: Returns an object of type SearchElement.
	**/
	func lockThread(withID threadID: Int?, lock: Int?, withSuccess successHandler:@escaping (Bool) -> Void) {
		guard let threadID = threadID else { return }
		guard let lock = lock else { return }

		let request: APIRequest<ForumThread,JSONError> = tron.swiftyJSON.request("forum-threads/\(threadID)/lock")
		request.headers = [
			"Content-Type": "application/x-www-form-urlencoded",
			"kuro-auth": User.authToken()
		]
		request.authorizationRequirement = .required
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
			if let responseMessage = error.errorModel?.message {
				SCLAlertView().showError("Can't lock thread 😔", subTitle: responseMessage)
			}

			print("Received thread lock error: \(error)")
		})
	}

// MARK: - Forum Replies
// All forum replies related endpoints
	/**
		Upvote or downvote a reply

		- Parameter replyID: ID of the forum reply.
		- Parameter vote: The vote to submit. (0 = downvote, 1 = upvote)
		- Parameter successHandler: Returns an int if the request finishes with no errors.
	**/
	func vote(forReply replyID: Int?, vote: Int?, withSuccess successHandler:@escaping (Int) -> Void) {
		guard let replyID = replyID else { return }
		guard let vote = vote else { return }

		let request : APIRequest<VoteThread,JSONError> = tron.swiftyJSON.request("forum-replies/\(replyID)/vote")
		request.headers = [
			"Content-Type": "application/x-www-form-urlencoded",
			"kuro-auth": User.authToken()
		]
		request.authorizationRequirement = .required
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
			if let responseMessage = error.errorModel?.message {
				SCLAlertView().showError("Can't vote on this reply 😔", subTitle: responseMessage)
			}

			print("Received vote reply error: \(error)")
		})
	}

// MARK: - Sessions
// All sessions related endpoints
	/**
		Create a new session a.k.a login

		- Parameter successHandler: Returns true if the request finishes without errors.
	**/
	func login(_ username: String?, _ password: String?, _ device: String?, withSuccess successHandler:@escaping (Bool) -> Void)  {
		guard let username = username else { return }
		guard let password = password else { return }
		guard let device = device else { return }

		let request : APIRequest<User,JSONError> = tron.swiftyJSON.request("sessions")
		request.headers = headers
		request.authorizationRequirement = .required
		request.method = .post
		request.parameters = [
			"username": username,
			"password": password,
			"device": device
		]
		request.perform(withSuccess: { user in
			if let success = user.success {
				if success {
					if let userId = user.user?.id {
						try? GlobalVariables().KDefaults.set(String(userId), key: "user_id")
					}

					try? GlobalVariables().KDefaults.set(username, key: "username")

					if let authToken = user.user?.authToken {
						try? GlobalVariables().KDefaults.set(authToken, key: "auth_token")
					}

					if let sessionID = user.user?.sessionID {
						try? GlobalVariables().KDefaults.set(String(sessionID), key: "session_id")
					}

					if let role = user.user?.role {
						try? GlobalVariables().KDefaults.set(String(role), key: "user_role")
					}
					successHandler(success)
				}
			}
		}, failure: { error in
			if let responseMessage = error.errorModel?.message {
				SCLAlertView().showError("Can't login 😔", subTitle: responseMessage)
				successHandler(false)
			}

			print("Received login error: \(error)")
		})
	}

	/**
		Check if the session is valid

		- Parameter successHandler: Returns true if the request finishes without errors.
	**/
    func validateSession(withSuccess successHandler:@escaping (Bool) -> Void) {
        if User.authToken() != "" && User.currentID() != nil {
			guard let sessionID = User.currentSessionID() else { return }
			let request : APIRequest<User,JSONError> = tron.swiftyJSON.request("sessions/\(sessionID)/validate")
			request.headers = [
				"Content-Type": "application/x-www-form-urlencoded",
				"kuro-auth": User.authToken()
			]
            request.authorizationRequirement = .required
            request.method = .post
            request.perform(withSuccess: { user in
                if let success = user.success {
					successHandler(success)
                }
            }, failure: { error in
				if let responseMessage = error.errorModel?.message {
					WorkflowController.logoutUser()
					SCLAlertView().showError("Can't validate session 😔", subTitle: responseMessage)
					NotificationCenter.default.post(name: heartAttackNotification, object: nil)
				}
                
                print("Received validate session error: \(error)")
            })
        } else {
            successHandler(false)
        }
    }

	/**
		Delete a session according to its ID

		- Parameter successHandler: Returns true if the request finishes without errors.
	**/
    func deleteSession(_ id: Int?, withSuccess successHandler:@escaping (Bool) -> Void) {
		guard let sessionID = id else { return }

        let request : APIRequest<UserSessions,JSONError> = tron.swiftyJSON.request("sessions/\(sessionID)/delete")

		request.headers = [
			"Content-Type": "application/x-www-form-urlencoded",
			"kuro-auth": User.authToken()
		]
        request.authorizationRequirement = .required
        request.method = .post
        
        request.perform(withSuccess: { session in
            if let success = session.success {
                if success {
                    successHandler(success)
                }
            }
        }, failure: { error in
			if let responseMessage = error.errorModel?.message {
				SCLAlertView().showError("Can't delete session 😔", subTitle: responseMessage)
			}
            
            print("Received delete session error: \(error)")
        })
    }

	/**
		Logout the current user by deleting the current session

		- Parameter successHandler: Returns true if the request finishes without errors.
	**/
	func logout(withSuccess successHandler:@escaping (Bool) -> Void)  {
		guard let sessionID = User.currentSessionID() else { return }

		let request : APIRequest<User,JSONError> = tron.swiftyJSON.request("sessions/\(sessionID)/delete")

		request.headers = [
			"Content-Type": "application/x-www-form-urlencoded",
			"kuro-auth": User.authToken()
		]
		request.authorizationRequirement = .required
		request.method = .post

		request.perform(withSuccess: { user in
			if let success = user.success {
				if success {
					WorkflowController.logoutUser()
					successHandler(success)
				}
			}
		}, failure: { error in
			if let responseMessage = error.errorModel?.message {
				SCLAlertView().showError("Can't logout 😔", subTitle: responseMessage)
			}

			print("Received logout error: \(error)")
		})
	}

// MARK: - Misc
// All misc related enpoints
	/**
		Get the latest privacy policy

		- Parameter successHandler: Returns an object of type PrivacyPolicyElement.
	**/
	func getPrivacyPolicy(withSuccess successHandler:@escaping (PrivacyPolicyElement?) -> Void) {
		let request: APIRequest<PrivacyPolicy,JSONError> = tron.swiftyJSON.request("privacy-policy")
		request.headers = headers
		request.method = .get
		request.perform(withSuccess: { privacyPolicy in
			if let success = privacyPolicy.success {
				if success {
					successHandler(privacyPolicy.privacyPolicy)
				}
			}
		}, failure: { error in
			if let responseMessage = error.errorModel?.message {
				SCLAlertView().showError("Can't get privacy policy 😔", subTitle: responseMessage)
			}

			print("Received privacy policy error: \(error)")
		})
	}

// MARK: - Theme Store
	/// Get Themes
	func getThemes(withSuccess successHandler:@escaping ([ThemesElement]?) -> Void){
		let request: APIRequest<Themes,JSONError> = tron.swiftyJSON.request("themes")
		request.headers = headers
		request.method = .get
		request.perform(withSuccess: { themes in
			if let success = themes.success {
				if success {
					successHandler(themes.themes)
				}
			}
		}, failure: { error in
			if let responseMessage = error.errorModel?.message {
				SCLAlertView().showError("Can't get privacy policy 😔", subTitle: responseMessage)
			}

			print("Received privacy policy error: \(error)")
		})
	}
}
