//
//  KCollectionViewCell.swift
//  Kurozora
//
//  Created by Khoren Katklian on 07/05/2022.
//  Copyright © 2022 Kurozora. All rights reserved.
//

import UIKit
import KurozoraKit
import Alamofire

class KCollectionViewCell: UICollectionViewCell, SkeletonDisplayable {
	// MARK: - Properties
	/// The request which handles in-memory Data download using URLSessionDataTask.
	var dataRequest: DataRequest?

	// MARK: - Initializers
	deinit {
		self.dataRequest?.cancel()
		self.dataRequest = nil
	}

	// MARK: - View
	override func prepareForReuse() {
		super.prepareForReuse()

		self.dataRequest?.cancel()
		self.dataRequest = nil
		self.showSkeleton()
	}
}
