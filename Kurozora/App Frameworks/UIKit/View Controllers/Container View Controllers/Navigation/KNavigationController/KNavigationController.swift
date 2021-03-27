//
//  KNavigationController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 24/07/2018.
//  Copyright © 2018 Kurozora. All rights reserved.
//

import UIKit
import SwiftTheme

class KNavigationController: UINavigationController {
	// MARK: - Properties
	override var preferredStatusBarStyle: UIStatusBarStyle {
		return KThemePicker.statusBarStyle.statusBarValue
	}
	private lazy var backwardGestureRecognizer = UIPanGestureRecognizer()
	private lazy var forwardGestureRecognizer = UIScreenEdgePanGestureRecognizer()
	private lazy var nextViewController: [UIViewController] = []

	// MARK: - View
    override func viewDidLoad() {
        super.viewDidLoad()
		NotificationCenter.default.addObserver(self, selector: #selector(updateNormalStyle), name: .ThemeUpdateNotification, object: nil)
		toggleStyle(.normal)
		setupToolbarStyle()
		#if !targetEnvironment(macCatalyst)
		setupBackwardPanGesture()
		setupForwardPanGesture()
		#endif
		self.nextViewController = viewControllers
    }

	// MARK: - Functions
	/// The shared settings used to initialize tab bar view.
	private func sharedInit () {
		// Configure theme
		self.toggleStyle(.normal)
		self.setupToolbarStyle()

		// configure delegates
		self.delegate = self
	}

	/**
		Used to update the theme of the view.

		- Parameter notification: An object containing information broadcast to registered observers that bridges to Notification.
	*/
	@objc func updateTheme(_ notification: NSNotification) {
		self.sharedInit()
	}

	/**
		Toggles between navigation bar styles.

		- Parameter style: The KNavigationStyle to be used on the navigation bar.
	*/
	func toggleStyle(_ style: KNavigationStyle) {
		self.navigationBar.isTranslucent = true
		self.navigationBar.backgroundColor = .clear
		self.navigationBar.barStyle = .default

		switch style {
		case .normal:
			let appearance = UINavigationBarAppearance()
			#if targetEnvironment(macCatalyst)
//			appearance.backgroundColor = KThemePicker.barTintColor.colorValue.withAlphaComponent(0.4)
			#else
			appearance.theme_backgroundColor = KThemePicker.barTintColor.rawValue
			#endif
			appearance.theme_titleTextAttributes = ThemeStringAttributesPicker(keyPath: KThemePicker.barTitleTextColor.stringValue) { value -> [NSAttributedString.Key: Any]? in
				guard let rgba = value as? String else { return nil }
				let color = UIColor(rgba: rgba)
				let titleTextAttributes = [NSAttributedString.Key.foregroundColor: color]

				return titleTextAttributes
			}
			appearance.theme_largeTitleTextAttributes = ThemeStringAttributesPicker(keyPath: KThemePicker.barTitleTextColor.stringValue) { value -> [NSAttributedString.Key: Any]? in
				guard let rgba = value as? String else { return nil }
				let color = UIColor(rgba: rgba)
				let titleTextAttributes = [NSAttributedString.Key.foregroundColor: color]

				return titleTextAttributes
			}

			self.navigationBar.standardAppearance = appearance
			self.navigationBar.compactAppearance = appearance
			self.navigationBar.prefersLargeTitles = UserSettings.largeTitlesEnabled
		case .blurred:
			#if !targetEnvironment(macCatalyst)
			self.navigationBar.barStyle = .black
			self.navigationBar.backgroundColor = .clear
			self.navigationBar.tintColor = nil
			self.navigationBar.barTintColor = nil
			#endif
		}
	}

	/// Setup toolbar style with the currently used theme.
	func setupToolbarStyle() {
		self.toolbar.backgroundColor = .clear
		self.toolbar.barStyle = .default
		self.toolbar.theme_tintColor = KThemePicker.tintColor.rawValue
		self.toolbar.theme_barTintColor = KThemePicker.barTintColor.rawValue
	}

	/// Connectes the custom backward pan gesture with the default interactive pop gesture recognizer.
	private func setupBackwardPanGesture() {
		guard let interactivePopGestureRecognizer = interactivePopGestureRecognizer, let targets = interactivePopGestureRecognizer.value(forKey: "targets") else { return }

		backwardGestureRecognizer.setValue(targets, forKey: "targets")
		backwardGestureRecognizer.delegate = self
		view.addGestureRecognizer(backwardGestureRecognizer)
	}

	/// Sets up the custom forward pan gesture to forward segue if possible.
	private func setupForwardPanGesture() {
		forwardGestureRecognizer.edges = .right
		forwardGestureRecognizer.delegate = self
		forwardGestureRecognizer.addTarget(self, action: #selector(screenEdgeSwiped(_:)))
		view.addGestureRecognizer(forwardGestureRecognizer)
	}

	/**
		Performs the screen edge swipe action.

		- Parameter recognizer: The discrete gesture recognizer that interprets panning gestures that start near an edge of the screen.
	*/
	@objc func screenEdgeSwiped(_ recognizer: UIScreenEdgePanGestureRecognizer) {
		if !nextViewController.isEmpty {
			switch recognizer.state {
			case .possible: break
			case .began: break
			case .changed: break
			case .ended:
				if !nextViewController.isEmpty {
					if nextViewController.first == visibleViewController {
						nextViewController.removeFirst()
					}

					self.pushViewController(nextViewController.first!, animated: true)
				}
			case .cancelled: break
			case .failed: break
			@unknown default: break
			}
		}
	}
}

// MARK: - UINavigationControllerDelegate
extension KNavigationController: UINavigationControllerDelegate {
	func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
		if !nextViewController.contains(viewController) {
			nextViewController.prepend(viewController)
		}
	}
}

// MARK: - UIGestureRecognizerDelegate
extension KNavigationController: UIGestureRecognizerDelegate { }
