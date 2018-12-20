//
//  UIImage+Base64.swift
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
}
