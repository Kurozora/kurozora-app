//
//  KNavigationController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 24/07/2018.
//  Copyright © 2018 Kurozora. All rights reserved.
//

import SwiftTheme
import UIKit

class KNavigationController: UINavigationController {
	// MARK: - View
	override func viewDidLoad() {
		super.viewDidLoad()

		NotificationCenter.default.addObserver(self, selector: #selector(self.updateTheme(_:)), name: .ThemeUpdateNotification, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(self.updatePrefersLargeTitles(_:)), name: .KSPrefersLargeTitlesDidChange, object: nil)

		self.sharedInit()

		if #available(iOS 17.0, macCatalyst 17.0, *) {
			self.registerForTraitChanges([UITraitHorizontalSizeClass.self], action: #selector(self.handleHorizontalSizeClassChange))
		}
	}

	override func didMove(toParent parent: UIViewController?) {
		super.didMove(toParent: parent)
		self.configureRootNavigationItemStyle()
	}

	// MARK: - Functions
	/// The shared settings used to initialize tab bar view.
	private func sharedInit() {
		// Configure theme
		self.configureNavigationBarStyle()
		self.configureToolbarStyle()
	}

	/// Configures the root navigation item style based on the current horizontal size class and user preferences.
	private func configureRootNavigationItemStyle() {
		guard
			#available(iOS 18.0, macCatalyst 18.0, *),
			self.tabBarController != nil,
			let rootNavigationItem = self.viewControllers.first?.navigationItem
		else { return }

		if self.traitCollection.horizontalSizeClass == .regular {
			rootNavigationItem.style = .browser
			rootNavigationItem.largeTitleDisplayMode = UserSettings.largeTitlesEnabled ? .always : .automatic
		} else {
			rootNavigationItem.style = .navigator
			rootNavigationItem.largeTitleDisplayMode = .automatic
		}
	}

	@objc private func handleHorizontalSizeClassChange() {
		self.configureRootNavigationItemStyle()
	}

	/// Used to update the large title preference.
	///
	/// - Parameter notification: An object containing information broadcast to registered observers that bridges to Notification.
	@objc func updatePrefersLargeTitles(_ notification: NSNotification) {
		self.navigationBar.prefersLargeTitles = UserSettings.largeTitlesEnabled
		self.configureRootNavigationItemStyle()
	}

	/// Used to update the theme of the view.
	///
	/// - Parameter notification: An object containing information broadcast to registered observers that bridges to Notification.
	@objc func updateTheme(_ notification: NSNotification) {
		self.configureNavigationBarStyle()
	}

	/// Configure the navigation bar style with the currently used theme.
	func configureNavigationBarStyle() {
		if #available(iOS 16.0, macCatalyst 16.0, *) {
			self.navigationBar.preferredBehavioralStyle = .pad
		}

		if #available(iOS 26.0, macOS 26.0, tvOS 26.0, visionOS 26.0, watchOS 26.0, *) {
			let appearance = UINavigationBarAppearance()
			self.navigationBar.theme_standardAppearance = ThemeNavigationBarAppearancePicker(appearances: appearance)
			self.navigationBar.theme_compactAppearance = ThemeNavigationBarAppearancePicker(appearances: appearance)
			self.navigationBar.theme_scrollEdgeAppearance = ThemeNavigationBarAppearancePicker(appearances: appearance)
		} else {
			self.navigationBar.isTranslucent = true
			self.navigationBar.backgroundColor = .clear
			self.navigationBar.barStyle = .default
			self.navigationBar.theme_tintColor = KThemePicker.tintColor.rawValue

			let appearance = UINavigationBarAppearance()
			appearance.theme_backgroundColor = KThemePicker.barTintColor.rawValue
			appearance.theme_titleTextAttributes = ThemeStringAttributesPicker(keyPath: KThemePicker.barTitleTextColor.stringValue) { value -> [NSAttributedString.Key: Any]? in
				guard let rgba = value as? String else { return nil }
				let color = UIColor(rgba: rgba)
				return [NSAttributedString.Key.foregroundColor: color]
			}
			appearance.theme_largeTitleTextAttributes = ThemeStringAttributesPicker(keyPath: KThemePicker.barTitleTextColor.stringValue) { value -> [NSAttributedString.Key: Any]? in
				guard let rgba = value as? String else { return nil }
				let color = UIColor(rgba: rgba)
				return [NSAttributedString.Key.foregroundColor: color]
			}

			self.navigationBar.theme_standardAppearance = ThemeNavigationBarAppearancePicker(appearances: appearance)
			self.navigationBar.theme_compactAppearance = ThemeNavigationBarAppearancePicker(appearances: appearance)
		}

		self.navigationBar.prefersLargeTitles = UserSettings.largeTitlesEnabled
	}

	/// Configure the toolbar style with the currently used theme.
	func configureToolbarStyle() {
		self.toolbar.theme_tintColor = KThemePicker.tintColor.rawValue

		if #available(iOS 26.0, macOS 26.0, tvOS 26.0, visionOS 26.0, watchOS 26.0, *) {
			// Let the system render the default variable-blur backdrop.
			return
		}

		self.toolbar.isTranslucent = true
		self.toolbar.theme_barTintColor = KThemePicker.barTintColor.rawValue
		self.toolbar.backgroundColor = .clear
		self.toolbar.barStyle = .default
	}
}
