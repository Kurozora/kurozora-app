//
//  UIFont+Kurozora.swift
//  Kurozora
//
//  Created by Khoren Katklian on 24/09/2025.
//  Copyright © 2025 Kurozora. All rights reserved.
//

import UIKit

extension UIFont {
	/// Returns the bold version of the font.
	var bold: UIFont {
		guard let descriptor = self.fontDescriptor.withSymbolicTraits(.traitBold) else { return self }
		return UIFont(descriptor: descriptor, size: 0)
	}
}
