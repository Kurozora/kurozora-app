//
//  SearchThreadCell.swift
//  Kurozora
//
//  Created by Khoren Katklian on 28/12/2018.
//  Copyright © 2018 Kurozora. All rights reserved.
//

//import UIKit
//
//class SearchThreadCell: UICollectionViewCell {
//	@IBOutlet weak var titleLabel: UILabel!
//	@IBOutlet weak var contentTeaserLabel: UILabel!
//	@IBOutlet weak var lockLabel: UILabel!
//
//	var searchElement: SearchElement? {
//		didSet {
//			update()
//		}
//	}
//
//	private func update() {
//		guard let searchElement = searchElement else { return }
//
//		titleLabel.text = searchElement.title
//		contentTeaserLabel.text = searchElement.contentTeaser
//		
//		if let locked = searchElement.locked, locked {
//			lockLabel.isHidden = false
//		} else {
//			lockLabel.isHidden = true
//		}
//	}
//}
