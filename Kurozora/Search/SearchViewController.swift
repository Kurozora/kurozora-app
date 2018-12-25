//
//  SearchViewController.swift
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
    case users
}

class SearchViewController: UIViewController, UISearchResultsUpdating {
	@IBOutlet weak var collectionView: UICollectionView!

	var results: [JSON]?
	var timer: Timer?
//    var loadingView: LoaderView!
//    var initialSearchScope: SearchScope?

//    func initWithSearchScope(searchScope: SearchScope) {
//        initialSearchScope = searchScope
//    }

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

	// MARK: - Functions
	fileprivate func search(for text: String) {
		if text != "" {
			Service.shared.search(for: text) { (results) in
				DispatchQueue.main.async {
					self.results = results
					self.collectionView.reloadData()
				}
			}
		}
	}

	@objc func search(_ timer: Timer) {
		if let text = timer.userInfo as? String, text != "" {
			search(for: text)
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
				let vc = segue.destination as! ShowTabBarController
				vc.showID = sender
			}
		}
	}

//    func fetchDataWithQuery(text: String, searchScope: SearchScope) {
//
//        if searchScope == .MyLibrary {
//
//            guard let library = LibraryController.sharedInstance.library else {
//                return
//            }
//            self.dataSource = library.filter({ anime in
//
//                if anime.progress == nil {
//                    return false
//                }
//                if let title = anime.title, title.lowercaseString.range(of: text.lowercaseString) != nil {
//                    return true
//                }
//                if let titleEnglish = anime.titleEnglish, titleEnglish.lowercaseString.range(of: text.lowercaseString) != nil {
//                    return true
//                }
//                return false
//            })
//            return
//        }
//
//
//        loadingView.startAnimating()
//        collectionView.animateFadeOut()
//
//        var query: PFQuery!
//
//        switch searchScope {
//        case .AllAnime:
//            let query1 = Anime.query()!
//            query1.whereKey("title", matchesRegex: text, modifiers: "i")
//
//            let query2 = Anime.query()!
//            query2.whereKey("titleEnglish", matchesRegex: text, modifiers: "i")
//
//            let orQuery = PFQuery.orQueryWithSubqueries([query1, query2])
//            orQuery.limit = 40
//            orQuery.orderByAscending("popularityRank")
//
//            query = orQuery
//
//        case .Users:
//            query = User.query()!
//            query.limit = 40
//            query.whereKey("kurozoraUsername", matchesRegex: text, modifiers: "i")
//            query.orderByAscending("kurozoraUsername")
//
//        case .Forum:
//            query = Thread.query()!
//            query.limit = 40
//            query.whereKey("title", matchesRegex: text, modifiers: "i")
//            query.includeKey("tags")
//            query.includeKey("startedBy")
//            query.includeKey("lastPostedBy")
//            query.orderByAscending("updatedAt")
//        default:
//            break
//        }
//
//        currentOperation.cancel()
//        let newOperation = Operation()
//
//        dispatch_after_delay(0.6, queue: dispatch_get_main_queue()) { _ in
//
//            if newOperation.cancelled == true {
//                return
//            }
//
//            query.findObjectsInBackgroundWithBlock({ (result, error) -> Void in
//                print("fetched! \(text)")
//                if result != nil {
//                    if let anime = result as? [Anime] {
//                        LibrarySyncController.matchAnimeWithProgress(anime)
//                        self.dataSource = anime
//                    } else if let users = result as? [User] {
//                        self.dataSource = users
//                    } else if let threads = result as? [Thread] {
//                        self.dataSource = threads
//                    }
//                }
//
//                self.loadingView.stopAnimating()
//                self.collectionView.animateFadeIn()
//            })
//        }
//
//        currentOperation = newOperation
//    }
}

extension SearchViewController: UISearchBarDelegate {
	// MARK: - UISearchBarDelegate
	func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
		guard let text = searchBar.text else { return }
		search(for: text)
	}

	func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
		if searchText != "" {
			timer?.invalidate()
			timer = Timer.scheduledTimer(timeInterval: 0.6, target: self, selector: #selector(search(_:)), userInfo: searchText, repeats: false)
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

extension SearchViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		if let resultsCount = results?.count, resultsCount != 0 {
        	return resultsCount
		}
		return 0
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
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
    }
}

extension SearchViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		if let showID = results?[indexPath.item]["id"].intValue {
			self.performSegue(withIdentifier: "ShowDetailsSegue", sender: showID)
		}
    }
}
