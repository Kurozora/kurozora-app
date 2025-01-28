//
//  AchievementResponse.swift
//  KurozoraKit
//
//  Created by Khoren Katklian on 05/08/2020.
//

/// A root object that stores information about a collection of achievements.
public struct AchievementResponse: Codable, Sendable {
	// MARK: - Properties
	/// The data included in the response for a achievement object request.
	public let data: [Achievement]
}
