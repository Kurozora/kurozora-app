//
//  BaseFeedMessageCellDelegate.swift
//  Kurozora
//
//  Created by Khoren Katklian on 18/01/2021.
//  Copyright © 2021 Kurozora. All rights reserved.
//

import UIKit

protocol BaseFeedMessageCellDelegate: AnyObject {
	func baseFeedMessageCell(_ cell: BaseFeedMessageCell, didPressHeartButton button: UIButton)
	func baseFeedMessageCell(_ cell: BaseFeedMessageCell, didPressReplyButton button: UIButton)
	func baseFeedMessageCell(_ cell: BaseFeedMessageCell, didPressReShareButton button: UIButton)
	func baseFeedMessageCell(_ cell: BaseFeedMessageCell, didPressMoreButton button: UIButton)
	func baseFeedMessageCell(_ cell: BaseFeedMessageCell, didPressUserName sender: AnyObject)
}
