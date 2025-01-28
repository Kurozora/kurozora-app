//
//  AppTheme.swift
//  KurozoraKit
//
//  Created by Khoren Katklian on 28/02/2019.
//

/// A root object that stores information about an app theme resource.
public struct AppTheme: IdentityResource, Hashable, Sendable {
	// MARK: - Properties
	public let id: String

	public let type: String

	public let href: String

	/// The attributes belonging to the app theme.
	public let attributes: AppTheme.Attributes

	// MARK: - Functions
	public static func == (lhs: AppTheme, rhs: AppTheme) -> Bool {
		return lhs.id == rhs.id
	}

	public func hash(into hasher: inout Hasher) {
		hasher.combine(self.id)
	}
}
