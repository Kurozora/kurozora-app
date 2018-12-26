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

	var results: [JSON]?
	var timer: Timer?
	var currentScope: Int!

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
	}

    override func viewDidLoad() {
        super.viewDidLoad()

		collectionView.delegate = self
		collectionView.dataSource = self
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        view.endEditing(true)
    }

	func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
		guard let searchScope = SearchScope(rawValue: selectedScope) else { return }
		var cellHeight: CGFloat = 0

		switch searchScope {
		case .anime:
			let searchShowCell = collectionView.dequeueReusableCell(withReuseIdentifier: "ShowCell", for: IndexPath(item: 0, section: 0)) as! SearchShowCell
			cellHeight = searchShowCell.bounds.size.height
		case .myLibrary: break
		case .forum: break
		case .user:
			let searchUserCell = collectionView.dequeueReusableCell(withReuseIdentifier: "UserCell", for: IndexPath(item: 0, section: 0)) as! SearchUserCell
			cellHeight = searchUserCell.bounds.size.height
		}

		collectionView.contentSize.height = cellHeight

		results = []
		collectionView.reloadData()
	}

	// MARK: - Functions
	fileprivate func search(for text: String, searchScope: Int) {
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
			search(for: text, searchScope: scope)
		}
	}

	// MARK: - UISearchResultsUpdating
	func updateSearchResults(for searchController: UISearchController) {
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

		search(for: text, searchScope: scope)
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
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		if let resultsCount = results?.count, resultsCount != 0 {
        	return resultsCount
		}
		return 0
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

		guard let searchScope = SearchScope(rawValue: currentScope) else { return UICollectionViewCell() }

		switch searchScope {
		case .anime:
			let searchShowCell = collectionView.dequeueReusableCell(withReuseIdentifier: "ShowCell", for: indexPath) as! SearchShowCell

			if let posterThumbnail = results?[indexPath.row]["poster_thumbnail"].stringValue, posterThumbnail != "" {
				let posterThumbnailUrl = URL(string: posterThumbnail)
				let resource = ImageResource(downloadURL: posterThumbnailUrl!)
				searchShowCell.posterImageView.kf.indicatorType = .activity
				searchShowCell.posterImageView.kf.setImage(with: resource, placeholder: #imageLiteral(resourceName: "placeholder_poster"), options: [.transition(.fade(0.2))], progressBlock: nil, completionHandler: nil)
			} else {
				searchShowCell.posterImageView.image = #imageLiteral(resourceName: "placeholder_poster")
			}

			if let title = results?[indexPath.row]["title"].stringValue, title != "" {
				searchShowCell.titleLabel.text = title
			} else {
				searchShowCell.titleLabel.text = ""
			}

			if let airDate = results?[indexPath.row]["air_date"].stringValue, airDate != "" {
				searchShowCell.airDateLabel.text = airDate
			} else {
				searchShowCell.airDateLabel.text = "Dec, 25 2018"
			}

			if let averageRating = results?[indexPath.row]["average_rating"].intValue, averageRating != 0 {
				searchShowCell.scoreLabel.text = "\(averageRating)"
			} else {
				searchShowCell.scoreLabel.text = "0"
			}

			if let status = results?[indexPath.row]["status"].stringValue, status != "" {
				searchShowCell.statusLabel.text = status
			} else {
				searchShowCell.statusLabel.text = "Currently Airing"
			}

			return searchShowCell
		case .myLibrary: break
		case .forum: break
		case .user:
			let searchUserCell = collectionView.dequeueReusableCell(withReuseIdentifier: "UserCell", for: indexPath) as! SearchUserCell

			if let avatar = results?[indexPath.row]["avatar"].stringValue, avatar != "" {
				let avatarUrl = URL(string: avatar)
				let resource = ImageResource(downloadURL: avatarUrl!)
				searchUserCell.avatarImageView.kf.indicatorType = .activity
				searchUserCell.avatarImageView.kf.setImage(with: resource, placeholder: #imageLiteral(resourceName: "default_avatar"), options: [.transition(.fade(0.2))], progressBlock: nil, completionHandler: nil)
			} else {
				searchUserCell.avatarImageView.image = #imageLiteral(resourceName: "default_avatar")
			}

			if let username = results?[indexPath.row]["username"].stringValue, username != "" {
				searchUserCell.usernameLabel.text = username
			} else {
				searchUserCell.usernameLabel.text = ""
			}

			if let reputation = results?[indexPath.row]["reputation_count"].intValue, reputation != 0 {
				searchUserCell.reputationLabel.text = "\(reputation)"
			} else {
				searchUserCell.reputationLabel.text = "0"
			}

			return searchUserCell
		}
		return UICollectionViewCell()
    }
}

extension SearchResultsViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		guard let searchScope = SearchScope(rawValue: currentScope) else { return }
		switch searchScope {
		case .anime:
			if let showID = results?[indexPath.item]["id"].intValue {
				self.performSegue(withIdentifier: "ShowDetailsSegue", sender: showID)
			}
		case .myLibrary: break
		case .forum: break
		case .user:
			if let userID = results?[indexPath.item]["id"].intValue {
				self.performSegue(withIdentifier: "ProfileSegue", sender: userID)
			}
		}
    }
}

extension SearchResultsViewController: UICollectionViewDelegateFlowLayout {
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
		guard let searchScope = SearchScope(rawValue: currentScope) else { return CGSize.zero }
		let cellWidth = collectionView.bounds.size.width
		switch searchScope {
		case .anime:
			return CGSize(width: cellWidth, height: 136)
		case .myLibrary: break
		case .forum: break
		case .user:
			return CGSize(width: cellWidth, height: 82)
		}
		return CGSize.zero
	}
}
