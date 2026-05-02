//
//  IconTableViewCell.swift
//  Kurozora
//
//  Created by Khoren Katklian on 05/06/2019.
//  Copyright © 2019 Kurozora. All rights reserved.
//

import KurozoraKit
import StoreKit
import UIKit

class IconTableViewCell: SettingsCell {
	@IBOutlet weak var selectedImageView: KImageView!

	// MARK: Properties
	fileprivate lazy var rainbowColors: [UIColor?] = [
		UIColor(hexString: "#FFFFFF"), // white
		UIColor(hexString: "#D87F33"), // orange
		UIColor(hexString: "#B24CD8"), // magenta
		UIColor(hexString: "#6699D8"), // light blue
		UIColor(hexString: "#E5E533"), // yellow
		UIColor(hexString: "#7FCC19"), // lime
		UIColor(hexString: "#F27FA5"), // pink
		UIColor(hexString: "#4C4C4C"), // gray
		UIColor(hexString: "#999999"), // light gray
		UIColor(hexString: "#4C7F99"), // cyan
		UIColor(hexString: "#334CB2"), // blue
		UIColor(hexString: "#7F3FB2"), // purple
		UIColor(hexString: "#667F33"), // green
		UIColor(hexString: "#664C33"), // brown
		UIColor(hexString: "#993333"), // red
		UIColor(hexString: "#000000"), // black
	]
	fileprivate var colorCycleTimer: Timer?

	// MARK: View
	override func prepareForReuse() {
		super.prepareForReuse()
		self.stopColorCycling()
	}

	// MARK: - Functions
	/// Sets the selected status of the cell.
	///
	/// - Parameter selected: The boolean value indicating whether the cell is selected.
	func setSelected(_ selected: Bool) {
		self.selectedImageView?.image = UIImage(systemName: "checkmark")
		self.selectedImageView?.isHidden = !selected
	}

	func configureCell(using alternativeIconsElement: AlternativeIconsElement?) {
		guard let alternativeIconsElement = alternativeIconsElement else {
			self.showSkeleton()
			return
		}
		self.hideSkeleton()

		self.primaryLabel?.text = alternativeIconsElement.name

		self.secondaryLabel?.text = nil
		self.secondaryLabel?.isHidden = true

		self.detailLabel?.text = nil
		self.detailLabel?.isHidden = true

		let image: UIImage?

		if alternativeIconsElement.name == "Kurozora" {
			image = UIImage(named: alternativeIconsElement.name)
		} else {
			image = UIImage(named: "\(alternativeIconsElement.name) Preview")
		}

		self.iconImageView?.image = image
		self.iconImageView?.preferredSymbolConfiguration = nil
		self.iconImageView?.contentMode = .scaleAspectFit
		self.iconImageView?.layerCornerRadius = 12.0
	}

	func configureCell(using browser: KBrowser?) {
		guard let browser = browser else {
			self.showSkeleton()
			return
		}
		self.hideSkeleton()

		self.primaryLabel?.text = browser.stringValue

		self.secondaryLabel?.text = nil
		self.secondaryLabel?.isHidden = true

		self.detailLabel?.text = nil
		self.detailLabel?.isHidden = true

		self.iconImageView?.image = browser.image
		self.iconImageView?.preferredSymbolConfiguration = nil
		self.iconImageView?.contentMode = .scaleAspectFit
		self.iconImageView?.layerCornerRadius = 12.0
	}

	func configureCell(using appChimeElement: AppChimeElement?) {
		guard let appChimeElement = appChimeElement else {
			self.showSkeleton()
			return
		}
		self.hideSkeleton()

		self.primaryLabel?.text = appChimeElement.name

		self.secondaryLabel?.text = nil
		self.secondaryLabel?.isHidden = true

		self.detailLabel?.text = nil
		self.detailLabel?.isHidden = true

		self.iconImageView?.image = UIImage(systemName: "speaker.wave.3")
		self.iconImageView?.preferredSymbolConfiguration = UIImage.SymbolConfiguration(pointSize: UIFont.preferredFont(forTextStyle: .body).pointSize, weight: .regular, scale: .default)
		self.iconImageView?.contentMode = .center
		self.iconImageView?.layer.borderWidth = 0.0
		self.iconImageView?.layerCornerRadius = 0.0

		if !self.selectedImageView.isHidden, appChimeElement.name == "jeb_" {
			self.startColorCycling()
		} else {
			self.primaryLabel?.theme_textColor = KThemePicker.textColor.rawValue
		}
	}

	func configureCell(using animation: SplashScreenAnimation) {
		self.primaryLabel?.text = animation.titleValue

		self.secondaryLabel?.text = nil
		self.secondaryLabel?.isHidden = true

		self.detailLabel?.text = nil
		self.detailLabel?.isHidden = true

		self.iconImageView?.image = UIImage(systemName: "play.circle")
		self.iconImageView?.preferredSymbolConfiguration = nil
		self.iconImageView?.contentMode = .center
		self.iconImageView?.layer.borderWidth = 0.0
		self.iconImageView?.layerCornerRadius = 0.0
	}

	/// Configures the cell with a store transaction and its StoreKit product.
	func configureCell(using transaction: StoreTransaction, product: Product?) {
		let displayName: String

		if let storeKitName = product?.displayName, !storeKitName.isEmpty {
			displayName = storeKitName
		} else {
			displayName = transaction.attributes.productID
		}

		self.primaryLabel?.text = displayName

		self.secondaryLabel?.text = Self.subtitle(for: transaction)
		self.secondaryLabel?.isHidden = self.secondaryLabel?.text?.isEmpty ?? true

		self.detailLabel?.text = Self.priceText(for: transaction, product: product)
		self.detailLabel?.isHidden = self.detailLabel?.text?.isEmpty ?? true

		self.iconImageView?.image = Store.shared.image(for: transaction.attributes.productID)
		self.iconImageView?.preferredSymbolConfiguration = nil
		self.iconImageView?.contentMode = .scaleAspectFit
		self.iconImageView?.layerCornerRadius = 12.0

		self.selectedImageView?.isHidden = true
	}
}

// MARK: - Helpers
private extension IconTableViewCell {
	private static func subtitle(for transaction: StoreTransaction) -> String? {
		if let revokedAt = transaction.attributes.revokedAt {
			return L10n.refundedOn(revokedAt.formatted(date: .abbreviated, time: .omitted))
		}
		guard let purchasedAt = transaction.attributes.purchasedAt else { return nil }
		switch transaction.attributes.productType {
		case .autoRenewingSubscription, .nonRenewingSubscription:
			return L10n.subscribedOn(purchasedAt.formatted(date: .abbreviated, time: .omitted))
		default:
			return L10n.purchasedOn(purchasedAt.formatted(date: .abbreviated, time: .omitted))
		}
	}

	private static func priceText(for transaction: StoreTransaction, product: Product?) -> String? {
		if let displayPrice = product?.displayPrice, !displayPrice.isEmpty {
			return displayPrice
		}
		guard let milliunits = transaction.attributes.priceMilliunits, let currency = transaction.attributes.currency else {
			return nil
		}
		let amount = NSDecimalNumber(value: milliunits).dividing(by: 1000)
		let formatter = NumberFormatter()
		formatter.numberStyle = .currency
		formatter.currencyCode = currency
		return formatter.string(from: amount)
	}

	func startColorCycling() {
		self.colorCycleTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { [weak self] _ in
			guard let self = self else { return }
			self.applyRainbowColors()
		}
		guard let colorCycleTimer = self.colorCycleTimer else { return }
		RunLoop.main.add(colorCycleTimer, forMode: .common)
	}

	func stopColorCycling() {
		self.colorCycleTimer?.invalidate()
		self.colorCycleTimer = nil
	}

	func applyRainbowColors() {
		let colorCycle = self.rainbowColors.rotate(by: -1)
		guard let textColor = colorCycle.first else { return }
		guard let primaryLabel = self.primaryLabel else { return }

		UIView.transition(with: primaryLabel, duration: 0.5, options: .transitionCrossDissolve) {
			self.primaryLabel?.textColor = textColor
		}
	}
}
