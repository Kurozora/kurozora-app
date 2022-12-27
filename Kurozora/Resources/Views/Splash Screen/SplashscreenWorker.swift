//
//  SplashscreenWorker.swift
//  Kurozora
//
//  Created by Khoren Katklian on 26/12/2022.
//  Copyright © 2022 Kurozora. All rights reserved.
//

import UIKit

protocol SplashscreenWorkerLogic {
	func doSomeWork(completion: (() -> Void)?)
}

// MARK: - WorkerLogic
final class SplashscreenWorker: SplashscreenWorkerLogic {
	func doSomeWork(completion: (() -> Void)?) {
		completion?()
	}
}
