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
		- Parameter email: The new user's email.
		- Parameter profileImage: The new user's profile image.
		- Parameter successHandler: A closure returning a boolean indicating whether registration is successful.
		- Parameter isSuccess: A boolean value indicating whether registration is successful.
	*/
	func register(withUsername username: String?, email: String?, password: String?, profileImage image: UIImage?, withSuccess successHandler: @escaping (_ isSuccess: Bool) -> Void) {
		guard let username = username else { return }
		guard let email = email else { return }
		guard let password = password else { return }

		let request: UploadAPIRequest<User, JSONError> = tron.swiftyJSON.uploadMultipart("users") { (formData) in
			if let profileImage = image?.jpegData(compressionQuality: 0.1) {
				formData.append(profileImage, withName: "profileImage", fileName: "ProfileImage.png", mimeType: "image/png")
			}
		}
		request.headers = [
			"Content-Type": "multipart/form-data"
		]
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
			print("Received register account error: \(error.message ?? "No message available")")
		})
	}

	/**
		Register a new account using the details from Sign In With Apple.

		- Parameter userID: The user's id returned by SIWA.
		- Parameter email: The user's email returned by SIWA.
		- Parameter successHandler: A closure returning a boolean indicating whether registration is successful.
		- Parameter isSuccess: A boolean value indicating whether registration is successful.
	*/
	func register(withAppleUserID userID: String?, email: String?, withSuccess successHandler: @escaping (_ isSuccess: Bool) -> Void) {
		guard let userID = userID else { return }
		guard let email = email else { return }

		print("Register User ID: \(userID)")
		print("Register Email: \(email)")

		let request: APIRequest<UserSessions, JSONError> = tron.swiftyJSON.request("users/register-siwa")
		request.headers = headers
		request.method = .post
		request.parameters = [
			"email": email,
			"siwa_id": userID
		]
		request.perform(withSuccess: { userSession in
			if let success = userSession.success {
				if success {
					try? Kurozora.shared.KDefaults.set("\(userID)", key: "SIWA_user")
					WorkflowController.shared.processUserData(fromSession: userSession)
					successHandler(success)
				}
			}
		}, failure: { error in
			UIView().endEditing(true)
			SCLAlertView().showError("Can't register account 😔", subTitle: error.message)
			print("Received register account with SIWA error: \(error.message ?? "No message available")")
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
			print("Received reset password error: \(error.message ?? "No message available")")
		})
	}

	/**
		Update the current user's profile information.

		- Parameter bio: The new biography to set.
		- Parameter profileImage: The new user's profile image.
		- Parameter bannerImage: The new user's profile image.
		- Parameter successHandler: A closure returning a User object with the updated information.
		- Parameter isSuccess: A User object containing the updated information.
	*/
	func updateInformation(for bio: String?, username: String?, profileImage: UIImage?, bannerImage: UIImage?, withSuccess successHandler: @escaping (_ isSuccess: User?) -> Void) {
		let request: UploadAPIRequest<User, JSONError> = tron.swiftyJSON.uploadMultipart("users/\(User.currentID)/profile") { (formData) in
			if let profileImage = profileImage?.jpegData(compressionQuality: 0.1) {
				formData.append(profileImage, withName: "profileImage", fileName: "ProfileImage.png", mimeType: "image/png")
			}
			if let bannerImage = bannerImage?.jpegData(compressionQuality: 0.1) {
				formData.append(bannerImage, withName: "bannerImage", fileName: "BannerImage.png", mimeType: "image/png")
			}
		}
		request.headers = [
			"Content-Type": "multipart/form-data",
			"kuro-auth": User.authToken
		]
		request.method = .post
		request.parameters = [
			"biography": bio ?? ""
		]
		if let username = username, !username.isEmpty {
			request.parameters["username"] = username
		}

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

		- Parameter successHandler: A closure returning a UserSessions object.
		- Parameter userSessions: The returned UserSessions object.
	*/
	func getSessions(withSuccess successHandler: @escaping (_ userSessions: UserSessions?) -> Void) {
		let request: APIRequest<UserSessions, JSONError> = tron.swiftyJSON.request("users/\(User.currentID)/sessions")
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
			print("Received get session error: \(error.message ?? "No message available")")
		})
	}

	/**
		Fetch the list of shows with the given show status in the current user's library.

		- Parameter status: The status to retrieve the library items for.
		- Parameter sortType: The sort value by which the retrived items should be sorted.
		- Parameter sortOption: The sort option value by which the retrived items should be sorted.
		- Parameter successHandler: A closure returning a LibraryElement array.
		- Parameter library: The returned LibraryElement array.
	*/
	func getLibrary(forStatus status: String?, withSortType sortType: Library.SortType, withSortOption sortOption: Library.SortType.Options, withSuccess successHandler: @escaping (_ library: [ShowDetailsElement]?) -> Void) {
		guard let status = status else { return }

		let request: APIRequest<ShowDetails, JSONError> = tron.swiftyJSON.request("users/\(User.currentID)/library")
		request.headers = [
			"Content-Type": "application/x-www-form-urlencoded",
			"kuro-auth": User.authToken
		]
		request.method = .get
		request.parameters = [
			"status": status
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

		- Parameter status: The watch status to assign to the Anime.
		- Parameter showID: The id of the show to add.
		- Parameter successHandler: A closure returning a boolean indicating whether adding show to library is successful.
		- Parameter isSuccess: A boolean value indicating whether adding show to library is successful.
	*/
	func addToLibrary(withStatus status: String?, showID: Int?, withSuccess successHandler: @escaping (_ isSuccess: Bool) -> Void) {
		guard let status = status else { return }
		guard let showID = showID else { return }

		let request: APIRequest<ShowDetails, JSONError> = tron.swiftyJSON.request("users/\(User.currentID)/library")
		request.headers = [
			"Content-Type": "application/x-www-form-urlencoded",
			"kuro-auth": User.authToken
		]
		request.method = .post
		request.parameters = [
			"status": status,
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

		- Parameter showID: The id of the show to delete.
		- Parameter successHandler: A closure returning a boolean indicating whether removing show from library is successful.
		- Parameter isSuccess: A boolean value indicating whether removing show from library is successful.
	*/
	func removeFromLibrary(withID showID: Int?, withSuccess successHandler: @escaping (_ isSuccess: Bool) -> Void) {
		guard let showID = showID else { return }

		let request: APIRequest<ShowDetails, JSONError> = tron.swiftyJSON.request("users/\(User.currentID)/library/delete")
		request.headers = [
			"Content-Type": "application/x-www-form-urlencoded",
			"kuro-auth": User.authToken
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

		- Parameter filePath: The path to the file to be imported.
		- Parameter behavior: The preferred behavior of importing the file.
		- Parameter successHandler: A closure returning a boolean indicating whether removing show from library is successful.
		- Parameter isSuccess: A boolean value indicating whether removing show from library is successful.
	*/
	func importMALLibrary(from filePath: URL?, behavior: String?, withSuccess successHandler: @escaping (_ isSuccess: Bool) -> Void) {
		guard let filePath = filePath else { return }
		guard let behavior = behavior else { return }

		let request: UploadAPIRequest<MALImport, JSONError> = tron.swiftyJSON.uploadMultipart("users/\(User.currentID)/library/mal-import") { formData in
			formData.append(filePath, withName: "file", fileName: "MALAnimeImport.xml", mimeType: "text/xml")
		}
		request.headers = [
			"accept": "application/json",
			"Content-Type": "multipart/form-data",
			"kuro-auth": User.authToken
		]
		request.method = .post
		request.parameters = [
			"behavior": behavior
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
		Fetch the favorite shows list for the given user. Fetches the current user's list if no `userID` is given.

		- Parameter userID: The id of the user whose favorite list will be fetched.
		- Parameter successHandler: A closure returning a ShowDetailsElement array.
		- Parameter favorites: The returned ShowDetailsElement array.
	*/
	func getFavourites(forUser userID: Int?, withSuccess successHandler: @escaping (_ favorites: [ShowDetailsElement]?) -> Void) {
		let userID = userID ?? User.currentID

		let request: APIRequest<ShowDetails, JSONError> = tron.swiftyJSON.request("users/\(userID)/favorite-anime")
		request.headers = [
			"Content-Type": "application/x-www-form-urlencoded",
			"kuro-auth": User.authToken
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

		- Parameter show_id: The show whose favorite status will be updated.
		- Parameter isFavorite: The fvalue by which the show's favorite status will be updated.
		- Parameter successHandler: A closure returning a ShowDetailsElement object.
		- Parameter isFavorite: The returned integer value indicating whether the show is favorited. (0 = false, 1 = true)
	*/
	func updateFavoriteStatus(forShow showID: Int?, isFavorite: Int?, withSuccess successHandler: @escaping (_ isFavorite: Int?) -> Void) {
		guard let showID = showID else { return }
		guard let isFavorite = isFavorite else { return }

		let request: APIRequest<FavoriteShow, JSONError> = tron.swiftyJSON.request("users/\(User.currentID)/favorite-anime")
		request.headers = [
			"Content-Type": "application/x-www-form-urlencoded",
			"kuro-auth": User.authToken
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
			print("Received user profile error: \(error.message ?? "No message available")")
		})
	}

	/**
		Fetch the list of notifications for the current user.

		- Parameter successHandler: A closure returning a UserNotificationsElement array.
		- Parameter userNotifications: The returned UserNotificationsElement array.
	*/
	func getNotifications(withSuccess successHandler: @escaping (_ userNotifications: [UserNotificationsElement]?) -> Void) {
		let request: APIRequest<UserNotification, JSONError> = tron.swiftyJSON.request("users/\(User.currentID)/notifications")
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
			SCLAlertView().showError("Can't get notifications 😔", subTitle: error.message)
			print("Received get notifications error: \(error.message ?? "No message available")")
		})
	}

	/**
		Fetch a list of users matching the search query.

		- Parameter user: The search query by which the search list should be fetched.
		- Parameter successHandler: A closure returning a SearchElement array.
		- Parameter search: The returned SearchElement array.
	*/
	func search(forUser user: String?, withSuccess successHandler: @escaping (_ search: [UserProfile]?) -> Void) {
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
			print("Received follow user error: \(error.message ?? "No message available")")
		})
	}

	/**
		Fetch the followers or following list for the current user.

		- Parameter list: The string indicating whather to fetch the followers or following list.
		- Parameter successHandler: A closure returning a UserNotificationsElement array.
		- Parameter userFollow: The returned UserFollow object.
	*/
	func getFollow(list: String, for userID: Int?, page: Int, withSuccess successHandler: @escaping (_ userFollow: UserFollow?) -> Void) {
		guard let userID = userID else { return }

		let request: APIRequest<UserFollow, JSONError> = tron.swiftyJSON.request("users/\(userID)/\(list.lowercased())")
		request.headers = [
			"Content-Type": "application/x-www-form-urlencoded",
			"kuro-auth": User.authToken
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
