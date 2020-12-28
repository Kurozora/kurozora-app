//
//  KCosmosView.swift
//  Kurozora
//
//  Created by Khoren Katklian on 13/12/2020.
//  Copyright © 2020 Kurozora. All rights reserved.
//

import UIKit
import Cosmos

/**
	A themed star rating view that can be used to show ratings for products. One can select stars by tapping on them when updateOnTouch settings is true. An optional text can be supplied that is shown on the right side.
*/
@IBDesignable
class KCosmosView: CosmosView {
	// MARK: - Initializers
	override func awakeFromNib() {
		super.awakeFromNib()
		self.sharedInit()
	}

	override init(frame: CGRect, settings: CosmosSettings) {
		super.init(frame: frame, settings: settings)
		self.sharedInit()
	}

	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		self.sharedInit()
	}

	// MARK: - Functions
	/// The shared settings used to initialize cosmos view.
	fileprivate func sharedInit() {
		NotificationCenter.default.addObserver(self, selector: #selector(updateTheme(_:)), name: .ThemeUpdateNotification, object: nil)

		self.rating = 0.0
		self.settings.starMargin = 3.0
		self.settings.totalStars = 5
		self.settings.emptyBorderWidth = 1.0
		self.settings.filledBorderWidth = 1.0
		self.settings.fillMode = .half

		self.configureTheme()
	}

	/// Configures the theme of the view.
	fileprivate func configureTheme() {
		self.settings.emptyBorderColor = KThemePicker.tintColor.colorValue
		self.settings.filledColor = KThemePicker.tintColor.colorValue
		self.settings.filledBorderColor = KThemePicker.tintColor.colorValue
	}

	/**
		Used to update the theme of the view.

		- Parameter notification: An object containing information broadcast to registered observers that bridges to Notification.
	*/
	@objc fileprivate func updateTheme(_ notification: NSNotification) {
		self.configureTheme()
	}
}
