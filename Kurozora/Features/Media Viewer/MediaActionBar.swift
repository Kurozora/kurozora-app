//
//  MediaActionBar.swift
//  Kurozora
//
//  Created by Khoren Katklian on 06/09/2025.
//  Copyright © 2025 Kurozora. All rights reserved.
//

import UIKit

enum MediaAction {
	case share
	case save
	case more(UIMenu)
}

final class MediaActionBar: UIView {
	// MARK: - Views
	private(set) var stackView = UIStackView()

	// MARK: - Properties
	let shareButton = AdaptiveCornerButton()
	private let saveButton = AdaptiveCornerButton()
	let moreButton = AdaptiveCornerButton()

	private var moreMenu: UIMenu?

	/// The menu the save button reveals when held.
	var saveMenu: UIMenu? {
		didSet {
			self.applySaveMenu()
		}
	}

	/// Called when the share button is tapped.
	var onShare: (() -> Void)?

	/// Called when the save button is tapped.
	var onSave: (() -> Void)?

	/// Called when a menu needs presenting from the given view.
	var onPresentMenu: ((UIMenu, UIView) -> Void)?

	/// A boolean value that indicates whether `UIButton.menu` composes with a `.glass()`
	/// configuration on the current platform.
	///
	/// Mac Catalyst on macOS 26 suppresses `UIButtonMacVisualElement` when a menu is assigned to a
	/// `.glass()` button, leaving the button invisible. iOS 26 on iPhone/iPad and older Mac
	/// Catalyst versions are unaffected.
	private static var canUseNativeUIButtonMenu: Bool {
		#if targetEnvironment(macCatalyst)
		if #available(macCatalyst 26.0, *) {
			return false
		}
		#endif
		return true
	}

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
	/// Populates the bar with a button per supplied action.
	///
	/// - Parameter actions: The actions to render, in order.
	func configure(with actions: [MediaAction]) {
		self.stackView.arrangedSubviews.forEach { $0.removeFromSuperview() }

		for action in actions {
			switch action {
			case .share: self.stackView.addArrangedSubview(self.shareButton)
			case .save: self.stackView.addArrangedSubview(self.saveButton)
			case .more(let menu):
				self.moreMenu = menu

				if Self.canUseNativeUIButtonMenu {
					self.moreButton.menu = menu
					self.moreButton.showsMenuAsPrimaryAction = true
				}

				self.stackView.addArrangedSubview(self.moreButton)
			}
		}

		self.isHidden = actions.isEmpty
	}

	private func configureView() {
		self.configureViews()
		self.configureViewHierarchy()
		self.configureViewConstraints()
	}

	private func configureViews() {
		self.configureStackView()
		self.configureSaveButton()
		self.configureShareButton()
		self.configureMoreButton()
	}

	private func configureStackView() {
		self.stackView.translatesAutoresizingMaskIntoConstraints = false
		self.stackView.axis = .horizontal
		self.stackView.spacing = 16
		self.stackView.distribution = .equalSpacing
	}

	private func configureShareButton() {
		self.shareButton.setImage(UIImage(systemName: "square.and.arrow.up"), for: .normal)
		self.shareButton.addTarget(self, action: #selector(self.shareTapped), for: .touchUpInside)

		if #unavailable(iOS 26.0, macOS 26.0, tvOS 26.0, visionOS 26.0, watchOS 26.0) {
			self.shareButton.backgroundColor = .black.withAlphaComponent(0.4)
		}
	}

	private func configureSaveButton() {
		self.saveButton.setImage(UIImage(systemName: "tray.and.arrow.down"), for: .normal)
		self.saveButton.addTarget(self, action: #selector(self.saveTapped), for: .touchUpInside)

		let longPress = UILongPressGestureRecognizer(target: self, action: #selector(self.saveHeld(_:)))
		self.saveButton.addGestureRecognizer(longPress)

		#if targetEnvironment(macCatalyst)
		self.saveButton.addInteraction(UIContextMenuInteraction(delegate: self))
		#endif

		if #unavailable(iOS 26.0, macOS 26.0, tvOS 26.0, visionOS 26.0, watchOS 26.0) {
			self.saveButton.backgroundColor = .black.withAlphaComponent(0.4)
		}
	}

	private func configureMoreButton() {
		self.moreButton.setImage(UIImage(systemName: "ellipsis"), for: .normal)

		if !Self.canUseNativeUIButtonMenu {
			self.moreButton.addTarget(self, action: #selector(self.moreTapped), for: .touchUpInside)
		}

		if #unavailable(iOS 26.0, macOS 26.0, tvOS 26.0, visionOS 26.0, watchOS 26.0) {
			self.moreButton.backgroundColor = .black.withAlphaComponent(0.4)
		}
	}

	private func configureViewHierarchy() {
		self.addSubview(self.stackView)
	}

	private func configureViewConstraints() {
		NSLayoutConstraint.activate([
			self.stackView.leadingAnchor.constraint(equalTo: leadingAnchor),
			self.stackView.trailingAnchor.constraint(equalTo: trailingAnchor),
			self.stackView.topAnchor.constraint(equalTo: topAnchor),
			self.stackView.bottomAnchor.constraint(equalTo: bottomAnchor),
			self.stackView.heightAnchor.constraint(greaterThanOrEqualToConstant: 44.0),

			self.shareButton.widthAnchor.constraint(equalTo: self.shareButton.heightAnchor),
			self.saveButton.widthAnchor.constraint(equalTo: self.saveButton.heightAnchor),
			self.moreButton.widthAnchor.constraint(equalTo: self.moreButton.heightAnchor)
		])
	}

	/// Assigns the save menu to the save button.
	private func applySaveMenu() {
		guard Self.canUseNativeUIButtonMenu else { return }

		self.saveButton.menu = self.saveMenu
		self.saveButton.showsMenuAsPrimaryAction = false
	}

	// MARK: - Handlers
	@objc private func shareTapped() {
		self.onShare?()
	}

	@objc private func saveTapped() {
		self.onSave?()
	}

	@objc private func saveHeld(_ gesture: UILongPressGestureRecognizer) {
		guard gesture.state == .began, !Self.canUseNativeUIButtonMenu else { return }
		self.presentSaveMenu()
	}

	private func presentSaveMenu() {
		guard let menu = self.saveMenu else { return }
		self.onPresentMenu?(menu, self.saveButton)
	}

	@objc private func moreTapped() {
		guard let menu = self.moreMenu else { return }
		self.onPresentMenu?(menu, self.moreButton)
	}
}

// MARK: - UIContextMenuInteractionDelegate
#if targetEnvironment(macCatalyst)
extension MediaActionBar: UIContextMenuInteractionDelegate {
	func contextMenuInteraction(_ interaction: UIContextMenuInteraction, configurationForMenuAtLocation location: CGPoint) -> UIContextMenuConfiguration? {
		guard let menu = self.saveMenu else { return nil }
		return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { _ in menu }
	}
}
#endif
