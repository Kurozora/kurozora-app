//
//  UIImage+KurozoraWidget.swift
//  Kurozora
//
//  Created by Khoren Katklian on 27/10/2024.
//  Copyright © 2024 Kurozora. All rights reserved.
//

import UIKit

extension UIImage {
	func resized(toWidth width: CGFloat, isOpaque: Bool = true) -> UIImage? {
		let canvas = CGSize(width: width, height: CGFloat(ceil(width / size.width * size.height)))
		let format = imageRendererFormat
		format.opaque = isOpaque
		return UIGraphicsImageRenderer(size: canvas, format: format).image { _ in
			draw(in: CGRect(origin: .zero, size: canvas))
		}
	}
}
