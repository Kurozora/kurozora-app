//
//  StudioAttributes+UIImage.swift
//  Kurozora
//
//  Created by Khoren Katklian on 13/08/2020.
//  Copyright © 2020 Kurozora. All rights reserved.
//

import KurozoraKit

extension Studio.Attributes {
	/// Returns a `UIImage` with the logo.
	///
	/// If the show has no logo image, then a placeholder studio logo image is returned.
	var logoImage: UIImage? {
		let logoImageView = UIImageView()
		let placeholderImage = R.image.placeholders.studioProfile()!
		logoImageView.setImage(with: self.logo?.url ?? "", placeholder: placeholderImage)
		return logoImageView.image?.withRenderingMode(.alwaysOriginal)
	}
}
