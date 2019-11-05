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
	var reachability: Reachability!

	// Create a singleton instance
	static let shared: KNetworkManager = { return KNetworkManager() }()

	override init() {
		super.init()

		// Initialise reachability
		reachability = Reachability()!

		// Register an observer for the network status
		NotificationCenter.default.addObserver(
			self,
			selector: #selector(networkStatusChanged(_:)),
			name: .reachabilityChanged,
			object: reachability
		)

		do {
			// Start the network status notifier
			try reachability.startNotifier()
		} catch {
			print("Unable to start notifier")
		}
	}

	@objc func networkStatusChanged(_ notification: Notification) {
		// Do something globally here!
	}

	static func stopNotifier() {
		do {
			// Stop the network status notifier
			try (KNetworkManager.shared.reachability).startNotifier()
		} catch {
			print("Error stopping notifier")
		}
	}

	// Network is reachable
	static func isReachable(completed: @escaping (KNetworkManager) -> Void) {
		if (shared.reachability).connection != .none {
			completed(shared)
		}
	}

	// Network is unreachable
	static func isUnreachable(completed: @escaping (KNetworkManager) -> Void) {
		if (shared.reachability).connection == .none {
			completed(shared)
		}
	}

	// Network is reachable via WWAN/Cellular
	static func isReachableViaWWAN(completed: @escaping (KNetworkManager) -> Void) {
		if (shared.reachability).connection == .cellular {
			completed(shared)
		}
	}
}
