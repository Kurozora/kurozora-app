//
//  KService+User.swift
//  Kurozora
//
//  Created by Khoren Katklian on 29/09/2019.
//  Copyright © 2019 Kurozora. All rights reserved.
//

import TRON
import SCLAlertView

extension KService {
	/**
		Register a new account with the given details.

		- Parameter username: The new user's username.
		- Parameter password: The new user's password.
		- Parameter emailAddress: The new user's email address.
		- Parameter profileImage: The new user's profile image.
		- Parameter successHandler: A closure returning a boolean indicating whether registration is successful.
		- Parameter isSuccess: A boolean value indicating whether registration is successful.
	*/
	func register(withUsername username: String, emailAddress: String, password: String, profileImage: UIImage, withSuccess successHandler: @escaping (_ isSuccess: Bool) -> Void) {
		let request: UploadAPIRequest<User, JSONError> = tron.swiftyJSON.uploadMultipart("users") { (formData) in
			if let profileImage = profileImage.jpegData(compressionQuality: 0.1) {
				formData.append(profileImage, withName: "profileImage", fileName: "ProfileImage.png", mimeType: "image/png")
			}
		}
		request.headers = [
			"Content-Type": "multipart/form-data"
		]
		request.method = .post
		request.parameters = [
			"username": username,
			"email": emailAddress,
			"password": password
		]
		request.perform(withSuccess: { reset in
			if let success = reset.success {
				if success {
					successHandler(success)
				}
			}
		}, failure: { error in
			SCLAlertView().showError("Can't register account 😔", subTitle: error.message)
			print("Received register account error: \(error.message ?? "No message available")")
		})
	}

	/**
		Register a new account using the details from Sign In With Apple.

		- Parameter idToken: A JSON Web Token (JWT) that securely communicates information about the user to the server.
		- Parameter authorizationCode: A short-lived token used by the app for proof of authorization when interacting with the server.
		- Parameter successHandler: A closure returning a boolean indicating whether registration is successful.
		- Parameter isSuccess: A boolean value indicating whether registration is successful.
	*/
	func signInWithApple(usingIDToken idToken: String, authorizationCode: String, withSuccess successHandler: @escaping (_ isSuccess: Bool) -> Void) {
		let request: APIRequest<UserSessions, JSONError> = tron.swiftyJSON.request("users/register-siwa")
		request.headers = headers
		request.method = .post
		request.parameters = [
			"identity_token": idToken,
			"auth_code": authorizationCode
		]
		request.perform(withSuccess: { userSession in
			if let success = userSession.success {
				if success {
//					try? Kurozora.shared.KDefaults.set(idToken, key: "SIWA_id_token")
//					WorkflowController.shared.processUserData(fromSession: userSession)
					successHandler(success)
				}
			}
		}, failure: { error in
			SCLAlertView().showError("Can't sign in with Apple 😔", subTitle: error.message)
			print("Received sign in with Apple error: \(error.message ?? "No message available")")
		})
	}

	/**
		Request a password reset link for the given email address.

		- Parameter emailAddress: The email address to which the reset link should be sent.
		- Parameter successHandler: A closure returning a boolean indicating whether reset password request is successful.
		- Parameter isSuccess: A boolean value indicating whether reset password request is successful.
	*/
	func resetPassword(forEmailAddress emailAddress: String, withSuccess successHandler: @escaping (_ isSuccess: Bool) -> Void) {
		let request: APIRequest<User, JSONError> = tron.swiftyJSON.request("users/reset-password")
		request.headers = headers
		request.method = .post
		request.parameters = [
			"email": emailAddress
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
			print("Received reset password error: \(error.message ?? "No message available")")
		})
	}

	/**
		Update the current user's profile information.

		- Parameter userID: The id of the user whose information should be udpated.
		- Parameter bio: The new biography to set.
		- Parameter profileImage: The new user's profile image.
		- Parameter bannerImage: The new user's profile image.
		- Parameter successHandler: A closure returning a User object with the updated information.
		- Parameter isSuccess: A User object containing the updated information.
	*/
	func updateInformation(forUserID userID: Int, bio: String, profileImage: UIImage, bannerImage: UIImage, withSuccess successHandler: @escaping (_ isSuccess: User?) -> Void) {
		let request: UploadAPIRequest<User, JSONError> = tron.swiftyJSON.uploadMultipart("users/\(userID)/profile") { (formData) in
			if let profileImage = profileImage.jpegData(compressionQuality: 0.1) {
				formData.append(profileImage, withName: "profileImage", fileName: "ProfileImage.png", mimeType: "image/png")
			}
			if let bannerImage = bannerImage.jpegData(compressionQuality: 0.1) {
				formData.append(bannerImage, withName: "bannerImage", fileName: "BannerImage.png", mimeType: "image/png")
			}
		}
		request.headers = [
			"Content-Type": "multipart/form-data",
//			"kuro-auth": User.authToken
		]
		request.method = .post
		request.parameters = [
			"biography": bio
		]

		request.perform(withSuccess: { (update) in
			if let success = update.success {
				if success {
					successHandler(update)
					if let message = update.message {
						SCLAlertView().showSuccess("Settings updated ☺️", subTitle: message)
					}
				}
			}
		}, failure: { error in
			UIView().endEditing(true)
			SCLAlertView().showError("Can't update information 😔", subTitle: error.message)
			print("Received update information error: \(error.message ?? "No message available")")
		})
	}

	/**
		Fetch the list of sessions for the current user.

		- Parameter userID: The id of the user whose session should be fetched.
		- Parameter successHandler: A closure returning a UserSessions object.
		- Parameter userSessions: The returned UserSessions object.
	*/
	func getSessions(forUserID userID: Int, withSuccess successHandler: @escaping (_ userSessions: UserSessions?) -> Void) {
		let request: APIRequest<UserSessions, JSONError> = tron.swiftyJSON.request("users/\(userID)/sessions")
		request.headers = [
			"Content-Type": "application/x-www-form-urlencoded",
//			"kuro-auth": User.authToken
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
			print("Received get session error: \(error.message ?? "No message available")")
		})
	}

	/**
		Fetch the list of shows with the given show status in the current user's library.

		- Parameter userID: The id of the user whose library should be fetched.
		- Parameter status: The status to retrieve the library items for.
		- Parameter sortType: The sort value by which the retrived items should be sorted.
		- Parameter sortOption: The sort option value by which the retrived items should be sorted.
		- Parameter successHandler: A closure returning a LibraryElement array.
		- Parameter library: The returned LibraryElement array.
	*/
	func getLibrary(forUserID userID: Int, withStatus status: Library.Status, withSortType sortType: Library.SortType, withSortOption sortOption: Library.SortType.Options, withSuccess successHandler: @escaping (_ library: [ShowDetailsElement]?) -> Void) {
		let request: APIRequest<ShowDetails, JSONError> = tron.swiftyJSON.request("users/\(userID)/library")
		request.headers = [
			"Content-Type": "application/x-www-form-urlencoded",
//			"kuro-auth": User.authToken
		]
		request.method = .get
		request.parameters = [
			"status": status.stringValue
		]
		if sortType != .none {
			request.parameters["sort"] = "\(sortType.parameterValue)\(sortOption.parameterValue)"
		}
		request.perform(withSuccess: { showDetails in
			if let success = showDetails.success {
				if success {
					successHandler(showDetails.showDetailsElements)
				}
			}
		}, failure: { error in
			SCLAlertView().showError("Can't get library 😔", subTitle: error.message)
			print("Received get library error: \(error.message ?? "No message available")")
		})
	}

	/**
		Add a show with the given show id to the current user's library.

		- Parameter userID: The id of the user in whose library the show will be added.
		- Parameter status: The watch status to assign to the Anime.
		- Parameter showID: The id of the show to add.
		- Parameter successHandler: A closure returning a boolean indicating whether adding show to library is successful.
		- Parameter isSuccess: A boolean value indicating whether adding show to library is successful.
	*/
	func addToLibrary(forUserID userID: Int, withStatus status: Library.Status, showID: Int, withSuccess successHandler: @escaping (_ isSuccess: Bool) -> Void) {
		let request: APIRequest<ShowDetails, JSONError> = tron.swiftyJSON.request("users/\(userID)/library")
		request.headers = [
			"Content-Type": "application/x-www-form-urlencoded",
//			"kuro-auth": User.authToken
		]
		request.method = .post
		request.parameters = [
			"status": status.stringValue,
			"anime_id": showID
		]
		request.perform(withSuccess: { showDetails in
			if let success = showDetails.success {
				if success {
					successHandler(success)
				}
			}
		}, failure: { error in
			SCLAlertView().showError("Can't add to your library 😔", subTitle: error.message)
			print("Received add library error: \(error.message ?? "No message available")")
		})
	}

	/**
		Remove a show with the given show id from the current user's library.

		- Parameter userID: The id of the user from whose library a show should be deleted.
		- Parameter showID: The id of the show to be deleted.
		- Parameter successHandler: A closure returning a boolean indicating whether removing show from library is successful.
		- Parameter isSuccess: A boolean value indicating whether removing show from library is successful.
	*/
	func removeFromLibrary(forUserID userID: Int, showID: Int, withSuccess successHandler: @escaping (_ isSuccess: Bool) -> Void) {
		let request: APIRequest<ShowDetails, JSONError> = tron.swiftyJSON.request("users/\(userID)/library/delete")
		request.headers = [
			"Content-Type": "application/x-www-form-urlencoded",
//			"kuro-auth": User.authToken
		]
		request.method = .post
		request.parameters = [
			"anime_id": showID
		]
		request.perform(withSuccess: { showDetails in
			if let success = showDetails.success {
				if success {
					successHandler(success)
				}
			}
		}, failure: { error in
			SCLAlertView().showError("Can't remove from your library 😔", subTitle: error.message)
			print("Received remove library error: \(error.message ?? "No message available")")
		})
	}

	/**
		Import a MAL export file into the user's library.

		- Parameter userID: The id of the user in whose library the MAL library will be imported.
		- Parameter filePath: The path to the file to be imported.
		- Parameter behavior: The preferred behavior of importing the file.
		- Parameter successHandler: A closure returning a boolean indicating whether removing show from library is successful.
		- Parameter isSuccess: A boolean value indicating whether removing show from library is successful.
	*/
	func importMALLibrary(forUserID userID: Int, filePath: URL, behavior: MALImport.Behavior, withSuccess successHandler: @escaping (_ isSuccess: Bool) -> Void) {
		let request: UploadAPIRequest<MALImport, JSONError> = tron.swiftyJSON.uploadMultipart("users/\(userID)/library/mal-import") { formData in
			formData.append(filePath, withName: "file", fileName: "MALAnimeImport.xml", mimeType: "text/xml")
		}
		request.headers = [
			"accept": "application/json",
			"Content-Type": "multipart/form-data",
//			"kuro-auth": User.authToken
		]
		request.method = .post
		request.parameters = [
			"behavior": behavior.stringValue
		]
		request.perform(withSuccess: { response in
			if let success = response.success {
				if success {
					SCLAlertView().showInfo("Processing request", subTitle: response.message)
				}
			}
		}, failure: { error in
			SCLAlertView().showError("Can't import MAL library 😔", subTitle: error.message)
			print("Received import MAL library error: \(error.message ?? "No message available")")
		})
	}

	/**
		Fetch the favorite shows list for the given user.

		- Parameter userID: The id of the user whose favorite list will be fetched.
		- Parameter successHandler: A closure returning a ShowDetailsElement array.
		- Parameter favorites: The returned ShowDetailsElement array.
	*/
	func getFavourites(forUserID userID: Int, withSuccess successHandler: @escaping (_ favorites: [ShowDetailsElement]?) -> Void) {
		let request: APIRequest<ShowDetails, JSONError> = tron.swiftyJSON.request("users/\(userID)/favorite-anime")
		request.headers = [
			"Content-Type": "application/x-www-form-urlencoded",
//			"kuro-auth": User.authToken
		]
		request.method = .get
		request.perform(withSuccess: { showDetails in
			if let success = showDetails.success {
				if success {
					successHandler(showDetails.showDetailsElements)
				}
			}
		}, failure: { error in
			SCLAlertView().showError("Can't get favorites list 😔", subTitle: error.message)
			print("Received get favorites error: \(error.message ?? "No message available")")
		})
	}

	/**
		Update the `isFavorite` value of a show in the current user's library.

		- Parameter userID: The id of the user whose favourite list should be updated.
		- Parameter showID: The id of the show whose favorite status should be updated.
		- Parameter isFavorite: The fvalue by which the show's favorite status will be updated.
		- Parameter successHandler: A closure returning a ShowDetailsElement object.
		- Parameter isFavorite: The returned integer value indicating whether the show is favorited. (0 = false, 1 = true)
	*/
	func updateFavoriteStatus(forUserID userID: Int, forShow showID: Int, isFavorite: Int, withSuccess successHandler: @escaping (_ isFavorite: Int?) -> Void) {
		let request: APIRequest<FavoriteShow, JSONError> = tron.swiftyJSON.request("users/\(userID)/favorite-anime")
		request.headers = [
			"Content-Type": "application/x-www-form-urlencoded",
//			"kuro-auth": User.authToken
		]
		request.method = .post
		request.parameters = [
			"anime_id": showID,
			"is_favorite": isFavorite
		]
		request.perform(withSuccess: { favoriteShow in
			if let success = favoriteShow.success {
				if success {
					successHandler(favoriteShow.isFavorite)
				}
			}
		}, failure: { error in
			SCLAlertView().showError("Can't update favorite status 😔", subTitle: error.message)
			print("Received update favorite status error: \(error.message ?? "No message available")")
		})
	}

	/**
		Fetch the profile details of the given user id.

		- Parameter userID: The id of the user whose profile details should be fetched.
		- Parameter successHandler: A closure returning a User object.
		- Parameter user: The returned User object.
	*/
	func getProfile(forUserID userID: Int, withSuccess successHandler: @escaping (_ user: User?) -> Void) {
		let request: APIRequest<User, JSONError> = tron.swiftyJSON.request("users/\(userID)/profile")
		request.headers = [
			"Content-Type": "application/x-www-form-urlencoded",
//			"kuro-auth": User.authToken
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
			print("Received user profile error: \(error.message ?? "No message available")")
		})
	}

	/**
		Fetch the list of notifications for the current user.

		- Parameter userID: The id of the user whose notifications should be fetched.
		- Parameter successHandler: A closure returning a UserNotificationsElement array.
		- Parameter userNotifications: The returned UserNotificationsElement array.
	*/
	func getNotifications(forUserID userID: Int, withSuccess successHandler: @escaping (_ userNotifications: [UserNotificationsElement]?) -> Void) {
		let request: APIRequest<UserNotification, JSONError> = tron.swiftyJSON.request("users/\(userID)/notifications")
		request.headers = [
			"Content-Type": "application/x-www-form-urlencoded",
//			"kuro-auth": User.authToken
		]
		request.method = .get
		request.perform(withSuccess: { userNotifications in
			if let success = userNotifications.success {
				if success {
					successHandler(userNotifications.notifications)
				}
			}
		}, failure: { error in
			SCLAlertView().showError("Can't get notifications 😔", subTitle: error.message)
			print("Received get notifications error: \(error.message ?? "No message available")")
		})
	}

	/**
		Fetch a list of users matching the search query.

		- Parameter username: The search query by which the search list should be fetched.
		- Parameter successHandler: A closure returning a SearchElement array.
		- Parameter search: The returned SearchElement array.
	*/
	func search(forUsername username: String, withSuccess successHandler: @escaping (_ search: [UserProfile]?) -> Void) {
		let request: APIRequest<Search, JSONError> = tron.swiftyJSON.request("users/search")
		request.headers = [
			"Content-Type": "application/x-www-form-urlencoded",
//			"kuro-auth": User.authToken
		]
		request.method = .get
		request.parameters = [
			"query": username
		]
		request.perform(withSuccess: { search in
			if let success = search.success {
				if success {
					successHandler(search.userResults)
				}
			}
		}, failure: { error in
//			SCLAlertView().showError("Can't get search results 😔", subTitle: error.message)
			print("Received user search error: \(error.message ?? "No message available")")
		})
	}

	/**
		Follow or unfollow a user with the given user id.

		- Parameter userID: The id of the user to follow/unfollow.
		- Parameter follow: The integer indicating whether to follow or unfollow.
		- Parameter successHandler: A closure returning a boolean indicating whether follow/unfollow is successful.
		- Parameter isSuccess: A boolean value indicating whether follow/unfollow is successful.
	*/
	func follow(userID: Int, _ follow: Int, withSuccess successHandler: @escaping (Bool) -> Void) {
		let request: APIRequest<UserFollow, JSONError> = tron.swiftyJSON.request("users/\(userID)/follow")
		request.headers = [
			"Content-Type": "application/x-www-form-urlencoded",
//			"kuro-auth": User.authToken
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
			print("Received follow user error: \(error.message ?? "No message available")")
		})
	}

	/**
		Fetch the followers or following list for the current user.

		- Parameter userID: The id of the user whose follower or following list should be fetched.
		- Parameter list: The string indicating whather to fetch the followers or following list.
		- Parameter page: The number of the page to fetch.
		- Parameter successHandler: A closure returning a UserNotificationsElement array.
		- Parameter userFollow: The returned UserFollow object.
	*/
	func getFollow(forUserID userID: Int, list: String, page: Int, withSuccess successHandler: @escaping (_ userFollow: UserFollow?) -> Void) {
		let request: APIRequest<UserFollow, JSONError> = tron.swiftyJSON.request("users/\(userID)/\(list.lowercased())")
		request.headers = [
			"Content-Type": "application/x-www-form-urlencoded",
//			"kuro-auth": User.authToken
		]
		request.method = .get
		request.parameters = [
			"page": page
		]
		request.perform(withSuccess: { userFollow in
			if let success = userFollow.success {
				if success {
					successHandler(userFollow)
				}
			}
		}, failure: { error in
			SCLAlertView().showError("Can't get \(list) list 😔", subTitle: error.message)
			print("Received get \(list) error: \(error.message ?? "No message available")")
		})
	}
}
