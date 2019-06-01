//
//  SearchResultsCell.swift
//  Kurozora
//
//  Created by Khoren Katklian on 16/03/2019.
//  Copyright © 2019 Kurozora. All rights reserved.
//

import UIKit
import Kingfisher
import Cosmos

class SearchResultsCell: UITableViewCell {
	@IBOutlet weak var collectionView: UICollectionView?

	// Global cell outlets
	@IBOutlet weak var separatorView: UIView?
	@IBOutlet weak var visualEffectView: UIVisualEffectView?

	// Show search cell outlets
	@IBOutlet weak var titleLabel: UILabel?
	@IBOutlet weak var posterImageView: UIImageView?
	@IBOutlet weak var statusLabel: UILabel?
	@IBOutlet weak var showRatingLabel: UILabel?
	@IBOutlet weak var episodeCountLabel: UILabel?
	@IBOutlet weak var airDateLabel: UILabel?
	@IBOutlet weak var scoreLabel: UILabel?
	@IBOutlet weak var scoreDecimalLabel: UILabel?
	@IBOutlet weak var cosmosView: CosmosView?

	// Forum search cell outlets
	@IBOutlet weak var contentTeaserLabel: UILabel?
	@IBOutlet weak var lockLabel: UILabel?

	// User search cell outlets
	@IBOutlet weak var usernameLabel: UILabel?
	@IBOutlet weak var avatarImageView: UIImageView?
	@IBOutlet weak var followerCountLabel: UILabel?
	@IBOutlet weak var followButton: UIButton?

	var searchElement: SearchElement? {
		didSet {
			configureCell()
		}
	}
	var suggestionElement: [SearchElement]? {
		didSet {
			collectionView?.dataSource = self
			collectionView?.delegate = self
			collectionView?.reloadData()
		}
	}

	func configureCell() {
		guard let searchElement = searchElement else { return }
		let cellType = SearchList(rawValue: self.reuseIdentifier!)

		switch cellType {
		case .show?:
			titleLabel?.text = searchElement.title

			if let posterThumbnail = searchElement.posterThumbnail, posterThumbnail != "" {
				let posterThumbnailUrl = URL(string: posterThumbnail)
				let resource = ImageResource(downloadURL: posterThumbnailUrl!)
				posterImageView?.kf.indicatorType = .activity
				posterImageView?.kf.setImage(with: resource, placeholder: #imageLiteral(resourceName: "placeholder_poster"), options: [.transition(.fade(0.2))])
			} else {
				posterImageView?.image = #imageLiteral(resourceName: "placeholder_poster")
			}

			statusLabel?.text = searchElement.status ?? "TBA"

			if let rating = searchElement.rating, rating != "" {
				showRatingLabel?.text = rating
			} else {
				showRatingLabel?.isHidden = true
			}

			if let episodeCount = searchElement.episodeCount, episodeCount != 0 {
				episodeCountLabel?.text = "\(episodeCount)"
			} else {
				episodeCountLabel?.isHidden = true
			}

			if let airDate = searchElement.airDate, airDate != "" {
				airDateLabel?.text = airDate
			} else {
				airDateLabel?.isHidden = true
			}

			if let score = searchElement.score, score != 0 {
				var decimalScore = "\(score)"
				decimalScore.removeFirst()

				cosmosView?.rating = score
				scoreLabel?.text = "\(score)".firstCharacterAsString
				scoreDecimalLabel?.text = decimalScore
			} else {
				cosmosView?.isHidden = true
				scoreLabel?.isHidden = true
				scoreDecimalLabel?.isHidden = true
			}
		case .myLibrary?: break
		case .thread?:
			titleLabel?.text = searchElement.title
			contentTeaserLabel?.text = searchElement.contentTeaser

			if let locked = searchElement.locked {
				lockLabel?.isHidden = locked
			}
		case .user?:
			usernameLabel?.text = searchElement.username

			if let avatar = searchElement.avatar, avatar != "" {
				let avatarUrl = URL(string: avatar)
				let resource = ImageResource(downloadURL: avatarUrl!)
				avatarImageView?.kf.indicatorType = .activity
				avatarImageView?.kf.setImage(with: resource, placeholder: #imageLiteral(resourceName: "default_avatar"), options: [.transition(.fade(0.2))])
			} else {
				avatarImageView?.image = #imageLiteral(resourceName: "default_avatar")
			}

			if let followerCount = searchElement.followerCount {
				switch followerCount {
				case 0:
					followerCountLabel?.text = "Be the first to follow!"
				case 1:
					followerCountLabel?.text = "\(followerCount) Follower"
				default:
					followerCountLabel?.text = "\(followerCount.kFormatted) Followers"
				}
			}
		default: break
		}
	}
}

// MARK: - UICollectionViewDataSource
extension SearchResultsCell: UICollectionViewDataSource {
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		guard let suggestionCount = suggestionElement?.count else { return 0 }
		return suggestionCount
	}

	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		let suggestionResultCell = collectionView.dequeueReusableCell(withReuseIdentifier: "SuggestionResultCell", for: indexPath) as! SuggestionResultCell

		suggestionResultCell.searchElement = suggestionElement?[indexPath.item]

		return suggestionResultCell
	}
}

// MARK: - UICollectionViewDelegate
extension SearchResultsCell: UICollectionViewDelegate {

}

extension SearchResultsCell: UICollectionViewDelegateFlowLayout {
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
		return CGSize(width: 88, height: 124)
	}
}

class SuggestionResultCell: UICollectionViewCell {
	@IBOutlet weak var titleLabel: UILabel?
	@IBOutlet weak var posterImageView: UIImageView?

	var searchElement: SearchElement? {
		didSet {
			configureCell()
		}
	}

	fileprivate func configureCell() {
		guard let searchElement = searchElement else { return }
		titleLabel?.text = searchElement.title

		if let posterThumbnail = searchElement.posterThumbnail, posterThumbnail != "" {
			let posterThumbnailUrl = URL(string: posterThumbnail)
			let resource = ImageResource(downloadURL: posterThumbnailUrl!)
			posterImageView?.kf.indicatorType = .activity
			posterImageView?.kf.setImage(with: resource, placeholder: #imageLiteral(resourceName: "placeholder_poster"), options: [.transition(.fade(0.2))])
		} else {
			posterImageView?.image = #imageLiteral(resourceName: "placeholder_poster")
		}
	}
}
