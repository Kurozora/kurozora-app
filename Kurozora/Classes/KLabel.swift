//
//  KLabel.swift
//  Kurozora
//
//  Created by Khoren Katklian on 29/09/2018.
//  Copyright © 2018 Kurozora. All rights reserved.
//

import UIKit

class KLabel: UILabel {
	// MARK: - Properties
	override var canBecomeFirstResponder: Bool {
		return true
	}

	// MARK: - Initializer
	override init(frame: CGRect) {
		super.init(frame: frame)
		sharedInit()
	}

	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		sharedInit()
	}

	// MARK: - Functions
	private func sharedInit() {
		isUserInteractionEnabled = true
		#if targetEnvironment(macCatalyst)
			let interaction = UIContextMenuInteraction(delegate: self)
			self.addInteraction(interaction)
		#else
			addGestureRecognizer(UILongPressGestureRecognizer(target: self, action: #selector(showMenu(_:))))
		#endif
	}

	@objc func showMenu(_ gesture: UILongPressGestureRecognizer) {
		guard let gestureView = gesture.view, let superView = gestureView.superview else { return }
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
	fileprivate func makeContextMenu() -> UIMenu {
		// Create a UIAction for sharing
		let copyAction = UIAction(title: "Copy") { action in
			self.showMenu(sender: action)
		}

		// Create and return a UIMenu with the share action
		return UIMenu(title: "Main Menu", children: [copyAction])
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
extension KLabel: UIContextMenuInteractionDelegate {
	func contextMenuInteraction(_ interaction: UIContextMenuInteraction, configurationForMenuAtLocation location: CGPoint) -> UIContextMenuConfiguration? {
		return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { _ -> UIMenu? in
			return self.makeContextMenu()
		}
	}
}
#endif
