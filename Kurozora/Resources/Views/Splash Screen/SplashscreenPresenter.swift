//
//  SplashscreenPresenter.swift
//  Kurozora
//
//  Created by Khoren Katklian on 26/12/2022.
//  Copyright © 2022 Kurozora. All rights reserved.
//

import UIKit

protocol SplashscreenPresentationLogic {
	func presentAnimateLogo(response: Splashscreen.AnimateLogo.Response)
}

// MARK: - PresentationLogic
final class SplashscreenPresenter: SplashscreenPresentationLogic {
	weak var viewController: SplashscreenDisplayLogic?

	func presentAnimateLogo(response: Splashscreen.AnimateLogo.Response) {
		let viewModel = Splashscreen.AnimateLogo.ViewModel(completion: response.completion)
		self.viewController?.displayAnimateLogo(viewModel: viewModel)
	}
}
