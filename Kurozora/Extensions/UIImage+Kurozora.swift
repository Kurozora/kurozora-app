//
//  UIImage+Kurozora.swift
//  Kurozora
//
//  Created by Khoren Katklian on 29/09/2018.
//  Copyright © 2018 Kurozora. All rights reserved.
//

import UIKit

public enum ImageFormat {
	case png
	case jpeg(CGFloat)
}

extension UIImage {
	/// Convert UIImage to Base64
	public func toBase64(format: ImageFormat) -> String? {
		var imageData: Data?
		switch format {
		case .png: imageData = self.pngData()
		case .jpeg(let compression): imageData = self.jpegData(compressionQuality: compression)
		}
		return imageData?.base64EncodedString()
	}

	public func withColor(_ color: UIColor) -> UIImage {
		UIGraphicsBeginImageContextWithOptions(size, false, scale)
		guard let ctx = UIGraphicsGetCurrentContext(), let cgImage = cgImage else { return self }
		color.setFill()
		ctx.translateBy(x: 0, y: size.height)
		ctx.scaleBy(x: 1.0, y: -1.0)
		ctx.clip(to: CGRect(x: 0, y: 0, width: size.width, height: size.height), mask: cgImage)
		ctx.fill(CGRect(x: 0, y: 0, width: size.width, height: size.height))
		guard let colored = UIGraphicsGetImageFromCurrentImageContext() else { return self }
		UIGraphicsEndImageContext()
		return colored
	}
}
