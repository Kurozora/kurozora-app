//
//  WarningPresenter.swift
//  Kurozora
//
//  Created by Khoren Katklian on 10/12/2022.
//  Copyright © 2022 Kurozora. All rights reserved.
//

import UIKit

protocol WarningPresentationLogic {
	func presentConfigureView(response: Warning.ConfigureView.Response)
	func presentActionButtonPressed(response: Warning.ActionButtonPressed.Response)
}

// MARK: - PresentationLogic
final class WarningPresenter: WarningPresentationLogic {
	weak var viewController: WarningDisplayLogic?

	func presentConfigureView(response: Warning.ConfigureView.Response) {
		let viewModel = Warning.ConfigureView.ViewModel(warningType: response.warningType)
		self.viewController?.displayConfigureView(viewModel: viewModel)
	}

	func presentActionButtonPressed(response: Warning.ActionButtonPressed.Response) {
		let viewModel = Warning.ActionButtonPressed.ViewModel(window: response.window, warningType: response.warningType)
		self.viewController?.displayActionButtonPressed(viewModel: viewModel)
	}
}
