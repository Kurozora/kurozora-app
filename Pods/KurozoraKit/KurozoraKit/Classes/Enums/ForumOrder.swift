//
//  ForumOrder.swift
//  KurozoraKit
//
//  Created by Khoren Katklian on 06/04/2020.
//  Copyright © 2020 Kurozora. All rights reserved.
//

import Foundation

/**
	The set of available forum order types.
*/
public enum ForumOrder: String, CaseIterable {
	// MARK: - Cases
	/// Order by the most well received resource.
	case best

	/// Order by the most liked resource.
	case top

	/// Order by the newly created resource at the top.
	case new

	/// Order by the oldest created resource.
	case old

	/// Order by the least liked resource.
	case poor

	/// Order by the least well received resource.
	case controversial
}
