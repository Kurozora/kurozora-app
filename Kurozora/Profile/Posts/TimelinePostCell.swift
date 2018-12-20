//
//  TimelinePostCell.swift
//  Kurozora
//
//  Created by Khoren Katklian on 29/11/2018.
//  Copyright © 2018 Kurozora. All rights reserved.
//

import UIKit

class TimelinePostCell: UITableViewCell {
	@IBOutlet weak var profileImageView: UIImageView!
	@IBOutlet weak var userNameLabel: UILabel!
	@IBOutlet weak var userSeparatorLabel: UILabel!
	@IBOutlet weak var otherUserNameLabel: UILabel!
	@IBOutlet weak var dateTimeLabel: UILabel!
	@IBOutlet weak var postTextView: UITextView!
	@IBOutlet weak var heartButton: UIButton!
	@IBOutlet weak var commentButton: UIButton!
	@IBOutlet weak var reshareButton: UIButton!
}
