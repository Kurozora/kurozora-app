//
//  ProfileBarButtonItem.swift
//  Kurozora
//
//  Created by Khoren Katklian on 19/12/2025.
//  Copyright © 2025 Kurozora. All rights reserved.
//

import KurozoraKit
import UIKit

/// A specialized profile button for placement on a toolbar, navigation bar, or shortcuts bar.
final class ProfileBarButtonItem: UIBarButtonItem {
	// MARK: - Views
	/// The button that displays the profile image.
	private let button = ProfileImageButton()

	// MARK: - Properties
	/// The primary action associated with the bar button item.
	private let _primaryAction: UIAction

	/// The image used to represent the item.
	///
	/// Setting this property updates the image displayed on the button.
	override var image: UIImage? {
		get { self.button.currentImage }
		set {
			self.button.setImage(newValue, for: .normal)
		}
	}

	// MARK: - Initializers
	/// Creates an item using the specified primary action.
	///
	/// - Parameters:
	///    - primaryAction: A [UIAction](https://developer.apple.com/documentation/uikit/uiaction) to associate with the item. The system item doesn’t use the action to configure its title and image.
	init(primaryAction: UIAction) {
		self._primaryAction = primaryAction

		super.init()

		self.configureView()
	}

	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	deinit {
		NotificationCenter.default.removeObserver(self)
	}

	// MARK: - Functions
	/// Configures the bar button item.
	private func configureView() {
		self.customView = self.button

		self.button.addAction(self._primaryAction, for: .touchUpInside)

		self.button.translatesAutoresizingMaskIntoConstraints = false

		let buttonSize: CGFloat
		#if targetEnvironment(macCatalyst)
		buttonSize = 28
		#else
		buttonSize = 36
		#endif

		NSLayoutConstraint.activate([
			self.button.widthAnchor.constraint(equalToConstant: buttonSize),
			self.button.heightAnchor.constraint(equalToConstant: buttonSize)
		])

		NotificationCenter.default.addObserver(self, selector: #selector(self.handleSignInDidChange), name: .KUserIsSignedInDidChange, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(self.refreshProfileImage), name: .KUserProfileDidUpdate, object: nil)
	}

	/// Loads the given user's profile image onto the button, falling back to the placeholder when no user is signed in.
	///
	/// - Parameter user: The user whose profile image should be displayed.
	func configure(for user: User?) {
		if let user = user {
			user.attributes.profileImage(button: self.button)
		} else {
			self.image = .Placeholders.userProfile
		}
	}

	@objc private func handleSignInDidChange() {
		self.configure(for: User.current)
	}

	@objc private func refreshProfileImage(_ notification: Notification) {
		if let image = notification.userInfo?["profileImage"] as? UIImage {
			self.image = image
		} else {
			self.configure(for: User.current)
		}
	}
}
