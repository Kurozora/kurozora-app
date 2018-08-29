//
//  ScreenshotsCell.swift
//  Kurozora
//
//  Created by Khoren Katklian on 09/08/2018.
//  Copyright © 2018 Kusa. All rights reserved.
//

//import UIKit
//
//class ScreenShotsCell: BaseCell, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
//    
//    var show: Show? {
//        didSet {
//            collectionView.reloadData()
//        }
//    }
//    
//    private let collectionView: UICollectionView = {
//        let layout = UICollectionViewFlowLayout()
//        layout.scrollDirection = .horizontal
//        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
//        cv.backgroundColor = .clear
//        return cv
//    }()
//    
//    private let cellId = "cellId"
//    
//    private let dividerLineView: UIView = {
//        let view = UIView()
//        view.backgroundColor = UIColor(white: 0.4, alpha: 0.6)
//        return view
//    }()
//    
//    override func setupViews() {
//        super.setupViews()
//        collectionView.dataSource = self
//        collectionView.delegate = self
//        
//        addSubview(collectionView)
//        addSubview(dividerLineView)
//        
//        addConstraintsWithFormat(format: "H:|[v0]|", views: collectionView)
//        addConstraintsWithFormat(format: "H:|-14-[v0]|", views: dividerLineView)
//        addConstraintsWithFormat(format: "V:|[v0][v1(1)]|", views: collectionView, dividerLineView)
//        collectionView.register(ScreenshotImageCell.self, forCellWithReuseIdentifier: cellId)
//    }
//    
//    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        if let count = show?.screenshots?.count {
//            return count
//        }
//        return 0
//    }
//    
//    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! ScreenshotImageCell
//        if let imageName = show?.screenshots?[indexPath.item] {
//            cell.imageView.image = UIImage(named: imageName)
//        }
//        return cell
//    }
//    
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//        return CGSize(width: 240, height: frame.height - 28)
//    }
//    
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
//        return UIEdgeInsets(top: 0, left: 14, bottom: 0, right: 14)
//    }
//    
//    private class ScreenshotImageCell: BaseCell {
//        
//        let imageView: UIImageView = {
//            let iv = UIImageView()
//            iv.contentMode = .scaleAspectFill
//            return iv
//        }()
//        
//        override func setupViews() {
//            layer.masksToBounds = true
//            addSubview(imageView)
//            addConstraintsWithFormat(format: "H:|[v0]|", views: imageView)
//            addConstraintsWithFormat(format: "V:|[v0]|", views: imageView)
//        }
//        
//    }
//    
//}

