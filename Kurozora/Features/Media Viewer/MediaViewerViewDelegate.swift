//
//  MediaViewerViewDelegate.swift
//  Kurozora
//
//  Created by Khoren Katklian on 21/02/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import UIKit

protocol MediaViewerViewDelegate: AnyObject {
	func mediaViewerViewDelegate(_ view: UIView, didTapImage imageView: UIImageView, at index: Int)
}
