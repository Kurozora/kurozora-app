//
//  ProfileUpdateImageRequest.swift
//  KurozoraKit
//
//  Created by Khoren Katklian on 24/02/2024.
//

/// The list of available profile update image request types.
///
/// - Tag: ProfileUpdateImageRequest
public enum ProfileUpdateImageRequest {
	/// Indicates the request should update the image with the specified URL.
	///
	/// - Parameters:
	///    - url: The URL object referencing the image.
	///
	/// - Tag: ProfileUpdateImageRequest-update
	case update(url: URL?)

	/// Indicates the request should delete the image.
	///
	/// - Tag: ProfileUpdateImageRequest-delete
	case delete
}
