//
//  Achievement+UIKit.swift
//  Kurozora
//
//  Created by Khoren Katklian on 26/02/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import KurozoraKit
import UIKit

extension Achievement.Attributes {
	/// Set the genre's symbol image.
	///
	/// If the genre has no symbol image set, then a placeholder image is applied.
	///
	/// - Parameter imageView: The image view on which to set the banner image.
	func symbolImage(imageView: UIImageView) {
		imageView.setImage(with: self.symbol?.url ?? "", placeholder: .kurozoraIcon)
	}
}
