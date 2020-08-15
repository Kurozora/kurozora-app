//
//  FeedSectionResponse.swift
//  KurozoraKit
//
//  Created by Khoren Katklian on 21/06/2019.
//  Copyright © 2019 Kurozora. All rights reserved.
//

/**
	A root object that stores information about a collection of feed sections.
*/
public struct FeedSectionResponse: Codable {
	// MARK: - Properties
	/// The data included in the repsonse for a feed section object request.
	public let data: [FeedSection]
}
