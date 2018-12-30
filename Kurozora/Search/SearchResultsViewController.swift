//
//  SearchResultsViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 25/04/2018.
//  Copyright © 2018 Kusa. All rights reserved.
//

import KCommonKit
import SwiftyJSON
import Kingfisher

enum SearchScope: Int {
    case anime = 0
    case myLibrary
	case forum
    case user
}

class SearchResultsViewController: UIViewController, UISearchResultsUpdating {
	@IBOutlet weak var collectionView: UICollectionView!
	@IBOutlet weak var suggestionsCollectionView: UICollectionView!
	@IBOutlet weak var suggestionsCollctionViewHeight: NSLayoutConstraint!
	@IBOutlet weak var suggestionsHeaderView: UIView!

	var results: [SearchElement]?
	var timer: Timer?
	var currentScope: Int!
	var suggestions: [JSON] = [
		[
			"id": 118,
			"title": "ONE ~Kagayaku Kisetsu e~",
			"average_rating": 0,
			"poster_thumbnail": ""
		],
		[
			"id": 202,
			"title": "Naruto",
			"average_rating": 0,
			"poster_thumbnail": "https://www.thetvdb.com/banners/_cache/posters/78857-9.jpg"
		],
		[
			"id": 147,
			"title": "Outlaw Star",
			"average_rating": 0,
			"poster_thumbnail": "https://www.thetvdb.com/banners/_cache/posters/75911-5.jpg"
		],
		[
			"id": 235,
			"title": "Kodocha",
			"average_rating": 0,
			"poster_thumbnail": "https://www.thetvdb.com/banners/_cache/posters/79544-2.jpg"
		],
		[
			"id": 3915,
			"title": "Re: Zero kara Hajimeru Isekai Seikatsu",
			"average_rating": 0,
			"poster_thumbnail": ""
		],
		[
			"id": 56,
			"title": "Vampire Hunter D",
			"average_rating": 0,
			"poster_thumbnail": "https://www.thetvdb.com/banners/_cache/posters/79042-3.jpg"
		],
		[
			"id": 22,
			"title": ".hack",
			"average_rating": 0,
			"poster_thumbnail": "https://www.thetvdb.com/banners/_cache/posters/79099-3.jpg"
		],
		[
			"id": 28,
			"title": "Hellsing",
			"average_rating": 0,
			"poster_thumbnail": "https://www.thetvdb.com/banners/_cache/posters/71278-6.jpg"
		]
	]

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
	}

    override func viewDidLoad() {
        super.viewDidLoad()

		collectionView.isHidden = true
		collectionView.delegate = self
		collectionView.dataSource = self

		// Suggestions collection view
		suggestionsCollctionViewHeight.constant = suggestionsCollctionViewHeight.constant / 2
		suggestionsCollectionView.delegate = self
		suggestionsCollectionView.dataSource = self
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
		suggestionsCollectionView.isHidden = false
		suggestionsHeaderView.isHidden = false
		collectionView.isHidden = true
        view.endEditing(true)
    }

	func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
		guard let searchScope = SearchScope(rawValue: selectedScope) else { return }
		guard let text = searchBar.text else { return }

		results = []
		collectionView.reloadData()

		if text != "" {
			switch searchScope {
			case .anime:
				search(forText: text, searchScope: selectedScope)
			case .myLibrary: break
			case .forum: break
			case .user:
				search(forText: text, searchScope: selectedScope)
			}
		}
	}

	// MARK: - Functions
	fileprivate func search(forText text: String, searchScope: Int) {
		// Prepare view for search
		suggestionsCollectionView.isHidden = true
		suggestionsHeaderView.isHidden = true
		collectionView.isHidden = false
		currentScope = searchScope

		guard let searchScope = SearchScope(rawValue: searchScope) else { return }

		switch searchScope {
		case .anime:
			if text != "" {
				Service.shared.search(forShow: text) { (results) in
					DispatchQueue.main.async {
						self.results = results
						self.collectionView.reloadData()
					}
				}
			}
		case .myLibrary: break
		case .forum: break
		case .user:
			if text != "" {
				Service.shared.search(forUser: text) { (results) in
					DispatchQueue.main.async {
						self.results = results
						self.collectionView.reloadData()
					}
				}
			}
		}
	}

	@objc func search(_ timer: Timer) {
		let userInfo = timer.userInfo as? [String: Any]
		if let text = userInfo?["searchText"] as? String, let scope = userInfo?["searchScope"] as? Int {
			search(forText: text, searchScope: scope)
		}
	}

	// MARK: - IBActions
	@IBAction func showMoreButtonPressed(_ sender: UIButton) {
		if sender.title(for: .normal) == "Show More" {
			sender.setTitle("Show Less", for: .normal)
			self.suggestionsCollctionViewHeight.constant = self.suggestionsCollctionViewHeight.constant * 2
			UIView.animate(withDuration: 0.2, delay: 0, options: .curveLinear, animations: {
				self.view.layoutIfNeeded()
			}, completion: nil)
		} else {
			sender.setTitle("Show More", for: .normal)
			self.suggestionsCollctionViewHeight.constant = self.suggestionsCollctionViewHeight.constant / 2
			UIView.animate(withDuration: 0.2, delay: 0, options: .curveLinear, animations: {
				self.view.layoutIfNeeded()
			}, completion: nil)
		}
	}

	// MARK: - UISearchResultsUpdating
	func updateSearchResults(for searchController: UISearchController) {
		suggestionsCollectionView.isHidden = false
		suggestionsHeaderView.isHidden = false
		collectionView.isHidden = true
		searchController.searchResultsController?.view.isHidden = false
	}

	// MARK: - Prepare for segue
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if segue.identifier == "ShowDetailsSegue" {
			// Show detail for show cell
			if let sender = sender as? Int {
				let showTabBarController = segue.destination as? ShowTabBarController
				showTabBarController?.showID = sender
			}
		} else if segue.identifier == "ProfileSegue" {
			// Show user profile for user cell
			if let sender = sender as? Int {
				let kurozoraNavigationController = segue.destination as? KurozoraNavigationController
				let profileViewController = kurozoraNavigationController?.topViewController as? ProfileViewController
				profileViewController?.otherUserID = sender
			}
		}
	}
}

extension SearchResultsViewController: UISearchBarDelegate {
	// MARK: - UISearchBarDelegate
	func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
		guard let text = searchBar.text else { return }
		let scope = searchBar.selectedScopeButtonIndex

		search(forText: text, searchScope: scope)
	}

	func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
		let searchScope = searchBar.selectedScopeButtonIndex

		if searchText != "" {
			timer?.invalidate()
			timer = Timer.scheduledTimer(timeInterval: 0.6, target: self, selector: #selector(search(_:)), userInfo: ["searchText": searchText, "searchScope": searchScope], repeats: false)
		} else {
			results = []
			collectionView.reloadData()
		}
	}

	func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
		results = []
		collectionView.reloadData()
	}
}

extension SearchResultsViewController: UICollectionViewDataSource {
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
		if collectionView == suggestionsCollectionView {
			return 10
		}

		return 0
	}

	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
		if collectionView == suggestionsCollectionView {
			return 10
		}

		return 0
	}

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		if collectionView == self.collectionView {
			if let resultsCount = results?.count, resultsCount != 0 {
				return resultsCount
			}
			return 0
		}

		// Search suggestion cell
		return suggestions.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		if collectionView == self.collectionView {
			guard let searchScope = SearchScope(rawValue: currentScope) else { return UICollectionViewCell() }

			switch searchScope {
			case .anime:
				let searchShowCell = collectionView.dequeueReusableCell(withReuseIdentifier: "ShowCell", for: indexPath) as! SearchShowCell

				if let posterThumbnail = results?[indexPath.row].posterThumbnail, posterThumbnail != "" {
					let posterThumbnailUrl = URL(string: posterThumbnail)
					let resource = ImageResource(downloadURL: posterThumbnailUrl!)
					searchShowCell.posterImageView.kf.indicatorType = .activity
					searchShowCell.posterImageView.kf.setImage(with: resource, placeholder: #imageLiteral(resourceName: "placeholder_poster"), options: [.transition(.fade(0.2))], progressBlock: nil, completionHandler: nil)
				} else {
					searchShowCell.posterImageView.image = #imageLiteral(resourceName: "placeholder_poster")
				}

				if let title = results?[indexPath.row].title {
					searchShowCell.titleLabel.text = title
				}

				if let airDate = results?[indexPath.row].airDate, airDate != "" {
					searchShowCell.airDateLabel.text = airDate
				} else {
					searchShowCell.airDateLabel.text = "Dec, 25 2018"
				}

				if let averageRating = results?[indexPath.row].averageRating {
					searchShowCell.scoreLabel.text = "\(averageRating)"
				}

				if let status = results?[indexPath.row].status, status != "" {
					searchShowCell.statusLabel.text = status
				} else {
					searchShowCell.statusLabel.text = "Currently Airing"
				}

				return searchShowCell
			case .myLibrary: break
			case .forum:
				let searchThreadCell = collectionView.dequeueReusableCell(withReuseIdentifier: "ThreadCell", for: indexPath) as! SearchThreadCell

				if let title = results?[indexPath.row].title {
					searchThreadCell.titleLabel.text = title
				}

				if let contentTeaser = results?[indexPath.row].contentTeaser {
					searchThreadCell.contentTeaserLabel.text = contentTeaser
				}

				if let locked = results?[indexPath.row].locked {
					if locked {
						searchThreadCell.loackedImageView.image = #imageLiteral(resourceName: "lock_icon")
					} else {
						searchThreadCell.loackedImageView.isHidden = true
						searchThreadCell.loackedImageView.alpha = 0
						searchThreadCell.loackedImageView.width = 0
						searchThreadCell.lockedImageViewHorizontalToTitleLabel.constant = 0
//						searchThreadCell.layoutSubviews()
					}
				}

				return searchThreadCell
			case .user:
				let searchUserCell = collectionView.dequeueReusableCell(withReuseIdentifier: "UserCell", for: indexPath) as! SearchUserCell

				if let avatar = results?[indexPath.row].avatar, avatar != "" {
					let avatarUrl = URL(string: avatar)
					let resource = ImageResource(downloadURL: avatarUrl!)
					searchUserCell.avatarImageView.kf.indicatorType = .activity
					searchUserCell.avatarImageView.kf.setImage(with: resource, placeholder: #imageLiteral(resourceName: "default_avatar"), options: [.transition(.fade(0.2))], progressBlock: nil, completionHandler: nil)
				} else {
					searchUserCell.avatarImageView.image = #imageLiteral(resourceName: "default_avatar")
				}

				if let username = results?[indexPath.row].username, username != "" {
					searchUserCell.usernameLabel.text = username
				} else {
					searchUserCell.usernameLabel.text = ""
				}

				if let reputation = results?[indexPath.row].reputationCount, reputation != 0 {
					searchUserCell.reputationLabel.text = "\(reputation)"
				} else {
					searchUserCell.reputationLabel.text = "0"
				}

				return searchUserCell
			}
			return UICollectionViewCell()
		}

		// Search suggestion cell
		let searchSuggestionCell = collectionView.dequeueReusableCell(withReuseIdentifier: "SearchSuggestionCell", for: indexPath) as! SearchSuggestionCell
		searchSuggestionCell.titleLabel.text = suggestions[indexPath.row]["title"].stringValue

		let posterThumbnail = suggestions[indexPath.row]["poster_thumbnail"].stringValue
		if posterThumbnail != "" {
			let posterThumbnailUrl = URL(string: posterThumbnail)
			let resource = ImageResource(downloadURL: posterThumbnailUrl!)
			searchSuggestionCell.posterImageView.kf.indicatorType = .activity
			searchSuggestionCell.posterImageView.kf.setImage(with: resource, placeholder: #imageLiteral(resourceName: "placeholder_poster"), options: [.transition(.fade(0.2))], progressBlock: nil, completionHandler: nil)
		} else {
			searchSuggestionCell.posterImageView.image = #imageLiteral(resourceName: "placeholder_poster")
		}

		return searchSuggestionCell
    }
}

extension SearchResultsViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		if collectionView == self.collectionView {
			guard let searchScope = SearchScope(rawValue: currentScope) else { return }
			switch searchScope {
			case .anime:
				if let showID = results?[indexPath.item].id {
					self.performSegue(withIdentifier: "ShowDetailsSegue", sender: showID)
				}
			case .myLibrary: break
			case .forum:
				if let threadID = results?[indexPath.item].id {
					self.performSegue(withIdentifier: "ThreadSegue", sender: threadID)
				}
			case .user:
				if let userID = results?[indexPath.item].id {
					self.performSegue(withIdentifier: "ProfileSegue", sender: userID)
				}
			}
		} else {
			// Search suggestion cell
			let showID = suggestions[indexPath.item]["id"].intValue
			self.performSegue(withIdentifier: "ShowDetailsSegue", sender: showID)
		}
    }
}

extension SearchResultsViewController: UICollectionViewDelegateFlowLayout {
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
		if collectionView == self.collectionView {
			guard let searchScope = SearchScope(rawValue: currentScope) else { return CGSize.zero }
			let cellWidth = collectionView.bounds.size.width

			switch searchScope {
			case .anime:
				return CGSize(width: cellWidth, height: 136)
			case .myLibrary: break
			case .forum:
				return CGSize(width: cellWidth, height: 82)
			case .user:
				return CGSize(width: cellWidth, height: 82)
			}
		}

		// Search suggestion cell
		let suggestionsCollectionViewSize = CGSize(width: 68, height: 130)
		return suggestionsCollectionViewSize
	}
}
