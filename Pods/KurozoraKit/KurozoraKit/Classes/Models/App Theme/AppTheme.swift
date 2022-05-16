//
//  AppTheme.swift
//  KurozoraKit
//
//  Created by Khoren Katklian on 28/02/2019.
//  Copyright © 2019 Kurozora. All rights reserved.
//

/// A root object that stores information about an app theme resource.
public struct AppTheme: IdentityResource, Hashable {
	// MARK: - Properties
	public let id: Int

	public let type: String

	public let href: String

	/// The attributes belonging to the app theme.
	public let attributes: AppTheme.Attributes

	// MARK: - Functions
	public static func == (lhs: AppTheme, rhs: AppTheme) -> Bool {
		lhs.id == rhs.id
	}

	public func hash(into hasher: inout Hasher) {
		hasher.combine(self.id)
	}
}
