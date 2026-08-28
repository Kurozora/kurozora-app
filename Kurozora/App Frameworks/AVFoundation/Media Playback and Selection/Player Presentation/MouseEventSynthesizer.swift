//
//  MouseEventSynthesizer.swift
//  Kurozora
//
//  Created by Khoren Katklian on 27/08/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

#if targetEnvironment(macCatalyst)
import Obfuscation
import UIKit

/// Presses the mouse at a chosen point in the app's window, without moving the pointer.
@MainActor
final class MouseEventSynthesizer {
	// MARK: - Properties
	/// The number stamped on the next event, counted from a range no real event occupies.
	private static var nextEventNumber = 880_000

	// MARK: - Functions
	/// Clicks at the given point.
	///
	/// - Parameters:
	///    - point: The point to click, in the window's coordinates.
	///    - window: The window the point is measured in.
	///
	/// - Returns: `true` if the click was sent.
	@discardableResult
	static func click(at point: CGPoint, in window: UIWindow) -> Bool {
		guard
			let applicationClass = NSClassFromString("NSApplication") as? NSObject.Type,
			let application = applicationClass.perform(NSSelectorFromString(#obfuscated("sharedApplication")))?.takeUnretainedValue() as? NSObject,
			let appKitWindow = application.value(forKey: #obfuscated("keyWindow")) as? NSObject,
			let contentView = appKitWindow.value(forKey: #obfuscated("contentView")) as? NSObject,
			let windowNumber = appKitWindow.value(forKey: #obfuscated("windowNumber")) as? Int,
			let contentFrameValue = contentView.value(forKey: "frame") as? NSValue,
			let windowFrameValue = appKitWindow.value(forKey: "frame") as? NSValue
		else {
			print("----- [Trailer] Mouse press could not reach the window")
			return false
		}

		var contentFrame = CGRect.zero
		contentFrameValue.getValue(&contentFrame, size: MemoryLayout<CGRect>.size)
		var windowFrame = CGRect.zero
		windowFrameValue.getValue(&windowFrame, size: MemoryLayout<CGRect>.size)

		// Top-left points become bottom-left window coordinates, measured against whichever frame
		// the UIKit window actually spans: the content view, or the whole window when the content
		// runs under the titlebar.
		let spansFullWindow = abs(window.bounds.height - windowFrame.height) < abs(window.bounds.height - contentFrame.height)
		let location: CGPoint

		if spansFullWindow {
			location = CGPoint(x: point.x, y: windowFrame.height - point.y)
		} else {
			location = CGPoint(x: contentFrame.minX + point.x, y: contentFrame.minY + (contentFrame.height - point.y))
		}

		let makerSelector = NSSelectorFromString(#obfuscated("mouseEventWithType:location:modifierFlags:timestamp:windowNumber:context:eventNumber:clickCount:pressure:"))
		guard
			let eventClass = NSClassFromString("NSEvent"),
			let makerMethod = class_getClassMethod(eventClass, makerSelector)
		else {
			print("----- [Trailer] Mouse press could not build its events")
			return false
		}

		typealias EventMaker = @convention(c) (AnyClass, Selector, UInt, CGPoint, UInt, TimeInterval, Int, AnyObject?, Int, Int, Float) -> NSObject?
		let makeEvent = unsafeBitCast(method_getImplementation(makerMethod), to: EventMaker.self)

		// The pointer walks to the spot first, or the press reads as a stray continuation and drops.
		// Types 5, 1 and 2: the pointer moving, the left button going down and coming back up.
		let timestamp = ProcessInfo.processInfo.systemUptime
		guard
			let movedEvent = makeEvent(eventClass, makerSelector, 5, location, 0, timestamp, windowNumber, nil, Self.takeEventNumber(), 0, 0.0),
			let downEvent = makeEvent(eventClass, makerSelector, 1, location, 0, timestamp + 0.01, windowNumber, nil, Self.takeEventNumber(), 1, 1.0),
			let upEvent = makeEvent(eventClass, makerSelector, 2, location, 0, timestamp + 0.05, windowNumber, nil, Self.takeEventNumber(), 1, 0.0)
		else {
			print("----- [Trailer] Mouse press could not build its events")
			return false
		}

		let sendSelector = NSSelectorFromString(#obfuscated("sendEvent:"))
		_ = application.perform(sendSelector, with: movedEvent)
		_ = application.perform(sendSelector, with: downEvent)
		_ = application.perform(sendSelector, with: upEvent)
		return true
	}

	/// Returns a fresh event number.
	private static func takeEventNumber() -> Int {
		self.nextEventNumber += 1
		return self.nextEventNumber
	}
}
#endif
