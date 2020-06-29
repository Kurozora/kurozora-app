//
//  SectionBackgroundDecorationView.swift
//  Kurozora
//
//  Created by Khoren Katklian on 30/06/2020.
//  Copyright © 2020 Kurozora. All rights reserved.
//

import UIKit

class SectionBackgroundDecorationView: UICollectionReusableView {
	// MARK: - Properties
	static let elementKindSectionBackground = "SectionBackgroundElementKind"

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
		self.theme_backgroundColor = KThemePicker.tintedBackgroundColor.rawValue
	}
}
