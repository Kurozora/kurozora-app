//
//  Review+UIKit.swift
//  Kurozora
//
//  Created by Khoren Katklian on 02/11/2023.
//  Copyright © 2023 Kurozora. All rights reserved.
//

import KurozoraKit
import UIKit

extension Review {
	/// Create a context menu configuration for the review.
	///
	/// - Parameters:
	///    - viewController: The view controller presenting the context menu.
	///    - userInfo: Additional information about the context menu.
	///    - sourceView: The `UIView` sending the request.
	///    - barButtonItem: The `UIBarButtonItem` sending the request.
	///
	/// - Returns: A `UIContextMenuConfiguration` representing the context menu for the review.
	///
	/// - NOTE: If both `sourceView` and `barButtonItem` are provided, `sourceView` will take precedence.
	func contextMenuConfiguration(in viewController: UIViewController, userInfo: [AnyHashable: Any]?, sourceView: UIView?, barButtonItem: UIBarButtonItem?) -> UIContextMenuConfiguration? {
		let identifier = userInfo?["identifier"] as? NSCopying

		return UIContextMenuConfiguration(identifier: identifier, previewProvider: nil) { _ in
			self.makeContextMenu(in: viewController, userInfo: userInfo, sourceView: sourceView, barButtonItem: barButtonItem)
		}
	}

	/// Create a context menu for the review.
	///
	/// - Parameters:
	///    - viewController: The view controller presenting the context menu.
	///    - userInfo: Additional information about the context menu.
	///    - sourceView: The `UIView` sending the request.
	///    - barButtonItem: The `UIBarButtonItem` sending the request.
	///
	/// - Returns: A `UIMenu` representing the context menu for the review.
	///
	/// - NOTE: If both `sourceView` and `barButtonItem` are provided, `sourceView` will take precedence.
	func makeContextMenu(in viewController: UIViewController, userInfo: [AnyHashable: Any]?, sourceView: UIView?, barButtonItem: UIBarButtonItem?) -> UIMenu {
		var menuElements: [UIMenuElement] = []

		var userMenuElements: [UIMenuElement] = []

		if let user = self.relationships?.users?.data.first {
			let username = user.attributes.username
			let userAction = UIAction(title: L10n.showUserProfile(username), image: UIImage(systemName: "person.crop.circle.fill")) { _ in
				self.visitOriginalPosterProfile(from: viewController)
			}
			userMenuElements.append(userAction)
		}

		if User.isSignedIn, User.current?.id == self.relationships?.users?.data.first?.id {
			let updateAction = UIAction(title: L10n.updateReview, image: UIImage(systemName: "pencil")) { _ in
				Task { @MainActor in
					await self.presentUpdateEditor(from: viewController)
				}
			}

			menuElements.append(UIMenu(title: "", options: .displayInline, children: [updateAction]))
		}

		if User.isSignedIn, let role = User.current?.attributes.role, [.superAdmin, .admin, .mod, .editor].contains(role) {
			let elevateAction = UIAction(title: L10n.elevateReview, image: UIImage(systemName: "star.circle")) { _ in
				Task { @MainActor in
					await self.elevate(via: viewController)
				}
			}

			menuElements.append(UIMenu(title: "", options: .displayInline, children: [elevateAction]))
		}

		if User.isSignedIn {
			let reviewUserID = self.relationships?.users?.data.first?.id
			if User.current?.attributes.role == .superAdmin ||
				User.current?.attributes.role == .admin ||
				User.current?.id == reviewUserID {
				var deleteMenuElements: [UIMenuElement] = []
				let deleteAction = UIAction(title: L10n.deleteReview, attributes: .destructive) { _ in
					self.confirmDelete(via: viewController)
				}
				deleteMenuElements.append(deleteAction)

				menuElements.append(UIMenu(title: L10n.delete, image: UIImage(systemName: "trash"), children: deleteMenuElements))
			}
		}

		menuElements.append(UIMenu(title: "", options: .displayInline, children: userMenuElements))

		var shareMenuChildren: [UIMenuElement] = []

		let copyAction = UIAction(title: L10n.copyReview, image: UIImage(systemName: "doc.on.doc.fill")) { _ in
			UIPasteboard.general.string = self.attributes.description
		}

		let shareAction = UIAction(title: L10n.share, image: UIImage(systemName: "square.and.arrow.up.fill")) { _ in
			self.openShareSheet(on: viewController, sourceView: sourceView, barButtonItem: barButtonItem)
		}
		shareMenuChildren.append(copyAction)
		shareMenuChildren.append(shareAction)

		let shareMenu = UIMenu(title: "", options: .displayInline, children: shareMenuChildren)
		menuElements.append(shareMenu)

		// Create "helpfulness" menu
		if User.isSignedIn, User.current?.id != self.relationships?.users?.data.first?.id {
			let helpfulAction = UIAction(title: L10n.helpful, image: UIImage(systemName: "hand.thumbsup")) { _ in
				Task {
					await self.castVote(.helpful)
				}
			}

			let unhelpfulAction = UIAction(title: L10n.unhelpful, image: UIImage(systemName: "hand.thumbsdown")) { _ in
				Task {
					await self.castVote(.unhelpful)
				}
			}

			menuElements.append(UIMenu(title: "", options: .displayInline, children: [helpfulAction, unhelpfulAction]))
		}

		if User.isSignedIn {
			var reportMenuElements: [UIMenuElement] = []
			let reportAction = UIAction(title: L10n.reportReview, attributes: .destructive) { _ in
				Task {
					await self.reportReview(on: viewController)
				}
			}
			reportMenuElements.append(reportAction)

			menuElements.append(UIMenu(title: L10n.report, image: UIImage(systemName: "exclamationmark.circle"), children: reportMenuElements))
		}

		return UIMenu(title: "", children: menuElements)
	}

	/// Presents the review editor for the review.
	///
	/// - Parameter viewController: The view controller showing the review.
	@MainActor
	private func presentUpdateEditor(from viewController: UIViewController) async {
		// The review's own page hands the editor to its presenter, so the two sheets never stack.
		guard viewController is ReviewDetailsCollectionViewController, let presentingViewController = viewController.presentingViewController else {
			await self.presentEditor(from: viewController)
			return
		}

		viewController.dismiss(animated: true) {
			Task { @MainActor in
				await self.presentEditor(from: presentingViewController)
			}
		}
	}

	/// Presents the review editor from the given view controller.
	///
	/// - Parameter viewController: The view controller presenting the editor.
	@MainActor
	private func presentEditor(from viewController: UIViewController) async {
		let delegate = viewController as? any ReviewEditorCollectionViewControllerDelegate

		// The screen showing the review already holds the item and the private note, so the editor opens without a fetch.
		if let context = (viewController as? any ReviewEditorContextProviding)?.writeAReviewContext() {
			await viewController.presentReviewEditor(using: context, delegate: delegate)
			return
		}

		guard let kind = await self.reviewKind() else { return }

		let context = ReviewEditorContext(kind: kind, rating: self.attributes.score, review: self.attributes.description, note: self.attributes.note, isSpoiler: self.attributes.isSpoiler, recommendation: self.attributes.recommendation)
		await viewController.presentReviewEditor(using: context, delegate: delegate)
	}

	/// Fetches the model the review belongs to.
	///
	/// - Returns: The reviewed model. `nil` when it cannot be fetched.
	private func reviewKind() async -> ReviewKind? {
		guard let relationships = self.relationships else { return nil }

		do {
			if let identity = relationships.characters?.data.first {
				return try await KService.detail(identity).response().data.first.map { .character($0) }
			} else if let identity = relationships.episodes?.data.first {
				return try await KService.detail(identity).response().data.first.map { .episode($0) }
			} else if let identity = relationships.games?.data.first {
				return try await KService.detail(identity).response().data.first.map { .game($0) }
			} else if let identity = relationships.literatures?.data.first {
				return try await KService.detail(identity).response().data.first.map { .literature($0) }
			} else if let identity = relationships.people?.data.first {
				return try await KService.detail(identity).response().data.first.map { .person($0) }
			} else if let identity = relationships.shows?.data.first {
				return try await KService.detail(identity).response().data.first.map { .show($0) }
			} else if let identity = relationships.songs?.data.first {
				return try await KService.detail(identity).response().data.first.map { .song($0) }
			} else if let identity = relationships.studios?.data.first {
				return try await KService.detail(identity).response().data.first.map { .studio($0) }
			}
		} catch {
			print(error.localizedDescription)
		}

		return nil
	}

	/// Presents the profile view for the review poster.
	///
	/// - Parameter viewController: The view controller initialing the segue.
	func visitOriginalPosterProfile(from viewController: UIViewController? = UIApplication.topViewController) {
		guard let user = self.relationships?.users?.data.first else { return }
		let profileTableViewController = ProfileTableViewController()(with: user)

		viewController?.show(profileTableViewController, sender: nil)
	}

	/// Present share sheet for the review.
	///
	/// Make sure to send either the view or the bar button item that's sending the request.
	///
	/// - Parameters:
	///    - viewController: The view controller presenting the share sheet.
	///    - sourceView: The `UIView` sending the request.
	///    - barButtonItem: The `UIBarButtonItem` sending the request.
	///
	/// - NOTE: If both `sourceView` and `barButtonItem` are provided, `sourceView` will take precedence.
	func openShareSheet(on viewController: UIViewController? = UIApplication.topViewController, sourceView: UIView?, barButtonItem: UIBarButtonItem?) {
		var activityItems: [Any] = []

		var shareText = "\"\(self.attributes.description ?? "")\""
		if let user = self.relationships?.users?.data.first {
			shareText += "-\(user.attributes.username)"
		}

		activityItems.append(shareText)

		let activityViewController = UIActivityViewController(activityItems: activityItems, applicationActivities: [])

		if let popoverController = activityViewController.popoverPresentationController {
			if let sourceView = sourceView {
				popoverController.sourceView = sourceView
				popoverController.sourceRect = sourceView.frame
			} else {
				popoverController.barButtonItem = barButtonItem
			}
		}
		viewController?.present(activityViewController, animated: true, completion: nil)
	}

	/// Presents the report sheet for the review.
	///
	/// - Parameter viewController: The view controller presenting the sheet.
	@MainActor
	func reportReview(on viewController: UIViewController? = nil) async {
		let signedIn = await WorkflowController.shared.isSignedIn(on: viewController)
		guard signedIn else { return }

		let reportViewController = ReportCollectionViewController()
		reportViewController.subject = .review(ReviewIdentity(id: self.id))

		let navigationController = KNavigationController(rootViewController: reportViewController)
		navigationController.modalPresentationStyle = .formSheet

		(viewController ?? UIApplication.topViewController)?.present(navigationController, animated: true)
	}

	/// Toggles the review's Editor's Choice slot.
	///
	/// - Parameter viewController: The view controller presenting the request, used to surface an error.
	@MainActor
	private func elevate(via viewController: UIViewController? = UIApplication.topViewController) async {
		let reviewIdentity = ReviewIdentity(id: self.id)

		do {
			_ = try await KService.elevateReview(reviewIdentity).response()
			NotificationCenter.default.post(name: .KReviewDidUpdate, object: nil)
		} catch let error as APIError {
			viewController?.presentAlertController(title: nil, message: error.message)
			print("-----", error.localizedDescription)
		} catch {
			print("-----", error.localizedDescription)
		}
	}

	/// Toggles a helpful or unhelpful vote on the review.
	///
	/// - Parameter vote: The vote to cast.
	func castVote(_ vote: ReviewVote?) async {
		let signedIn = await WorkflowController.shared.isSignedIn(on: nil)
		guard signedIn else { return }

		let reviewIdentity = ReviewIdentity(id: self.id)
		let request = ReviewVoteRequest(vote: vote)
		var userInfo: [AnyHashable: Any] = ["reviewID": self.id]

		do {
			let response = try await KService.voteReview(reviewIdentity, request: request).response()

			if let isHelpful = response.data.isHelpful {
				userInfo["isHelpful"] = isHelpful
			}
		} catch {
			userInfo["isHelpful"] = self.attributes.isHelpful
			print("-----", error.localizedDescription)
		}

		// A vote changes one row, so it never asks for the list it sits in to be refetched.
		NotificationCenter.default.post(name: .KReviewVoteDidUpdate, object: nil, userInfo: userInfo)
	}

	/// Removes the review.
	private func remove() async {
		let reviewIdentity = ReviewIdentity(id: self.id)

		do {
			_ = try await KService.deleteReview(reviewIdentity).response()

			NotificationCenter.default.post(name: .KReviewDidDelete, object: nil, userInfo: ["reviewID": self.id])
			NotificationCenter.default.post(name: .KReviewDidUpdate, object: nil)
		} catch {
			print(error.localizedDescription)
		}
	}

	/// Asks the user to confirm before deleting the review.
	private func confirmDelete(via viewController: UIViewController? = UIApplication.topViewController) {
		let actionSheetAlertController = UIAlertController.alert(title: nil, message: L10n.deleteReviewSubheadline) { alertController in
			let deleteAction = UIAlertAction(title: L10n.deleteReview, style: .destructive) { _ in
				Task {
					await self.remove()
				}
			}
			alertController.addAction(deleteAction)
		}

		if let popoverController = actionSheetAlertController.popoverPresentationController {
			if let view = viewController?.view {
				popoverController.sourceView = view
				popoverController.sourceRect = view.frame
			}
		}

		if (viewController?.navigationController?.visibleViewController as? UIAlertController) == nil {
			viewController?.present(actionSheetAlertController, animated: true, completion: nil)
		}
	}
}
