//
//  KurozoraKit+User.swift
//  Kurozora
//
//  Created by Khoren Katklian on 29/09/2019.
//  Copyright © 2019 Kurozora. All rights reserved.
//

import TRON
import SCLAlertView

extension KurozoraKit {
	/**
		Register a new account with the given details.

		- Parameter username: The new user's username.
		- Parameter password: The new user's password.
		- Parameter emailAddress: The new user's email address.
		- Parameter profileImage: The new user's profile image.
		- Parameter completionHandler: A closure returning a value that represents either a success or a failure, including an associated value in each case.
		- Parameter result: A value that represents either a success or a failure, including an associated value in each case.
	*/
	public func register(withUsername username: String, emailAddress: String, password: String, profileImage: UIImage?, completion completionHandler: @escaping (_ result: Result<KKSuccess, KKError>) -> Void) {
		let users = self.kurozoraKitEndpoints.users
		let request: UploadAPIRequest<KKSuccess, KKError> = tron.swiftyJSON.uploadMultipart(users) { (formData) in
			if let profileImage = profileImage?.jpegData(compressionQuality: 0.1) {
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
		request.perform(withSuccess: { success in
			completionHandler(.success(success))
		}, failure: { error in
			if self.services.showAlerts {
				SCLAlertView().showError("Can't register account 😔", subTitle: error.message)
			}
			print("Received register account error: \(error.message ?? "No message available")")
			completionHandler(.failure(error))
		})
	}

	/**
		Register a new account and sign in using the details from Sign in with Apple.

		After the new account has been created successfully the user is signed in immediately. A notification with the `KUserIsSignedInDidChange` name is posted.
		This notification can be observed to perform UI changes regarding the user's sign in status. For example you can remove buttons the user should not have access to if not signed in.

		- Parameter userID: The user's id returned by Sign in with Apple.
		- Parameter emailAddress: The user's email returned by Sign in with Apple.
		- Parameter completionHandler: A closure returning a value that represents either a success or a failure, including an associated value in each case.
		- Parameter result: A value that represents either a success or a failure, including an associated value in each case.
	*/
	public func register(withAppleUserID userID: String, emailAddress: String, completion completionHandler: @escaping (_ result: Result<KKSuccess, KKError>) -> Void) {
		let usersRegisterSIWA = self.kurozoraKitEndpoints.usersRegisterSIWA
		let request: APIRequest<KKSuccess, KKError> = tron.swiftyJSON.request(usersRegisterSIWA)
		request.headers = headers
		request.method = .post
		request.parameters = [
			"email": emailAddress,
			"siwa_id": userID
		]
		request.perform(withSuccess: { success in
//			try? self.services._keychainDefaults.set("\(userID)", key: "siwa_id")
//			self.services.processUserData(fromSession: userSession)
			completionHandler(.success(success))
			NotificationCenter.default.post(name: .KUserIsSignedInDidChange, object: nil)
		}, failure: { error in
			UIView().endEditing(true)
			if self.services.showAlerts {
				SCLAlertView().showError("Can't register account 😔", subTitle: error.message)
			}
			print("Received register account with SIWA error: \(error.message ?? "No message available")")
			completionHandler(.failure(error))
		})
	}

	/**
		Sign in users to their account using Sign in with Apple.

		After the user is signed in successfully, a notification with the `KUserIsSignedInDidChange` name is posted.
		This notification can be observed to perform UI changes regarding the user's sign in status. For example you can remove buttons the user should not have access to if not signed in.

		- Parameter idToken: A JSON Web Token (JWT) that securely communicates information about the user to the server.
		- Parameter authorizationCode: A short-lived token used by the app for proof of authorization when interacting with the server.
		- Parameter completionHandler: A closure returning a value that represents either a success or a failure, including an associated value in each case.
		- Parameter result: A value that represents either a success or a failure, including an associated value in each case.
	*/
	public func signInWithApple(usingIDToken idToken: String, authorizationCode: String, completion completionHandler: @escaping (_ result: Result<KKSuccess, KKError>) -> Void) {
		let usersRegisterSIWA = self.kurozoraKitEndpoints.usersRegisterSIWA
		let request: APIRequest<KKSuccess, KKError> = tron.swiftyJSON.request(usersRegisterSIWA)
		request.headers = headers
		request.method = .post
		request.parameters = [
			"identity_token": idToken,
			"auth_code": authorizationCode
		]
		request.perform(withSuccess: { success in
//			try? KKServices.shared.KeychainDefaults.set(idToken, key: "SIWA_id_token")
//			KKServices.shared.processUserData(fromSession: userSession)
			completionHandler(.success(success))
			NotificationCenter.default.post(name: .KUserIsSignedInDidChange, object: nil)
		}, failure: { error in
			if self.services.showAlerts {
				SCLAlertView().showError("Can't sign in with Apple 😔", subTitle: error.message)
			}
			print("Received sign in with Apple error: \(error.message ?? "No message available")")
			completionHandler(.failure(error))
		})
	}

	/**
		Request a password reset link for the given email address.

		- Parameter emailAddress: The email address to which the reset link should be sent.
		- Parameter completionHandler: A closure returning a value that represents either a success or a failure, including an associated value in each case.
		- Parameter result: A value that represents either a success or a failure, including an associated value in each case.
	*/
	public func resetPassword(withEmailAddress emailAddress: String, completion completionHandler: @escaping (_ result: Result<KKSuccess, KKError>) -> Void) {
		let usersResetPassword = self.kurozoraKitEndpoints.usersResetPassword
		let request: APIRequest<KKSuccess, KKError> = tron.swiftyJSON.request(usersResetPassword)
		request.headers = headers
		request.method = .post
		request.parameters = [
			"email": emailAddress
		]
		request.perform(withSuccess: { success in
			completionHandler(.success(success))
		}, failure: { error in
			UIView().endEditing(true)
			if self.services.showAlerts {
				SCLAlertView().showError("Can't send reset link 😔", subTitle: error.message)
			}
			print("Received reset password error: \(error.message ?? "No message available")")
			completionHandler(.failure(error))
		})
	}

	/**
		Update the current user's profile information.

		- Parameter userID: The id of the user whose information should be udpated.
		- Parameter bio: The new biography to set.
		- Parameter profileImage: The new user's profile image.
		- Parameter bannerImage: The new user's profile image.
		- Parameter completionHandler: A closure returning a value that represents either a success or a failure, including an associated value in each case.
		- Parameter result: A value that represents either a success or a failure, including an associated value in each case.
	*/
	public func updateInformation(forUserID userID: Int, bio: String, profileImage: UIImage, bannerImage: UIImage, completion completionHandler: @escaping (_ result: Result<User, KKError>) -> Void) {
		let usersProfile = self.kurozoraKitEndpoints.usersProfile.replacingOccurrences(of: "?", with: "\(userID)")
		let request: UploadAPIRequest<User, KKError> = tron.swiftyJSON.uploadMultipart(usersProfile) { (formData) in
			if let profileImage = profileImage.jpegData(compressionQuality: 0.1) {
				formData.append(profileImage, withName: "profileImage", fileName: "ProfileImage.png", mimeType: "image/png")
			}
			if let bannerImage = bannerImage.jpegData(compressionQuality: 0.1) {
				formData.append(bannerImage, withName: "bannerImage", fileName: "BannerImage.png", mimeType: "image/png")
			}
		}

		request.headers = [
			"Content-Type": "multipart/form-data"
		]
		if User.isSignedIn {
			request.headers["kuro-auth"] = self.authenticationKey
		}

		request.method = .post
		request.parameters = [
			"biography": bio
		]
		request.perform(withSuccess: { updatedUser in
			if self.services.showAlerts {
				SCLAlertView().showSuccess("Settings updated ☺️", subTitle: updatedUser.message)
			}

			if updatedUser.profile?.id == User.current?.id {
				if let userDetails = updatedUser.profile {
					User.current?.updateDetails(with: userDetails)
				}
			}

			completionHandler(.success(updatedUser))
		}, failure: { error in
			UIView().endEditing(true)
			if self.services.showAlerts {
				SCLAlertView().showError("Can't update information 😔", subTitle: error.message)
			}
			print("Received update information error: \(error.message ?? "No message available")")
			completionHandler(.failure(error))
		})
	}

	/**
		Fetch the list of sessions for the current user.

		- Parameter userID: The id of the user whose session should be fetched.
		- Parameter completionHandler: A closure returning a value that represents either a success or a failure, including an associated value in each case.
		- Parameter result: A value that represents either a success or a failure, including an associated value in each case.
	*/
	public func getSessions(forUserID userID: Int, completion completionHandler: @escaping (_ result: Result<UserSessions, KKError>) -> Void) {
		let usersSessions = self.kurozoraKitEndpoints.usersSessions.replacingOccurrences(of: "?", with: "\(userID)")
		let request: APIRequest<UserSessions, KKError> = tron.swiftyJSON.request(usersSessions)

		request.headers = headers
		if User.isSignedIn {
			request.headers["kuro-auth"] = self.authenticationKey
		}

		request.method = .get
		request.perform(withSuccess: { session in
			completionHandler(.success(session))
		}, failure: { error in
			if self.services.showAlerts {
				SCLAlertView().showError("Can't get session 😔", subTitle: error.message)
			}
			print("Received get session error: \(error.message ?? "No message available")")
			completionHandler(.failure(error))
		})
	}

	/**
		Fetch the list of shows with the given show status in the current user's library.

		- Parameter userID: The id of the user whose library should be fetched.
		- Parameter libraryStatus: The library status to retrieve the library items for.
		- Parameter sortType: The sort value by which the retrived items should be sorted.
		- Parameter sortOption: The sort option value by which the retrived items should be sorted.
		- Parameter completionHandler: A closure returning a value that represents either a success or a failure, including an associated value in each case.
		- Parameter result: A value that represents either a success or a failure, including an associated value in each case.
	*/
	public func getLibrary(forUserID userID: Int, withLibraryStatus libraryStatus: KKLibrary.Status, withSortType sortType: KKLibrary.SortType, withSortOption sortOption: KKLibrary.SortType.Options, completion completionHandler: @escaping (_ result: Result<[ShowDetailsElement], KKError>) -> Void) {
		let usersLibrary = self.kurozoraKitEndpoints.usersLibrary.replacingOccurrences(of: "?", with: "\(userID)")
		let request: APIRequest<ShowDetails, KKError> = tron.swiftyJSON.request(usersLibrary)

		request.headers = headers
		if User.isSignedIn {
			request.headers["kuro-auth"] = self.authenticationKey
		}

		request.method = .get
		request.parameters = [
			"status": libraryStatus.sectionValue
		]
		if sortType != .none {
			request.parameters["sort"] = "\(sortType.parameterValue)\(sortOption.parameterValue)"
		}
		request.perform(withSuccess: { showDetails in
			completionHandler(.success(showDetails.showDetailsElements ?? []))
		}, failure: { error in
			if self.services.showAlerts {
				SCLAlertView().showError("Can't get library 😔", subTitle: error.message)
			}
			print("Received get library error: \(error.message ?? "No message available")")
			completionHandler(.failure(error))
		})
	}

	/**
		Add a show with the given show id to the current user's library.

		- Parameter userID: The id of the user in whose library the show will be added.
		- Parameter libraryStatus: The watch status to assign to the Anime.
		- Parameter showID: The id of the show to add.
		- Parameter completionHandler: A closure returning a value that represents either a success or a failure, including an associated value in each case.
		- Parameter result: A value that represents either a success or a failure, including an associated value in each case.
	*/
	public func addToLibrary(forUserID userID: Int, withLibraryStatus libraryStatus: KKLibrary.Status, showID: Int, completion completionHandler: @escaping (_ result: Result<KKSuccess, KKError>) -> Void) {
		let usersLibrary = self.kurozoraKitEndpoints.usersLibrary.replacingOccurrences(of: "?", with: "\(userID)")
		let request: APIRequest<KKSuccess, KKError> = tron.swiftyJSON.request(usersLibrary)

		request.headers = headers
		if User.isSignedIn {
			request.headers["kuro-auth"] = self.authenticationKey
		}

		request.method = .post
		request.parameters = [
			"status": libraryStatus.sectionValue,
			"anime_id": showID
		]
		request.perform(withSuccess: { success in
			completionHandler(.success(success))
		}, failure: { error in
			if self.services.showAlerts {
				SCLAlertView().showError("Can't add to your library 😔", subTitle: error.message)
			}
			print("Received add library error: \(error.message ?? "No message available")")
			completionHandler(.failure(error))
		})
	}

	/**
		Remove a show with the given show id from the current user's library.

		- Parameter userID: The id of the user from whose library a show should be deleted.
		- Parameter showID: The id of the show to be deleted.
		- Parameter completionHandler: A closure returning a value that represents either a success or a failure, including an associated value in each case.
		- Parameter result: A value that represents either a success or a failure, including an associated value in each case.
	*/
	public func removeFromLibrary(forUserID userID: Int, showID: Int, completion completionHandler: @escaping (_ result: Result<KKSuccess, KKError>) -> Void) {
		let usersLibraryDelete = self.kurozoraKitEndpoints.usersLibraryDelete.replacingOccurrences(of: "?", with: "\(userID)")
		let request: APIRequest<KKSuccess, KKError> = tron.swiftyJSON.request(usersLibraryDelete)

		request.headers = headers
		if User.isSignedIn {
			request.headers["kuro-auth"] = self.authenticationKey
		}

		request.method = .post
		request.parameters = [
			"anime_id": showID
		]
		request.perform(withSuccess: { success in
			completionHandler(.success(success))
		}, failure: { error in
			if self.services.showAlerts {
				SCLAlertView().showError("Can't remove from your library 😔", subTitle: error.message)
			}
			print("Received remove library error: \(error.message ?? "No message available")")
			completionHandler(.failure(error))
		})
	}

	/**
		Import a MAL export file into the user's library.

		- Parameter userID: The id of the user in whose library the MAL library will be imported.
		- Parameter filePath: The path to the file to be imported.
		- Parameter behavior: The preferred behavior of importing the file.
		- Parameter completionHandler: A closure returning a value that represents either a success or a failure, including an associated value in each case.
		- Parameter result: A value that represents either a success or a failure, including an associated value in each case.
	*/
	public func importMALLibrary(forUserID userID: Int, filePath: URL, importBehavior behavior: MALImport.Behavior, completion completionHandler: @escaping (_ result: Result<KKSuccess, KKError>) -> Void) {
		let usersLibraryMALImport = self.kurozoraKitEndpoints.usersLibraryMALImport.replacingOccurrences(of: "?", with: "\(userID)")
		let request: UploadAPIRequest<KKSuccess, KKError> = tron.swiftyJSON.uploadMultipart(usersLibraryMALImport) { formData in
			formData.append(filePath, withName: "file", fileName: "MALAnimeImport.xml", mimeType: "text/xml")
		}

		request.headers = [
			"accept": "application/json",
			"Content-Type": "multipart/form-data"
		]
		if User.isSignedIn {
			request.headers["kuro-auth"] = self.authenticationKey
		}

		request.method = .post
		request.parameters = [
			"behavior": behavior.stringValue
		]
		request.perform(withSuccess: { success in
			if self.services.showAlerts {
				SCLAlertView().showInfo("Processing request", subTitle: success.message)
			}
			completionHandler(.success(success))
		}, failure: { error in
			if self.services.showAlerts {
				SCLAlertView().showError("Can't import MAL library 😔", subTitle: error.message)
			}
			print("Received import MAL library error: \(error.message ?? "No message available")")
			completionHandler(.failure(error))
		})
	}

	/**
		Fetch a list of shows matching the search query in the user's library.

		- Parameter userID: The id of the user in whose library the shows will searched.
		- Parameter show: The search query by which the search list should be fetched.
		- Parameter completionHandler: A closure returning a value that represents either a success or a failure, including an associated value in each case.
		- Parameter result: A value that represents either a success or a failure, including an associated value in each case.
	*/
	public func search(inUserLibrary userID: Int,forShow show: String, completion completionHandler: @escaping (_ result: Result<[ShowDetailsElement], KKError>) -> Void) {
		let animeSearchInLibrary = self.kurozoraKitEndpoints.animeSearchInLibrary.replacingOccurrences(of: "?", with: "\(userID)")
		let request: APIRequest<Search, KKError> = tron.swiftyJSON.request(animeSearchInLibrary)

		request.headers = headers
		if User.isSignedIn {
			request.headers["kuro-auth"] = self.authenticationKey
		}

		request.method = .get
		request.parameters = [
			"query": show
		]
		request.perform(withSuccess: { search in
			completionHandler(.success(search.showResults ?? []))
		}, failure: { error in
//			if self.services.showAlerts {
//				SCLAlertView().showError("Can't get search results 😔", subTitle: error.message)
//			}
			print("Received library search error: \(error.message ?? "No message available")")
			completionHandler(.failure(error))
		})
	}

	/**
		Fetch the favorite shows list for the given user.

		- Parameter userID: The id of the user whose favorite list will be fetched.
		- Parameter completionHandler: A closure returning a value that represents either a success or a failure, including an associated value in each case.
		- Parameter result: A value that represents either a success or a failure, including an associated value in each case.
	*/
	public func getFavourites(forUserID userID: Int, completion completionHandler: @escaping (_ result: Result<[ShowDetailsElement], KKError>) -> Void) {
		let usersFavoriteAnime = self.kurozoraKitEndpoints.usersFavoriteAnime.replacingOccurrences(of: "?", with: "\(userID)")
		let request: APIRequest<ShowDetails, KKError> = tron.swiftyJSON.request(usersFavoriteAnime)

		request.headers = headers
		if User.isSignedIn {
			request.headers["kuro-auth"] = self.authenticationKey
		}

		request.method = .get
		request.perform(withSuccess: { showDetails in
			completionHandler(.success(showDetails.showDetailsElements ?? []))
		}, failure: { error in
			if self.services.showAlerts {
				SCLAlertView().showError("Can't get favorites list 😔", subTitle: error.message)
			}
			print("Received get favorites error: \(error.message ?? "No message available")")
			completionHandler(.failure(error))
		})
	}

	/**
		Update the `isFavorite` value of a show in the current user's library.

		- Parameter userID: The id of the user whose favourite list should be updated.
		- Parameter showID: The id of the show whose favorite status should be updated.
		- Parameter favoriteStatus: The favorite status value by which the show's favorite status will be updated.
		- Parameter completionHandler: A closure returning a value that represents either a success or a failure, including an associated value in each case.
		- Parameter result: A value that represents either a success or a failure, including an associated value in each case.
	*/
	public func updateFavoriteStatus(forUserID userID: Int, forShow showID: Int, withFavoriteStatus favoriteStatus: FavoriteStatus, completion completionHandler: @escaping (_ result: Result<FavoriteStatus, KKError>) -> Void) {
		let usersFavoriteAnime = self.kurozoraKitEndpoints.usersFavoriteAnime.replacingOccurrences(of: "?", with: "\(userID)")
		let request: APIRequest<FavoriteShow, KKError> = tron.swiftyJSON.request(usersFavoriteAnime)

		request.headers = headers
		if User.isSignedIn {
			request.headers["kuro-auth"] = self.authenticationKey
		}

		request.method = .post
		request.parameters = [
			"anime_id": showID,
			"is_favorite": favoriteStatus.rawValue
		]
		request.perform(withSuccess: { favoriteShow in
			completionHandler(.success(favoriteShow.favoriteStatus ?? .unfavorite))
		}, failure: { error in
			if self.services.showAlerts {
				SCLAlertView().showError("Can't update favorite status 😔", subTitle: error.message)
			}
			print("Received update favorite status error: \(error.message ?? "No message available")")
			completionHandler(.failure(error))
		})
	}

	/**
		Fetches and restores the details for the current user.

		- Parameter authenticationKey: The authentication key of the user whose details should be fetched.
		- Parameter completionHandler: A closure returning a value that represents either a success or a failure, including an associated value in each case.
		- Parameter result: A value that represents either a success or a failure, including an associated value in each case.
	*/
	public func restoreDetails(forUserWith authenticationKey: String, completion completionHandler: @escaping (_ result: Result<String, KKError>) -> Void) {
		let usersMe = self.kurozoraKitEndpoints.usersMe
		let request: APIRequest<User, KKError> = tron.swiftyJSON.request(usersMe)

		request.headers = headers
		request.headers["kuro-auth"] = authenticationKey

		request.method = .get
		request.perform(withSuccess: { user in
			self.authenticationKey = user.kuroAuthToken ?? ""
			completionHandler(.success(self.authenticationKey))
			NotificationCenter.default.post(name: .KUserIsSignedInDidChange, object: nil)
		}, failure: { error in
			if self.services.showAlerts {
				SCLAlertView().showError("Can't get current user's details 😔", subTitle: error.message)
			}
			print("Received get details for current user error: \(error.message ?? "No message available")")
			completionHandler(.failure(error))
		})
	}

	/**
		Fetch the profile details of the given user id.

		- Parameter userID: The id of the user whose profile details should be fetched.
		- Parameter completionHandler: A closure returning a value that represents either a success or a failure, including an associated value in each case.
		- Parameter result: A value that represents either a success or a failure, including an associated value in each case.
	*/
	public func getProfile(forUserID userID: Int, completion completionHandler: @escaping (_ result: Result<User, KKError>) -> Void) {
		let usersProfile = self.kurozoraKitEndpoints.usersProfile.replacingOccurrences(of: "?", with: "\(userID)")
		let request: APIRequest<User, KKError> = tron.swiftyJSON.request(usersProfile)

		request.headers = headers
		if User.isSignedIn {
			request.headers["kuro-auth"] = self.authenticationKey
		}

		request.method = .get
		request.perform(withSuccess: { userProfile in
			completionHandler(.success(userProfile))
		}, failure: { error in
			if self.services.showAlerts {
				SCLAlertView().showError("Can't get user details 😔", subTitle: error.message)
			}
			print("Received user profile error: \(error.message ?? "No message available")")
			completionHandler(.failure(error))
		})
	}

	/**
		Fetch the list of notifications for the current user.

		- Parameter userID: The id of the user whose notifications should be fetched.
		- Parameter completionHandler: A closure returning a value that represents either a success or a failure, including an associated value in each case.
		- Parameter result: A value that represents either a success or a failure, including an associated value in each case.
	*/
	public func getNotifications(forUserID userID: Int, completion completionHandler: @escaping (_ result: Result<[UserNotificationElement], KKError>) -> Void) {
		let usersNotifications = self.kurozoraKitEndpoints.usersNotifications.replacingOccurrences(of: "?", with: "\(userID)")
		let request: APIRequest<UserNotification, KKError> = tron.swiftyJSON.request(usersNotifications)

		request.headers = headers
		if User.isSignedIn {
			request.headers["kuro-auth"] = self.authenticationKey
		}

		request.method = .get
		request.perform(withSuccess: { userNotifications in
			completionHandler(.success(userNotifications.notifications))
		}, failure: { error in
			if self.services.showAlerts {
				SCLAlertView().showError("Can't get notifications 😔", subTitle: error.message)
			}
			print("Received get notifications error: \(error.message ?? "No message available")")
			completionHandler(.failure(error))
		})
	}

	/**
		Fetch a list of users matching the search query.

		- Parameter username: The search query by which the search list should be fetched.
		- Parameter successHandler: A closure returning a SearchElement array.
		- Parameter search: The returned SearchElement array.
	*/
	public func search(forUsername username: String, completion completionHandler: @escaping (_ result: Result<[UserProfile], KKError>) -> Void) {
		let usersSearch = self.kurozoraKitEndpoints.usersSearch
		let request: APIRequest<Search, KKError> = tron.swiftyJSON.request(usersSearch)

		request.headers = headers
		if User.isSignedIn {
			request.headers["kuro-auth"] = self.authenticationKey
		}

		request.method = .get
		request.parameters = [
			"query": username
		]
		request.perform(withSuccess: { search in
			completionHandler(.success(search.userResults ?? []))
		}, failure: { error in
//			if self.services.showAlerts {
//				SCLAlertView().showError("Can't get search results 😔", subTitle: error.message)
//			}
			print("Received user search error: \(error.message ?? "No message available")")
			completionHandler(.failure(error))
		})
	}

	/**
		Follow or unfollow a user with the given user id.

		- Parameter userID: The id of the user to follow/unfollow.
		- Parameter followStatus: The follow status value indicating whether to follow or unfollow a user.
		- Parameter completionHandler: A closure returning a value that represents either a success or a failure, including an associated value in each case.
		- Parameter result: A value that represents either a success or a failure, including an associated value in each case.
	*/
	public func updateFollowStatus(_ userID: Int, withFollowStatus follow: FollowStatus, completion completionHandler: @escaping (_ result: Result<KKSuccess, KKError>) -> Void) {
		let usersFollow = self.kurozoraKitEndpoints.usersFolllow.replacingOccurrences(of: "?", with: "\(userID)")
		let request: APIRequest<KKSuccess, KKError> = tron.swiftyJSON.request(usersFollow)

		request.headers = headers
		if User.isSignedIn {
			request.headers["kuro-auth"] = self.authenticationKey
		}

		request.method = .post
		request.parameters = [
			"follow": follow.rawValue
		]
		request.perform(withSuccess: { success in
			completionHandler(.success(success))
		}, failure: { error in
			if self.services.showAlerts {
				SCLAlertView().showError("Can't follow user 😔", subTitle: error.message)
			}
			print("Received follow user error: \(error.message ?? "No message available")")
			completionHandler(.failure(error))
		})
	}

	/**
		Fetch the followers or following list for the current user.

		- Parameter userID: The id of the user whose follower or following list should be fetched.
		- Parameter followList: The follow list value indicating whather to fetch the followers or following list.
		- Parameter next: The URL string of the next page in the paginated response. Use `nil` to get first page.
		- Parameter completionHandler: A closure returning a value that represents either a success or a failure, including an associated value in each case.
		- Parameter result: A value that represents either a success or a failure, including an associated value in each case.
	*/
	public func getFollowList(_ userID: Int, _ followList: FollowList, next: String? = nil, completion completionHandler: @escaping (_ result: Result<UserFollow, KKError>) -> Void) {
		let usersFollowerOrFollowing = next ?? (followList == .following ? self.kurozoraKitEndpoints.usersFollowing : self.kurozoraKitEndpoints.usersFollowers).replacingOccurrences(of: "?", with: "\(userID)")
		let request: APIRequest<UserFollow, KKError> = tron.swiftyJSON.request(usersFollowerOrFollowing).buildURL(.relativeToBaseURL)

		request.headers = headers
		if User.isSignedIn {
			request.headers["kuro-auth"] = self.authenticationKey
		}

		request.method = .get
		request.perform(withSuccess: { userFollow in
			completionHandler(.success(userFollow))
		}, failure: { error in
			if self.services.showAlerts {
				SCLAlertView().showError("Can't get \(followList.rawValue) list 😔", subTitle: error.message)
			}
			print("Received get \(followList.rawValue) error: \(error.message ?? "No message available")")
			completionHandler(.failure(error))
		})
	}
}
