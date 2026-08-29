//
//  MacKeyDownMonitor.swift
//  Kurozora
//
//  Created by Khoren Katklian on 29/08/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

#if targetEnvironment(macCatalyst)
import Obfuscation
import UIKit

/// Handles a single key press ahead of the responder chain.
@MainActor
final class MacKeyDownMonitor {
	// MARK: - Properties
	/// The key code of the Escape key.
	static let escapeKeyCode = 53

	/// The key code to watch for.
	private let keyCode: Int

	/// The token identifying the installed event monitor.
	private var monitorToken: NSObject?

	/// The closure called when the key is pressed.
	private let pressHandler: () -> Void

	// MARK: - Initializers
	/// Creates a monitor for the given key.
	///
	/// - Parameters:
	///    - keyCode: The key code to watch for.
	///    - pressHandler: The closure called when the key is pressed.
	init(keyCode: Int, pressHandler: @escaping () -> Void) {
		self.keyCode = keyCode
		self.pressHandler = pressHandler
	}

	// MARK: - Functions
	/// Starts monitoring for the key.
	func start() {
		guard self.monitorToken == nil else { return }

		let selector = NSSelectorFromString(#obfuscated("addLocalMonitorForEventsMatchingMask:handler:"))
		guard
			let eventClass = NSClassFromString("NSEvent"),
			let method = class_getClassMethod(eventClass, selector)
		else {
			print("----- [Trailer] Key monitor could not reach the event stream")
			return
		}

		typealias EventHandler = @convention(block) (NSObject) -> NSObject?
		let handler: EventHandler = { [weak self] event in
			MainActor.assumeIsolated {
				guard
					let self = self,
					(event.value(forKey: #obfuscated("keyCode")) as? Int) == self.keyCode
				else { return event }

				self.pressHandler()

				// Returning nil keeps the press from the responder chain.
				return nil
			}
		}

		typealias Installer = @convention(c) (AnyClass, Selector, UInt64, EventHandler) -> NSObject?
		let install = unsafeBitCast(method_getImplementation(method), to: Installer.self)

		// NSEventMaskKeyDown.
		self.monitorToken = install(eventClass, selector, 1 << 10, handler)

		if self.monitorToken == nil {
			print("----- [Trailer] Key monitor failed to install")
		}
	}

	/// Stops monitoring for the key.
	func stop() {
		guard let monitorToken = self.monitorToken else { return }
		self.monitorToken = nil

		guard let eventClass = NSClassFromString("NSEvent") as? NSObject.Type else { return }

		eventClass.perform(NSSelectorFromString(#obfuscated("removeMonitor:")), with: monitorToken)
	}
}
#endif
