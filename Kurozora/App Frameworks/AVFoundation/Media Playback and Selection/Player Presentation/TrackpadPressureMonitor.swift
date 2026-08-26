//
//  TrackpadPressureMonitor.swift
//  Kurozora
//
//  Created by Khoren Katklian on 27/08/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

#if targetEnvironment(macCatalyst)
import Obfuscation
import UIKit

/// Follows how hard the trackpad is pressed while a control is held.
@MainActor
final class TrackpadPressureMonitor {
	// MARK: - Properties
	/// The greatest depth a press can reach: the second stage, fully pressed.
	private static let maximumDepth = 2.0

	/// The token identifying the installed event monitor.
	private var monitorToken: NSObject?

	/// The depth the hold began at, which readings are measured from.
	private var baselineDepth: Double?

	/// The closure told how far the press has travelled, from `0` at the starting depth to `1` at
	/// the deepest the trackpad reads.
	private let progressionHandler: (Double) -> Void

	// MARK: - Initializers
	/// Creates a monitor reporting to the given closure.
	///
	/// - Parameter progressionHandler: The closure told how far the press has travelled.
	init(progressionHandler: @escaping (Double) -> Void) {
		self.progressionHandler = progressionHandler
	}

	// MARK: - Functions
	/// Begins following the trackpad's pressure.
	func start() {
		guard self.monitorToken == nil else { return }
		self.baselineDepth = nil

		let selector = NSSelectorFromString(#obfuscated("addLocalMonitorForEventsMatchingMask:handler:"))
		guard
			let eventClass = NSClassFromString("NSEvent"),
			let method = class_getClassMethod(eventClass, selector)
		else {
			print("----- [Trailer] Trackpad pressure monitor could not reach the event stream")
			return
		}

		typealias EventHandler = @convention(block) (NSObject) -> NSObject?
		let handler: EventHandler = { [weak self] event in
			MainActor.assumeIsolated {
				self?.read(event)
			}
			return event
		}

		typealias Installer = @convention(c) (AnyClass, Selector, UInt64, EventHandler) -> NSObject?
		let install = unsafeBitCast(method_getImplementation(method), to: Installer.self)

		// The mask for pressure-change events, which UIKit has no name for.
		self.monitorToken = install(eventClass, selector, 1 << 34, handler)

		if self.monitorToken == nil {
			print("----- [Trailer] Trackpad pressure monitor failed to install")
		}
	}

	/// Stops following the trackpad's pressure.
	func stop() {
		guard let monitorToken = self.monitorToken else { return }
		self.monitorToken = nil
		self.baselineDepth = nil

		guard let eventClass = NSClassFromString("NSEvent") as? NSObject.Type else { return }
		eventClass.perform(NSSelectorFromString(#obfuscated("removeMonitor:")), with: monitorToken)
	}

	/// Taps the trackpad the way the system marks a force-click level change.
	static func performLevelChangeHaptic() {
		let selector = NSSelectorFromString(#obfuscated("performFeedbackPattern:performanceTime:"))
		guard
			let managerClass = NSClassFromString("NSHapticFeedbackManager") as? NSObject.Type,
			let performer = managerClass.perform(NSSelectorFromString(#obfuscated("defaultPerformer")))?.takeUnretainedValue() as? NSObject,
			performer.responds(to: selector)
		else { return }

		typealias Performer = @convention(c) (NSObject, Selector, Int, Int) -> Void
		let perform = unsafeBitCast(performer.method(for: selector), to: Performer.self)

		// The level-change pattern, performed now.
		perform(performer, selector, 2, 1)
	}

	/// Reads one pressure event into a progression.
	///
	/// - Parameter event: The event carrying the trackpad's pressure.
	private func read(_ event: NSObject) {
		guard
			let stage = event.value(forKey: #obfuscated("stage")) as? Int,
			let pressure = event.value(forKey: #obfuscated("pressure")) as? Double
		else { return }

		let depth = Double(max(0, stage - 1)) + min(max(0.0, pressure), 1.0)

		// The first reading anchors the scale.
		let baseline: Double
		if let anchoredDepth = self.baselineDepth {
			baseline = anchoredDepth
		} else {
			baseline = depth
			print("----- [Trailer] Trackpad pressure monitor anchored at depth \(depth)")
		}
		self.baselineDepth = baseline

		let headroom = Self.maximumDepth - baseline
		guard headroom > 0.01 else { return }

		self.progressionHandler(min(max(0.0, (depth - baseline) / headroom), 1.0))
	}
}
#endif
