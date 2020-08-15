//
//  PlatformResponse.swift
//  KurozoraKit
//
//  Created by Khoren Katklian on 04/08/2020.
//

/**
	A root object that stores information about a collection of platforms.
*/
public struct PlatformResponse: Codable {
	// MARK: - Properties
	/// The data included in the repsonse for a platform object request.
	public let data: [Platform]
}
