//
//  LargeCellCategory.swift
//  Kurozora
//
//  Created by Khoren Katklian on 13/08/2018.
//  Copyright © 2018 Kusa. All rights reserved.
//

import UIKit

class LargeCategoryCell: CategoryCell {
    
    private let largeCellShowId = "largeShowCellId"
    
    override func setupViews() {
        super.setupViews()
        showsCollectionView.register(LargeShowCell.self, forCellWithReuseIdentifier: largeCellShowId)
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: largeCellShowId, for: indexPath) as! ShowCell
        cell.show = showCategory?.shows?[indexPath.item]
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 200, height: frame.height - 32)
    }
    
    private class LargeShowCell: ShowCell {
        
        fileprivate override func setupViews() {
            addSubview(imageView)
            imageView.translatesAutoresizingMaskIntoConstraints = false
            addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[v0]|", options: NSLayoutFormatOptions(), metrics: nil, views: ["v0": imageView]))
            addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[v0]|", options: NSLayoutFormatOptions(), metrics: nil, views: ["v0": imageView]))
        }
        
    }
}
