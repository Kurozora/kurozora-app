//
//  ReplyCellDelegate.swift
//  Kurozora
//
//  Created by Khoren Katklian on 16/01/2021.
//  Copyright © 2021 Kurozora. All rights reserved.
//

import UIKit
import KurozoraKit

protocol ReplyCellDelegate: class {
	func voteOnReplyCell(_ cell: ReplyCell, with voteStatus: VoteStatus)
	func visitOriginalPosterProfile(_ cell: ReplyCell)
	func showActionsList(_ cell: ReplyCell, sender: UIButton)
}
