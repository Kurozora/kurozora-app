//
//  FavoriteStatus.swift
//  KurozoraKit
//
//  Created by Khoren Katklian on 06/04/2020.
//  Copyright © 2020 Kurozora. All rights reserved.
//

import Foundation

/**
	The set of available favorite status types.

	```
	case unfavorite = -1
	case disabled = 0
	case favorite = 1
	```
*/
public enum FavoriteStatus: Int, Codable {
	// MARK: - Cases
	/// The show is not favorited.
	case notFavorited = -1

	/// The show can't be favorited or unfavorited
	case disabled = 0

	/// The show is favorited.
	case favorited = 1

	// MARK: - Initializers
	/**
		Initializes an instance of `FavoriteStatus` with the given bool value.

		If `nil` is given, then an instance of `.disabled` is initialized.

		- Parameter bool: The boolean value used to initialize an instance of `FavoriteStatus`.
	*/
	public init(_ bool: Bool?) {
		if let bool = bool {
			self = bool ? .favorited : .notFavorited
		} else {
			self = .disabled
		}
	}
}
