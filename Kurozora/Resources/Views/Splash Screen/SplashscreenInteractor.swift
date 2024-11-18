//
//  SplashscreenInteractor.swift
//  Kurozora
//
//  Created by Khoren Katklian on 26/12/2022.
//  Copyright © 2022 Kurozora. All rights reserved.
//

import UIKit

protocol SplashscreenBusinessLogic {
	func animateLogo(request: Splashscreen.AnimateLogo.Request)
}

protocol SplashscreenDataStore: AnyObject {}

// MARK: - DataStore
final class SplashscreenInteractor: SplashscreenDataStore {
	var presenter: SplashscreenPresentationLogic?
	var worker: SplashscreenWorkerLogic?
}

// MARK: - BusinessLogic
extension SplashscreenInteractor: SplashscreenBusinessLogic {
	func animateLogo(request: Splashscreen.AnimateLogo.Request) {
		let response = Splashscreen.AnimateLogo.Response(completion: request.completion)
		self.presenter?.presentAnimateLogo(response: response)
	}
}
