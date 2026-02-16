//
//  OrientationManager.swift
//  Kurozora
//
//  Created by Khoren Katklian on 08/09/2025.
//  Copyright © 2025 Kurozora. All rights reserved.
//

import CoreMotion
import UIKit

enum OrientationDownEdge {
	case top, bottom, left, right
}

protocol OrientationManagerDelegate: AnyObject {
	func orientationManager(_ manager: OrientationManager, didDetect deviceOrientation: UIInterfaceOrientationMask, downEdge: OrientationDownEdge)
}

final class OrientationManager: NSObject {
	weak var delegate: OrientationManagerDelegate?

	private let motion = CMMotionManager()
	private(set) var lastDetectedOrientation: UIInterfaceOrientationMask = .portrait
	private(set) var lastDownEdge: OrientationDownEdge = .bottom

	func startMonitoring(updateInterval: TimeInterval = 0.18) {
		guard UserSettings.isPortraitLockBuddyEnabled else { return }
		guard self.motion.isDeviceMotionAvailable else { return }

		self.motion.deviceMotionUpdateInterval = updateInterval
		self.motion.startDeviceMotionUpdates(to: .main) { [weak self] motionData, _ in
			guard let self = self, let grav = motionData?.gravity else { return }
			let gx = grav.x
			let gy = grav.y

			// Ignore flat-device noise (e.g. lying on a table)
			guard max(abs(gx), abs(gy)) > 0.3 else { return }

			// Determine which axis is dominant
			if abs(gx) > abs(gy) {
				// gravity mostly along device X -> landscape
				if gx > 0 {
					// Right side down, top points left → landscapeLeft
					self.lastDetectedOrientation = .landscapeLeft
					self.lastDownEdge = .right
				} else {
					// Left side down, top points right → landscapeRight
					self.lastDetectedOrientation = .landscapeRight
					self.lastDownEdge = .left
				}
			} else {
				// gravity mostly along device Y -> portrait/upsideDown
				if gy > 0 {
					self.lastDetectedOrientation = .portraitUpsideDown
					self.lastDownEdge = .top
				} else {
					self.lastDetectedOrientation = .portrait
					self.lastDownEdge = .bottom
				}
			}

			self.delegate?.orientationManager(self, didDetect: self.lastDetectedOrientation, downEdge: self.lastDownEdge)
		}
	}

	func stopMonitoring() {
		self.motion.stopDeviceMotionUpdates()
	}
}
