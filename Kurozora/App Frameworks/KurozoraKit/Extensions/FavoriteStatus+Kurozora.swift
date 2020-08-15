//
//  FavoriteStatus+Kurozora.swift
//  Kurozora
//
//  Created by Khoren Katklian on 13/08/2020.
//  Copyright © 2020 Kurozora. All rights reserved.
//

import KurozoraKit

extension FavoriteStatus {
	// MARK: - Properties
	/// The image value of a favorite status type.
	var imageValue: UIImage {
		switch self {
		case .favorited:
			return R.image.symbols.heart_fill()!
		case .notFavorited, .disabled:
			return R.image.symbols.heart()!
		}
	}
}
