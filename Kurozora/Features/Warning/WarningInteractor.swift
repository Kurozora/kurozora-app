//
//  WarningInteractor.swift
//  Kurozora
//
//  Created by Khoren Katklian on 10/12/2022.
//  Copyright © 2022 Kurozora. All rights reserved.
//

import UIKit

protocol WarningBusinessLogic {
	func doConfigureView(request: Warning.ConfigureView.Request)
	func doActionButtonPressed(request: Warning.ActionButtonPressed.Request)
}

protocol WarningDataStore: AnyObject {
	var window: UIWindow? { get set }
    var warningType: WarningType { get set }
}

// MARK: - DataStore
final class WarningInteractor: WarningDataStore {
	var presenter: WarningPresentationLogic?
	var worker: WarningWorkerLogic?
	var window: UIWindow?
	var warningType: WarningType = .noSignal
}

// MARK: - BusinessLogic
extension WarningInteractor: WarningBusinessLogic {
	func doConfigureView(request: Warning.ConfigureView.Request) {
		let response = Warning.ConfigureView.Response(warningType: self.warningType)
		self.presenter?.presentConfigureView(response: response)
	}

	func doActionButtonPressed(request: Warning.ActionButtonPressed.Request) {
		let response = Warning.ActionButtonPressed.Response(window: self.window, warningType: self.warningType)
		self.presenter?.presentActionButtonPressed(response: response)
	}
}
