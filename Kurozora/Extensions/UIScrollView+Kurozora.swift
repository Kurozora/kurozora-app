//
//  UIScrollView+Kurozora.swift
//  Kurozora
//
//  Created by Khoren Katklian on 10/01/2019.
//  Copyright © 2019 Kurozora. All rights reserved.
//

import UIKit

extension UITableView {
	/// A boolean indicating if the scrollview is at the top
	var isAtTop: Bool {
		return contentOffset.y <= verticalOffsetForTop
	}

	/// A boolean indicating if the scrollview is at the bottom
	var isAtBottom: Bool {
		return contentOffset.y >= verticalOffsetForBottom
	}

	/// The top vertical offset for the scrollview
	var verticalOffsetForTop: CGFloat {
		let topInset = contentInset.top
		return -topInset
	}

	/// The bottom vertical offset for the scrollview
	var verticalOffsetForBottom: CGFloat {
		let scrollViewHeight = bounds.height
		let scrollContentSizeHeight = contentSize.height
		let bottomInset = contentInset.bottom
		let scrollViewBottomOffset = scrollContentSizeHeight + bottomInset - scrollViewHeight
		return scrollViewBottomOffset
	}
}
