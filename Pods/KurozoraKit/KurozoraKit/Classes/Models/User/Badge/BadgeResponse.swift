//
//  BadgeResponse.swift
//  KurozoraKit
//
//  Created by Khoren Katklian on 05/08/2020.
//

/// A root object that stores information about a collection of badges.
public struct BadgeResponse: Codable {
	// MARK: - Properties
	/// The data included in the repsonse for a badge object request.
	public let data: [Badge]
}
