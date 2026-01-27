//
//  OnboardingFooterTableViewCell.swift
//  Kurozora
//
//  Created by Khoren Katklian on 22/09/2019.
//  Copyright © 2019 Kurozora. All rights reserved.
//

import UIKit

protocol OnboardingFooterTableViewCellDelegate: AnyObject {
	/// Notifies the delegate that the legal button was pressed.
	func onboardingFooterTableViewCell(_ cell: OnboardingFooterTableViewCell, didPressLegalButton sender: UIButton)
}

extension OnboardingFooterTableViewCellDelegate where Self: UIViewController {
	func onboardingFooterTableViewCell(_ cell: OnboardingFooterTableViewCell, didPressLegalButton sender: UIButton) {
		let legalViewController = LegalViewController()
		let kNavigationController = KNavigationController(rootViewController: legalViewController)
		self.present(kNavigationController, animated: true)
	}
}

class OnboardingFooterTableViewCell: OnboardingBaseTableViewCell {
	// MARK: - IBOutlets
	@IBOutlet weak var legalButton: UIButton! {
		didSet {
			self.legalButton.addTarget(self, action: #selector(self.legalButtonPressed), for: .touchUpInside)
			self.legalButton.addTarget(self, action: #selector(self.legalButtonTouched), for: [.touchDown, .touchDragExit, .touchDragInside, .touchCancel])
		}
	}

	// MARK: - Properties
	weak var delegate: OnboardingFooterTableViewCellDelegate?

	// MARK: - Functions
	/// Configure the cell with the given details.
	override func configureCell() {
		let paragraphStyle = NSMutableParagraphStyle()
		paragraphStyle.alignment = .center

		// Normal state
		let attributedString = NSMutableAttributedString(string: "Your Kurozora Account information is used to enable Kurozora services when you sign in. Kurozora services includes the library where you can keep track of the shows you are interested in. \n", attributes: [.foregroundColor: KThemePicker.subTextColor.colorValue, .paragraphStyle: paragraphStyle])
		attributedString.append(NSAttributedString(string: "See how your data is managed...", attributes: [.foregroundColor: KThemePicker.tintColor.colorValue, .paragraphStyle: paragraphStyle]))
		self.legalButton?.setAttributedTitle(attributedString, for: .normal)
	}

	/// Modally presents the legal view controller.
	///
	/// - Parameter sender: The object containing a reference to the button that initiated this action.
	@objc fileprivate func legalButtonPressed(_ sender: UIButton) {
		sender.alpha = 1.0

		self.delegate?.onboardingFooterTableViewCell(self, didPressLegalButton: sender)
	}

	/// Changes the opacity of the button to match the default UIButton mechanic.
	///
	/// - Parameter sender: The object containing a reference to the button that initiated this action.
	@objc fileprivate func legalButtonTouched(_ sender: UIButton) {
		if sender.state == .highlighted {
			sender.alpha = 0.5
		} else {
			sender.alpha = 1.0
		}
	}
}
