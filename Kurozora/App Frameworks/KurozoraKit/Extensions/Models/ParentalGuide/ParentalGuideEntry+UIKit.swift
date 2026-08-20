//
//  ParentalGuideEntry+UIKit.swift
//  Kurozora
//
//  Created by Khoren Katklian on 05/05/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import KurozoraKit
import UIKit

extension ParentalGuideEntry {
	/// Returns the context menu configuration for the entry.
	///
	/// - Parameters:
	///    - viewController: The view controller presenting the menu.
	///    - userInfo: Caller-supplied context forwarded to action handlers.
	///    - sourceView: The view anchoring the menu's popover.
	///    - barButtonItem: The bar button item anchoring the menu's popover.
	///
	/// - Returns: The configuration, or `nil` to suppress the menu.
	func contextMenuConfiguration(in viewController: UIViewController, userInfo: [AnyHashable: Any]?, sourceView: UIView?, barButtonItem: UIBarButtonItem?) -> UIContextMenuConfiguration? {
		let identifier = userInfo?["identifier"] as? NSCopying

		return UIContextMenuConfiguration(identifier: identifier, previewProvider: nil) { _ in
			self.makeContextMenu(in: viewController, userInfo: userInfo, sourceView: sourceView, barButtonItem: barButtonItem)
		}
	}

	/// Returns the entry's context menu without a popover anchor.
	///
	/// - Parameters:
	///    - viewController: The view controller presenting the menu.
	///    - userInfo: Caller-supplied context forwarded to action handlers.
	///
	/// - Returns: The menu, or `nil` to suppress it.
	func makeContextMenu(in viewController: UIViewController, userInfo: [AnyHashable: Any]?) -> UIMenu? {
		return self.makeContextMenu(in: viewController, userInfo: userInfo, sourceView: nil, barButtonItem: nil)
	}

	/// Returns the entry's context menu.
	///
	/// - Parameters:
	///    - viewController: The view controller presenting the menu.
	///    - userInfo: Caller-supplied context forwarded to action handlers.
	///    - sourceView: The view anchoring the menu's popover.
	///    - barButtonItem: The bar button item anchoring the menu's popover.
	///
	/// - Returns: The menu.
	func makeContextMenu(in viewController: UIViewController, userInfo: [AnyHashable: Any]?, sourceView: UIView?, barButtonItem: UIBarButtonItem?) -> UIMenu {
		var menuElements: [UIMenuElement] = []

		let helpfulAction = UIAction(title: L10n.helpful, image: UIImage(systemName: "hand.thumbsup")) { _ in
			Task {
				await self.castVote(.helpful, indexPath: userInfo?["indexPath"] as? IndexPath)
			}
		}

		let unhelpfulAction = UIAction(title: L10n.unhelpful, image: UIImage(systemName: "hand.thumbsdown")) { _ in
			Task {
				await self.castVote(.unhelpful, indexPath: userInfo?["indexPath"] as? IndexPath)
			}
		}

		menuElements.append(UIMenu(title: "", options: .displayInline, children: [helpfulAction, unhelpfulAction]))

		let mediaType = userInfo?["mediaType"] as? ParentalGuide.MediaType
		let shareAction = UIAction(title: L10n.share, image: UIImage(systemName: "square.and.arrow.up")) { _ in
			self.openShareSheet(on: viewController, mediaType: mediaType, sourceView: sourceView, barButtonItem: barButtonItem)
		}

		menuElements.append(UIMenu(title: "", options: .displayInline, children: [shareAction]))

		if let viewerID = User.current?.id.rawValue, viewerID == self.attributes.userID {
			let editAction = UIAction(title: L10n.edit, image: UIImage(systemName: "pencil")) { [weak viewController] _ in
				guard let viewController = viewController else { return }

				self.presentEditor(in: viewController, mediaType: userInfo?["mediaType"] as? ParentalGuide.MediaType)
			}

			let deleteAction = UIAction(title: L10n.delete, image: UIImage(systemName: "trash"), attributes: .destructive) { _ in
				self.confirmDelete(via: viewController, indexPath: userInfo?["indexPath"] as? IndexPath)
			}

			menuElements.append(UIMenu(title: "", options: .displayInline, children: [editAction, deleteAction]))
		} else if User.isSignedIn {
			let reportAction = UIAction(title: L10n.report, image: UIImage(systemName: "exclamationmark.triangle"), attributes: .destructive) { _ in
				Task {
					await self.reportEntry(on: viewController)
				}
			}

			menuElements.append(UIMenu(title: "", options: .displayInline, children: [reportAction]))
		}

		return UIMenu(title: "", children: menuElements)
	}

	/// Casts a helpful or unhelpful vote on the entry.
	///
	/// - Parameters:
	///    - vote: The vote to cast, or `nil` to clear an existing one.
	///    - indexPath: The index path of the cell that initiated the vote.
	private func castVote(_ vote: ParentalGuideVote?, indexPath: IndexPath?) async {
		let signedIn = await WorkflowController.shared.isSignedIn(on: nil)
		guard signedIn else { return }

		let oldHelpful = self.attributes.isHelpful
		let tapHelpful: Bool? = vote.map { $0 == .helpful }
		let predicted: Bool? = (oldHelpful == tapHelpful) ? nil : tapHelpful

		var userInfo: [AnyHashable: Any] = ["entry": self]
		if let indexPath = indexPath {
			userInfo["indexPath"] = indexPath
		}

		self.attributes.applyVote(predicted)
		NotificationCenter.default.post(name: .KPGEntryDidUpdate, object: nil, userInfo: userInfo)

		let identity = ParentalGuideEntryIdentity(id: self.id)
		let request = ParentalGuideVoteRequest(vote: vote)

		do {
			let response = try await KService.voteParentalGuideEntry(identity, request: request).response()
			self.attributes.applyVote(response.data.isHelpful)
			NotificationCenter.default.post(name: .KPGEntryDidUpdate, object: nil, userInfo: userInfo)
		} catch {
			self.attributes.applyVote(oldHelpful)
			NotificationCenter.default.post(name: .KPGEntryDidUpdate, object: nil, userInfo: userInfo)
			print(error.localizedDescription)
		}
	}

	/// Presents the share sheet for the entry, composing a title line and quoted reason alongside the deep link.
	///
	/// - Parameters:
	///    - viewController: The presenting view controller.
	///    - mediaType: The parent media context, used to resolve the share URL.
	///    - sourceView: The view anchoring the share sheet's popover.
	///    - barButtonItem: The bar button item anchoring the share sheet's popover.
	func openShareSheet(on viewController: UIViewController? = UIApplication.topViewController, mediaType: ParentalGuide.MediaType? = nil, sourceView: UIView?, barButtonItem: UIBarButtonItem?) {
		var activityItems: [Any] = []

		var lines: [String] = []

		if let mediaTitle = mediaType?.title, !mediaTitle.isEmpty {
			let titleLine = L10n.parentalGuideShareTitleFormat(
				mediaTitle,
				self.attributes.rating.stringValue,
				self.attributes.category.displayName
			)
			lines.append(titleLine)
		}

		if let reason = self.attributes.reason, !reason.isEmpty {
			lines.append("\"\(reason)\"")
		}

		if !lines.isEmpty {
			activityItems.append(lines.joined(separator: "\n"))
		}

		if let url = mediaType?.parentalGuideURL(for: self.attributes.category) {
			activityItems.append(url)
		}

		let activityViewController = UIActivityViewController(activityItems: activityItems, applicationActivities: [])

		if let popoverController = activityViewController.popoverPresentationController {
			if let sourceView = sourceView {
				popoverController.sourceView = sourceView
				popoverController.sourceRect = sourceView.frame
			} else {
				popoverController.barButtonItem = barButtonItem
			}
		}
		viewController?.present(activityViewController, animated: true)
	}

	/// Presents the editor for the entry.
	///
	/// - Parameters:
	///    - presentingViewController: The view controller presenting the editor.
	///    - mediaType: The media context the submission targets.
	@MainActor
	func presentEditor(in presentingViewController: UIViewController, mediaType: ParentalGuide.MediaType?) {
		Task { [weak presentingViewController] in
			guard let presentingViewController = presentingViewController else { return }
			let signedIn = await WorkflowController.shared.isSignedIn(on: presentingViewController)
			guard signedIn else { return }

			guard let mediaType = mediaType else { return }

			let editorViewController = ParentalGuideEditorCollectionViewController()
			editorViewController.mediaType = mediaType
			editorViewController.category = self.attributes.category
			editorViewController.existingEntry = self

			let navigationController = KNavigationController(rootViewController: editorViewController)
			navigationController.modalPresentationStyle = .formSheet
			navigationController.presentationController?.delegate = editorViewController

			presentingViewController.present(navigationController, animated: true)
		}
	}

	/// Presents the report sheet for the entry.
	///
	/// - Parameter viewController: The view controller presenting the sheet.
	@MainActor
	func reportEntry(on viewController: UIViewController?) async {
		let signedIn = await WorkflowController.shared.isSignedIn(on: viewController)
		guard signedIn else { return }

		let reportViewController = ReportCollectionViewController()
		reportViewController.subject = .parentalGuideEntry(ParentalGuideEntryIdentity(id: self.id))

		let navigationController = KNavigationController(rootViewController: reportViewController)
		navigationController.modalPresentationStyle = .formSheet

		(viewController ?? UIApplication.topViewController)?.present(navigationController, animated: true)
	}

	/// Deletes the entry.
	///
	/// - Parameter indexPath: The index path of the cell that initiated the delete.
	private func remove(at indexPath: IndexPath?) async {
		let identity = ParentalGuideEntryIdentity(id: self.id)

		do {
			_ = try await KService.deleteParentalGuideEntry(identity).response()

			var userInfo: [AnyHashable: Any] = ["entryID": self.id]

			if let indexPath = indexPath {
				userInfo["indexPath"] = indexPath
			}

			NotificationCenter.default.post(name: .KPGEntryDidDelete, object: nil, userInfo: userInfo)
		} catch {
			print(error.localizedDescription)
		}
	}

	/// Confirms then deletes the entry.
	///
	/// - Parameters:
	///    - viewController: The view controller presenting the alert.
	///    - indexPath: The index path of the cell that initiated the delete.
	private func confirmDelete(via viewController: UIViewController? = UIApplication.topViewController, indexPath: IndexPath?) {
		let alert = UIAlertController.alert(title: nil, message: L10n.deleteEntryConfirmMessage) { alertController in
			let deleteAction = UIAlertAction(title: L10n.delete, style: .destructive) { _ in
				Task {
					await self.remove(at: indexPath)
				}
			}

			alertController.addAction(deleteAction)
		}

		if let popoverController = alert.popoverPresentationController {
			if let view = viewController?.view {
				popoverController.sourceView = view
				popoverController.sourceRect = view.frame
			}
		}

		if (viewController?.navigationController?.visibleViewController as? UIAlertController) == nil {
			viewController?.present(alert, animated: true)
		}
	}
}
