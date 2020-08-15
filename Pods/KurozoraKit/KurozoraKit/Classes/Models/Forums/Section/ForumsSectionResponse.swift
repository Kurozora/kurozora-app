//
//  ForumsSectionResponse.swift
//  KurozoraKit
//
//  Created by Khoren Katklian on 07/08/2020.
//

/**
	A root object that stores information about a collection of forums sections.
*/
public struct ForumsSectionResponse: Codable {
	// MARK: - Properties
	/// The data included in the repsonse for a forums section object request.
	public let data: [ForumsSection]
}
