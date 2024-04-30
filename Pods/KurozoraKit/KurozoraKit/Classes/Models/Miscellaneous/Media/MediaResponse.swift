//
//  MediaResponse.swift
//  KurozoraKit
//
//  Created by Khoren Katklian on 07/04/2024.
//

/// A root object that stores information about a collection of media.
public struct MediaResponse: Codable {
	// MARK: - Properties
	/// The data included in the response for a media object request.
	public let data: [Media]
}
