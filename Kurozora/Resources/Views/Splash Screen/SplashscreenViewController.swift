//
//  SplashscreenViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 26/12/2022.
//  Copyright © 2022 Kurozora. All rights reserved.
//

import UIKit

protocol SplashscreenDisplayLogic: AnyObject {
	func displaySomething(viewModel: Splashscreen.Something.ViewModel)
}

final class SplashscreenViewController: UIViewController {
	// MARK: - IBOutlets
	@IBOutlet private var sceneView: SplashscreenView!

	// MARK: - Parameters
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

		self.doSomething()
	}
}

// MARK: - Requests
extension SplashscreenViewController {
	func doSomething() {
		let request = Splashscreen.Something.Request()
		self.interactor?.doSomething(request: request)
	}
}

// MARK: - Display
extension SplashscreenViewController: SplashscreenDisplayLogic {
	func displaySomething(viewModel: Splashscreen.Something.ViewModel) {
		self.sceneView.setData()
	}
}

// MARK: - ViewDelegate
extension SplashscreenViewController: SplashscreenViewDelegate {
//    func handleButtonPress() { }
}
