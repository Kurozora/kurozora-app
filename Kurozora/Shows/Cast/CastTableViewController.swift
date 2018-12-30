//
//  CastTableViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 01/10/2018.
//  Copyright © 2018 Kurozora. All rights reserved.
//

import UIKit
import SwiftyJSON
import Kingfisher
import BottomPopup
import EmptyDataSet_Swift

class CastTableViewController: BottomPopupViewController, UICollectionViewDataSource, UICollectionViewDelegate, EmptyDataSetDelegate, EmptyDataSetSource {
    @IBOutlet var collectionView: UICollectionView!
    
    var actors: [ActorsElement]?

    override func viewDidLoad() {
        super.viewDidLoad()

		// Setup collection view
        collectionView.dataSource = self
        collectionView.delegate = self

		// Setup empty collection view
        collectionView.emptyDataSetSource = self
        collectionView.emptyDataSetDelegate = self
        collectionView.emptyDataSetView { view in
            view.titleLabelString(NSAttributedString(string: "No actors found!"))
				.shouldDisplay(true)
				.shouldFadeIn(true)
				.isTouchAllowed(true)
				.isScrollAllowed(true)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    // MARK: - Collection view data source
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let actorsCount = actors?.count else {return 0}
        
        return actorsCount
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let castCell = collectionView.dequeueReusableCell(withReuseIdentifier: "ShowCastCell", for: indexPath) as! ShowCharacterCollectionCell
        
        if let actorName = actors?[indexPath.row].name {
            castCell.actorName.text = actorName
        }
        
        if let actorRole = actors?[indexPath.row].role {
            castCell.actorJob.text = actorRole
        }
        
        if let actorImage = actors?[indexPath.row].image, actorImage != ""  {
            let actorImageUrl = URL(string: actorImage)
            let resource = ImageResource(downloadURL: actorImageUrl!)
            castCell.actorImageView.kf.indicatorType = .activity
            castCell.actorImageView.kf.setImage(with: resource, placeholder: #imageLiteral(resourceName: "placeholder_person"), options: [.transition(.fade(0.2))], progressBlock: nil, completionHandler: nil)
		} else {
			castCell.actorImageView.image = #imageLiteral(resourceName: "placeholder_person")
		}
        
        return castCell
    }
    
    // Bottom popup delegate methods
    override func getPopupHeight() -> CGFloat {
        let height: CGFloat = UIScreen.main.bounds.size.height / 1.5
        return height
    }
}
