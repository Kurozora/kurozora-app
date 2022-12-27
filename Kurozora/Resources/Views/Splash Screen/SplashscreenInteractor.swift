//
//  SplashscreenInteractor.swift
//  Kurozora
//
//  Created by Khoren Katklian on 26/12/2022.
//  Copyright © 2022 Kurozora. All rights reserved.
//

import UIKit

protocol SplashscreenBusinessLogic {
	func doSomething(request: Splashscreen.Something.Request)
}

protocol SplashscreenDataStore: AnyObject {
//    var name: String { get set }
}

// MARK: - DataStore
final class SplashscreenInteractor: SplashscreenDataStore {
	var presenter: SplashscreenPresentationLogic?
	var worker: SplashscreenWorkerLogic?
//	var name: String = ""
}

// MARK: - BusinessLogic
extension SplashscreenInteractor: SplashscreenBusinessLogic {
	func doSomething(request: Splashscreen.Something.Request) {
		worker?.doSomeWork(completion: {
			let response = Splashscreen.Something.Response()
			self.presenter?.presentSomething(response: response)
		})
	}
}
