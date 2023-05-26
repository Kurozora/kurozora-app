//
//  SearchFilterModels.swift
//  Kurozora
//
//  Created by Khoren Katklian on 16/04/2023.
//  Copyright © 2023 Kurozora. All rights reserved.
//

import UIKit
import KurozoraKit

enum SearchFilter {
	enum Section {
		case main
	}

	enum ItemKind: Hashable {
		case searchFilter(attribute: FilterableAttribute, value: Any?)

		// MARK: - Functions
		func hash(into hasher: inout Hasher) {
			switch self {
			case .searchFilter(let attribute, _):
				hasher.combine(attribute.name)
			}
		}

		static func == (lhs: SearchFilter.ItemKind, rhs: SearchFilter.ItemKind) -> Bool {
			switch (lhs, rhs) {
			case (.searchFilter(let attribute1, _), .searchFilter(let attribute2, _)):
				return attribute1.name == attribute2.name
			}
		}
	}
}
