//
//  KurozoraKit+Users.swift
//  KurozoraKit
//
//  Created by Khoren Katklian on 29/09/2019.
//

import Alamofire
import TRON

extension KurozoraKit {
	/// Sign up a new account with the given details.
	///
	/// - Parameters:
	///    - username: The new user's username.
	///    - password: The new user's password.
	///    - emailAddress: The new user's email address.
	///    - profileImage: The new user's profile image.
	///    - completionHandler: A closure returning a value that represents either a success or a failure, including an associated value in each case.
	///    - result: A value that represents either a success or a failure, including an associated value in each case.
	@discardableResult
	public func signUp(withUsername username: String, emailAddress: String, password: String, profileImage: UIImage?, completion completionHandler: @escaping (_ result: Result<KKSuccess, KKAPIError>) -> Void) -> DataRequest {
		let usersSignUp = KKEndpoint.Users.signUp.endpointValue
		let request: UploadAPIRequest<KKSuccess, KKAPIError> = tron.codable.uploadMultipart(usersSignUp) { (formData) in
			if let profileImage = profileImage?.jpegData(compressionQuality: 0.1) {
				formData.append(profileImage, withName: "profileImage", fileName: "ProfileImage.png", mimeType: "image/png")
			}
		}
		request.headers = [
			.contentType("multipart/form-data")
		]
		request.method = .post
		request.parameters = [
			"username": username,
			"email": emailAddress,
			"password": password
		]
		return request.perform(withSuccess: { kKSuccess in
			completionHandler(.success(kKSuccess))
		}, failure: { [weak self] error in
			guard let self = self else { return }
			if self.services.showAlerts {
				UIApplication.topViewController?.presentAlertController(title: "Can't Sign Up 😔", message: error.message)
			}
			print("❌ Received sign up account error:", error.errorDescription ?? "Unknown error")
			print("┌ Server message:", error.message ?? "No message")
			print("├ Recovery suggestion:", error.recoverySuggestion ?? "No suggestion available")
			print("└ Failure reason:", error.failureReason ?? "No reason available")
			completionHandler(.failure(error))
		})
	}

	/// Sign in with the given `kurozoraID` and `password`.
	///
	/// This endpoint is used for signing in a user to their account. If the sign in was successful then a Kurozora authentication token is returned in the success closure.
	///
	/// - Parameters:
	///    - kurozoraID: The Kurozora id of the user to be signed in.
	///    - password: The password of the user to be signed in.
	///    - completionHandler: A closure returning a value that represents either a success or a failure, including an associated value in each case.
	///    - result: A value that represents either a success or a failure, including an associated value in each case.
	@discardableResult
	public func signIn(_ kurozoraID: String, _ password: String, completion completionHandler: @escaping (_ result: Result<String, KKAPIError>) -> Void) -> DataRequest {
		let usersSignIn = KKEndpoint.Users.signIn.endpointValue
		let request: APIRequest<SignInResponse, KKAPIError> = tron.codable.request(usersSignIn)
		request.headers = headers
		request.method = .post
		request.parameters = [
			"email": kurozoraID,
			"password": password,
			"platform": UIDevice.commonSystemName,
			"platform_version": UIDevice.current.systemVersion,
			"device_vendor": "Apple",
			"device_model": UIDevice.modelName
		]

		return request.perform(withSuccess: { [weak self] signInResponse in
			guard let self = self else { return }
			self.authenticationKey = signInResponse.authenticationToken
			User.current = signInResponse.data.first
			completionHandler(.success(self.authenticationKey))
			NotificationCenter.default.post(name: .KUserIsSignedInDidChange, object: nil)
		}, failure: { [weak self] error in
			guard let self = self else { return }
			if self.services.showAlerts {
				UIApplication.topViewController?.presentAlertController(title: "Can't Sign In 😔", message: error.message)
			}
			print("❌ Received sign in error:", error.errorDescription ?? "Unknown error")
			print("┌ Server message:", error.message ?? "No message")
			print("├ Recovery suggestion:", error.recoverySuggestion ?? "No suggestion available")
			print("└ Failure reason:", error.failureReason ?? "No reason available")
			completionHandler(.failure(error))
		})
	}

	/// Sign in or up an account using the details from Sign in with Apple.
	///
	/// If a new account is created, the response will ask for the user to provide a username.
	///
	/// If an account exists, the user is signed in and a notification with the `KUserIsSignedInDidChange` name is posted.
	/// This notification can be observed to perform UI changes regarding the user's sign in status. For example you can remove buttons the user should not have access to if not signed in.
	///
	/// - Parameters:
	///    - token: A JSON Web Token (JWT) that securely communicates information about the user to the server.
	///    - completionHandler: A closure returning a value that represents either a success or a failure, including an associated value in each case.
	///    - result: A value that represents either a success or a failure, including an associated value in each case.
	@discardableResult
	public func signIn(withAppleID token: String, completion completionHandler: @escaping (_ result: Result<OAuthResponse, KKAPIError>) -> Void) -> DataRequest {
		let siwaSignIn = KKEndpoint.Users.siwaSignIn.endpointValue
		let request: APIRequest<OAuthResponse, KKAPIError> = tron.codable.request(siwaSignIn)
		request.headers = headers
		request.method = .post
		request.parameters = [
			"token": token,
			"platform": UIDevice.commonSystemName,
			"platform_version": UIDevice.current.systemVersion,
			"device_vendor": "Apple",
			"device_model": UIDevice.modelName
		]
		return request.perform(withSuccess: { [weak self] oAuthResponse in
			guard let self = self else { return }
			self.authenticationKey = oAuthResponse.authenticationToken
			if let user = oAuthResponse.data?.first {
				User.current = user
			}
			completionHandler(.success(oAuthResponse))
			if oAuthResponse.data?.first != nil {
				NotificationCenter.default.post(name: .KUserIsSignedInDidChange, object: nil)
			}
		}, failure: { [weak self] error in
			guard let self = self else { return }
			UIView().endEditing(true)
			if self.services.showAlerts {
				UIApplication.topViewController?.presentAlertController(title: "Can't Sign In 😔", message: error.message)
			}
			print("❌ Received sign in with SIWA error:", error.errorDescription ?? "Unknown error")
			print("┌ Server message:", error.message ?? "No message")
			print("├ Recovery suggestion:", error.recoverySuggestion ?? "No suggestion available")
			print("└ Failure reason:", error.failureReason ?? "No reason available")
			completionHandler(.failure(error))
		})
	}

	/// Request a password reset link for the given email address.
	///
	/// - Parameters:
	///    - emailAddress: The email address to which the reset link should be sent.
	///    - completionHandler: A closure returning a value that represents either a success or a failure, including an associated value in each case.
	///    - result: A value that represents either a success or a failure, including an associated value in each case.
	@discardableResult
	public func resetPassword(withEmailAddress emailAddress: String, completion completionHandler: @escaping (_ result: Result<KKSuccess, KKAPIError>) -> Void) -> DataRequest {
		let usersResetPassword = KKEndpoint.Users.resetPassword.endpointValue
		let request: APIRequest<KKSuccess, KKAPIError> = tron.codable.request(usersResetPassword)
		request.headers = headers
		request.method = .post
		request.parameters = [
			"email": emailAddress
		]
		return request.perform(withSuccess: { success in
			completionHandler(.success(success))
		}, failure: { [weak self] error in
			guard let self = self else { return }
			UIView().endEditing(true)
			if self.services.showAlerts {
				UIApplication.topViewController?.presentAlertController(title: "Can't Send Reset Link 😔", message: error.message)
			}
			print("❌ Received reset password error:", error.errorDescription ?? "Unknown error")
			print("┌ Server message:", error.message ?? "No message")
			print("├ Recovery suggestion:", error.recoverySuggestion ?? "No suggestion available")
			print("└ Failure reason:", error.failureReason ?? "No reason available")
			completionHandler(.failure(error))
		})
	}

	/// Fetch the followers or following list for the given user identity.
	///
	/// - Parameters:
	///    - userIdentity: The identity of the user whose follower or following list should be fetched.
	///    - followList: The follow list value indicating whather to fetch the followers or following list.
	///    - next: The URL string of the next page in the paginated response. Use `nil` to get first page.
	///    - limit: The limit on the number of objects, or number of objects in the specified relationship, that are returned. The default value is 25 and the maximum value is 100.
	///
	/// - Returns: An instance of `RequestSender` with the results of the get follow list response.
	public func getFollowList(forUser userIdentity: UserIdentity, _ followList: UsersListType, next: String? = nil, limit: Int = 25) -> RequestSender<UserIdentityResponse, KKAPIError> {
		// Prepare headers
		var headers = self.headers
		if !self.authenticationKey.isEmpty {
			headers.add(.authorization(bearerToken: self.authenticationKey))
		}

		// Prepare request
		let usersFollowerOrFollowing = next ?? (followList == .following ? KKEndpoint.Users.following(userIdentity).endpointValue : KKEndpoint.Users.followers(userIdentity).endpointValue)
		let request: APIRequest<UserIdentityResponse, KKAPIError> = tron.codable.request(usersFollowerOrFollowing).buildURL(.relativeToBaseURL)
			.method(.get)
			.parameters([
				"limit": limit
			])
			.headers(headers)

		// Send request
		return request.sender()
	}

	/// Follow or unfollow a user with the given user identity.
	///
	/// - Parameters:
	///    - userIdentity: The identity of the user to follow/unfollow.
	///
	/// - Returns: An instance of `RequestSender` with the results of the update follow status response.
	public func updateFollowStatus(forUser userIdentity: UserIdentity) -> RequestSender<FollowUpdateResponse, KKAPIError> {
		// Prepare headers
		var headers = self.headers
		if !self.authenticationKey.isEmpty {
			headers.add(.authorization(bearerToken: self.authenticationKey))
		}

		// Prepare request
		let usersFollow = KKEndpoint.Users.follow(userIdentity).endpointValue
		let request: APIRequest<FollowUpdateResponse, KKAPIError> = tron.codable.request(usersFollow).buildURL(.relativeToBaseURL)
			.method(.post)
			.headers(headers)

		// Send request
		return request.sender()
	}

	/// Fetch the favorite shows list for the given user identity.
	///
	/// - Parameters:
	///    - userIdentity: The identity of the user whose favorite list will be fetched.
	///    - next: The URL string of the next page in the paginated response. Use `nil` to get first page.
	///    - limit: The limit on the number of objects, or number of objects in the specified relationship, that are returned. The default value is 25 and the maximum value is 100.
	///
	/// - Returns: An instance of `RequestSender` with the results of the get favorite shows response.
	public func getFavoriteShows(forUser userIdentity: UserIdentity, next: String? = nil, limit: Int = 25) -> RequestSender<ShowResponse, KKAPIError> {
		// Prepare headers
		var headers = self.headers
		if !self.authenticationKey.isEmpty {
			headers.add(.authorization(bearerToken: self.authenticationKey))
		}

		// Prepare request
		let usersFavoriteShow = next ?? KKEndpoint.Users.favoriteShow(userIdentity).endpointValue
		let request: APIRequest<ShowResponse, KKAPIError> = tron.codable.request(usersFavoriteShow).buildURL(.relativeToBaseURL)
			.method(.get)
			.parameters([
				"limit": limit
			])
			.headers(headers)

		// Send request
		return request.sender()
	}

	/// Fetch the profile details of the given user user identity.
	///
	/// - Parameters:
	///    - userIdentity: The identity of the user whose profile details should be fetched.
	///    - completionHandler: A closure returning a value that represents either a success or a failure, including an associated value in each case.
	///    - result: A value that represents either a success or a failure, including an associated value in each case.
	@discardableResult
	public func getDetails(forUser userIdentity: UserIdentity, completion completionHandler: @escaping (_ result: Result<[User], KKAPIError>) -> Void) -> DataRequest {
		let usersProfile = KKEndpoint.Users.profile(userIdentity).endpointValue
		let request: APIRequest<UserResponse, KKAPIError> = tron.codable.request(usersProfile)

		request.headers = headers
		if !self.authenticationKey.isEmpty {
			request.headers.add(.authorization(bearerToken: self.authenticationKey))
		}

		request.method = .get
		return request.perform(withSuccess: { userResponse in
			completionHandler(.success(userResponse.data))
		}, failure: { error in
			print("❌ Received user profile error:", error.errorDescription ?? "Unknown error")
			print("┌ Server message:", error.message ?? "No message")
			print("├ Recovery suggestion:", error.recoverySuggestion ?? "No suggestion available")
			print("└ Failure reason:", error.failureReason ?? "No reason available")
			completionHandler(.failure(error))
		})
	}

	/// Search for a user using the given username.
	///
	/// - Parameters:
	///    - username: The username to search for.
	public func searchUsers(for username: String) -> RequestSender<UserIdentityResponse, KKAPIError> {
		// Prepare headers
		var headers = headers
		if !self.authenticationKey.isEmpty {
			headers.add(.authorization(bearerToken: self.authenticationKey))
		}

		// Prepare request
		let usersSearch = KKEndpoint.Users.search(username).endpointValue
		let request: APIRequest<UserIdentityResponse, KKAPIError> = tron.codable.request(usersSearch)
			.method(.get)
			.headers(headers)

		// Send request
		return request.sender()
	}

	/// Deletes the authenticated user's account.
	///
	/// - Parameters:
	///    - password: The authenticated user's password.
	///
	/// - Returns: An instance of `RequestSender` with the results of the delete user response.
	public func deleteUser(password: String) -> RequestSender<KKSuccess, KKAPIError> {
		// Prepare headers
		var headers = self.headers
		headers.add(.authorization(bearerToken: self.authenticationKey))

		// Prepare request
		let usersDelete = KKEndpoint.Users.delete.endpointValue
		let request: APIRequest<KKSuccess, KKAPIError> = tron.codable.request(usersDelete).buildURL(.relativeToBaseURL)
			.method(.delete)
			.parameters([
				"password": password
			])
			.headers(headers)

		// Send request
		return request.sender()
	}
}
