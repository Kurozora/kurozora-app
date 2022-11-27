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
	@IBOutlet weak var opMessagePreviewContainer: UIView! {
		didSet {
			self.opMessagePreviewContainer.theme_backgroundColor = KThemePicker.tableViewCellBackgroundColor.rawValue
		}
	}

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
		self.opMessageTextView.setAttributedText(self.opFeedMessage.attributes.contentHTML.htmlAttributedString())
		self.opDateTimeLabel.text = self.opFeedMessage.attributes.createdAt.relativeToNow
	}

	// MARK: - Functions
	override func performFeedMessageRequest() async {
		if let feedMessage = self.editingFeedMessage {
			do {
				let feedMessageUpdateResponse = try await KService.updateMessage(feedMessage.id, withContent: self.editedText, isNSFW: self.isNSFWSwitch.isOn, isSpoiler: self.isSpoilerSwitch.isOn).value
				let feedMessageUpdate = feedMessageUpdateResponse.data

				self.editingFeedMessage?.attributes.update(using: feedMessageUpdate)
				NotificationCenter.default.post(name: .KFMDidUpdate, object: nil, userInfo: self.userInfo)
				self.dismiss(animated: true, completion: nil)
			} catch {
				print("-----", error.localizedDescription)
			}
		} else {
			do {
				let feedMessagesResponse = try await KService.postFeedMessage(withContent: self.editedText, relatedToParent: self.opFeedMessage.id, isReply: true, isReShare: false, isNSFW: self.isNSFWSwitch.isOn, isSpoiler: self.isSpoilerSwitch.isOn).value
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
