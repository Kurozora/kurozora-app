//
//  SearchUserCell.swift
//  Kurozora
//
//  Created by Khoren Katklian on 26/12/2018.
//  Copyright © 2018 Kurozora. All rights reserved.
//

//import UIKit
//import Kingfisher
//
//class SearchUserCell: UICollectionViewCell {
//	@IBOutlet weak var avatarImageView: UIImageView!
//	@IBOutlet weak var usernameLabel: UILabel!
//	@IBOutlet weak var reputationLabel: UILabel!
//	@IBOutlet weak var followButton: UIButton!
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
//		if let avatar = searchElement.avatar, avatar != "" {
//			let avatarUrl = URL(string: avatar)
//			let resource = ImageResource(downloadURL: avatarUrl!)
//			avatarImageView.kf.indicatorType = .activity
//			avatarImageView.kf.setImage(with: resource, placeholder: #imageLiteral(resourceName: "default_avatar"), options: [.transition(.fade(0.2))])
//		} else {
//			avatarImageView.image = #imageLiteral(resourceName: "default_avatar")
//		}
//
//		usernameLabel.text = searchElement.username
//		reputationLabel.text = "\(searchElement.reputationCount ?? 0)"
//	}
//}
