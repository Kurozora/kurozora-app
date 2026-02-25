//
//  GenreAttributes+UIImage.swift
//  Kurozora
//
//  Created by Khoren Katklian on 14/08/2020.
//  Copyright © 2020 Kurozora. All rights reserved.
//

import KurozoraKit
import UIKit

extension Genre.Attributes {
	// MARK: - Properties
	/// Returns a `UIImage` with the symbol.
	///
	/// If the show has no symbol image, then a placeholder genre symbol image is returned.
	var symbolImage: UIImage? {
		let symbolImageView = UIImageView()
		symbolImageView.setImage(with: self.symbol?.url ?? "", placeholder: .kurozoraIcon)
		return symbolImageView.image?.withRenderingMode(.alwaysOriginal)
	}
}
