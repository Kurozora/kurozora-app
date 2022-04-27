//
//  ProfileImageButton.swift
//  Kurozora
//
//  Created by Khoren Katklian on 02/05/2020.
//  Copyright © 2020 Kurozora. All rights reserved.
//

import UIKit

/// `ProfileImageButton` is a sepcially crafted object that displays a single image in your interface.
///
/// `ProfileImageButton` adjusts some options to achieve its design, this includes:
/// - Applying a border width and border color.
/// - Rounding the image's corners.
class ProfileImageButton: UIButton {
	// MARK: - Initializers
	override init(frame: CGRect) {
		super.init(frame: frame)
		sharedInit()
	}

	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		sharedInit()
	}

	// MARK: - View
	override func layoutSubviews() {
		super.layoutSubviews()
		self.cornerRadius = self.height / 2
	}

	// MARK: - Functions
	/// The shared settings used to initialize the button.
	func sharedInit() {
		self.borderWidth = 2
		self.borderColor = UIColor.white.withAlphaComponent(0.20)
	}
}
