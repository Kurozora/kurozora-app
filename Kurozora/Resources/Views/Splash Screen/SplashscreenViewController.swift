//
//  SplashscreenViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 26/12/2022.
//  Copyright © 2022 Kurozora. All rights reserved.
//

import UIKit

protocol SplashscreenDisplayLogic: AnyObject {
	func displayAnimateLogo(viewModel: Splashscreen.AnimateLogo.ViewModel)
}

final class SplashscreenViewController: UIViewController {
	// MARK: - IBOutlets
	@IBOutlet private var sceneView: SplashscreenView!

	// MARK: - Properties
	var interactor: SplashscreenBusinessLogic?
	var router: (SplashscreenRoutingLogic & SplashscreenDataPassing)?

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
		let interactor = SplashscreenInteractor()
		let presenter = SplashscreenPresenter()
		let router = SplashscreenRouter()
		let worker = SplashscreenWorker()

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
	}
}

// MARK: - Requests
extension SplashscreenViewController {
	func animateLogo(completion: ((Bool) -> Void)?) {
		let request = Splashscreen.AnimateLogo.Request(completion: completion)
		self.interactor?.animateLogo(request: request)
	}
}

// MARK: - Display
extension SplashscreenViewController: SplashscreenDisplayLogic {
	func displayAnimateLogo(viewModel: Splashscreen.AnimateLogo.ViewModel) {
		self.sceneView.animateLogo(completion: viewModel.completion)
	}
}

// MARK: - ViewDelegate
extension SplashscreenViewController: SplashscreenViewDelegate {}
