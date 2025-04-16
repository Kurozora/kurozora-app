//
//  KurozoraAPI.swift
//  KurozoraKit
//
//  Created by Khoren Katklian on 17/08/2024.
//

@preconcurrency import TRON

/// The set of possible API endpoints for the Kurozora API.
///
/// - `v1`: The endpoint for the Kurozora API version 1.
/// - `custom`: A custom URL for the Kurozora API.
///
/// - Tag: KurozoraAPI
public enum KurozoraAPI: Equatable, Sendable {
	// MARK: - Cases
	/// The endpoint for the Kurozora API version 1.
	case v1

	/// A custom URL for the Kurozora API.
	case custom(_ url: String, _ plugin: [Plugin]? = nil)

	// MARK: - Properties
	/// All cases of `KurozoraAPI`.
	public static let allCases: [KurozoraAPI] = [.v1]

	/// The base URL for the API.
	public var baseURL: String {
		switch self {
		case .v1:
			return "https://api.kurozora.app/v1/"
		case .custom(let url, _):
			return url
		}
	}

	// MARK: - Functions
	public static func == (lhs: KurozoraAPI, rhs: KurozoraAPI) -> Bool {
		switch (lhs, rhs) {
		case (.v1, .v1):
			return true
		case (.custom(let lhsURL, _), .custom(let rhsURL, _)):
			return lhsURL == rhsURL
		default:
			return false
		}
	}
}
