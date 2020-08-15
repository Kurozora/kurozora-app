//
//  ActorResponse.swift
//  KurozoraKit
//
//  Created by Khoren Katklian on 09/09/2018.
//

/**
	A root object that stores information about a collection of actors.
*/
public struct ActorResponse: Codable {
	// MARK: - Properties
	/// The data included in the repsonse for an actor object request.
	public let data: [Actor]
}
