//
//  SeasonUpdateResponse.swift
//  KurozoraKit
//
//  Created by Khoren Katklian on 12/09/2023.
//

/// A root object that stores information about an season's update.
public struct SeasonUpdateResponse: Codable, Sendable {
	// MARK: - Properties
	/// The data included in the response for an season update object request.
	public let data: SeasonUpdate
}
