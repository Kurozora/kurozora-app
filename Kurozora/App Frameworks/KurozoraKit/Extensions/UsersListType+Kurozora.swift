//
//  UsersListType+Kurozora.swift
//  Kurozora
//
//  Created by Khoren Katklian on 28/04/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import KurozoraKit

extension UsersListType {
	// MARK: - Properties
	/// The localized title of the users list, suitable for screen titles and empty-state headlines.
	var localizedTitle: String {
		switch self {
		case .followers: return L10n.followers
		case .following: return L10n.following
		}
	}

	/// The localized title of the users list in lowercase, suitable for inlining into a sentence.
	var localizedTitleLowercase: String {
		switch self {
		case .followers: return L10n.followersLowercase
		case .following: return L10n.followingLowercase
		}
	}
}
