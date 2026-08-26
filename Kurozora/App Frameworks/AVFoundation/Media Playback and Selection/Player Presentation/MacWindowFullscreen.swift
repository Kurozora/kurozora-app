//
//  MacWindowFullscreen.swift
//  Kurozora
//
//  Created by Khoren Katklian on 27/08/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

#if targetEnvironment(macCatalyst)
import Obfuscation
import UIKit

/// Moves the app's window in and out of the Mac's own fullscreen.
@MainActor
final class MacWindowFullscreen {
	// MARK: - Functions
	/// A Boolean value indicating whether the window fills the screen.
	static var isFullscreen: Bool {
		guard
			let window = Self.keyWindow(),
			let styleMask = window.value(forKey: #obfuscated("styleMask")) as? UInt
		else { return false }

		// Fullscreen is the 1 << 14 bit of the window's style.
		return styleMask & (1 << 14) != 0
	}

	/// Fills the screen with the window, or hands the screen back.
	static func toggle() {
		guard let window = Self.keyWindow() else {
			print("----- [Trailer] The window's fullscreen state is out of reach")
			return
		}

		window.perform(NSSelectorFromString(#obfuscated("toggleFullScreen:")), with: nil)
	}

	/// Returns the window taking the reader's input.
	///
	/// - Returns: The window.
	private static func keyWindow() -> NSObject? {
		guard
			let applicationClass = NSClassFromString("NSApplication") as? NSObject.Type,
			let application = applicationClass.perform(NSSelectorFromString(#obfuscated("sharedApplication")))?.takeUnretainedValue() as? NSObject
		else { return nil }

		return application.value(forKey: #obfuscated("keyWindow")) as? NSObject
	}
}
#endif
