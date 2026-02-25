//
//  SeasonAttributes+UIImage.swift
//  Kurozora
//
//  Created by Khoren Katklian on 14/08/2020.
//  Copyright © 2020 Kurozora. All rights reserved.
//

import KurozoraKit
import UIKit

extension Season.Attributes {
	// MARK: - Properties
	/// Returns a `UIImage` with the poster.
	///
	/// If the show has no poster image, then a placeholder show poster image is returned.
	var posterImage: UIImage? {
		let posterImageView = UIImageView()
		posterImageView.setImage(with: self.poster?.url ?? "", placeholder: .Placeholders.showPoster)
		return posterImageView.image?.withRenderingMode(.alwaysOriginal)
	}
}
