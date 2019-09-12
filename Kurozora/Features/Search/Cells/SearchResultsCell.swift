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
import SwiftTheme

class SearchResultsCell: UITableViewCell {
	@IBOutlet weak var collectionView: UICollectionView?

	// Global cell outlets
	@IBOutlet weak var separatorView: UIView?
	@IBOutlet weak var visualEffectView: UIVisualEffectView? {
		didSet {
			visualEffectView?.theme_effect = ThemeVisualEffectPicker(keyPath: KThemePicker.visualEffect.stringValue, vibrancyEnabled: true)
			visualEffectView?.theme_backgroundColor = KThemePicker.blurBackgroundColor.rawValue
		}
	}

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
	@IBOutlet weak var libraryStatusButton: UIButton? {
		didSet {
			libraryStatusButton?.theme_setTitleColor(KThemePicker.tintedButtonTextColor.rawValue, forState: .normal)
			libraryStatusButton?.theme_backgroundColor = KThemePicker.tintColor.rawValue
		}
	}

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
	var searchResultsTableViewController: SearchResultsTableViewController!

	// MARK: - Functions
	fileprivate func configureCell() {
		guard let searchElement = searchElement else { return }
		guard let reuseIdentifier = self.reuseIdentifier else { return }
		let cellType = SearchScope.scope(from: reuseIdentifier)

		switch cellType {
		case .show:
			titleLabel?.text = searchElement.title

			if let posterThumbnail = searchElement.posterThumbnail, !posterThumbnail.isEmpty {
				let posterThumbnailUrl = URL(string: posterThumbnail)
				let resource = ImageResource(downloadURL: posterThumbnailUrl!)
				posterImageView?.kf.indicatorType = .activity
				posterImageView?.kf.setImage(with: resource, placeholder: #imageLiteral(resourceName: "placeholder_poster"), options: [.transition(.fade(0.2))])
			} else {
				posterImageView?.image = #imageLiteral(resourceName: "placeholder_poster")
			}

			statusLabel?.text = searchElement.status ?? "TBA"

			// Configure library status
			if let libraryStatus = searchElement.currentUser?.libraryStatus, !libraryStatus.isEmpty {
				libraryStatusButton?.setTitle("\(libraryStatus.capitalized) ▾", for: .normal)
			} else {
				libraryStatusButton?.setTitle("ADD", for: .normal)
			}

			// Cinfigure rating
			if let rating = searchElement.rating, !rating.isEmpty {
				showRatingLabel?.text = rating
			} else {
				showRatingLabel?.isHidden = true
			}

			// Configure episode count
			if let episodeCount = searchElement.episodeCount, episodeCount != 0 {
				episodeCountLabel?.text = "\(episodeCount)"
			} else {
				episodeCountLabel?.isHidden = true
			}

			// Configure air date
			if let airDate = searchElement.airDate, !airDate.isEmpty {
				airDateLabel?.text = airDate
			} else {
				airDateLabel?.isHidden = true
			}

			// Configure score
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
		case .myLibrary: break
		case .thread:
			titleLabel?.text = searchElement.title
			contentTeaserLabel?.text = searchElement.contentTeaser

			if let locked = searchElement.locked {
				lockLabel?.isHidden = locked
			}
		case .user:
			usernameLabel?.text = searchElement.username

			if let avatar = searchElement.avatar, !avatar.isEmpty {
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
		}
	}

	// MARK: - Functions
	@IBAction func chooseStatusButtonPressed(_ sender: UIButton) {
		guard let libraryStatus = searchElement?.currentUser?.libraryStatus else { return }
		let action = UIAlertController.actionSheetWithItems(items: [("Planning", "Planning"), ("Watching", "Watching"), ("Completed", "Completed"), ("Dropped", "Dropped"), ("On-Hold", "OnHold")], currentSelection: libraryStatus, action: { (title, value)  in
			guard let showID = self.searchElement?.id else { return }

			if libraryStatus != value {
				Service.shared.addToLibrary(withStatus: value, showID: showID, withSuccess: { (success) in
					if success {
						// Update entry in library
						self.searchElement?.currentUser?.libraryStatus = value

						let libraryUpdateNotificationName = Notification.Name("Update\(value)Section")
						NotificationCenter.default.post(name: libraryUpdateNotificationName, object: nil)

						self.libraryStatusButton?.setTitle("\(title) ▾", for: .normal)
					}
				})
			}
		})

		if let libraryStatus = searchElement?.currentUser?.libraryStatus, !libraryStatus.isEmpty {
			action.addAction(UIAlertAction.init(title: "Remove from library", style: .destructive, handler: { (_) in
				Service.shared.removeFromLibrary(withID: self.searchElement?.id, withSuccess: { (success) in
					if success {
						self.searchElement?.currentUser?.libraryStatus = ""
						self.libraryStatusButton?.setTitle("ADD", for: .normal)
					}
				})
			}))
		}
		action.addAction(UIAlertAction.init(title: "Cancel", style: .cancel, handler: nil))

		//Present the controller
		if let popoverController = action.popoverPresentationController {
			popoverController.sourceView = sender
			popoverController.sourceRect = sender.bounds
		}

		searchResultsTableViewController.present(action, animated: true, completion: nil)
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

// MARK: - UICollectionViewDelegateFlowLayout
extension SearchResultsCell: UICollectionViewDelegateFlowLayout {
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
		return CGSize(width: 88, height: 124)
	}
}
