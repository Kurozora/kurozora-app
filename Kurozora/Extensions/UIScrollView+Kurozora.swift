//
//  UIScrollView+Kurozora.swift
//  Kurozora
//
//  Created by Khoren Katklian on 10/01/2019.
//  Copyright © 2019 Kurozora. All rights reserved.
//

import UIKit

extension UITableView {
	var isAtTop: Bool {
		return contentOffset.y <= verticalOffsetForTop
	}

	var isAtBottom: Bool {
		return contentOffset.y >= verticalOffsetForBottom
	}

	var verticalOffsetForTop: CGFloat {
		let topInset = contentInset.top
		return -topInset
	}

	var verticalOffsetForBottom: CGFloat {
		let scrollViewHeight = bounds.height
		let scrollContentSizeHeight = contentSize.height
		let bottomInset = contentInset.bottom
		let scrollViewBottomOffset = scrollContentSizeHeight + bottomInset - scrollViewHeight
		return scrollViewBottomOffset
	}
}
