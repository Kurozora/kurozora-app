//
//  MetaResponse.swift
//  KurozoraKit
//
//  Created by Khoren Katklian on 10/12/2022.
//

/// An immutable object that stores meta information returned by the API.
public struct MetaResponse: Codable, Sendable {
	// MARK: - Properties
	/// The object containing the meta attributes.
	public let meta: Meta
}
