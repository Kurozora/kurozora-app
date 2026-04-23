//
//  FeedMessages+UIKit.swift
//  Kurozora
//
//  Created by Khoren Katklian on 23/11/2020.
//  Copyright © 2020 Kurozora. All rights reserved.
//

import KurozoraKit
import UIKit

extension FeedMessage {
	/// Create a context menu configuration for the feed message.
	///
	/// - Parameters:
	///    - viewController: The view controller presenting the context menu.
	///    - userInfo: Additional information about the context menu.
	///    - sourceView: The `UIView` sending the request.
	///    - barButtonItem: The `UIBarButtonItem` sending the request.
	///
	/// - Returns: A `UIContextMenuConfiguration` representing the context menu for the feed message.
	///
	/// - NOTE: If both `sourceView` and `barButtonItem` are provided, `sourceView` will take precedence.
	@MainActor
	func contextMenuConfiguration(in viewController: UIViewController, userInfo: [AnyHashable: Any]?, sourceView: UIView?, barButtonItem: UIBarButtonItem?) -> UIContextMenuConfiguration? {
		let identifier = userInfo?["identifier"] as? NSCopying

		return UIContextMenuConfiguration(identifier: identifier, previewProvider: nil) { [weak self] _ in
			guard let self = self else { return nil }
			return self.makeContextMenu(in: viewController, userInfo: userInfo, sourceView: sourceView, barButtonItem: barButtonItem)
		}
	}

	/// Create a context menu for the feed message.
	///
	/// - Parameters:
	///    - viewController: The view controller presenting the context menu.
	///    - userInfo: Additional information about the context menu.
	///    - sourceView: The `UIView` sending the request.
	///    - barButtonItem: The `UIBarButtonItem` sending the request.
	///
	/// - Returns: A `UIMenu` representing the context menu for the feed message.
	///
	/// - NOTE: If both `sourceView` and `barButtonItem` are provided, `sourceView` will take precedence.
	@MainActor
	func makeContextMenu(in viewController: UIViewController, userInfo: [AnyHashable: Any]?, sourceView: UIView?, barButtonItem: UIBarButtonItem?) -> UIMenu {
		var menuElements: [UIMenuElement] = []

		// User actions
		if let user = self.relationships.users.data.first {
			var profileElements: [UIMenuElement] = []

			// Follow action
			if user != User.current {
				let followActionTitle: String
				let followActionImage: UIImage?

				switch user.attributes.followStatus {
				case .followed:
					followActionTitle = L10n.unfollow
					followActionImage = UIImage(systemName: "person.badge.minus")
				case .notFollowed, .disabled:
					followActionTitle = L10n.follow
					followActionImage = UIImage(systemName: "person.badge.plus")
				}

				let followAction = UIAction(title: followActionTitle, image: followActionImage) { [weak self] _ in
					guard let self = self else { return }
					Task {
						await self.relationships.users.data.first?.follow(on: viewController)
					}
				}
				profileElements.append(followAction)
			}

			// Show profile action
			let showProfileAction = UIAction(title: L10n.showProfile, image: UIImage(systemName: "person.crop.circle")) { [weak self] _ in
				guard let self = self else { return }
				self.visitOriginalPosterProfile(from: viewController)
			}
			profileElements.append(showProfileAction)

			// Block action
			if User.isSignedIn, user != User.current {
				let blockAction = UIAction(title: L10n.block, image: UIImage(systemName: "xmark.shield")) { [weak self] _ in
					guard let self = self else { return }
					self.relationships.users.data.first?.confirmBlock(via: viewController, userInfo: userInfo)
				}
				profileElements.append(blockAction)
			}

			menuElements.append(UIMenu(title: "@\(user.attributes.slug)", children: profileElements))

			if User.isSignedIn, user == User.current {
				// Pin
				var pinAction: UIAction
				if self.attributes.isPinned {
					pinAction = UIAction(title: L10n.unpin, image: UIImage(systemName: "pin.slash")) { [weak self] _ in
						guard let self = self else { return }
						self.pinMessage(via: viewController, userInfo: userInfo)
					}
				} else {
					pinAction = UIAction(title: L10n.pin, image: UIImage(systemName: "pin")) { [weak self] _ in
						guard let self = self else { return }
						self.pinMessage(via: viewController, userInfo: userInfo)
					}
				}
				menuElements.append(pinAction)
			}
		}

		if User.isSignedIn {
			// Heart, reply and reshare
			var heartAction: UIAction
			if self.attributes.isHearted ?? false {
				heartAction = UIAction(title: L10n.unlike, image: UIImage(systemName: "heart.slash")) { [weak self] _ in
					guard let self = self else { return }
					Task {
						await self.heartMessage(via: viewController, userInfo: userInfo)
					}
				}
			} else {
				heartAction = UIAction(title: L10n.like, image: UIImage(systemName: "heart")) { [weak self] _ in
					guard let self = self else { return }
					Task {
						await self.heartMessage(via: viewController, userInfo: userInfo)
					}
				}
			}
			let replyAction = UIAction(title: L10n.reply, image: .Symbols.messageLeftAndMessageRight) { [weak self] _ in
				guard let self = self else { return }
				Task {
					await self.replyToMessage(via: viewController, userInfo: userInfo)
				}
			}
			let reShareAction = UIAction(title: L10n.reshare, image: UIImage(systemName: "arrow.2.squarepath")) { [weak self] _ in
				guard let self = self else { return }
				Task {
					await self.reShareMessage(via: viewController, userInfo: userInfo)
				}
			}

			menuElements.append(heartAction)
			menuElements.append(replyAction)
			menuElements.append(reShareAction)

			// Edit and delete
			let messageUserID = self.relationships.users.data.first?.id
			if User.current?.attributes.role == .superAdmin ||
				User.current?.attributes.role == .admin ||
				User.current?.id == messageUserID {
				// Edit action
				let editAction = UIAction(title: L10n.edit, image: UIImage(systemName: "pencil.circle")) { [weak self] _ in
					guard let self = self else { return }
					self.editMessage(via: viewController, userInfo: userInfo)
				}
				menuElements.append(editAction)

				var deleteMenuElements: [UIMenuElement] = []
				// Delete action
				let deleteAction = UIAction(title: L10n.deleteMessage, attributes: .destructive) { [weak self] _ in
					guard let self = self else { return }
					self.confirmDelete(via: viewController, userInfo: userInfo)
				}
				deleteMenuElements.append(deleteAction)

				menuElements.append(UIMenu(title: L10n.delete, image: UIImage(systemName: "trash"), children: deleteMenuElements))
			}
		}

		var userMenuElements: [UIMenuElement] = []
		// Replies action
		let showRepliesAction = UIAction(title: L10n.showReplies, image: .Symbols.messageLeftAndMessageRight) { [weak self] _ in
			guard let self = self else { return }
			self.visitRepliesView(from: viewController)
		}
		userMenuElements.append(showRepliesAction)

		// Create "share" element
		let shareAction = UIAction(title: L10n.shareMessage, image: UIImage(systemName: "square.and.arrow.up")) { [weak self] _ in
			guard let self = self else { return }
			self.openShareSheet(on: viewController, sourceView: sourceView, barButtonItem: barButtonItem)
		}
		userMenuElements.append(shareAction)

		// Append user menu
		menuElements.append(UIMenu(title: "", options: .displayInline, children: userMenuElements))

		if User.isSignedIn {
			// Report message action
			var reportMenuElements: [UIMenuElement] = []
			let reportAction = UIAction(title: L10n.reportMessage, attributes: .destructive) { [weak self] _ in
				guard let self = self else { return }
				Task {
					await self.reportMessage()
				}
			}
			reportMenuElements.append(reportAction)

			// Append report menu
			menuElements.append(UIMenu(title: L10n.report, image: UIImage(systemName: "exclamationmark.circle"), children: reportMenuElements))
		}

		// Create and return a UIMenu
		return UIMenu(title: "", children: menuElements)
	}

	/// Heart or un-heart the message.
	///
	/// - Parameters:
	///    - viewController: The view controller initiating the action.
	///    - userInfo: Any information passed by the user.
	@MainActor
	func heartMessage(via viewController: UIViewController? = nil, userInfo: [AnyHashable: Any]?) async {
		let signedIn = await WorkflowController.shared.isSignedIn(on: viewController)
		guard signedIn else { return }

		do {
			let messageIdentity = FeedMessageIdentity(id: self.id)
			let feedMessageUpdateResponse = try await KService.heartFeedMessage(messageIdentity).response()

			self.attributes.update(using: feedMessageUpdateResponse.data)

			if let indexPath = userInfo?["indexPath"] as? IndexPath {
				NotificationCenter.default.post(name: .KFMDidUpdate, object: nil, userInfo: ["indexPath": indexPath])
			}
		} catch {
			print(error.localizedDescription)
		}
	}

	/// Pin or un-pin the message.
	///
	/// - Parameters:
	///    - viewController: The view controller initiating the action.
	///    - userInfo: Any information passed by the user.
	func pinMessage(via viewController: UIViewController? = UIApplication.topViewController, userInfo: [AnyHashable: Any]?) {
		let title = self.attributes.isPinned ? L10n.unpinMessageHeadline : L10n.pinMessageHeadline
		let message = self.attributes.isPinned ? L10n.unpinMessageSubheadline : L10n.pinMessageSubheadline
		let primaryActionStyle: UIAlertAction.Style = self.attributes.isPinned ? .destructive : .default

		let actionSheetAlertController = UIAlertController.alert(title: title, message: message) { [weak self] alertController in
			guard let self = self else { return }

			let pinAction = UIAlertAction(title: self.attributes.isPinned ? L10n.unpin : L10n.pin, style: primaryActionStyle) { _ in
				Task {
					do {
						let messageIdentity = FeedMessageIdentity(id: self.id)
						let feedMessageUpdateResponse = try await KService.pinFeedMessage(messageIdentity).response()

						self.attributes.update(using: feedMessageUpdateResponse.data)

						if let indexPath = userInfo?["indexPath"] as? IndexPath {
							NotificationCenter.default.post(name: .KFMDidUpdate, object: nil, userInfo: ["indexPath": indexPath])
						}
					} catch {
						print(error.localizedDescription)
					}
				}
			}
			alertController.addAction(pinAction)
			alertController.preferredAction = pinAction
		}

		// Present the controller
		if let popoverController = actionSheetAlertController.popoverPresentationController {
			if let view = viewController?.view {
				popoverController.sourceView = view
				popoverController.sourceRect = view.bounds
			}
		}

		if (viewController?.navigationController?.visibleViewController as? UIAlertController) == nil {
			viewController?.present(actionSheetAlertController, animated: true, completion: nil)
		}
	}

	/// Presents the reply view for the current message.
	///
	/// - Parameters:
	///    - viewController: The view controller initiating the action.
	///    - userInfo: Any information passed by the user.
	@MainActor
	func replyToMessage(via viewController: UIViewController? = nil, userInfo: [AnyHashable: Any]?) async {
		let signedIn = await WorkflowController.shared.isSignedIn(on: viewController)
		guard signedIn else { return }

		self.openTextEditor(layout: .reply, via: viewController, userInfo: userInfo, isEditingMessage: false)
	}

	/// Presents the re-share view for the current message.
	///
	/// - Parameters:
	///    - viewController: The view controller initiating the action.
	///    - userInfo: Any information passed by the user.
	@MainActor
	func reShareMessage(via viewController: UIViewController? = nil, userInfo: [AnyHashable: Any]?) async {
		let signedIn = await WorkflowController.shared.isSignedIn(on: viewController)
		guard signedIn else { return }

		if !self.attributes.isReShared {
			self.openTextEditor(layout: .reShare, via: viewController, userInfo: userInfo, isEditingMessage: false)
		} else {
			let viewController = viewController ?? UIApplication.topViewController
			viewController?.presentAlertController(title: L10n.reshareMessageErrorHeadline, message: L10n.reshareMessageErrorSubheadline)
		}
	}

	/// Presents the text editor on the given view controller with the specified layout.
	///
	/// - Parameters:
	///    - layout: The editor layout to use (standard, reply, or reShare).
	///    - viewController: The view controller initiating the action.
	///    - userInfo: Any information passed by the user.
	///    - isEditingMessage: Whether the user is editing a message.
	func openTextEditor(layout: FeedMessageEditorLayout, via viewController: UIViewController? = UIApplication.topViewController, userInfo: [AnyHashable: Any]?, isEditingMessage: Bool) {
		let editor = KFeedMessageTextEditorViewController()
		editor.delegate = viewController as? KFeedMessageTextEditorViewDelegate
		editor.editorLayout = layout

		if isEditingMessage {
			editor.editingFeedMessage = self
			editor.opFeedMessage = self.relationships.parent?.data.first
			editor.userInfo = userInfo ?? [:]
		} else {
			switch layout {
			case .reply:
				editor.segueToOPFeedDetails = !(userInfo?["liveReplyEnabled"] as? Bool ?? false)
				editor.opFeedMessage = self
			case .reShare:
				editor.segueToOPFeedDetails = !(userInfo?["liveReShareEnabled"] as? Bool ?? false)
				editor.opFeedMessage = self
			case .standard:
				break
			}
		}

		let kurozoraNavigationController = KNavigationController(rootViewController: editor)
		kurozoraNavigationController.presentationController?.delegate = editor
		kurozoraNavigationController.navigationBar.prefersLargeTitles = false
		kurozoraNavigationController.sheetPresentationController?.detents = [.medium(), .large()]
		kurozoraNavigationController.sheetPresentationController?.selectedDetentIdentifier = .large
		kurozoraNavigationController.sheetPresentationController?.prefersEdgeAttachedInCompactHeight = true
		kurozoraNavigationController.sheetPresentationController?.prefersGrabberVisible = true
		viewController?.present(kurozoraNavigationController, animated: true)
	}

	/// Presents the edit view for the current message.
	///
	/// - Parameters:
	///    - viewController: The view controller initiating the action.
	///    - userInfo: Any information passed by the user.
	func editMessage(via viewController: UIViewController? = UIApplication.topViewController, userInfo: [AnyHashable: Any]?) {
		if self.attributes.isReply {
			self.openTextEditor(layout: .reply, via: viewController, userInfo: userInfo, isEditingMessage: true)
		} else if self.attributes.isReShare {
			self.openTextEditor(layout: .reShare, via: viewController, userInfo: userInfo, isEditingMessage: true)
		} else {
			self.openTextEditor(layout: .standard, via: viewController, userInfo: userInfo, isEditingMessage: true)
		}
	}

	/// Remove the feed message from the user's messages list.
	///
	/// - Parameter indexPath: The index path of the message.
	private func remove(at indexPath: IndexPath) async {
		do {
			let messageIdentity = FeedMessageIdentity(id: self.id)
			_ = try await KService.deleteFeedMessage(messageIdentity).response()

			NotificationCenter.default.post(name: .KFMDidDelete, object: nil, userInfo: ["indexPath": indexPath])
		} catch {
			print(error.localizedDescription)
		}
	}

	/// Confirm if the user wants to delete the message.
	private func confirmDelete(via viewController: UIViewController? = UIApplication.topViewController, userInfo: [AnyHashable: Any]?) {
		let actionSheetAlertController = UIAlertController.alert(title: nil, message: L10n.deleteMessageSubheadline) { [weak self] alertController in
			guard let self = self else { return }

			let deleteAction = UIAlertAction(title: L10n.deleteMessage, style: .destructive) { _ in
				if let indexPath = userInfo?["indexPath"] as? IndexPath {
					Task {
						await self.remove(at: indexPath)
					}
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

	/// Presents the details view of the message.
	///
	/// - Parameter viewController: The view controller initiating the segue.
	func visitRepliesView(from viewController: UIViewController? = UIApplication.topViewController) {
		let fmDetailsTableViewController = FMDetailsTableViewController()
		fmDetailsTableViewController.feedMessageID = self.id

		viewController?.show(fmDetailsTableViewController, sender: nil)
	}

	/// Presents the profile view for the message poster.
	///
	/// - Parameter viewController: The view controller initiating the segue.
	func visitOriginalPosterProfile(from viewController: UIViewController? = UIApplication.topViewController) {
		guard let user = self.relationships.users.data.first else { return }
		let profileTableViewController = ProfileTableViewController()(with: user)

		viewController?.show(profileTableViewController, sender: nil)
	}

	/// Present share sheet for the feed message.
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
		var shareText = "\"\(self.attributes.content)\""
		if let user = self.relationships.users.data.first {
			shareText += "-\(user.attributes.username)"
		}

		let activityItems: [Any] = [shareText]
		let activityViewController = UIActivityViewController(activityItems: activityItems, applicationActivities: [])

		if let popoverController = activityViewController.popoverPresentationController {
			if let sourceView = sourceView {
				popoverController.sourceView = sourceView
				popoverController.sourceRect = sourceView.frame
			} else {
				popoverController.barButtonItem = barButtonItem
			}
		}

		let viewController = viewController ?? UIApplication.topViewController
		viewController?.present(activityViewController, animated: true, completion: nil)
	}

	/// Sends a report of the selected message to the mods.
	///
	/// - Parameters:
	///   - viewController: The view controller initiating the report.
	@MainActor
	func reportMessage(on viewController: UIViewController? = nil) async {
		let signedIn = await WorkflowController.shared.isSignedIn(on: viewController)
		guard signedIn else { return }

		let viewController = viewController ?? UIApplication.topViewController
		viewController?.presentAlertController(title: L10n.messageReportedHeadline, message: L10n.messageReportedSubheadline)
	}

	/// Collects image URLs for Kingfisher prefetching and triggers background RichLink metadata fetches.
	///
	/// - Parameter imageURLs: Array to append profile image URLs to for batch prefetching.
	@MainActor
	func collectPrefetchURLs(into imageURLs: inout [URL]) {
		if let user = self.relationships.users.data.first,
		   let urlString = user.attributes.profile?.url,
		   !urlString.isEmpty,
		   let url = URL(string: urlString) {
			imageURLs.append(url)
		}

		if let url = self.attributes.content.extractURLs().last, url.isWebURL {
			if RichLink.shared.cachedMetadata(for: url) == nil {
				Task { _ = await RichLink.shared.fetchMetadata(for: url) }
			}
		}

		if let opMessage = self.relationships.parent?.data.first {
			if let opUser = opMessage.relationships.users.data.first,
			   let urlString = opUser.attributes.profile?.url,
			   !urlString.isEmpty,
			   let url = URL(string: urlString) {
				imageURLs.append(url)
			}

			if let url = opMessage.attributes.content.extractURLs().last, url.isWebURL {
				if RichLink.shared.cachedMetadata(for: url) == nil {
					Task { _ = await RichLink.shared.fetchMetadata(for: url) }
				}
			}
		}
	}
}
