//
//  SplashscreenPresenter.swift
//  Kurozora
//
//  Created by Khoren Katklian on 26/12/2022.
//  Copyright © 2022 Kurozora. All rights reserved.
//

import UIKit

protocol SplashscreenPresentationLogic {
	func presentSomething(response: Splashscreen.Something.Response)
}

// MARK: - PresentationLogic
final class SplashscreenPresenter: SplashscreenPresentationLogic {
	weak var viewController: SplashscreenDisplayLogic?

	func presentSomething(response: Splashscreen.Something.Response) {
		let viewModel = Splashscreen.Something.ViewModel()
		viewController?.displaySomething(viewModel: viewModel)
	}
}
