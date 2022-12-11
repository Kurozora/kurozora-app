//
//  WarningViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 10/12/2022.
//  Copyright © 2022 Kurozora. All rights reserved.
//

import UIKit

protocol WarningDisplayLogic: AnyObject {
	func displayConfigureView(viewModel: Warning.ConfigureView.ViewModel)
	func displayActionButtonPressed(viewModel: Warning.ActionButtonPressed.ViewModel)
}

final class WarningViewController: KViewController {
	// MARK: - IBOutlets
	@IBOutlet private var sceneView: WarningView!

	// MARK: - Parameters
	var interactor: WarningBusinessLogic?
	var router: (WarningRoutingLogic & WarningDataPassing)?

	// MARK: - Initializers
	override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
		super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
		self.setup()
	}

	required init?(coder: NSCoder) {
		super.init(coder: coder)
		self.setup()
	}

	// MARK: - Setup
	private func setup() {
		let viewController = self
		let interactor = WarningInteractor()
		let presenter = WarningPresenter()
		let router = WarningRouter()
		let worker = WarningWorker()

		viewController.interactor = interactor
		viewController.router = router
		interactor.presenter = presenter
		interactor.worker = worker
		presenter.viewController = viewController
		router.viewController = viewController
		router.dataStore = interactor
	}

	// MARK: - View state
	override func viewDidLoad() {
		super.viewDidLoad()
		self.sceneView.viewDelegate = self

		self.doConfigureView()

		// If the network is reachable show the main controller
		KNetworkManager.shared.reachability.whenReachable = { [weak self] _ in
			guard let self = self else { return }
			self.doActionButtonPressed()
		}
	}

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)

		// Hide the navigation bar
		self.navigationController?.setNavigationBarHidden(true, animated: animated)
	}

	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)

		// Show the navigation bar
		navigationController?.setNavigationBarHidden(false, animated: animated)
	}
}

// MARK: - Requests
extension WarningViewController {
	func doConfigureView() {
		let request = Warning.ConfigureView.Request()
		self.interactor?.doConfigureView(request: request)
	}

	func doActionButtonPressed() {
		let request = Warning.ActionButtonPressed.Request()
		self.interactor?.doActionButtonPressed(request: request)
	}

	func doHandleActionButton() {
		let request = Warning.ActionButtonPressed.Request()
		self.interactor?.doActionButtonPressed(request: request)
	}
}

// MARK: - Display
extension WarningViewController: WarningDisplayLogic {
	func displayConfigureView(viewModel: Warning.ConfigureView.ViewModel) {
		self.sceneView.setData(warningType: viewModel.warningType)
	}

	func displayActionButtonPressed(viewModel: Warning.ActionButtonPressed.ViewModel) {
		switch viewModel.warningType {
		case .forceUpdate:
			UIApplication.shared.kOpen(nil, deepLink: URL.appStoreURL)
		case .noSignal:
			KNetworkManager.isReachable { [weak self] _ in
				guard let self = self else { return }
				KurozoraDelegate.shared.showMainPage(for: viewModel.window, viewController: self)
			}
		}
	}
}

// MARK: - ViewDelegate
extension WarningViewController: WarningViewDelegate {
	func handleActionButtonPressed() {
		self.doActionButtonPressed()
	}
}
