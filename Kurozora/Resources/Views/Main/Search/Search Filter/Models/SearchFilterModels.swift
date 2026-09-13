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
		case main
	}

	enum ItemKind: nonisolated Hashable {
		/// A filter row, identified by the attribute's key and its current value.
		case searchFilter(key: FilterKey, selectedValue: AnyHashable?)
	}
}
