//
//  SectionBackgroundDecorationView.swift
//  Kurozora
//
//  Created by Khoren Katklian on 30/12/2019.
//  Copyright © 2019 Kurozora. All rights reserved.
//

import UIKit
import SwiftTheme

class SectionBackgroundDecorationView: UICollectionReusableView {
	// MARK: - Properties
	static let elementKindSectionBackground = "SectionBackgroundElementKind"

	// MARK: - Initializer
	override init(frame: CGRect) {
		super.init(frame: frame)
		configureView()
	}

	required init?(coder: NSCoder) {
		super.init(coder: coder)
	}

	// MARK: - Functions
	func configureView() {
		// Blurred table view background
		let blurEffect = UIBlurEffect()
		let visualEffectView = UIVisualEffectView(effect: blurEffect)
		visualEffectView.theme_effect = ThemeVisualEffectPicker(keyPath: KThemePicker.visualEffect.stringValue, vibrancyEnabled: true)
		visualEffectView.theme_backgroundColor = KThemePicker.blurBackgroundColor.rawValue
		visualEffectView.cornerRadius = 10

		self.addSubview(visualEffectView)
		visualEffectView.fillToSuperview()
	}
}
