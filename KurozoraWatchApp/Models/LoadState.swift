//
//  LoadState.swift
//  Kurozora Watch App
//
//  Created by Khoren Katklian on 12/04/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

/// Represents the loading state of a view's data.
enum LoadState: Equatable {
	case idle
	case loading
	case loaded
	case error(String)
}
