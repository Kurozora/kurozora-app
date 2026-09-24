//
//  ReCapShareButton.swift
//  Kurozora
//
//  Created by Khoren Katklian on 25/09/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import UIKit

/// The round button that shares a Re:CAP card.
final class ReCapShareButton: UIButton {
	// MARK: - Properties
	/// The width and height of the button.
	static let size: CGFloat = 32.0

	/// The space between the button and the corner of its card.
	static let inset: CGFloat = 12.0

	/// The image of the button.
	private static let image = UIImage(systemName: "square.and.arrow.up")

	/// Called with the button when it's tapped.
	var shareHandler: ((ReCapShareButton) -> Void)?

	/// Whether the button shows that its card is being prepared.
	var isLoading = false {
		didSet {
			self.configuration?.image = self.isLoading ? nil : Self.image
			self.isUserInteractionEnabled = !self.isLoading

			if self.isLoading {
				self.activityIndicatorView.startAnimating()
			} else {
				self.activityIndicatorView.stopAnimating()
			}
		}
	}

	/// The indicator shown while the card is being prepared.
	private let activityIndicatorView = UIActivityIndicatorView(style: .medium)

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
	private func sharedInit() {
		var configuration: UIButton.Configuration

		if #available(iOS 26.0, macCatalyst 26.0, *) {
			configuration = .glass()
		} else {
			configuration = .gray()
		}

		configuration.image = Self.image
		configuration.preferredSymbolConfigurationForImage = UIImage.SymbolConfiguration(pointSize: 13.0, weight: .semibold)
		configuration.cornerStyle = .capsule
		self.configuration = configuration
		self.theme_tintColor = KThemePicker.textColor.rawValue
		self.accessibilityLabel = L10n.share
		self.translatesAutoresizingMaskIntoConstraints = false

		self.activityIndicatorView.theme_color = KThemePicker.textColor.rawValue
		self.activityIndicatorView.hidesWhenStopped = true
		self.activityIndicatorView.isUserInteractionEnabled = false
		self.activityIndicatorView.translatesAutoresizingMaskIntoConstraints = false
		self.addSubview(self.activityIndicatorView)

		NSLayoutConstraint.activate([
			self.widthAnchor.constraint(equalToConstant: Self.size),
			self.heightAnchor.constraint(equalToConstant: Self.size),
			self.activityIndicatorView.centerXAnchor.constraint(equalTo: self.centerXAnchor),
			self.activityIndicatorView.centerYAnchor.constraint(equalTo: self.centerYAnchor),
		])

		self.addAction(UIAction { [weak self] _ in
			guard let self = self else { return }
			self.shareHandler?(self)
		}, for: .primaryActionTriggered)
	}
}
