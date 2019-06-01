//
//  SearchResultsCell.swift
//  Kurozora
//
//  Created by Khoren Katklian on 16/03/2019.
//  Copyright © 2019 Kurozora. All rights reserved.
//

import UIKit
import Kingfisher

class SearchResultsCell: UITableViewCell {
	// Global and suggestion search cell outlets
	@IBOutlet weak var posterImageView: UIImageView?
	@IBOutlet weak var titleLabel: UILabel?

	// Show search cell outlets
	@IBOutlet weak var airDateLabel: UILabel?
	@IBOutlet weak var scoreLabel: UILabel?
	@IBOutlet weak var statusLabel: UILabel?

	// Forum search cell outlets
	@IBOutlet weak var contentTeaserLabel: UILabel?
	@IBOutlet weak var lockLabel: UILabel?

	// User search cell outlets
	@IBOutlet weak var avatarImageView: UIImageView?
	@IBOutlet weak var usernameLabel: UILabel?
	@IBOutlet weak var reputationLabel: UILabel?
	@IBOutlet weak var followButton: UIButton?

	var searchElement: SearchElement? {
		didSet {
			update()
		}
	}

	func update() {
		guard let searchElement = searchElement else { return }

		// Global and suggestion search cell
		if let posterThumbnail = searchElement.posterThumbnail, posterThumbnail != "" {
			let posterThumbnailUrl = URL(string: posterThumbnail)
			let resource = ImageResource(downloadURL: posterThumbnailUrl!)
			posterImageView?.kf.indicatorType = .activity
			posterImageView?.kf.setImage(with: resource, placeholder: #imageLiteral(resourceName: "placeholder_poster"), options: [.transition(.fade(0.2))])
		} else {
			posterImageView?.image = #imageLiteral(resourceName: "placeholder_poster")
		}
		titleLabel?.text = searchElement.title

		// Show search cell
		airDateLabel?.text = searchElement.airDate
		scoreLabel?.text = "\(searchElement.averageRating ?? 0)"
		statusLabel?.text = (searchElement.status ?? "TBA")

		// Forum search cell
		contentTeaserLabel?.text = searchElement.contentTeaser
		if let locked = searchElement.locked, locked {
			lockLabel?.isHidden = false
		} else {
			lockLabel?.isHidden = true
		}

		// User search cell
		if let avatar = searchElement.avatar, avatar != "" {
			let avatarUrl = URL(string: avatar)
			let resource = ImageResource(downloadURL: avatarUrl!)
			avatarImageView?.kf.indicatorType = .activity
			avatarImageView?.kf.setImage(with: resource, placeholder: #imageLiteral(resourceName: "default_avatar"), options: [.transition(.fade(0.2))])
		} else {
			avatarImageView?.image = #imageLiteral(resourceName: "default_avatar")
		}
		usernameLabel?.text = searchElement.username
		reputationLabel?.text = "\(searchElement.reputationCount ?? 0)"
	}
}
