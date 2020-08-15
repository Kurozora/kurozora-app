//
//  ForumsThreadResponse.swift
//  KurozoraKit
//
//  Created by Khoren Katklian on 07/08/2020.
//

/**
	A root object that stores information about a collection of forums threads.
*/
public struct ForumsThreadResponse: Codable {
	// MARK: - Properties
	/// The data included in the repsonse for a forums thread object request.
	public let data: [ForumsThread]

	/// The realtive URL to the next page in the paginated response.
	public let next: String?
}
