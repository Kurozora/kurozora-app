//
//  KNetworkManager.swift
//  Kurozora
//
//  Created by Khoren Katklian on 30/12/2018.
//  Copyright © 2018 Kurozora. All rights reserved.
//

import UIKit
import Reachability

class KNetworkManager: NSObject {
	/// An instance object of `Reachability` to monitor the network status.
	var reachability: Reachability!

	/// Shared instance of the network manager.
	static let shared: KNetworkManager = KNetworkManager()

	override private init() {
		super.init()

		// Initialise reachability
		self.reachability = try? Reachability()

		// Register an observer for the network status
		NotificationCenter.default.addObserver(self, selector: #selector(self.networkStatusChanged(_:)), name: .reachabilityChanged, object: self.reachability)

		do {
			// Start the network status notifier
			try self.reachability.startNotifier()
		} catch {
			print("Unable to start notifier")
		}
	}

	/// A method to handle the network status change.
	@objc func networkStatusChanged(_ notification: Notification) {
		// Do something globally here!
	}

	/// Stop the network status notifier.
	static func stopNotifier() {
		do {
			try KNetworkManager.self.shared.reachability.startNotifier()
		} catch {
			print("Error stopping notifier")
		}
	}

	/// A closure to execute when the network is reachable.
	static func isReachable(completed: @escaping (KNetworkManager) -> Void) {
		guard self.shared.reachability.connection != .unavailable else { return }
		completed(self.shared)
	}

	/// A closure to execute when the network is unreachable
	static func isUnreachable(completed: @escaping (KNetworkManager) -> Void) {
		guard self.shared.reachability.connection == .unavailable else { return }
		completed(self.shared)
	}

	/// A closure to execute when the network is reachable via WWAN/Cellular.
	static func isReachableViaWWAN(completed: @escaping (KNetworkManager) -> Void) {
		guard self.shared.reachability.connection == .cellular else { return }
		completed(self.shared)
	}
}
