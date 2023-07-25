//
//  ReviewTextEditorInteractor.swift
//  Kurozora
//
//  Created by Khoren Katklian on 24/07/2023.
//  Copyright © 2023 Kurozora. All rights reserved.
//

import UIKit
import KurozoraKit

protocol ReviewTextEditorBusinessLogic {
	func doConfigure(request: ReviewTextEditor.Configure.Request)
	func doSaveRating(request: ReviewTextEditor.SaveRating.Request)
	func doSaveReview(request: ReviewTextEditor.SaveReview.Request)
	func doCancel(request: ReviewTextEditor.Cancel.Request)
	func doConfirmCancel(request: ReviewTextEditor.ConfirmCancel.Request)
	func doSubmit(request: ReviewTextEditor.Submit.Request) async
}

protocol ReviewTextEditorDataStore: AnyObject {
	var rating: Double? { get set }
	var review: String? { get set }
	var kind: ReviewTextEditor.Kind? { get set }
	var isEdited: Bool { get set }
}

// MARK: - DataStore
final class ReviewTextEditorInteractor: ReviewTextEditorDataStore {
	var presenter: ReviewTextEditorPresentationLogic?
	var worker: ReviewTextEditorWorkerLogic?
	var rating: Double?
	var review: String?
	var kind: ReviewTextEditor.Kind?
	var isEdited: Bool = false
}

// MARK: - BusinessLogic
extension ReviewTextEditorInteractor: ReviewTextEditorBusinessLogic {
	func doConfigure(request: ReviewTextEditor.Configure.Request) {
		let response = ReviewTextEditor.Configure.Response(rating: self.rating ?? 1, review: self.review)
		self.presenter?.presentConfigure(response: response)
	}

	func doSaveRating(request: ReviewTextEditor.SaveRating.Request) {
		self.isEdited = true
		self.rating = request.rating

		let response = ReviewTextEditor.SaveRating.Response()
		self.presenter?.presentSaveRating(response: response)
	}

	func doSaveReview(request: ReviewTextEditor.SaveReview.Request) {
		self.isEdited = true
		self.review = request.review

		let response = ReviewTextEditor.SaveReview.Response()
		self.presenter?.presentSaveReview(response: response)
	}

	func doCancel(request: ReviewTextEditor.Cancel.Request) {
		let response = ReviewTextEditor.Cancel.Response(forceCancel: request.forceCancel, hasChanges: self.isEdited)
		self.presenter?.presentCancel(response: response)
	}

	func doConfirmCancel(request: ReviewTextEditor.ConfirmCancel.Request) {
		let response = ReviewTextEditor.ConfirmCancel.Response(showingSend: request.showingSend)
		self.presenter?.presentConfirmCancel(response: response)
	}

	func doSubmit(request: ReviewTextEditor.Submit.Request) async {
		let rating = self.rating ?? 1
		var payload: (isSuccess: Bool, message: String?)?

		switch self.kind {
		case .show(let showIdentity):
			payload = await self.worker?.rateShow(showIdentity, rating: rating, review: self.review)
		case .literature(let literatureIdentity):
			payload = await self.worker?.rateLiterature(literatureIdentity, rating: rating, review: self.review)
		case .game(let gameIdentity):
			payload = await self.worker?.rateGame(gameIdentity, rating: rating, review: self.review)
		case .episode(let episodeIdentity):
			payload = await self.worker?.rateEpisode(episodeIdentity, rating: rating, review: self.review)
		case .none:
			payload = (isSuccess: false, message: "No review kind was specified. Bad developer :O")
		}

		if payload?.isSuccess == true {
			let response = ReviewTextEditor.Submit.Response()
			DispatchQueue.main.async {
				self.presenter?.presentSubmit(response: response)
			}
		} else {
			let response = ReviewTextEditor.Alert.Response(message: payload?.message)
			self.presenter?.presentAlert(response: response)
		}
	}
}
