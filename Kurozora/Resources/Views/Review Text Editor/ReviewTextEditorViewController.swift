//
//  ReviewTextEditorViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 24/07/2023.
//  Copyright © 2023 Kurozora. All rights reserved.
//

import UIKit
import IQKeyboardManagerSwift

protocol ReviewTextEditorDisplayLogic: AnyObject {
	func displayConfigure(viewModel: ReviewTextEditor.Configure.ViewModel)
	func displayUnsavedChanges(viewModel: ReviewTextEditor.UnsavedChanges.ViewModel)
	func displaySaveRating(viewModel: ReviewTextEditor.SaveRating.ViewModel)
	func displaySaveReview(viewModel: ReviewTextEditor.SaveReview.ViewModel)
	func displayCancel(viewModel: ReviewTextEditor.Cancel.ViewModel)
	func displayConfirmCancel(viewModel: ReviewTextEditor.ConfirmCancel.ViewModel)
	@MainActor
	func displaySubmit(viewModel: ReviewTextEditor.Submit.ViewModel)
	func displayAlert(viewModel: ReviewTextEditor.Alert.ViewModel)
}

protocol ReviewTextEditorViewControllerDelegate: AnyObject {
	func reviewTextEditorViewControllerDidSubmitReview()
}

final class ReviewTextEditorViewController: KViewController {
	// MARK: - IBOutlets
	@IBOutlet private var sceneView: ReviewTextEditorView!

	// MARK: - Properties
	var interactor: ReviewTextEditorBusinessLogic?
	var router: (ReviewTextEditorRoutingLogic & ReviewTextEditorDataPassing)?

	var cancelBarButtonItem: UIBarButtonItem!
	var sendBarButtonItem: UIBarButtonItem!

	weak var delegate: ReviewTextEditorViewControllerDelegate?

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
		let interactor = ReviewTextEditorInteractor()
		let presenter = ReviewTextEditorPresenter()
		let router = ReviewTextEditorRouter()
		let worker = ReviewTextEditorWorker()

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
		self.sceneView.delegate = self

		self.title = Trans.writeAReview

		self.navigationController?.navigationBar.prefersLargeTitles = false
		self.sheetPresentationController?.detents = [.medium(), .large()]
		self.sheetPresentationController?.selectedDetentIdentifier = .large
		self.sheetPresentationController?.prefersEdgeAttachedInCompactHeight = true
		self.sheetPresentationController?.prefersGrabberVisible = true

		self.setupNavigationItems()

		self.doConfigure()
	}

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)

		IQKeyboardManager.shared.isEnabled = false
	}

	override func viewWillLayoutSubviews() {
		super.viewWillLayoutSubviews()

		self.doUnsavedChanges()
	}

	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)

		IQKeyboardManager.shared.isEnabled = true
	}

	// MARK: - Functions
	func setupNavigationItems() {
		self.cancelBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(self.cancelButtonPressed(_:)))
		self.sendBarButtonItem = UIBarButtonItem(title: Trans.send, style: .done, target: self, action: #selector(self.sendButtonPressed(_:)))

		self.navigationItem.leftBarButtonItem = self.cancelBarButtonItem
		self.navigationItem.rightBarButtonItem = self.sendBarButtonItem
	}

	@objc func cancelButtonPressed(_ sender: UIBarButtonItem) {
		self.doCancel(forceCancel: false)
	}

	@objc func sendButtonPressed(_ sender: UIBarButtonItem) {
		sender.isEnabled = false
		self.doSubmit()
	}
}

// MARK: - Requests
extension ReviewTextEditorViewController {
	func doConfigure() {
		let request = ReviewTextEditor.Configure.Request()
		self.interactor?.doConfigure(request: request)
	}

	func doUnsavedChanges() {
		let request = ReviewTextEditor.UnsavedChanges.Request()
		self.interactor?.doUnsavedChanges(request: request)
	}

	func doSaveRating(_ rating: Double) {
		let request = ReviewTextEditor.SaveRating.Request(rating: rating)
		self.interactor?.doSaveRating(request: request)
	}

	func doSaveReview(_ review: String) {
		let request = ReviewTextEditor.SaveReview.Request(review: review)
		self.interactor?.doSaveReview(request: request)
	}

	func doCancel(forceCancel: Bool) {
		let request = ReviewTextEditor.Cancel.Request(forceCancel: forceCancel)
		self.interactor?.doCancel(request: request)
	}

	func doConfirmCancel(showingSend: Bool) {
		let request = ReviewTextEditor.ConfirmCancel.Request(showingSend: showingSend)
		self.interactor?.doConfirmCancel(request: request)
	}

	func doSubmit() {
		Task { [weak self] in
			guard let self = self else { return }
			let request = ReviewTextEditor.Submit.Request()
			await self.interactor?.doSubmit(request: request)
		}
	}
}

// MARK: - Display
extension ReviewTextEditorViewController: ReviewTextEditorDisplayLogic {
	func displayConfigure(viewModel: ReviewTextEditor.Configure.ViewModel) {
		self.sceneView.configure(using: viewModel)
	}

	func displayUnsavedChanges(viewModel: ReviewTextEditor.UnsavedChanges.ViewModel) {
		// If there are unsaved changes, enable the Save button and disable the ability to
		// dismiss using the pull-down gesture.
		self.navigationItem.rightBarButtonItem?.isEnabled = viewModel.isEdited
		self.isModalInPresentation = viewModel.isEdited
	}

	func displaySaveRating(viewModel: ReviewTextEditor.SaveRating.ViewModel) {
		self.doUnsavedChanges()
	}

	func displaySaveReview(viewModel: ReviewTextEditor.SaveReview.ViewModel) {
		self.doUnsavedChanges()
	}

	func displayCancel(viewModel: ReviewTextEditor.Cancel.ViewModel) {
		if !viewModel.forceCancel && viewModel.hasChanges {
			// The user tapped Cancel with unsaved changes. Confirm that it's OK to lose the changes.
			self.doConfirmCancel(showingSend: viewModel.hasChanges)
		} else {
			// There are no unsaved changes. Dismiss immediately.
			self.dismiss(animated: true)
		}
	}

	func displayConfirmCancel(viewModel: ReviewTextEditor.ConfirmCancel.ViewModel) {
		// Present a UIAlertController as an action sheet to have the user confirm losing any recent changes.
		let actionSheetAlertController = UIAlertController.actionSheet(title: nil, message: nil) { [weak self] actionSheetAlertController in
			guard let self = self else { return }
			// Only ask if the user wants to send if they attempt to pull to dismiss, not if they tap Cancel.
			if viewModel.showingSend {
				// Send action.
				actionSheetAlertController.addAction(UIAlertAction(title: Trans.send, style: .default) { _ in
					self.doSubmit()
				})
			}

			// Discard action.
			actionSheetAlertController.addAction(UIAlertAction(title: Trans.discard, style: .destructive) { _ in
				self.doCancel(forceCancel: true)
			})
		}

		// Present the controller
		if let popoverController = actionSheetAlertController.popoverPresentationController {
			popoverController.barButtonItem = self.navigationItem.leftBarButtonItem
		}

		if (self.navigationController?.visibleViewController as? UIAlertController) == nil {
			self.present(actionSheetAlertController, animated: true, completion: nil)
		}
	}

	func displaySubmit(viewModel: ReviewTextEditor.Submit.ViewModel) {
		let `self` = self

		`self`.dismiss(animated: true) {
			`self`.delegate?.reviewTextEditorViewControllerDidSubmitReview()
		}
	}

	func displayAlert(viewModel: ReviewTextEditor.Alert.ViewModel) {
		self.presentAlertController(title: "Can’t Save Review 😔", message: viewModel.message)
	}
}

// MARK: - ViewDelegate
extension ReviewTextEditorViewController: ReviewTextEditorViewDelegate {
	func reviewTextEditorView(_ view: ReviewTextEditorView, rateWith rating: Double) {
		self.doSaveRating(rating)
	}

	func reviewTextEditorView(_ view: ReviewTextEditorView, textDidChange text: String) {
		self.doSaveReview(text)
	}
}

// MARK: - UIAdaptivePresentationControllerDelegate
extension ReviewTextEditorViewController: UIAdaptivePresentationControllerDelegate {
	func presentationControllerDidAttemptToDismiss(_ presentationController: UIPresentationController) {
		// The system calls this delegate method whenever the user attempts to pull down to dismiss and `isModalInPresentation` is false.
		// Clarify the user's intent by asking whether they want to cancel or send.
		self.doConfirmCancel(showingSend: true)
	}
}
