//
//  Meta.swift
//  KurozoraKit
//
//  Created by Khoren Katklian on 10/12/2022.
//

/// An immutable object that stores meta information returned by the API.
public struct Meta: Codable, Sendable {
	// MARK: - Properties
	/// The version of the API.
	public var version: String

	/// The version of the app supported by the API.
	public var minimumAppVersion: String

	/// Whether the API is down for maintenance.
	public var isMaintenanceModeEnabled: Bool

	/// Whether the user sending the request is authenticated.
	public var isUserAuthenticated: Bool?

	/// The authenticated user ID.
	public var authenticatedUserID: String?
}
