//
//  KCopyableLabel.swift
//  Kurozora
//
//  Created by Khoren Katklian on 01/05/2020.
//  Copyright © 2020 Kurozora. All rights reserved.
//

import UIKit

/// A themed view that displays one or more lines of read-only text, often used in conjunction with controls to describe their intended purpose.
///
/// The color of the labels is pre-configured with the currently selected theme.
/// You can add labels to your interface programmatically or by using Interface Builder.
/// The view also allows users to long press to copy the text within the label.
class KCopyableLabel: KLabel {
	// MARK: - Properties
	override var canBecomeFirstResponder: Bool {
		return true
	}

	// MARK: - Functions
	/// The shared settings used to initialize the label.
	override func sharedInit() {
		super.sharedInit()
		isUserInteractionEnabled = true

		let interaction = UIContextMenuInteraction(delegate: self)
		self.addInteraction(interaction)
	}

	/// Shows a menu with the given gesture recognizer object as the source.
	///
	/// - Parameter gestureRecognizer: The gesture object containing information about the recognized gesture.
	@objc private func showMenu(_ gestureRecognizer: UILongPressGestureRecognizer) {
		guard let gestureView = gestureRecognizer.view, let superView = gestureView.superview else { return }
		let menuController = UIMenuController.shared
		guard !menuController.isMenuVisible, gestureView.canBecomeFirstResponder else { return }

		gestureView.becomeFirstResponder()
		menuController.showMenu(from: superView, rect: gestureView.frame)
	}

	/// Creates and returns a `UIMenu` object with the preconfigured actions.
	///
	/// - Returns: a `UIMenu` object with the preconfigured actions.
	private func makeContextMenu() -> UIMenu {
		// Create a UIAction for sharing
		let copyAction = UIAction(title: "Copy") { [weak self] action in
			guard let self = self else { return }
			self.copy(action)
		}

		// Create and return a UIMenu with the share action
		return UIMenu(title: "", children: [copyAction])
	}

	override func copy(_ sender: Any?) {
		// Copy the text to
		UIPasteboard.general.string = text

		// Hide the menu controller
		let menuController = UIMenuController.shared
		menuController.hideMenu()
	}

	override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
		return (action == #selector(self.copy(_:)))
	}
}

// MARK: - UIContextMenuInteractionDelegate
extension KCopyableLabel: UIContextMenuInteractionDelegate {
	func contextMenuInteraction(_ interaction: UIContextMenuInteraction, configurationForMenuAtLocation location: CGPoint) -> UIContextMenuConfiguration? {
		return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { [weak self] _ -> UIMenu? in
			guard let self = self else { return nil }
			return self.makeContextMenu()
		}
	}

	func contextMenuInteraction(_ interaction: UIContextMenuInteraction, previewForHighlightingMenuWithConfiguration configuration: UIContextMenuConfiguration) -> UITargetedPreview? {
		let parameters = UIPreviewParameters()
		parameters.backgroundColor = KThemePicker.backgroundColor.colorValue
		return UITargetedPreview(view: interaction.view!, parameters: parameters)
	}

	func contextMenuInteraction(_ interaction: UIContextMenuInteraction, previewForDismissingMenuWithConfiguration configuration: UIContextMenuConfiguration) -> UITargetedPreview? {
		let parameters = UIPreviewParameters()
		parameters.backgroundColor = KThemePicker.backgroundColor.colorValue
		return UITargetedPreview(view: interaction.view!, parameters: parameters)
	}
}
