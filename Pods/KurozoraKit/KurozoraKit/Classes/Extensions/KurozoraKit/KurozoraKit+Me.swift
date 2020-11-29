//
//  KurozoraKit+Me.swift
//  KurozoraKit
//
//  Created by Khoren Katklian on 18/08/2020.
//

import TRON

extension KurozoraKit {
	/**
		Fetches the authenticated user's profile details.

		- Parameter completionHandler: A closure returning a value that represents either a success or a failure, including an associated value in each case.
		- Parameter result: A value that represents either a success or a failure, including an associated value in each case.
	*/
	public func getProfileDetails(completion completionHandler: @escaping (_ result: Result<String, KKAPIError>) -> Void) {
		let meProfile = KKEndpoint.Me.profile.endpointValue
		let request: APIRequest<SignInResponse, KKAPIError> = tron.codable.request(meProfile)

		request.headers = headers
		request.headers["kuro-auth"] = self.authenticationKey

		request.method = .get
		request.perform(withSuccess: { [weak self] signInResponse in
			guard let self = self else { return }
			self.authenticationKey = signInResponse.authenticationToken
			User.current = signInResponse.data.first
			completionHandler(.success(self.authenticationKey))
			NotificationCenter.default.post(name: .KUserIsSignedInDidChange, object: nil)
		}, failure: { [weak self] error in
			guard let self = self else { return }
			if self.services.showAlerts {
				UIApplication.topViewController?.presentAlertController(title: "Can't Get Profile Details 😔", message: error.message)
			}
			print("❌ Received get profile details error", error.errorDescription ?? "Unknown error")
			print("┌ Server message:", error.message ?? "No message")
			print("├ Recovery suggestion:", error.recoverySuggestion ?? "No suggestion available")
			print("└ Failure reason:", error.failureReason ?? "No reason available")
			completionHandler(.failure(error))
		})
	}

	/**
		Fetches and restores the details for the authenticated user.

		- Parameter authenticationKey: The authentication key of the user whose details should be fetched.
		- Parameter completionHandler: A closure returning a value that represents either a success or a failure, including an associated value in each case.
		- Parameter result: A value that represents either a success or a failure, including an associated value in each case.
	*/
	public func restoreDetails(forUserWith authenticationKey: String, completion completionHandler: @escaping (_ result: Result<String, KKAPIError>) -> Void) {
		let meProfile = KKEndpoint.Me.profile.endpointValue
		let request: APIRequest<SignInResponse, KKAPIError> = tron.codable.request(meProfile)

		request.headers = headers
		request.headers["kuro-auth"] = authenticationKey

		request.method = .get
		request.perform(withSuccess: { [weak self] signInResponse in
			guard let self = self else { return }
			self.authenticationKey = signInResponse.authenticationToken
			User.current = signInResponse.data.first
			completionHandler(.success(self.authenticationKey))
			NotificationCenter.default.post(name: .KUserIsSignedInDidChange, object: nil)
		}, failure: { error in
			print("❌ Received restore details error", error.errorDescription ?? "Unknown error")
			print("┌ Server message:", error.message ?? "No message")
			print("├ Recovery suggestion:", error.recoverySuggestion ?? "No suggestion available")
			print("└ Failure reason:", error.failureReason ?? "No reason available")
			completionHandler(.failure(error))
		})
	}

	/**
		Updates the authenticated user's profile information.

		Send `nil` if an infomration shouldn't be updated, otherwise send an empty instance to unset an information.

		- Parameter biography: The user's new biography.
		- Parameter profileImage: The user's new profile image.
		- Parameter bannerImage: The user's new profile image.
		- Parameter username: The user's new username.
		- Parameter completionHandler: A closure returning a value that represents either a success or a failure, including an associated value in each case.
		- Parameter result: A value that represents either a success or a failure, including an associated value in each case.
	*/
	public func updateInformation(biography: String? = nil, bannerImage: UIImage? = nil, profileImageFilePath: String? = nil, username: String? = nil, completion completionHandler: @escaping (_ result: Result<UserUpdate, KKAPIError>) -> Void) {
		let usersProfile = KKEndpoint.Me.update.endpointValue
		let request: UploadAPIRequest<UserUpdateResponse, KKAPIError> = tron.codable.uploadMultipart(usersProfile) { formData in
			if let profileImageFilePath = profileImageFilePath, let profileImageFilePathURL = URL(string: profileImageFilePath) {
				if let profileImageData = try? Data(contentsOf: profileImageFilePathURL) {
					let fileExtension = profileImageFilePathURL.pathExtension
					formData.append(profileImageData, withName: "profileImage", fileName: "ProfileImage.\(fileExtension)", mimeType: "image/\(fileExtension)")
				}
			}
			if let bannerImage = bannerImage {
				if bannerImage.size.width != 0 {
					if let bannerImageData = bannerImage.jpegData(compressionQuality: 0.1) {
						formData.append(bannerImageData, withName: "bannerImage", fileName: "BannerImage.png", mimeType: "image/png")
					}
				}
			}
		}

		request.headers = [
			"Content-Type": "multipart/form-data",
			"Accept": "application/json"
		]
		request.headers["kuro-auth"] = self.authenticationKey

		request.method = .post
		if let biography = biography {
			request.parameters["biography"] = biography
		}
		if let username = username {
			request.parameters["username"] = username
		}

		request.perform(withSuccess: { userUpdateResponse in
			User.current?.attributes.update(using: userUpdateResponse.data)
			completionHandler(.success(userUpdateResponse.data))
		}, failure: { [weak self] error in
			guard let self = self else { return }
			UIView().endEditing(true)
			if self.services.showAlerts {
				UIApplication.topViewController?.presentAlertController(title: "Can't Update Information 😔", message: error.message)
			}
			print("❌ Received update profile information error", error.errorDescription ?? "Unknown error")
			print("┌ Server message:", error.message ?? "No message")
			print("├ Recovery suggestion:", error.recoverySuggestion ?? "No suggestion available")
			print("└ Failure reason:", error.failureReason ?? "No reason available")
			completionHandler(.failure(error))
		})
	}

	/**
		Fetch the followers or following list for the authenticated user.

		- Parameter followList: The follow list value indicating whather to fetch the followers or following list.
		- Parameter next: The URL string of the next page in the paginated response. Use `nil` to get first page.
		- Parameter limit: The limit on the number of objects, or number of objects in the specified relationship, that are returned. The default value is 25 and the maximum value is 100.
		- Parameter completionHandler: A closure returning a value that represents either a success or a failure, including an associated value in each case.
		- Parameter result: A value that represents either a success or a failure, including an associated value in each case.
	*/
	public func getFollowList(_ followList: FollowList, next: String? = nil, limit: Int = 25, completion completionHandler: @escaping (_ result: Result<UserFollow, KKAPIError>) -> Void) {
		let meFollowersOrFollowing = next ?? (followList == .followers ? KKEndpoint.Me.followers.endpointValue : KKEndpoint.Me.following.endpointValue)
		let request: APIRequest<UserFollow, KKAPIError> = tron.codable.request(meFollowersOrFollowing).buildURL(.relativeToBaseURL)

		request.headers = headers
		request.headers["kuro-auth"] = self.authenticationKey

		request.parameters["limit"] = limit

		request.method = .get
		request.perform(withSuccess: { userFollow in
			completionHandler(.success(userFollow))
		}, failure: { [weak self] error in
			guard let self = self else { return }
			if self.services.showAlerts {
				UIApplication.topViewController?.presentAlertController(title: "Can't Get \(followList.rawValue.capitalized) List 😔", message: error.message)
			}
			print("❌ Received get \(followList.rawValue) error:", error.errorDescription ?? "Unknown error")
			print("┌ Server message:", error.message ?? "No message")
			print("├ Recovery suggestion:", error.recoverySuggestion ?? "No suggestion available")
			print("└ Failure reason:", error.failureReason ?? "No reason available")
			completionHandler(.failure(error))
		})
	}
}
