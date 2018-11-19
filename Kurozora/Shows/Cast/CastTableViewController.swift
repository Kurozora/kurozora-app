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
    
    var castDetails: [JSON]?
    var totalCast: Int?
    var page: Int?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.dataSource = self
        collectionView.delegate = self
        
        collectionView.emptyDataSetSource = self
        collectionView.emptyDataSetDelegate = self
        collectionView.emptyDataSetView { view in
            view.titleLabelString(NSAttributedString(string: "No actors found!"))
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
        guard let castCount = castDetails?.count else {return 0}
        
        return castCount
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let castCell = collectionView.dequeueReusableCell(withReuseIdentifier: "ShowCastCell", for: indexPath) as! ShowCharacterCollectionCell
        
        if let actorName = castDetails?[indexPath.row]["name"] {
            castCell.actorName.text = actorName.stringValue
        }
        
        if let actorRole = castDetails?[indexPath.row]["role"] {
            castCell.actorJob.text = actorRole.stringValue
        }
        
        if let castImage = castDetails?[indexPath.row]["image"].stringValue {
            let castImage = URL(string: castImage)
            let resource = ImageResource(downloadURL: castImage!)
            castCell.actorImageView.kf.indicatorType = .activity
            castCell.actorImageView.kf.setImage(with: resource, placeholder: UIImage(named: "placeholder_person"), options: [.transition(.fade(0.2))], progressBlock: nil, completionHandler: nil)
        }
        
        return castCell
    }
    
    // Bottom popup delegate methods
    override func getPopupHeight() -> CGFloat {
        let height: CGFloat = UIScreen.main.bounds.size.height / 1.5
        return height
    }
}
