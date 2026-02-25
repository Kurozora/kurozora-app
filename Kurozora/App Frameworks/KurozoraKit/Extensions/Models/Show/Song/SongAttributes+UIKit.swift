//
//  SongAttributes+UIKit.swift
//  Kurozora
//
//  Created by Khoren Katklian on 20/03/2024.
//  Copyright © 2024 Kurozora. All rights reserved.
//

import KurozoraKit
import UIKit

extension Song.Attributes {
	// MARK: - Functions
	/// Set the artwork.
	///
	/// If the song has no artwork image, then a placeholder album image is used.
	///
	/// - Parameter imageView: The image view on which to set the artwork image.
	func artworkImage(imageView: UIImageView) {
		imageView.setImage(with: self.artwork?.url ?? "", placeholder: .Placeholders.musicAlbum)
	}
}
