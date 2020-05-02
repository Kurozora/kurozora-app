//
//  KCopyableLabel.swift
//  Kurozora
//
//  Created by Khoren Katklian on 01/05/2020.
//  Copyright © 2020 Kurozora. All rights reserved.
//

import UIKit

/**
	A themed view that displays one or more lines of read-only text, often used in conjunction with controls to describe their intended purpose.

	The color of the labels is pre-configured with the currently selected theme.
	You can add labels to your interface programmatically or by using Interface Builder.
	The view also allows users to long press to copy the text within the label.
*/
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
		#if targetEnvironment(macCatalyst)
		let interaction = UIContextMenuInteraction(delegate: self)
		self.addInteraction(interaction)
		#else
		addGestureRecognizer(UILongPressGestureRecognizer(target: self, action: #selector(showMenu(_:))))
		#endif
	}

	/**
		Shows a menu with the given gesture recognizer object as the source.

		- Parameter gestureRecognizer: The gesture object containing information about the recognized gesture.
	*/
	@objc private func showMenu(_ gestureRecognizer: UILongPressGestureRecognizer) {
		guard let gestureView = gestureRecognizer.view, let superView = gestureView.superview else { return }
		let menuController = UIMenuController.shared
		guard !menuController.isMenuVisible, gestureView.canBecomeFirstResponder else { return }

		gestureView.becomeFirstResponder()

		#if targetEnvironment(macCatalyst)
		menuController.showMenu(from: superView, rect: gestureView.frame)
		#else
		menuController.setTargetRect(gestureView.frame, in: superView)
		menuController.setMenuVisible(true, animated: true)
		#endif
	}

	#if targetEnvironment(macCatalyst)
	/**
		Creates and returns a `UIMenu` object with the preconfigured actions.

		- Returns: a `UIMenu` object with the preconfigured actions.
	*/
	private func makeContextMenu() -> UIMenu {
		// Create a UIAction for sharing
		let copyAction = UIAction(title: "Copy") { action in
			self.copy(action)
		}

		// Create and return a UIMenu with the share action
		return UIMenu(title: "", children: [copyAction])
	}
	#endif

	override func copy(_ sender: Any?) {
		// Copy the text to
		UIPasteboard.general.string = text

		// Hide the menu controller
		let menuController = UIMenuController.shared

		#if targetEnvironment(macCatalyst)
		menuController.hideMenu()
		#else
		menuController.setMenuVisible(false, animated: true)
		#endif
	}

	override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
		return (action == #selector(copy(_:)))
	}
}

// MARK: - UIContextMenuInteractionDelegate
#if targetEnvironment(macCatalyst)
extension KCopyableLabel: UIContextMenuInteractionDelegate {
	func contextMenuInteraction(_ interaction: UIContextMenuInteraction, configurationForMenuAtLocation location: CGPoint) -> UIContextMenuConfiguration? {
		return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { _ -> UIMenu? in
			return self.makeContextMenu()
		}
	}
}
#endif
