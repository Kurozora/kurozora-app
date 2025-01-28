//
//  Receipt.swift
//  KurozoraKit
//
//  Created by Khoren Katklian on 04/10/2020.
//

/// A root object that stores information about a receipt.
public struct Receipt: Codable, Sendable {
	// MARK: - Properties
	/// The type of the resource.
	public let type: String

	/// The attributes belonging to the receipt.
	public var attributes: Receipt.Attributes
}
