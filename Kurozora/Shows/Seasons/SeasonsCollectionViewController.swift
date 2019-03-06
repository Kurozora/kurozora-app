//
//  SeasonsCollectionViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 10/10/2018.
//  Copyright © 2018 Kurozora. All rights reserved.
//

import KCommonKit
import Kingfisher
import SwiftyJSON
import SCLAlertView
import EmptyDataSet_Swift
import NVActivityIndicatorView

class SeasonsCollectionViewController: UICollectionViewController, NVActivityIndicatorViewable, EmptyDataSetSource, EmptyDataSetDelegate {
    var canFadeImages = true
    var laidOutSubviews = false

    var showID: Int?
    var seasonID: Int?
    var seasons: [SeasonsElement]?

	override func viewDidLoad() {
        super.viewDidLoad()
		view.theme_backgroundColor = "Global.backgroundColor"

        startAnimating(CGSize(width: 100, height: 100), type: NVActivityIndicatorType.ballScaleMultiple, color: #colorLiteral(red: 1, green: 0.5764705882, blue: 0, alpha: 1), minimumDisplayTime: 3)
        
        collectionView?.emptyDataSetSource = self
        collectionView?.emptyDataSetDelegate = self
        collectionView?.emptyDataSetView { view in
            view.titleLabelString(NSAttributedString(string: "No seasons found!"))
                .image(UIImage(named: ""))
                .shouldDisplay(true)
                .shouldFadeIn(true)
                .isTouchAllowed(true)
                .isScrollAllowed(false)
        }

		showID = KCommonKit.shared.showID
        fetchSeasons()
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)

        updateLayoutWithSize(viewSize: size)
    }
 
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        if !laidOutSubviews {
            laidOutSubviews = true
            updateLayoutWithSize(viewSize: view.bounds.size)
        }
    }

	// MARK: - Functions
    func updateLayoutWithSize(viewSize: CGSize) {
        let height: CGFloat = 126

        guard let collectionView = collectionView,
            let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout else {return}

        var size: CGSize?
        var inset: CGFloat = 0
        var lineSpacing: CGFloat = 0

        if UIDevice.isPad() {
            inset = 4
            lineSpacing = 4
            let columns: CGFloat = UIDevice.isLandscape() ? 3 : 2
            let totalWidth: CGFloat = viewSize.width - (inset * (columns + 1))
            size = CGSize(width: totalWidth / columns, height: height)
        } else {
            inset = 10
            lineSpacing = 10
            size = CGSize(width: viewSize.width - inset * 2, height: height)
        }
        layout.sectionInset = UIEdgeInsets(top: inset, left: inset, bottom: inset, right: inset)
        layout.minimumLineSpacing = lineSpacing
        layout.minimumInteritemSpacing = lineSpacing

        layout.itemSize = size!
        layout.invalidateLayout()
    }
    
    func fetchSeasons() {
        Service.shared.getSeasonFor(showID, withSuccess: { (seasons) in
            if let seasons = seasons {
				self.seasons = seasons
            }
            self.collectionView?.reloadData()
        })
		
        collectionView?.animateFadeIn()
        self.stopAnimating()
    }
    
    
    // MARK: - IBActions
    @IBAction func dismissButtonPressed(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
}

// MARK: - UICollectionViewDataSource
extension SeasonsCollectionViewController {
	override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		if let seasonsCount = seasons?.count, seasonsCount != 0 {
			return seasonsCount
		}
		return 0
	}

	override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		let seasonCell = collectionView.dequeueReusableCell(withReuseIdentifier: "SeasonCell", for: indexPath) as! SeasonCollectionCell

		let posterUrl = URL(string: "https://something.com/somthing")
		let resource = ImageResource(downloadURL: posterUrl!)
		seasonCell.seasonPosterImageView.kf.setImage(with: resource, placeholder: UIImage(named: "placeholder_poster"), options: [.transition(.fade(0.2))])

		// Season number
		seasonCell.seasonCountLabel.theme_textColor = "Global.textColor"
		seasonCell.seasonCountLabel.alpha = 0.64
		if let seasonNumber = seasons?[indexPath.row].number, seasonNumber != 0 {
			seasonCell.seasonCountLabel.text = "Season \(seasonNumber)"
		} else {
			seasonCell.seasonCountLabel.text = "Season ?"
		}

		// Season title
		seasonCell.seasonTitleLabel.theme_textColor = "Global.textColor"
		if let seasonTitle = seasons?[indexPath.row].title, seasonTitle != "" {
			seasonCell.seasonTitleLabel.text = seasonTitle
		} else {
			seasonCell.seasonTitleLabel.text = "Unknown"
		}

		// Season date
		seasonCell.seasonStartDateLabel.theme_textColor = "Global.textColor"
		seasonCell.seasonStartDateLabel.alpha = 0.56
		seasonCell.seasonStartDateLabel.text = "12-10-2000"

		// Season rating
		seasonCell.seasonRatingTitleLabel.theme_textColor = "Global.textColor"
		seasonCell.seasonRatingLabel.theme_textColor = "Global.textColor"
		seasonCell.seasonRatingLabel.text = "5.00"

		seasonCell.separatorView.theme_backgroundColor = "Global.separatorColor"
		return seasonCell
	}
}

// MARK: - UICollectionViewDelegate
extension SeasonsCollectionViewController {
	override func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
		return false
	}

	override func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
		return false
	}

	override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		if let seasonID = seasons?[indexPath.item].id {
			performSegue(withIdentifier: "EpisodeSegue", sender: seasonID)
		}
	}

	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if segue.identifier == "EpisodeSegue" {
			let vc = segue.destination as! EpisodesCollectionViewController
			vc.seasonID = sender as? Int
		}
	}
}
