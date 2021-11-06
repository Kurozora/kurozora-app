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

		if let user = User.current {
			self.currentUsernameLabel.text = user.attributes.username
			self.profileImageView.setImage(with: user.attributes.profile?.url ?? "", placeholder: user.attributes.placeholderImage)

		}
		self.characterCountLabel.text = "\(self.characterLimit)"
		self.commentTextView.text = self.placeholderText
		self.commentTextView.theme_textColor = KThemePicker.textFieldPlaceholderTextColor.rawValue
		self.commentTextView.becomeFirstResponder()
		self.commentTextView.selectedTextRange = self.commentTextView.textRange(from: self.commentTextView.beginningOfDocument, to: self.commentTextView.beginningOfDocument)

		if let opUser = self.opFeedMessage.relationships.users.data.first {
			self.opUsernameLabel.text = opUser.attributes.username
			self.opProfileImageView.setImage(with: opUser.attributes.profile?.url ?? "", placeholder: opUser.attributes.placeholderImage)
		}
		self.opMessageTextView.text = self.opFeedMessage.attributes.body
		self.dateLabel.text = self.opFeedMessage.attributes.createdAt.relativeToNow
	}

	// MARK: - IBActions
	override func performFeedMessageRequest(feedMessage: String) {
		KService.postFeedMessage(withBody: feedMessage, relatedToParent: opFeedMessage.id, isReply: false, isReShare: true, isNSFW: opFeedMessage.attributes.isNSFW, isSpoiler: opFeedMessage.attributes.isSpoiler) { [weak self] result in
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
