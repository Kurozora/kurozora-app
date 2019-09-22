//
//  LoginFooterTableViewCell.swift
//  Kurozora
//
//  Created by Khoren Katklian on 22/09/2019.
//  Copyright © 2019 Kurozora. All rights reserved.
//

import UIKit

class OnboardingFooterTableViewCell: OnboardingBaseTableViewCell {
	// MARK: - IBOutlets
	@IBOutlet weak var forgotPasswordButton: UIButton! {
		didSet {
			forgotPasswordButton.theme_setTitleColor(KThemePicker.tintColor.rawValue, forState: .normal)
		}
	}
	@IBOutlet weak var orLabel: UILabel? {
		didSet {
			orLabel?.theme_textColor = KThemePicker.subTextColor.rawValue
		}
	}
	@IBOutlet weak var registerPasswordButton: UIButton! {
		didSet {
			registerPasswordButton.theme_setTitleColor(KThemePicker.tintColor.rawValue, forState: .normal)
		}
	}
	@IBOutlet weak var promotionalImageView: UIImageView?
	@IBOutlet weak var descriptionLabel: UILabel? {
		didSet {
			descriptionLabel?.theme_textColor = KThemePicker.textColor.rawValue
		}
	}
	@IBOutlet weak var legalButton: UIButton? {
		didSet {
			legalButton?.addTarget(self, action: #selector(legalButtonPressed), for: .touchUpInside)
			legalButton?.addTarget(self, action: #selector(legalButtonTouched), for: [.touchDown, .touchDragExit, .touchDragInside, .touchCancel])
		}
	}

	// MARK: - Functions
	/// Configure the cell with the given details.
	override func configureCell() {
		super.configureCell()

		if legalButton != nil {
			let paragraphStyle = NSMutableParagraphStyle()
			paragraphStyle.alignment = .center

			// Normal state
			let attributedString = NSMutableAttributedString(string: "Your Kurozra ID information is used to enable Kurozora services when you sign in. Kurozora services includes the library where you can keep track of the shows you are interested in. \n", attributes: [.foregroundColor: KThemePicker.subTextColor.colorValue, .paragraphStyle: paragraphStyle])
			attributedString.append(NSAttributedString(string: "See how your data is managed...", attributes: [.foregroundColor: KThemePicker.tintColor.colorValue, .paragraphStyle: paragraphStyle]))
			legalButton?.setAttributedTitle(attributedString, for: .normal)
		}
	}

	/**
		Modally presents the legal view controller.

		- Parameter sender: The object containing a reference to the button that initiated this action.
	*/
	@objc fileprivate func legalButtonPressed(_ sender: UIButton) {
		sender.alpha = 1.0

		if let legalViewController = LegalViewController.instantiateFromStoryboard() as? LegalViewController {
			let kNavigationController = KNavigationController(rootViewController: legalViewController)
			self.parentViewController?.present(kNavigationController)
		}
	}

	/**
		Changes the opacity of the button to match the default UIButton mechanic.

		- Parameter sender: The object containing a reference to the button that initiated this action.
	*/
	@objc fileprivate func legalButtonTouched(_ sender: UIButton) {
		if sender.state == .highlighted {
			sender.alpha = 0.5
		} else {
			sender.alpha = 1.0
		}
	}
}
