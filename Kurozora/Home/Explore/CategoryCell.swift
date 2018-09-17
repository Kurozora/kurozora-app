//
//  CategoryCell.swift
//  Kurozora
//
//  Created by Khoren Katklian on 09/08/2018.
//  Copyright © 2018 Kusa. All rights reserved.
//

import UIKit

class CategoryCell: BaseCell, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource, UICollectionViewDelegate {
    
    var featuredShowsViewController: FeaturedShowsViewController?
    
    var showCategory: ShowCategory? {
        didSet {
            if let title = showCategory?.title {
                titleLabel.text = title
            }
            showsCollectionView.reloadData()
        }
    }
    
    var featuredShows: [Show]? {
        didSet {
            showsCollectionView.reloadData()
        }
    }
    
    let showsCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.showsVerticalScrollIndicator = false
        collectionView.backgroundColor = .clear
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()
    
    private let dividerLineView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(white: 0.4, alpha: 0.6)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 2
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let showCellId = "showCellId"

    override func setupViews() {
        super.setupViews()
        backgroundColor = .clear
        
        // Prepare auto layout
        showsCollectionView.register(ShowCell.self, forCellWithReuseIdentifier: showCellId)
        showsCollectionView.dataSource = self
        showsCollectionView.delegate = self
        
        // Add them to the view
        addSubview(showsCollectionView)
        addSubview(dividerLineView)
        addSubview(titleLabel)
        
        // Category collection view constraint
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-14-[titleLabel]|", options: NSLayoutFormatOptions(), metrics: nil, views:  ["titleLabel": titleLabel]))
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-14-[dividerLineView]|", options: NSLayoutFormatOptions(), metrics: nil, views:  ["dividerLineView": dividerLineView]))
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[showsCollectionView]|", options: NSLayoutFormatOptions(), metrics: nil, views:  ["showsCollectionView": showsCollectionView]))
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[titleLabel(30)][showsCollectionView][dividerLineView(0.5)]|", options: NSLayoutFormatOptions(), metrics: nil, views:  ["titleLabel": titleLabel, "showsCollectionView": showsCollectionView, "dividerLineView": dividerLineView]))
    }

    // Collection view items in section
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let count = showCategory?.shows?.count { return count }
        return 0
    }

    // Collection view item cell
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: showCellId, for: indexPath) as! ShowCell
        cell.show = showCategory?.shows?[indexPath.item]
        return cell
    }

    // Collection view item size
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 100, height: frame.height - 32)
    }

    // Collection view insets
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 14, bottom: 0, right: 14)
    }

    // Collection view item selected
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let show = showCategory?.shows?[indexPath.item] {
            featuredShowsViewController?.showDetailFor(show)
        }
    }
}
