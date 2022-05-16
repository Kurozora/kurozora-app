//
//  FavoriteShowResponse.swift
//  KurozoraKit
//
//  Created by Khoren Katklian on 13/08/2020.
//

/// A root object that stores information about a show's favorite status.
public struct FavoriteShowResponse: Codable {
	// MARK: - Properties
	/// The data included in the repsonse for a favorite show object request.
	public let data: FavoriteShow
}
