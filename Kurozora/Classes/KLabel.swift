//
//  KLabel.swift
//  Kurozora
//
//  Created by Khoren Katklian on 29/09/2018.
//  Copyright © 2018 Kurozora. All rights reserved.
//

import UIKit

class KLabel: UILabel {
	override var canBecomeFirstResponder: Bool {
		return true
	}

	// MARK: - Init
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
		addGestureRecognizer(
			UILongPressGestureRecognizer(
				target: self,
				action: #selector(handleLongPressed(_:))
			)
		)
	}

	@objc internal func handleLongPressed(_ gesture: UILongPressGestureRecognizer) {
		guard let gestureView = gesture.view, let superView = gestureView.superview else {
			return
		}

		let menuController = UIMenuController.shared

		guard !menuController.isMenuVisible, gestureView.canBecomeFirstResponder else {
			return
		}

		gestureView.becomeFirstResponder()

		menuController.menuItems = [
			UIMenuItem(
				title: "Copy",
				action: #selector(handleCopyAction(_:))
			)
		]

		if #available(iOS 13.0, macCatalyst 13.0, *) {
			menuController.showMenu(from: superView, rect: gestureView.frame)
		} else {
			menuController.setTargetRect(gestureView.frame, in: superView)
			menuController.setMenuVisible(true, animated: true)
		}
	}

	@objc internal func handleCopyAction(_ controller: UIMenuController) {
		UIPasteboard.general.string = text ?? ""
	}
}
