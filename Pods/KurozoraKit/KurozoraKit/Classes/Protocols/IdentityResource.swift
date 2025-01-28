//
//  IdentityResource.swift
//  KurozoraKit
//
//  Created by Khoren Katklian on 06/08/2020.
//

/// A type that holds the value of an entity with stable identity.
///
/// Use the `IdentityResource` protocol to provide a stable notion of identity to a class or value type. For example, you could define a User type with an id property that is stable across your app and your app’s database storage. You could use the id property to identify a particular user even if other data fields change, such as the user’s name.
internal protocol IdentityResource: Codable, Identifiable, Sendable {
	// MARK: - Properties
	/// The id of the resource.
	var id: String { get }

	/// The type of the resource.
	var type: String { get }

	/// The relative link to where the resource is located.
	var href: String { get }
}
