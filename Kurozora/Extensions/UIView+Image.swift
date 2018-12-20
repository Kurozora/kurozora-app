//
//  UIView+Image.swift
//  Kurozora
//
//  Created by Khoren Katklian on 11/12/2018.
//  Copyright © 2018 Kurozora. All rights reserved.
//

import UIKit

extension UIView {
	func asImage() -> UIImage {
		if #available(iOS 10.0, *) {
			let renderer = UIGraphicsImageRenderer(bounds: bounds)
			return renderer.image { rendererContext in
				layer.render(in: rendererContext.cgContext)
			}
		} else {
			UIGraphicsBeginImageContext(self.frame.size)
			self.layer.render(in:UIGraphicsGetCurrentContext()!)
			let image = UIGraphicsGetImageFromCurrentImageContext()
			UIGraphicsEndImageContext()
			return UIImage(cgImage: image!.cgImage!)
		}
	}
}
