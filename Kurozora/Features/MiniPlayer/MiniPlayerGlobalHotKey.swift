//
//  MiniPlayerGlobalHotKey.swift
//  Kurozora
//
//  Created by Khoren Katklian on 09/08/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

#if targetEnvironment(macCatalyst)
import Foundation
import Obfuscation
import UIKit

private typealias EventHandlerCallback = @convention(c) (UnsafeMutableRawPointer?, UnsafeMutableRawPointer?, UnsafeMutableRawPointer?) -> Int32
private typealias GetApplicationEventTargetFunction = @convention(c) () -> UnsafeMutableRawPointer?
private typealias InstallEventHandlerFunction = @convention(c) (UnsafeMutableRawPointer?, EventHandlerCallback?, UInt, UnsafeRawPointer?, UnsafeMutableRawPointer?, UnsafeMutablePointer<UnsafeMutableRawPointer?>?) -> Int32
private typealias RegisterEventHotKeyFunction = @convention(c) (UInt32, UInt32, UInt64, UnsafeMutableRawPointer?, UInt32, UnsafeMutablePointer<UnsafeMutableRawPointer?>?) -> Int32
private typealias RemoveEventHandlerFunction = @convention(c) (UnsafeMutableRawPointer?) -> Int32
private typealias UnregisterEventHotKeyFunction = @convention(c) (UnsafeMutableRawPointer?) -> Int32

/// Registers the system-wide shortcut that toggles the MiniPlayer.
///
/// Carbon's hot key API is the only route to a system-wide shortcut that never asks for
/// Accessibility access: the system reports this one combination and nothing else about the
/// keyboard. It is absent from the Mac Catalyst SDK, so its symbols resolve at runtime and every
/// step degrades to leaving the shortcut unregistered.
final class MiniPlayerGlobalHotKey {
	// MARK: - Properties
	/// The shared hot key registrar.
	static let shared = MiniPlayerGlobalHotKey()

	/// The `kVK_ANSI_M` virtual key code.
	private let keyCodeM: UInt32 = 0x2E

	/// The `cmdKey`, `shiftKey` and `optionKey` modifier mask.
	///
	/// Command is part of the combination on purpose: macOS 15 stopped reporting hot keys whose
	/// only modifiers are Option, or Option and Shift.
	private let modifierMask: UInt32 = 0x0100 | 0x0200 | 0x0800

	/// The `kEventClassKeyboard` four character code.
	private let keyboardEventClass: UInt32 = 0x6B65_7962

	/// The `kEventHotKeyPressed` event kind.
	private let hotKeyPressedEventKind: UInt32 = 5

	/// The four character code marking the registered hot key as this app's.
	private let hotKeySignature: UInt32 = 0x4B5A_4D50

	/// The identifier distinguishing this app's hot keys from one another.
	private let hotKeyIdentifier: UInt32 = 1

	/// The `noErr` result the event handler returns once it has taken the event.
	private static let noError: Int32 = 0

	/// The `EventHotKeyID` the hot key registers under.
	///
	/// The structure holds two adjacent 32-bit fields and reaches the callee in a single register,
	/// so it travels as the packed integer the calling convention would build anyway.
	private var packedHotKeyID: UInt64 {
		return UInt64(self.hotKeySignature) | (UInt64(self.hotKeyIdentifier) << 32)
	}

	/// The opened Carbon image the symbols resolve from.
	private var carbonHandle: UnsafeMutableRawPointer?

	/// The registered hot key.
	private var hotKeyReference: UnsafeMutableRawPointer?

	/// The installed event handler.
	private var eventHandlerReference: UnsafeMutableRawPointer?

	// MARK: - Initializers
	private init() {}

	// MARK: - Functions
	/// Registers the shortcut, resolving Carbon's hot key API at runtime.
	func register() {
		guard self.hotKeyReference == nil else { return }

		guard let carbonHandle = dlopen(#obfuscated("/System/Library/Frameworks/Carbon.framework/Carbon"), RTLD_LAZY) else { return }
		self.carbonHandle = carbonHandle

		guard
			let getApplicationEventTargetSymbol = dlsym(carbonHandle, #obfuscated("GetApplicationEventTarget")),
			let installEventHandlerSymbol = dlsym(carbonHandle, #obfuscated("InstallEventHandler")),
			let registerEventHotKeySymbol = dlsym(carbonHandle, #obfuscated("RegisterEventHotKey"))
		else { return }

		let getApplicationEventTarget = unsafeBitCast(getApplicationEventTargetSymbol, to: GetApplicationEventTargetFunction.self)
		let installEventHandler = unsafeBitCast(installEventHandlerSymbol, to: InstallEventHandlerFunction.self)
		let registerEventHotKey = unsafeBitCast(registerEventHotKeySymbol, to: RegisterEventHotKeyFunction.self)

		guard let eventTarget = getApplicationEventTarget() else { return }

		// An `EventTypeSpec` is two adjacent 32-bit fields, which the tuple matches.
		var eventTypeSpec: (UInt32, UInt32) = (self.keyboardEventClass, self.hotKeyPressedEventKind)
		var eventHandlerReference: UnsafeMutableRawPointer?
		let handlerStatus = withUnsafePointer(to: &eventTypeSpec) { eventTypeSpecPointer in
			return installEventHandler(eventTarget, { _, _, _ in
				MiniPlayerGlobalHotKey.shared.hotKeyPressed()
				return MiniPlayerGlobalHotKey.noError
			}, 1, UnsafeRawPointer(eventTypeSpecPointer), nil, &eventHandlerReference)
		}

		guard handlerStatus == Self.noError else { return }
		self.eventHandlerReference = eventHandlerReference

		var hotKeyReference: UnsafeMutableRawPointer?
		let hotKeyStatus = registerEventHotKey(self.keyCodeM, self.modifierMask, self.packedHotKeyID, eventTarget, 0, &hotKeyReference)

		guard hotKeyStatus == Self.noError else {
			self.removeEventHandler()
			return
		}
		self.hotKeyReference = hotKeyReference
	}

	/// Releases the shortcut and its event handler.
	func unregister() {
		if
			let carbonHandle = self.carbonHandle,
			let hotKeyReference = self.hotKeyReference,
			let unregisterEventHotKeySymbol = dlsym(carbonHandle, #obfuscated("UnregisterEventHotKey")) {
			let unregisterEventHotKey = unsafeBitCast(unregisterEventHotKeySymbol, to: UnregisterEventHotKeyFunction.self)
			_ = unregisterEventHotKey(hotKeyReference)
		}
		self.hotKeyReference = nil

		self.removeEventHandler()
	}

	/// Removes the installed event handler.
	private func removeEventHandler() {
		guard
			let carbonHandle = self.carbonHandle,
			let eventHandlerReference = self.eventHandlerReference,
			let removeEventHandlerSymbol = dlsym(carbonHandle, #obfuscated("RemoveEventHandler"))
		else { return }

		let removeEventHandler = unsafeBitCast(removeEventHandlerSymbol, to: RemoveEventHandlerFunction.self)
		_ = removeEventHandler(eventHandlerReference)
		self.eventHandlerReference = nil
	}

	/// Toggles the MiniPlayer in response to the shortcut.
	private func hotKeyPressed() {
		guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
		appDelegate.handleMiniPlayer(self)
	}
}
#endif
