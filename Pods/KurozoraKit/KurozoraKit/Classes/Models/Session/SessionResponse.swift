//
//  SessionResponse.swift
//  KurozoraKit
//
//  Created by Khoren Katklian on 19/09/2018.
//

/**
	A root object that stores information about a session response.
*/
public struct SessionResponse: Codable {
	// MARK: - Properties
	/// The data included in the repsonse for a session object request.
	public let data: [Session]
}
