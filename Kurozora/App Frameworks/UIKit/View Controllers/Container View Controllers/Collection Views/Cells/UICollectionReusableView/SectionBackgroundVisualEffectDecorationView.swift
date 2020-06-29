//
//  SectionBackgroundVisualEffectDecorationView.swift
//  Kurozora
//
//  Created by Khoren Katklian on 30/12/2019.
//  Copyright © 2019 Kurozora. All rights reserved.
//

import UIKit

class SectionBackgroundVisualEffectDecorationView: UICollectionReusableView {
	// MARK: - Properties
	static let elementKindSectionBackground = "SectionBackgroundVisualEffectElementKind"

	// MARK: - Initializers
	override init(frame: CGRect) {
		super.init(frame: frame)
		self.configureView()
	}

	required init?(coder: NSCoder) {
		super.init(coder: coder)
		self.configureView()
	}

	// MARK: - Functions
	/// Configures the views in the resuable view.
	private func configureView() {
		// Blurred table view background
		let blurEffect = UIBlurEffect()
		let visualEffectView = KVibrantVisualEffectView(effect: blurEffect)
		visualEffectView.theme_backgroundColor = KThemePicker.blurBackgroundColor.rawValue
		visualEffectView.cornerRadius = 10

		self.addSubview(visualEffectView)
		visualEffectView.fillToSuperview()
	}
}
