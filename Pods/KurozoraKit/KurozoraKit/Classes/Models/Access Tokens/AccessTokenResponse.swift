//
//  AccessTokenResponse.swift
//  KurozoraKit
//
//  Created by Khoren Katklian on 19/09/2018.
//

/// A root object that stores information about an access token response.
public struct AccessTokenResponse: Codable {
	// MARK: - Properties
	/// The data included in the repsonse for an access token object request.
	public let data: [AccessToken]

	/// The realtive URL to the next page in the paginated response.
	public let next: String?
}
