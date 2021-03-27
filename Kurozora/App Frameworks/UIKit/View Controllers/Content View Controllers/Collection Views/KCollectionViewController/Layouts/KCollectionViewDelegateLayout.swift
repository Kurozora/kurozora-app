//
//  KCollectionViewDelegateLayout.swift
//  Kurozora
//
//  Created by Khoren Katklian on 04/05/2020.
//  Copyright © 2020 Kurozora. All rights reserved.
//

import UIKit

/**
	The KCollectionViewDelegateLayout protocol defines methods that guide you with managing the (compositional) layout of sections, groups and items in a collection view. The methods of this protocol are all optional.
*/
@objc protocol KCollectionViewDelegateLayout: AnyObject {
	@objc optional func columnCount(forSection section: Int, layout layoutEnvironment: NSCollectionLayoutEnvironment) -> Int
	@objc optional func groupHeightFraction(forSection section: Int, with columnsCount: Int, layout layoutEnvironment: NSCollectionLayoutEnvironment) -> CGFloat
	@objc optional func contentInset(forBackgroundInSection section: Int, layout collectionViewLayout: NSCollectionLayoutEnvironment) -> NSDirectionalEdgeInsets
	@objc optional func contentInset(forItemInSection section: Int, layout layoutEnvironment: NSCollectionLayoutEnvironment) -> NSDirectionalEdgeInsets
	@objc optional func contentInset(forSection section: Int, layout layoutEnvironment: NSCollectionLayoutEnvironment) -> NSDirectionalEdgeInsets
	@objc optional func createLayout() -> UICollectionViewLayout?
}
