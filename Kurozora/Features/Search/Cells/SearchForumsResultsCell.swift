//
//  SearchForumsResultsCell.swift
//  Kurozora
//
//  Created by Khoren Katklian on 27/09/2019.
//  Copyright © 2019 Kurozora. All rights reserved.
//

import UIKit

class SearchForumsResultsCell: SearchBaseResultsCell {
	// MARK: - Properties
	var forumsThreadElement: ForumsThreadElement? = nil {
		didSet {
			if forumsThreadElement != nil {
				configureCell()
			}
		}
	}

	override func configureCell() {
		super.configureCell()
		guard let forumsThreadElement = forumsThreadElement else { return }

		primaryLabel.text = forumsThreadElement.title
		textView?.text = forumsThreadElement.content

		// Configure lock
		if let locked = forumsThreadElement.locked {
			searchImageView.isHidden = !locked
		}
	}
}
