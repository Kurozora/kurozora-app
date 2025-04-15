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
	func doUnsavedChanges(request: ReviewTextEditor.UnsavedChanges.Request)
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
		let rating = max(self.rating ?? 1.0, 1.0)
		let response = ReviewTextEditor.Configure.Response(rating: rating, review: self.review)
		self.presenter?.presentConfigure(response: response)
	}

	func doUnsavedChanges(request: ReviewTextEditor.UnsavedChanges.Request) {
		let response = ReviewTextEditor.UnsavedChanges.Response(isEdited: self.isEdited)
		self.presenter?.presentUnsavedChanges(response: response)
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
		let rating = max(self.rating ?? 1.0, 1.0)
		var isSuccess: Bool = false
		var message: String? = nil

		do throws(KKAPIError) {
			switch self.kind {
			case .character(let character):
				let rating = try await character.rate(using: rating, description: self.review)
				isSuccess = rating != nil
			case .episode(let episode):
				let rating = try await episode.rate(using: rating, description: self.review)
				isSuccess = rating != nil
			case .game(let game):
				let rating = try await game.rate(using: rating, description: self.review)
				isSuccess = rating != nil
			case .literature(let literature):
				let rating = try await literature.rate(using: rating, description: self.review)
				isSuccess = rating != nil
			case .person(let person):
				let rating = try await person.rate(using: rating, description: self.review)
				isSuccess = rating != nil
			case .show(let show):
				let rating = try await show.rate(using: rating, description: self.review)
				isSuccess = rating != nil
			case .song(let song):
				let rating = try await song.rate(using: rating, description: self.review)
				isSuccess = rating != nil
			case .studio(let studio):
				let rating = try await studio.rate(using: rating, description: self.review)
				isSuccess = rating != nil
			case .none:
				isSuccess = false
				message = "No review kind was specified. Bad developer :O"
			}
		} catch {
			print(error.localizedDescription)
			isSuccess = false
			message = error.message
		}

		if isSuccess == true {
			let response = ReviewTextEditor.Submit.Response()
			Task { @MainActor [weak self] in
			    guard let self = self else { return }
				self.presenter?.presentSubmit(response: response)
			}
		} else {
			let response = ReviewTextEditor.Alert.Response(message: message)
			self.presenter?.presentAlert(response: response)
		}
	}
}
