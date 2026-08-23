//
//  FullScreenTitlebarBridge.swift
//  Kurozora
//
//  Created by Khoren Katklian on 24/08/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import Obfuscation
import UIKit

/// Clears the backgrounds behind a window's titlebar while it is in full screen.
@MainActor
final class FullScreenTitlebarBridge {
	// MARK: - Properties
	/// The shared instance of `FullScreenTitlebarBridge`.
	static let shared = FullScreenTitlebarBridge()

	/// The notification AppKit posts after a window enters full screen.
	private let windowDidEnterFullScreenNotification = Notification.Name(#obfuscated("NSWindowDidEnterFullScreenNotification"))

	/// The notification AppKit posts after a window leaves full screen.
	private let windowDidExitFullScreenNotification = Notification.Name(#obfuscated("NSWindowDidExitFullScreenNotification"))

	/// The `NSWindowStyleMaskFullScreen` bit.
	private let fullScreenMask: UInt = 1 << 14

	/// Whether full screen transitions are already being observed.
	private var isObserving = false

	// MARK: - Initializers
	private init() { }

	// MARK: - Functions
	/// Starts observing full screen transitions.
	func activate() {
		guard !self.isObserving else { return }

		self.isObserving = true
		NotificationCenter.default.addObserver(self, selector: #selector(self.windowDidEnterFullScreen), name: self.windowDidEnterFullScreenNotification, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(self.windowDidExitFullScreen), name: self.windowDidExitFullScreenNotification, object: nil)
	}

	/// Clears the titlebar backgrounds of every full screen window.
	@objc private func windowDidEnterFullScreen() {
		self.setTitlebarBackgroundAlpha(0.0)
	}

	/// Restores the titlebar backgrounds of every full screen window.
	@objc private func windowDidExitFullScreen() {
		self.setTitlebarBackgroundAlpha(1.0)
	}

	/// Applies the given opacity to the backgrounds behind every full screen titlebar.
	///
	/// - Parameter alpha: The opacity to apply.
	private func setTitlebarBackgroundAlpha(_ alpha: Double) {
		guard
			let applicationClass = NSClassFromString(#obfuscated("NSApplication")) as? NSObject.Type,
			let application = applicationClass.perform(NSSelectorFromString(#obfuscated("sharedApplication")))?.takeUnretainedValue() as? NSObject,
			let windows = application.value(forKey: #obfuscated("windows")) as? [NSObject],
			let toolbarWindowClass = NSClassFromString(#obfuscated("NSToolbarFullScreenWindow")),
			let containerClass = NSClassFromString(#obfuscated("NSTitlebarContainerView")),
			let backgroundClass = NSClassFromString(#obfuscated("NSTitlebarBackgroundView"))
		else { return }

		for window in windows {
			let styleMask = window.value(forKey: #obfuscated("styleMask")) as? UInt ?? 0

			// AppKit lends the titlebar to a window of its own while it is revealed, and takes it back once it hides.
			let hostsTitlebar = window.isKind(of: toolbarWindowClass) || (styleMask & self.fullScreenMask) != 0

			guard
				hostsTitlebar,
				let contentView = window.value(forKey: #obfuscated("contentView")) as? NSObject,
				let frameView = contentView.value(forKey: #obfuscated("superview")) as? NSObject,
				let container = Self.descendant(of: frameView, ofClass: containerClass, depth: 0)
			else { continue }

			self.setBackgroundAlpha(alpha, in: container, ofClass: backgroundClass)
		}
	}

	/// Applies the given opacity to the backgrounds inside the given titlebar container.
	///
	/// - Parameters:
	///    - alpha: The opacity to apply.
	///    - container: The titlebar container to search.
	///    - backgroundClass: The class the backgrounds belong to.
	private func setBackgroundAlpha(_ alpha: Double, in container: NSObject, ofClass backgroundClass: AnyClass) {
		let subviewsKey = #obfuscated("subviews")

		guard
			let titlebarView = (container.value(forKey: subviewsKey) as? [NSObject])?.first,
			let titlebarSubviews = titlebarView.value(forKey: subviewsKey) as? [NSObject]
		else { return }

		for background in titlebarSubviews where background.isKind(of: backgroundClass) {
			// AppKit drives `hidden` itself for the titlebar slide; opacity survives it.
			background.setValue(alpha, forKey: #obfuscated("alphaValue"))
		}
	}

	/// Returns the first descendant of the given view belonging to the given class.
	///
	/// - Parameters:
	///    - view: The view to search.
	///    - targetClass: The class to match.
	///    - depth: The depth the search has reached.
	///
	/// - Returns: The matching descendant.
	private static func descendant(of view: NSObject, ofClass targetClass: AnyClass, depth: Int) -> NSObject? {
		guard depth < 3, let subviews = view.value(forKey: #obfuscated("subviews")) as? [NSObject] else { return nil }

		for subview in subviews {
			if subview.isKind(of: targetClass) {
				return subview
			}

			if let match = Self.descendant(of: subview, ofClass: targetClass, depth: depth + 1) {
				return match
			}
		}

		return nil
	}
}
