//
//  ThreadReplyResponse.swift
//  KurozoraKit
//
//  Created by Khoren Katklian on 23/12/2018.
//

/**
	A root object that stores information about a collection of thread replies.
*/
public struct ThreadReplyResponse: Codable {
	// MARK: - Properties
	/// The data included in the repsonse for a thread reply object request.
	public let data: [ThreadReply]

	/// The realtive URL to the next page in the paginated response.
	public let next: String?
}
