//
//  TableCellWithCollection.swift
//  Kurozora
//
//  Created by Khoren Katklian on 01/05/2018.
//  Copyright © 2018 Kusa. All rights reserved.
//

import KCommonKit
import UIKit

class TableCellWithCollection: UITableViewCell {
    
    static let id = "TableCellWithCollection"
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    var dataSource : Array = [["title": "michael", "poster_url": "jackson"], ["title" : "bill", "poster_url" : "gates"], ["title" : "steve", "poster_url" : "jobs"], ["title" : "mark", "poster_url" : "zuckerberg"], ["title" : "anthony", "poster_url" : "quinn"]]
//    var selectedAnimeCallBack: (Anime -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        PosterCell.registerNibFor(collectionView: collectionView)
    }
    
    class func registerNibFor(tableView: UITableView) {
        let chartNib = UINib(nibName: TableCellWithCollection.id, bundle: nil)
        tableView.register(chartNib, forCellReuseIdentifier: TableCellWithCollection.id)
    }
}

extension TableCellWithCollection: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSource.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PosterCell", for: indexPath as IndexPath) as? PosterCell else {
            return UICollectionViewCell()
        }

        let anime = dataSource[indexPath.row]

        cell.imageView.image = UIImage(named: anime["image_url"]!)
        cell.titleLabel.text = anime["title"] ?? ""

        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        let anime = dataSource[indexPath.row]
//        selectedAnimeCallBack?(anime)
    }
}
