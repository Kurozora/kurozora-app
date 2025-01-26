//
//  WorkflowController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 24/04/2018.
//  Copyright © 2018 Kurozora. All rights reserved.
//

import UIKit

final class WorkflowController: NSObject {
	// MARK: - Properties
	/// Returns the singleton WorkflowController instance.
	static let shared = WorkflowController()

	/// Returns the current UNUserNotificationCenter instance.
	let notificationCenter = UNUserNotificationCenter.current()

	// MARK: - Initializers
	private override init() {}
}
