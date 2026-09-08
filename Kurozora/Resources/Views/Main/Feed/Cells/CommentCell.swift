//
//  CommentCell.swift
//  Kurozora
//
//  Created by Khoren Katklian on 03/05/2018.
//  Copyright © 2018 Kurozora. All rights reserved.
//

import UIKit

class CommentCell: PostCell {
	// MARK: - IBOutlets
	@IBOutlet weak var bubbleView: UIView!

	// MARK: - View
	nonisolated override func awakeFromNib() {
		super.awakeFromNib()

		MainActor.assumeIsolated {
			self.bubbleView.layerCornerRadius = 10
		}
	}
}
