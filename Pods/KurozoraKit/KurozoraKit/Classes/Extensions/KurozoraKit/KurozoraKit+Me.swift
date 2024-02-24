//
//  KurozoraKit+Me.swift
//  KurozoraKit
//
//  Created by Khoren Katklian on 18/08/2020.
//

import Alamofire
import TRON
import UIKit

extension KurozoraKit {
	/// Fetches the authenticated user's profile details.
	///
	/// - Returns: An instance of `RequestSender` with the results of the profile details response.
	public func getProfileDetails() -> RequestSender<UserResponse, KKAPIError> {
		let profileDetailsRequest = self.sendGetProfileDetailsRequest()

		Task {
			do {
				let userResponse = try await profileDetailsRequest.value

				User.current = userResponse.data.first
				NotificationCenter.default.post(name: .KUserIsSignedInDidChange, object: nil)
			} catch {
				print("Received validate receipt error: \(error.localizedDescription)")
			}
		}

		return profileDetailsRequest
	}

	/// Fetches the authenticated user's profile details.
	///
	/// - Returns: An instance of `RequestSender` with the results of the profile details response.
	private func sendGetProfileDetailsRequest() -> RequestSender<UserResponse, KKAPIError> {
		// Prepare headers
		var headers = self.headers
		headers.add(.authorization(bearerToken: self.authenticationKey))

		// Prepare request
		let meProfile = KKEndpoint.Me.profile.endpointValue
		let request: APIRequest<UserResponse, KKAPIError> = tron.codable.request(meProfile)
			.method(.get)
			.headers(headers)

		// Send request
		return request.sender()
	}

	/// Updates the authenticated user's profile information.
	///
	/// Send `nil` if an infomration shouldn't be updated, otherwise send an empty instance to unset an information.
	///
	/// - Parameters:
	///    - profileUpdateRequest: An instance of `ProfileUpdateRequest` containing the new profile details.
	///
	/// - Returns: An instance of `RequestSender` with the results of the update information response.
	public func updateInformation(_ profileUpdateRequest: ProfileUpdateRequest) -> RequestSender<UserUpdateResponse, KKAPIError> {
		// Prepare headers
		let headers: HTTPHeaders = [
			.contentType("multipart/form-data"),
			.accept("application/json"),
			.authorization(bearerToken: self.authenticationKey)
		]

		// Prepare parameters
		var parameters: [String: Any] = [:]

		if let username = profileUpdateRequest.username {
			parameters["username"] = username
		}
		if let username = profileUpdateRequest.nickname {
			parameters["nickname"] = username
		}
		if let biography = profileUpdateRequest.biography {
			parameters["biography"] = biography
		}
		switch profileUpdateRequest.profileImageRequest {
		case .update: break
		case .delete:
			parameters["profileImage"] = "null"
		case .none: break
		}
		switch profileUpdateRequest.bannerImageRequest {
		case .update: break
		case .delete:
			parameters["bannerImage"] = "null"
		case .none: break
		}
		if let preferredLanguage = profileUpdateRequest.preferredLanguage {
			parameters["preferredLanguage"] = preferredLanguage
		}
		if let preferredTVRating = profileUpdateRequest.preferredTVRating {
			parameters["preferredTVRating"] = preferredTVRating
		}
		if let preferredTimezone = profileUpdateRequest.preferredTimezone {
			parameters["preferredTimezone"] = preferredTimezone
		}

		// Prepare request
		let usersProfile = KKEndpoint.Me.update.endpointValue
		let request: UploadAPIRequest<UserUpdateResponse, KKAPIError> = tron.codable.uploadMultipart(usersProfile) { formData in
			switch profileUpdateRequest.profileImageRequest {
			case .update(url: let profileImageURL):
				if let profileImageURL = profileImageURL, let profileImageData = try? Data(contentsOf: profileImageURL) {
					let pathExtension = profileImageURL.pathExtension
					var uploadImage: Data!

					switch pathExtension {
					case "jpeg", "jpg", "png":
						uploadImage = UIImage(data: profileImageData)?.jpegData(compressionQuality: 0.1) ?? profileImageData
					default:
						uploadImage = profileImageData
					}

					formData.append(uploadImage, withName: "profileImage", fileName: profileImageURL.lastPathComponent, mimeType: "image/\(pathExtension)")
				}
			case .delete: break
			case .none: break
			}

			switch profileUpdateRequest.bannerImageRequest {
			case .update(url: let bannerImageURL):
				if let bannerImageURL = bannerImageURL, let bannerImageData = try? Data(contentsOf: bannerImageURL) {
					let pathExtension = bannerImageURL.pathExtension
					var uploadImage: Data!

					switch pathExtension {
					case "jpeg", "jpg", "png":
						uploadImage = UIImage(data: bannerImageData)?.jpegData(compressionQuality: 0.1) ?? bannerImageData
					default:
						uploadImage = bannerImageData
					}

					formData.append(uploadImage, withName: "bannerImage", fileName: bannerImageURL.lastPathComponent, mimeType: "image/\(pathExtension)")
				}
			case .delete: break
			case .none: break
			}
		}
			.method(.post)
			.parameters(parameters)
			.headers(headers)

		// Send request
		return request.sender()
	}

	/// Fetch the followers or following list for the authenticated user.
	///
	/// - Parameters:
	///    - followList: The follow list value indicating whather to fetch the followers or following list.
	///    - next: The URL string of the next page in the paginated response. Use `nil` to get first page.
	///    - limit: The limit on the number of objects, or number of objects in the specified relationship, that are returned. The default value is 25 and the maximum value is 100.
	///
	/// - Returns: An instance of `RequestSender` with the results of the get follow list response.
	public func getFollowList(_ followList: UsersListType, next: String? = nil, limit: Int = 25) -> RequestSender<UserIdentityResponse, KKAPIError> {
		// Prepare headers
		var headers = self.headers
		headers.add(.authorization(bearerToken: self.authenticationKey))

		// Prepare request
		let meFollowersOrFollowing = next ?? (followList == .followers ? KKEndpoint.Me.followers.endpointValue : KKEndpoint.Me.following.endpointValue)
		let request: APIRequest<UserIdentityResponse, KKAPIError> = tron.codable.request(meFollowersOrFollowing).buildURL(.relativeToBaseURL)
			.method(.get)
			.parameters([
				"limit": limit
			])
			.headers(headers)

		// Send request
		return request.sender()
	}
}
