//
//  SelfSizingCollectionView.swift
//  Kurozora
//
//  Created by Khoren Katklian on 23/10/2019.
//  Copyright © 2019 Kurozora. All rights reserved.
//

import UIKit

protocol SelfSizingCollectionViewDelegate: class {
	func collectionView(_ collectionView: UICollectionView, didChageContentSizeFrom oldSize: CGSize, to newSize: CGSize)
}

class SelfSizingCollectionView: UICollectionView {
	// MARK: - Properties
	weak var selfSizingDelegate: SelfSizingCollectionViewDelegate?
	override open var contentSize: CGSize {
		didSet {
			guard bounds.size.height != contentSize.height else { return }
			frame.size.height = contentSize.height
			selfSizingDelegate?.collectionView(self, didChageContentSizeFrom: oldValue, to: contentSize)
		}
	}
	override open var intrinsicContentSize: CGSize {
		return contentSize
	}

	// MARK: - View
	override func awakeFromNib() {
		super.awakeFromNib()

		if (collectionViewLayout as? UICollectionViewFlowLayout) == nil {
			assertionFailure("Collection view layout is not flow layout. SelfSizing may not work")
		}
	}
}
