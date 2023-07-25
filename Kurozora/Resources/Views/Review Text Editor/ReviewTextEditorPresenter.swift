//
//  ReviewTextEditorPresenter.swift
//  Kurozora
//
//  Created by Khoren Katklian on 24/07/2023.
//  Copyright © 2023 Kurozora. All rights reserved.
//

import UIKit

protocol ReviewTextEditorPresentationLogic {
	func presentConfigure(response: ReviewTextEditor.Configure.Response)
	func presentSaveRating(response: ReviewTextEditor.SaveRating.Response)
	func presentSaveReview(response: ReviewTextEditor.SaveReview.Response)
	func presentCancel(response: ReviewTextEditor.Cancel.Response)
	func presentConfirmCancel(response: ReviewTextEditor.ConfirmCancel.Response)
	func presentSubmit(response: ReviewTextEditor.Submit.Response)
	func presentAlert(response: ReviewTextEditor.Alert.Response)
}

// MARK: - PresentationLogic
final class ReviewTextEditorPresenter: ReviewTextEditorPresentationLogic {
	weak var viewController: ReviewTextEditorDisplayLogic?

	func presentConfigure(response: ReviewTextEditor.Configure.Response) {
		let viewModel = ReviewTextEditor.Configure.ViewModel(rating: response.rating, review: response.review)
		self.viewController?.displayConfigure(viewModel: viewModel)
	}

	func presentSaveRating(response: ReviewTextEditor.SaveRating.Response) {
		let viewModel = ReviewTextEditor.SaveRating.ViewModel()
		self.viewController?.displaySaveRating(viewModel: viewModel)
	}

	func presentSaveReview(response: ReviewTextEditor.SaveReview.Response) {
		let viewModel = ReviewTextEditor.SaveReview.ViewModel()
		self.viewController?.displaySaveReview(viewModel: viewModel)
	}

	func presentCancel(response: ReviewTextEditor.Cancel.Response) {
		let viewModel = ReviewTextEditor.Cancel.ViewModel(forceCancel: response.forceCancel, hasChanges: response.hasChanges)
		self.viewController?.displayCancel(viewModel: viewModel)
	}

	func presentConfirmCancel(response: ReviewTextEditor.ConfirmCancel.Response) {
		let viewModel = ReviewTextEditor.ConfirmCancel.ViewModel(showingSend: response.showingSend)
		self.viewController?.displayConfirmCancel(viewModel: viewModel)
	}

	func presentSubmit(response: ReviewTextEditor.Submit.Response) {
		let viewModel = ReviewTextEditor.Submit.ViewModel()
		self.viewController?.displaySubmit(viewModel: viewModel)
	}

	func presentAlert(response: ReviewTextEditor.Alert.Response) {
		let viewModel = ReviewTextEditor.Alert.ViewModel(message: response.message)
		self.viewController?.displayAlert(viewModel: viewModel)
	}
}
