//
//  OrientationManager.swift
//  Kurozora
//
//  Created by Khoren Katklian on 08/09/2025.
//  Copyright © 2025 Kurozora. All rights reserved.
//

import CoreMotion
import UIKit

protocol OrientationManagerDelegate: AnyObject {
	func orientationManager(_ manager: OrientationManager, didDetect deviceOrientation: UIInterfaceOrientationMask)
}

final class OrientationManager: NSObject {
	// MARK: - Properties
	weak var delegate: OrientationManagerDelegate?

	private let motion = CMMotionManager()
	private var lastDetectedOrientation: UIInterfaceOrientationMask = .portrait

	// MARK: - Functions
	func startMonitoring(updateInterval: TimeInterval = 0.18) {
		guard UserSettings.isPortraitLockBuddyEnabled else { return }
		guard self.motion.isDeviceMotionAvailable else { return }

		self.motion.deviceMotionUpdateInterval = updateInterval
		self.motion.startDeviceMotionUpdates(to: .main) { [weak self] motionData, _ in
			guard let self = self, let grav = motionData?.gravity else { return }
			let newOrientation: UIInterfaceOrientationMask
			let gx = grav.x
			let gy = grav.y

			// Ignore flat-device noise (e.g. lying on a table)
			guard max(abs(gx), abs(gy)) > 0.3 else { return }

			// Determine which axis is dominant
			if abs(gx) > abs(gy) {
				// gravity mostly along device X -> landscape
				if gx > 0 {
					// Right side down, top points left → interface landscapeLeft
					newOrientation = .landscapeLeft
				} else {
					// Left side down, top points right → interface landscapeRight
					newOrientation = .landscapeRight
				}
			} else {
				// gravity mostly along device Y -> portrait/upsideDown
				if gy > 0 {
					newOrientation = .portraitUpsideDown
				} else {
					newOrientation = .portrait
				}
			}

			if self.lastDetectedOrientation != newOrientation {
				self.lastDetectedOrientation = newOrientation

				self.delegate?.orientationManager(self, didDetect: newOrientation)
			}
		}
	}

	func stopMonitoring() {
		self.motion.stopDeviceMotionUpdates()
	}
}
