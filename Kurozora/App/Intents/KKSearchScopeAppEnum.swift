//
//  KKSearchScopeAppEnum.swift
//  Kurozora
//
//  Created by Khoren Katklian on 10/02/2024.
//  Copyright © 2024 Kurozora. All rights reserved.
//

import Foundation
import AppIntents
import KurozoraKit

@available(iOS 16.0, macOS 13.0, watchOS 9.0, tvOS 16.0, *)
enum KKSearchScopeAppEnum: String, AppEnum {
    case kurozora
    case library

    static var typeDisplayRepresentation = TypeDisplayRepresentation(name: "Search Scope")
    static var caseDisplayRepresentations: [Self: DisplayRepresentation] = [
        .kurozora: "Kurozora",
        .library: "Library"
    ]

	/// The `KKSearchScope` value of a `KKSearchScopeAppEnum` type.
	var kkSearchScopeValue: KKSearchScope {
		switch self {
		case .kurozora:
			return .kurozora
		case .library:
			return .library
		}
	}
}
