//
//  KBaseCollectionViewFlowLayout.swift
//  Kurozora
//
//  Created by Khoren Katklian on 28/07/2019.
//  Copyright © 2019 Kurozora. All rights reserved.
//

import UIKit

class KBaseCollectionViewFlowLayout: UICollectionViewFlowLayout {
	var spacing: CGFloat {
		return (UIDevice.isPad()) ? 15 : 5
	}
	var spacingWhenFocused: CGFloat {
		return (UIDevice.isPad()) ? 25 : 15
	}
	var interItemGap: Int {
		return (UIDevice.isPad()) ? 20 : 10
	}
}

