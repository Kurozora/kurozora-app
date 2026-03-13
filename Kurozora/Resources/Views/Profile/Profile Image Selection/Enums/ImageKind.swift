//
//  ImageKind.swift
//  Kurozora
//
//  Created by Khoren Katklian on 13/03/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import Foundation

enum ImageKind {
	// MARK: - Cases
	/// Indicates that the image being selected is a profile image.
	case profile

	/// Indicates that the image being selected is a banner image.
	case banner

	// MARK: - Properties
	/// The shape type to apply to the crop mask in the image crop view controller.
	var shapeType: ShapeType {
		switch self {
		case .profile: return .circle
		case .banner: return .rectangle
		}
	}

	/// The corner style to apply to adaptive corner buttons related to an image kind.
	var cornerStyle: AdaptiveCornerButton.CornerStyle {
		switch self {
		case .profile: return .capsule
		case .banner: return .fixed(12)
		}
	}

	/// The target output size to use when cropping images for an image kind.
	var targetOutputSize: CGSize {
		switch self {
		case .profile: return CGSize(width: 400, height: 400)
		case .banner: return CGSize(width: 1500, height: 500)
		}
	}

	/// The cell size to use in the layout of the image source collection views.
	var layoutCellSize: CGFloat {
		switch self {
		case .profile: return 140.0
		case .banner: return 200.0
		}
	}
}
