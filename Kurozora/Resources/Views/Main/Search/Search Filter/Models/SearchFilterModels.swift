//
//  SearchFilterModels.swift
//  Kurozora
//
//  Created by Khoren Katklian on 16/04/2023.
//  Copyright © 2023 Kurozora. All rights reserved.
//

import UIKit

enum SearchFilter {
	enum Section {
		case main
	}

	enum ItemKind: Hashable {
		case searchFilter(attribute: FilterableAttribute, selectedValue: AnyHashable?)

		// MARK: - Functions
		func hash(into hasher: inout Hasher) {
			switch self {
			case .searchFilter(let attribute, let selectedValue):
				hasher.combine(attribute.name)
				hasher.combine(selectedValue)
			}
		}

		static func == (lhs: SearchFilter.ItemKind, rhs: SearchFilter.ItemKind) -> Bool {
			switch (lhs, rhs) {
			case (.searchFilter(let attribute1, let selectedValue1), .searchFilter(let attribute2, let selectedValue2)):
				if attribute1.name == "Astrological Sign" && attribute2.name == "Astrological Sign" {
					print("-------------")
				}
				return attribute1.name == attribute2.name && selectedValue1 == selectedValue2
			}
		}
	}
}
