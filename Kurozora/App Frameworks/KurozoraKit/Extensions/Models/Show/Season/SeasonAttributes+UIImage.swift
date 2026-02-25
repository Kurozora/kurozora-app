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
	/// Set the genre's poster image.
	///
	/// If the genre has no poster image set, then a placeholder image is applied.
	///
	/// - Parameter imageView: The image view on which to set the banner image.
	func posterImage(imageView: UIImageView) {
		imageView.setImage(with: self.poster?.url ?? "", placeholder: .Placeholders.showPoster)
	}
}
