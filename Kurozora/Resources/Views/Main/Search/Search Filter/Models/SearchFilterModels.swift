//
//  SearchFilterModels.swift
//  Kurozora
//
//  Created by Khoren Katklian on 16/04/2023.
//  Copyright © 2023 Kurozora. All rights reserved.
//

import KurozoraKit
import UIKit

enum SearchFilterDataSource {
	enum Section: nonisolated Equatable, nonisolated Hashable {
		/// A filter and the control it is set with.
		case filter(FilterKey)

		/// The card holding every filter presented as a row.
		case details
	}

	enum ItemKind: nonisolated Hashable {
		/// A single pill within a filter.
		case pill(key: FilterKey, index: Int, state: FilterSelectionState)

		/// A single duration within a filter.
		case duration(key: FilterKey, index: Int, isSelected: Bool)

		/// A filter presented as a row within the details card.
		case row(key: FilterKey, selectedValue: AnyHashable?, position: GroupedRowPosition)
	}
}
