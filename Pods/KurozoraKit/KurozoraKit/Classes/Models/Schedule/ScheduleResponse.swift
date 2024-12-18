//
//  ScheduleResponse.swift
//  KurozoraKit
//
//  Created by Khoren Katklian on 09/12/2024.
//

/// A root object that stores information about a collection of schedules.
public struct ScheduleResponse: Codable {
	// MARK: - Properties
	/// The data included in the response for an schedule object request.
	public let data: [Schedule]

	/// The realtive URL to the next page in the paginated response.
	public let next: String?
}
