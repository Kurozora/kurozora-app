//
//  KotodamaHintView.swift
//  Kurozora
//
//  Created by Khoren Katklian on 30/07/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import UIKit

class KotodamaHintView: UIView {
	// MARK: - Views
	private let hintLabel = UILabel()

	// MARK: - Initializers
	override init(frame: CGRect) {
		super.init(frame: frame)

		self.sharedInit()
	}

	required init?(coder: NSCoder) {
		super.init(coder: coder)

		self.sharedInit()
	}

	// MARK: - Functions
	/// The shared init of the view.
	private func sharedInit() {
		self.translatesAutoresizingMaskIntoConstraints = false

		self.hintLabel.translatesAutoresizingMaskIntoConstraints = false
		self.hintLabel.textAlignment = .center
		self.hintLabel.numberOfLines = 2
		self.hintLabel.font = .preferredFont(forTextStyle: .footnote)
		self.hintLabel.adjustsFontForContentSizeCategory = true
		self.hintLabel.theme_textColor = KThemePicker.subTextColor.rawValue
		self.addSubview(self.hintLabel)

		NSLayoutConstraint.activate([
			self.hintLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor),
			self.hintLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor),
			self.hintLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor),
			self.heightAnchor.constraint(equalToConstant: 38)
		])
	}

	/// Configures the view with the given hint.
	///
	/// - Parameter hint: The hint to show.
	func configure(using hint: String?) {
		guard self.hintLabel.text != hint else { return }

		self.hintLabel.text = hint

		guard hint != nil else { return }

		self.hintLabel.alpha = 0
		UIView.animate(withDuration: 0.25) {
			self.hintLabel.alpha = 1
		}
	}
}
