//
//  PostLinkCell.swift
//  Kurozora
//
//  Created by Khoren Katklian on 04/05/2018.
//  Copyright © 2018 Kurozora. All rights reserved.
//

import UIKit

class LinkCell: PostCell {
	@IBOutlet public weak var linkTitleLabel: UILabel!
	@IBOutlet public weak var linkContentLabel: UILabel!
	@IBOutlet public weak var linkUrlLabel: UILabel!

	@IBOutlet weak var linkContentView: UIView!

	public override func awakeFromNib() {
		super.awakeFromNib()

		do {
			let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(pressedOnLink))
			gestureRecognizer.numberOfTouchesRequired = 1
			gestureRecognizer.numberOfTapsRequired = 1
			linkContentView.addGestureRecognizer(gestureRecognizer)
		}

		do {
			let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(pressedOnLink))
			gestureRecognizer.numberOfTouchesRequired = 1
			gestureRecognizer.numberOfTapsRequired = 1
			imageContent?.addGestureRecognizer(gestureRecognizer)
		}

		let borderWidth: CGFloat = 1
		linkContentView.layer.borderColor = #colorLiteral(red: 0.8941176471, green: 0.8941176471, blue: 0.8941176471, alpha: 1).cgColor
		linkContentView.layer.borderWidth = borderWidth
	}

	// MARK: - UITapGestureRecognizer
	@objc func pressedOnLink(sender: AnyObject) {
	}
}
