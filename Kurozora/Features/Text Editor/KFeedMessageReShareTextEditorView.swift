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
		return "Write a comment..."
	}
	var opFeedMessage: FeedMessage!
	var segueToOPFeedDetails: Bool = false

	// MARK: - View
	override func viewDidLoad() {
		super.viewDidLoad()

		if let opUser = self.opFeedMessage.relationships.users.data.first {
			self.opUsernameLabel.text = opUser.attributes.username
			self.opProfileImageView.setImage(with: opUser.attributes.profile?.url ?? "", placeholder: opUser.attributes.placeholderImage)
		}
		self.opMessageTextView.text = self.opFeedMessage.attributes.body
		self.dateLabel.text = self.opFeedMessage.attributes.createdAt.relativeToNow
	}

	// MARK: - IBActions
	override func performFeedMessageRequest() {
		if let feedMessage = self.editingFeedMessage {
			let isNSFW = self.isNSFWSwitch?.isOn ?? feedMessage.attributes.isNSFW
			let isSpoiler = self.isSpoilerSwitch?.isOn ?? feedMessage.attributes.isSpoiler

			KService.updateMessage(feedMessage.id, withBody: self.editedText, isNSFW: isNSFW, isSpoiler: isSpoiler) { [weak self] result in
				guard let self = self else { return }
				switch result {
				case .success(let feedMessageUpdate):
					self.editingFeedMessage?.attributes.update(using: feedMessageUpdate)
					NotificationCenter.default.post(name: .KFMDidUpdate, object: nil, userInfo: self.userInfo)
					self.dismiss(animated: true, completion: nil)
				case .failure: break
				}
			}
		} else {
			KService.postFeedMessage(withBody: self.editedText, relatedToParent: self.opFeedMessage.id, isReply: false, isReShare: true, isNSFW: self.opFeedMessage.attributes.isNSFW, isSpoiler: self.opFeedMessage.attributes.isSpoiler) { [weak self] result in
				guard let self = self else { return }
				switch result {
				case .success(let feedMessages):
					if self.segueToOPFeedDetails, let feedMessage = feedMessages.first {
						self.delegate?.segueToOPFeedDetails(feedMessage)
					} else {
						self.delegate?.kFeedMessageTextEditorView(updateMessagesWith: feedMessages)
					}
					self.dismiss(animated: true, completion: nil)
				case .failure: break
				}
			}
		}
	}
}
