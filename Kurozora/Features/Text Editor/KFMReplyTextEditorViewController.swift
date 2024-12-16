//
//  KFMReplyTextEditorViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 31/08/2020.
//  Copyright © 2020 Kurozora. All rights reserved.
//

import UIKit
import KurozoraKit

class KFMReplyTextEditorViewController: KFeedMessageTextEditorViewController {
	// MARK: - IBOutlets
	@IBOutlet weak var opProfileImageView: ProfileImageView!
	@IBOutlet weak var opUsernameLabel: KLabel!
	@IBOutlet weak var opMessageTextView: KSelectableTextView!
	@IBOutlet weak var opDateTimeLabel: KSecondaryLabel!
	@IBOutlet weak var opMessagePreviewContainer: UIView!

	// MARK: - Properties
	override var placeholderText: String {
		return Trans.whatsOnYourMind
	}
	var opFeedMessage: FeedMessage!
	var segueToOPFeedDetails: Bool = false

	// MARK: - View
	override func viewDidLoad() {
		super.viewDidLoad()

		if let opUser = self.opFeedMessage.relationships.users.data.first {
			self.opUsernameLabel.text = opUser.attributes.username
			opUser.attributes.profileImage(imageView: self.opProfileImageView)
		}
		self.opMessageTextView.setAttributedText(self.opFeedMessage.attributes.contentMarkdown.markdownAttributedString())
		self.opDateTimeLabel.text = self.opFeedMessage.attributes.createdAt.relativeToNow
	}

	// MARK: - Functions
	override func performFeedMessageRequest() async {
		if let feedMessage = self.editingFeedMessage {
			do {
				let feedMessageIdentity = FeedMessageIdentity(id: feedMessage.id)
				let feedMessageUpdateRequest = FeedMessageUpdateRequest(feedMessageIdentity: feedMessageIdentity, content: self.editedText, isNSFW: self.isNSFW, isSpoiler: self.isSpoiler)
				let feedMessageUpdateResponse = try await KService.updateMessage(feedMessageUpdateRequest).value
				let feedMessageUpdate = feedMessageUpdateResponse.data

				self.editingFeedMessage?.attributes.update(using: feedMessageUpdate)
				NotificationCenter.default.post(name: .KFMDidUpdate, object: nil, userInfo: self.userInfo)
				self.dismiss(animated: true, completion: nil)
			} catch {
				print("-----", error.localizedDescription)
			}
		} else {
			do {
				let parentFeedMessageIdentity = FeedMessageIdentity(id: self.opFeedMessage.id)
				let feedMessageRequest = FeedMessageRequest(content: self.editedText, parentIdentity: parentFeedMessageIdentity, isReply: true, isReShare: false, isNSFW: self.isNSFW, isSpoiler: self.isSpoiler)
				let feedMessagesResponse = try await KService.postFeedMessage(feedMessageRequest).value
				let feedMessages = feedMessagesResponse.data

				if self.segueToOPFeedDetails {
					self.delegate?.segueToOPFeedDetails(self.opFeedMessage)
				} else {
					self.delegate?.kFeedMessageTextEditorView(updateMessagesWith: feedMessages)
				}

				self.dismiss(animated: true, completion: nil)
			} catch {
				print("-----", error.localizedDescription)
			}
		}
	}
}
