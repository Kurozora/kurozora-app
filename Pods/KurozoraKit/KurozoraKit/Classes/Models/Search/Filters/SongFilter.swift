//
//  SongFilter.swift
//  KurozoraKit
//
//  Created by Khoren Katklian on 26/04/2023.
//

public struct SongFilter {
	public init() {	}
}

// MARK: - Filterable
extension SongFilter: Filterable {
	func toFilterArray() -> [String: Any?] {
		return [:]
	}
}
