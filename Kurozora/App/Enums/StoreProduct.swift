//
//  StoreProduct.swift
//  Kurozora
//
//  Created by Khoren Katklian on 11/08/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import UIKit

/// The set of available in-app purchase product types.
enum StoreProduct: String, CaseIterable {
	// MARK: - Cases
	case wolfTip = "app.kurozora.consumable.wolfTip"
	case tigerTip = "app.kurozora.consumable.tigerTip"
	case demonTip = "app.kurozora.consumable.demonTip"
	case dragonTip = "app.kurozora.consumable.dragonTip"
	case godTip = "app.kurozora.consumable.godTip"
	case extraterrestrialTip = "app.kurozora.consumable.extraterrestrialTip"
	case eternalTip = "app.kurozora.consumable.eternalTip"
	case kurozoraOne = "app.kurozora.nonConsumable.kurozoraOne"
	case kPlus1Month = "app.kurozora.autoRenewableSubscription.kPlus1Month"
	case kPlus6Months = "app.kurozora.autoRenewableSubscription.kPlus6Months"
	case kPlus12Months = "app.kurozora.autoRenewableSubscription.kPlus12Months"

	// MARK: - Properties
	/// The identifiers of every product.
	static var identifiers: [String] {
		return Self.allCases.map(\.rawValue)
	}

	/// The image of the product.
	var image: UIImage? {
		switch self {
		case .wolfTip:
			return self.image(fromGlyph: "🐺")
		case .tigerTip:
			return self.image(fromGlyph: "🐯")
		case .demonTip:
			return self.image(fromGlyph: "👺")
		case .dragonTip:
			return self.image(fromGlyph: "🐲")
		case .godTip:
			return self.image(fromGlyph: "🙏")
		case .extraterrestrialTip:
			return self.image(fromGlyph: "👽")
		case .eternalTip:
			return self.image(fromGlyph: "♾️")
		case .kurozoraOne:
			return nil
		case .kPlus1Month:
			return .Promotional.Purchases.Subscriptions.month1
		case .kPlus6Months:
			return .Promotional.Purchases.Subscriptions.month6
		case .kPlus12Months:
			return .Promotional.Purchases.Subscriptions.month12
		}
	}

	// MARK: - Functions
	/// Returns an image of the given glyph.
	///
	/// - Parameter glyph: The glyph rendered in the image.
	///
	/// - Returns: An image of the glyph.
	private func image(fromGlyph glyph: String) -> UIImage {
		return glyph.toImage(withFrameSize: CGRect(x: 0, y: 0, width: 150, height: 150), backgroundColor: .secondaryLabel, fontSize: 40, placeholder: .Icons.jarHeart)
	}
}
