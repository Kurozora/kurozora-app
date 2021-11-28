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
		return "What's on your mind..."
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
		self.opMessageTextView.text = self.opFeedMessage.attributes.body
		self.opDateTimeLabel.text = self.opFeedMessage.attributes.createdAt.relativeToNow
	}

	// MARK: - Functions
	override func performFeedMessageRequest() {
		if let feedMessage = self.editingFeedMessage {
			KService.updateMessage(feedMessage.id, withBody: self.editedText, isNSFW: self.isNSFWSwitch.isOn, isSpoiler: self.isSpoilerSwitch.isOn) { [weak self] result in
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
			KService.postFeedMessage(withBody: self.editedText, relatedToParent: self.opFeedMessage.id, isReply: true, isReShare: false, isNSFW: self.isNSFWSwitch.isOn, isSpoiler: self.isSpoilerSwitch.isOn) { [weak self] result in
				guard let self = self else { return }
				switch result {
				case .success(let feedMessages):
					if self.segueToOPFeedDetails {
						self.delegate?.segueToOPFeedDetails(self.opFeedMessage)
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
