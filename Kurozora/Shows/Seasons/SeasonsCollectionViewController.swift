//
//  SeasonsCollectionViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 10/10/2018.
//  Copyright © 2018 Kurozora. All rights reserved.
//

import KCommonKit
import EmptyDataSet_Swift

class SeasonsCollectionViewController: UICollectionViewController, EmptyDataSetSource, EmptyDataSetDelegate {
	var showID: Int?
	var heroID: String?
	var seasons: [SeasonsElement]? {
		didSet {
			self.collectionView?.reloadData()
		}
	}

	override func viewDidLoad() {
        super.viewDidLoad()
		view.theme_backgroundColor = KThemePicker.backgroundColor.rawValue

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

	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if segue.identifier == "EpisodesSegue", let cell = sender as? SeasonsCollectionViewCell {
			if let episodesCollectionViewController = segue.destination as? EpisodesCollectionViewController, let indexPath = collectionView.indexPath(for: cell) {
				episodesCollectionViewController.seasonID = seasons?[indexPath.item].id
			}
		}
	}

	// MARK: - Functions
    fileprivate func fetchSeasons() {
        Service.shared.getSeasonsFor(showID, withSuccess: { (seasons) in
			DispatchQueue.main.async {
				self.seasons = seasons
			}
        })
    }

    // MARK: - IBActions
    @IBAction func dismissButtonPressed(_ sender: UIBarButtonItem) {
		view.hero.id = heroID
		dismiss(animated: true, completion: nil)
    }

	override func viewWillLayoutSubviews() {
		super.viewWillLayoutSubviews()
		collectionView.collectionViewLayout.invalidateLayout()
	}
}

// MARK: - UITableViewDataSource
extension SeasonsCollectionViewController {
	override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		guard let seasonsCount = seasons?.count else { return 0 }
		return seasonsCount
	}

	override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		let seasonsCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "SeasonsCollectionViewCell", for: indexPath) as! SeasonsCollectionViewCell

		seasonsCollectionViewCell.seasonsElement = seasons?[indexPath.row]

		return seasonsCollectionViewCell
	}
}

// MARK: - UITableViewDelegate
extension SeasonsCollectionViewController: UICollectionViewDelegateFlowLayout {
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
		let interItemGap: CGFloat = (UIDevice.isPad) ? 20 : 10

		if UIDevice.isPad {
			if UIDevice.isLandscape {
				return CGSize(width: (collectionView.frame.width - interItemGap) / 3, height: 170)
			}
			return CGSize(width: (collectionView.frame.width - interItemGap) / 2, height: 170)
		}

		if UIDevice.isLandscape {
			return CGSize(width: (collectionView.frame.width - interItemGap) / 2, height: 170)
		}
		return CGSize(width: (collectionView.frame.width - interItemGap), height: 170)
	}
}
