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
	@IBOutlet weak var contentLabel: UILabel?
	@IBOutlet weak var lockLabel: UILabel?

	// User search cell outlets
	@IBOutlet weak var usernameLabel: UILabel?
	@IBOutlet weak var profileImageView: UIImageView?
	@IBOutlet weak var followerCountLabel: UILabel?
	@IBOutlet weak var followButton: UIButton?

	var showDetailsElement: ShowDetailsElement? {
		didSet {
			if showDetailsElement != nil {
				configureCell()
			}
		}
	}
	var forumsThreadElement: ForumsThreadElement? = nil {
		didSet {
			if forumsThreadElement != nil {
				configureCell()
			}
		}
	}
	var userProfile: UserProfile? = nil {
		didSet {
			if userProfile != nil {
				configureCell()
			}
		}
	}
	var suggestionElement: [ShowDetailsElement]? {
		didSet {
			collectionView?.dataSource = self
			collectionView?.delegate = self
			collectionView?.reloadData()
		}
	}
	var searchResultsTableViewController: SearchResultsTableViewController!

	// MARK: - Functions
	/// Configure the cell with the given details.
	fileprivate func configureCell() {
		guard let reuseIdentifier = self.reuseIdentifier else { return }
		let cellType = SearchScope.scope(from: reuseIdentifier)

		switch cellType {
		case .show:
			guard let showDetailsElement = showDetailsElement else { return }

			titleLabel?.text = showDetailsElement.title

			if let posterThumbnail = showDetailsElement.posterThumbnail, !posterThumbnail.isEmpty {
				if let posterThumbnailUrl = URL(string: posterThumbnail) {
					let resource = ImageResource(downloadURL: posterThumbnailUrl)
					posterImageView?.kf.indicatorType = .activity
					posterImageView?.kf.setImage(with: resource, placeholder: #imageLiteral(resourceName: "placeholder_poster_image"), options: [.transition(.fade(0.2))])
				}
			} else {
				posterImageView?.image = #imageLiteral(resourceName: "placeholder_poster_image")
			}

			statusLabel?.text = showDetailsElement.status ?? "TBA"

			// Configure library status
			if let libraryStatus = showDetailsElement.currentUser?.libraryStatus, !libraryStatus.isEmpty {
				libraryStatusButton?.setTitle("\(libraryStatus.capitalized) ▾", for: .normal)
			} else {
				libraryStatusButton?.setTitle("ADD", for: .normal)
			}

			// Cinfigure rating
			if let watchRating = showDetailsElement.watchRating, !watchRating.isEmpty {
				showRatingLabel?.text = watchRating
			} else {
				showRatingLabel?.isHidden = true
			}

			// Configure episode count
			if let episodeCount = showDetailsElement.episodes, episodeCount != 0 {
				episodeCountLabel?.text = "\(episodeCount) \(episodeCount == 1 ? "Episode" : "Episodes")"
			} else {
				episodeCountLabel?.isHidden = true
			}

			// Configure air date
			if let airDate = showDetailsElement.airDate, !airDate.isEmpty {
				airDateLabel?.text = airDate
			} else {
				airDateLabel?.isHidden = true
			}

			// Configure score
			if let score = showDetailsElement.averageRating, score != 0 {
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
			guard let forumsThreadElement = forumsThreadElement else { return }

			titleLabel?.text = forumsThreadElement.title
			contentLabel?.text = forumsThreadElement.content

			// Configure lock
			if let locked = forumsThreadElement.locked {
				lockLabel?.isHidden = locked
			}
		case .user:
			guard let userProfile = userProfile else { return }

			usernameLabel?.text = userProfile.username

			// Configure profile image
			if let profileImage = userProfile.profileImage, !profileImage.isEmpty {
				let profileImageUrl = URL(string: profileImage)
				let resource = ImageResource(downloadURL: profileImageUrl!)
				profileImageView?.kf.indicatorType = .activity
				profileImageView?.kf.setImage(with: resource, placeholder: #imageLiteral(resourceName: "default_profile_image"), options: [.transition(.fade(0.2))])
			} else {
				profileImageView?.image = #imageLiteral(resourceName: "default_profile_image")
			}

			// Configure follower count label
			if let followerCount = userProfile.followerCount {
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
		guard let libraryStatus = showDetailsElement?.currentUser?.libraryStatus else { return }
		let action = UIAlertController.actionSheetWithItems(items: [("Watching", "Watching"), ("Planning", "Planning"), ("Completed", "Completed"), ("On-Hold", "OnHold"), ("Dropped", "Dropped")], currentSelection: libraryStatus, action: { (title, value)  in
			guard let showID = self.showDetailsElement?.id else { return }

			if libraryStatus != value {
				Service.shared.addToLibrary(withStatus: value, showID: showID, withSuccess: { (success) in
					if success {
						// Update entry in library
						self.showDetailsElement?.currentUser?.libraryStatus = value

						let libraryUpdateNotificationName = Notification.Name("Update\(value)Section")
						NotificationCenter.default.post(name: libraryUpdateNotificationName, object: nil)

						self.libraryStatusButton?.setTitle("\(title) ▾", for: .normal)
					}
				})
			}
		})

		if let libraryStatus = showDetailsElement?.currentUser?.libraryStatus, !libraryStatus.isEmpty {
			action.addAction(UIAlertAction.init(title: "Remove from library", style: .destructive, handler: { (_) in
				Service.shared.removeFromLibrary(withID: self.showDetailsElement?.id, withSuccess: { (success) in
					if success {
						self.showDetailsElement?.currentUser?.libraryStatus = ""
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

		if (searchResultsTableViewController.navigationController?.visibleViewController as? UIAlertController) == nil {
			searchResultsTableViewController.present(action, animated: true, completion: nil)
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
		suggestionResultCell.showDetailsElement = suggestionElement?[indexPath.item]
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
