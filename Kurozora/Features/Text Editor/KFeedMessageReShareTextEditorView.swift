//
//  KFMReShareTextEditorViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 30/08/2020.
//  Copyright © 2020 Kurozora. All rights reserved.
//

import UIKit
import KurozoraKit

class KFMReShareTextEditorViewController: KFeedMessageTextEditorViewController {
	// MARK: - IBOutlets
	@IBOutlet weak var dateLabel: KSecondaryLabel!
	@IBOutlet weak var opProfileImageView: ProfileImageView!
	@IBOutlet weak var opUsernameLabel: KLabel!
	@IBOutlet weak var opMessageTextView: KSelectableTextView!

	// MARK: - Properties
	override var placeholderText: String {
		return Trans.writeAComment
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
		self.opMessageTextView.setAttributedText(self.opFeedMessage.attributes.contentHTML.htmlAttributedString())
		self.dateLabel.text = self.opFeedMessage.attributes.createdAt.relativeToNow
	}

	// MARK: - IBActions
	override func performFeedMessageRequest() async {
		if let feedMessage = self.editingFeedMessage {
			let isNSFW = self.isNSFWSwitch?.isOn ?? feedMessage.attributes.isNSFW
			let isSpoiler = self.isSpoilerSwitch?.isOn ?? feedMessage.attributes.isSpoiler

			do {
				let feedMessageUpdateResponse = try await KService.updateMessage(feedMessage.id, withContent: self.editedText, isNSFW: isNSFW, isSpoiler: isSpoiler).value
				let feedMessageUpdate = feedMessageUpdateResponse.data

				self.editingFeedMessage?.attributes.update(using: feedMessageUpdate)
				NotificationCenter.default.post(name: .KFMDidUpdate, object: nil, userInfo: self.userInfo)
				self.dismiss(animated: true, completion: nil)
			} catch {
				print("-----", error.localizedDescription)
			}
		} else {
			do {
				let feedMessagesResponse = try await KService.postFeedMessage(withContent: self.editedText, relatedToParent: self.opFeedMessage.id, isReply: false, isReShare: true, isNSFW: self.opFeedMessage.attributes.isNSFW, isSpoiler: self.opFeedMessage.attributes.isSpoiler).value
				let feedMessages = feedMessagesResponse.data

				if self.segueToOPFeedDetails, let feedMessage = feedMessages.first {
					self.delegate?.segueToOPFeedDetails(feedMessage)
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
