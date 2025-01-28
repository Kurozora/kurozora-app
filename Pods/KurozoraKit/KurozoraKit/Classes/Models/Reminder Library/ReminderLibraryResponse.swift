//
//  ReminderLibraryResponse.swift
//  Pods
//
//  Created by Khoren Katklian on 11/07/2024.
//

/// A root object that stores information about a collection of reminder libraries.
public struct ReminderLibraryResponse: Codable, Sendable {
	// MARK: - Properties
	/// The data included in the response for a reminder library object request.
	public let data: ReminderLibrary

	/// The relative URL to the next page in the paginated response.
	public let next: String?
}
