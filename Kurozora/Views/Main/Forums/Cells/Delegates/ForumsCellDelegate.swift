//
//  ForumsCellDelegate.swift
//  Kurozora
//
//  Created by Khoren Katklian on 16/01/2021.
//  Copyright © 2021 Kurozora. All rights reserved.
//

import UIKit
import KurozoraKit

protocol ForumsCellDelegate: AnyObject {
	func voteOnForumsCell(_ cell: ForumsCell, with voteStatus: VoteStatus)
	func visitOriginalPosterProfile(_ cell: ForumsCell)
	func showActionsList(_ cell: ForumsCell, sender: UIButton)
}
