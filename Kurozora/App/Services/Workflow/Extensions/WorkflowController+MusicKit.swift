//
//  WorkflowController+MusicKit.swift
//  Kurozora
//
//  Created by Khoren Katklian on 01/03/2022.
//  Copyright © 2022 Kurozora. All rights reserved.
//

import UIKit
import MusicKit

// MARK: - Music Kit
extension WorkflowController {
	/// Checks whether the current user is authorized to use `MusicKit`. If the user is authorized then a success block is run. Otherwise the user is asked to authorize.
	///
	///	You can provide your own value of [MusicAuthorization.Status](doc://com.apple.documentation/documentation/musickit/musicauthorization/status?language=swift) as the source that should be used to determin the current user's authorization status.
	///	If no `status` is provided
	///
	/// - Parameter status: A value of `MusicAuthorization.Status` indicating the status of the authorization (default is `nil`).
	/// - Parameter completion: Optional completion handler (default is `nil`).
	@discardableResult
	func isMusicKitAuthorized(_ status: MusicAuthorization.Status? = nil, _ completion: (() -> Void)? = nil) -> Bool {
		switch status ?? MusicAuthorization.currentStatus {
		case .authorized:
			completion?()
			return true
		case .restricted:
			UIApplication.topViewController?.presentAlertController(title: "Restricted", message: "Music cannot be used on this \(UIDevice.modelName) because usage of 􀣺 Music is restricted.")
			return false
		case .denied, .notDetermined:
			if status == nil {
				Task { [weak self] in
					guard let self = self else { return }
					self.isMusicKitAuthorized(await MusicAuthorization.request(), completion)
				}
			}
		default: break
		}

		return false
	}
}
