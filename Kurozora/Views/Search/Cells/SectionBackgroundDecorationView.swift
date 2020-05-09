//
//  SectionBackgroundDecorationView.swift
//  Kurozora
//
//  Created by Khoren Katklian on 30/12/2019.
//  Copyright © 2019 Kurozora. All rights reserved.
//

import UIKit

class SectionBackgroundDecorationView: UICollectionReusableView {
	// MARK: - Properties
	static let elementKindSectionBackground = "SectionBackgroundElementKind"

	// MARK: - Initializers
	override init(frame: CGRect) {
		super.init(frame: frame)
		configureView()
	}

	required init?(coder: NSCoder) {
		super.init(coder: coder)
		configureView()
	}

	// MARK: - Functions
	func configureView() {
		// Blurred table view background
		let blurEffect = UIBlurEffect()
		let visualEffectView = KVibrantVisualEffectView(effect: blurEffect)
		visualEffectView.theme_backgroundColor = KThemePicker.blurBackgroundColor.rawValue
		visualEffectView.cornerRadius = 10

		self.addSubview(visualEffectView)
		visualEffectView.fillToSuperview()
	}
}
