//
//  SearchForumsResultsCell.swift
//  Kurozora
//
//  Created by Khoren Katklian on 27/09/2019.
//  Copyright © 2019 Kurozora. All rights reserved.
//

import UIKit
import KurozoraKit

class SearchForumsResultsCell: SearchBaseResultsCell {
	// MARK: - Properties
	var forumsThread: ForumsThread! {
		didSet {
			if forumsThread != nil {
				configureCell()
			}
		}
	}

	override func configureCell() {
		super.configureCell()

		primaryLabel.text = forumsThread.attributes.title
		textView?.text = forumsThread.attributes.content

		// Configure lock
		let lockStatus = forumsThread.attributes.lockStatus
		searchImageView.isHidden = !lockStatus.boolValue
	}
}
