//
//  KurozoraKit+Me.swift
//  KurozoraKit
//
//  Created by Khoren Katklian on 18/08/2020.
//

import TRON
import UIKit

extension KurozoraKit {
	/// Fetches the authenticated user's profile details.
	///
	/// - Parameters:
	///    - completionHandler: A closure returning a value that represents either a success or a failure, including an associated value in each case.
	///    - result: A value that represents either a success or a failure, including an associated value in each case.
	public func getProfileDetails(completion completionHandler: @escaping (_ result: Result<[User], KKAPIError>) -> Void) {
		let meProfile = KKEndpoint.Me.profile.endpointValue
		let request: APIRequest<UserResponse, KKAPIError> = tron.codable.request(meProfile)

		request.headers = headers
		request.headers.add(.authorization(bearerToken: self.authenticationKey))

		request.method = .get
		request.perform(withSuccess: { userResponse in
			User.current = userResponse.data.first
			completionHandler(.success(userResponse.data))
//			NotificationCenter.default.post(name: .KUserIsSignedInDidChange, object: nil)
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

	/// Updates the authenticated user's profile information.
	///
	/// Send `nil` if an infomration shouldn't be updated, otherwise send an empty instance to unset an information.
	/// - Parameters:
	///    - biography: The user's new biography.
	///    - profileImage: The user's new profile image.
	///    - bannerImage: The user's new profile image.
	///    - username: The user's new username.
	///    - completionHandler: A closure returning a value that represents either a success or a failure, including an associated value in each case.
	///    - result: A value that represents either a success or a failure, including an associated value in each case.
	public func updateInformation(biography: String? = nil, profileImage: UIImage? = nil, bannerImage: UIImage? = nil, username: String? = nil, completion completionHandler: @escaping (_ result: Result<UserUpdate, KKAPIError>) -> Void) {
		let usersProfile = KKEndpoint.Me.update.endpointValue
		let request: UploadAPIRequest<UserUpdateResponse, KKAPIError> = tron.codable.uploadMultipart(usersProfile) { formData in
			if let profileImage = profileImage {
				if !profileImage.isEqual(UIImage()) {
					if let profileImage = profileImage.jpegData(compressionQuality: 0.1) {
						formData.append(profileImage, withName: "profileImage", fileName: "ProfileImage.jpg", mimeType: "image/jpg")
					}
				}
			}
			if let bannerImage = bannerImage {
				if !bannerImage.isEqual(UIImage()) {
					if let bannerImageData = bannerImage.jpegData(compressionQuality: 0.1) {
						formData.append(bannerImageData, withName: "bannerImage", fileName: "BannerImage.jpg", mimeType: "image/jpg")
					}
				}
			}
		}

		request.headers = [
			.contentType("multipart/form-data"),
			.accept("application/json")
		]
		request.headers.add(.authorization(bearerToken: self.authenticationKey))

		request.method = .post
		if let biography = biography {
			request.parameters["biography"] = biography
		}
		if let username = username {
			request.parameters["username"] = username
		}
		if profileImage?.isEqual(UIImage()) ?? false {
			request.parameters["profileImage"] = "null"
		}
		if bannerImage?.isEqual(UIImage()) ?? false {
			request.parameters["bannerImage"] = "null"
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

	/// Fetch the followers or following list for the authenticated user.
	///
	/// - Parameters:
	///    - followList: The follow list value indicating whather to fetch the followers or following list.
	///    - next: The URL string of the next page in the paginated response. Use `nil` to get first page.
	///    - limit: The limit on the number of objects, or number of objects in the specified relationship, that are returned. The default value is 25 and the maximum value is 100.
	///    - completionHandler: A closure returning a value that represents either a success or a failure, including an associated value in each case.
	///    - result: A value that represents either a success or a failure, including an associated value in each case.
	public func getFollowList(_ followList: UsersListType, next: String? = nil, limit: Int = 25, completion completionHandler: @escaping (_ result: Result<UserIdentityResponse, KKAPIError>) -> Void) {
		let meFollowersOrFollowing = next ?? (followList == .followers ? KKEndpoint.Me.followers.endpointValue : KKEndpoint.Me.following.endpointValue)
		let request: APIRequest<UserIdentityResponse, KKAPIError> = tron.codable.request(meFollowersOrFollowing).buildURL(.relativeToBaseURL)

		request.headers = headers
		request.headers.add(.authorization(bearerToken: self.authenticationKey))

		request.parameters["limit"] = limit

		request.method = .get
		request.perform(withSuccess: { userIdentityResponse in
			completionHandler(.success(userIdentityResponse))
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
