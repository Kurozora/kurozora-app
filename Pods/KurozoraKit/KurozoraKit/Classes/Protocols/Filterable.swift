//
//  Filterable.swift
//  KurozoraKit
//
//  Created by Khoren Katklian on 26/04/2023.
//

internal protocol Filterable {
	func toFilterArray() -> [String: Any?]
}
