//
//  KnockoutButton.swift
//  Kurozora
//
//  Created by Khoren Katklian on 12/06/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import SwiftTheme
import UIKit

/// `KnockoutButton` is a specially crafted object that displays a button with a cutout in your interface.
///
/// `KnockoutButton` adjusts some options to achieve its design, this includes:
/// - Knocking the symbol out of a fill when active, revealing the content behind it.
final class KnockoutButton: UIButton {
	// MARK: - Views
	private let effectView: UIVisualEffectView = {
		let view: UIVisualEffectView
		if #available(iOS 26.0, *) {
			let glass = UIGlassEffect()
			glass.isInteractive = true
			view = UIVisualEffectView(effect: glass)
			view.cornerConfiguration = .capsule()
		} else {
			view = UIVisualEffectView(effect: UIBlurEffect(style: .systemMaterial))
			view.layer.masksToBounds = true
		}
		view.isUserInteractionEnabled = false
		view.translatesAutoresizingMaskIntoConstraints = false
		return view
	}()

	private let symbolImageView: UIImageView = {
		let imageView = UIImageView()
		imageView.contentMode = .center
		imageView.translatesAutoresizingMaskIntoConstraints = false
		return imageView
	}()

	private let fillView: UIView = {
		let view = UIView()
		view.isHidden = true
		view.translatesAutoresizingMaskIntoConstraints = false
		return view
	}()

	private let knockoutMaskView = UIImageView()

	// MARK: - Properties
	private let symbolImage: UIImage?
	private let colorKey: KThemePicker
	private var maskedSize: CGSize = .zero

	/// A Boolean value that indicates whether the material is filled with the symbol knocked out of it.
	var isActiveState = false {
		didSet {
			self.symbolImageView.isHidden = self.isActiveState
			self.fillView.isHidden = !self.isActiveState
		}
	}

	// MARK: - Initializers
	/// Creates a knockout button.
	///
	/// - Parameters:
	///    - symbol: The symbol image to display.
	///    - pointSize: The point size of the symbol.
	///    - weight: The weight of the symbol.
	///    - colorKey: The theme color of the symbol and its active-state fill.
	init(symbol: UIImage?, pointSize: CGFloat = 18, weight: UIImage.SymbolWeight = .regular, colorKey: KThemePicker = .textColor) {
		let configuration = UIImage.SymbolConfiguration(pointSize: pointSize, weight: weight)
		self.symbolImage = symbol?.applyingSymbolConfiguration(configuration)?.withRenderingMode(.alwaysTemplate)
		self.colorKey = colorKey
		super.init(frame: .zero)
		self.configureSubviews()
	}

	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	// MARK: - View
	override func layoutSubviews() {
		super.layoutSubviews()

		guard self.bounds.width > 0, self.bounds.height > 0 else { return }

		if #unavailable(iOS 26.0) {
			self.effectView.layer.cornerRadius = min(self.bounds.width, self.bounds.height) / 2
		}

		self.fillView.mask = self.knockoutMaskView
		self.knockoutMaskView.frame = self.bounds

		guard self.maskedSize != self.bounds.size else { return }
		self.maskedSize = self.bounds.size
		self.knockoutMaskView.image = self.knockoutMaskImage(size: self.bounds.size)
	}

	// MARK: - Functions
	private func configureSubviews() {
		self.symbolImageView.theme_tintColor = self.colorKey.rawValue
		self.symbolImageView.image = self.symbolImage
		self.fillView.theme_backgroundColor = self.colorKey.rawValue

		self.addSubview(self.effectView)
		self.effectView.contentView.addSubview(self.fillView)
		self.effectView.contentView.addSubview(self.symbolImageView)

		NSLayoutConstraint.activate([
			self.effectView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
			self.effectView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
			self.effectView.topAnchor.constraint(equalTo: self.topAnchor),
			self.effectView.bottomAnchor.constraint(equalTo: self.bottomAnchor),

			self.fillView.leadingAnchor.constraint(equalTo: self.effectView.contentView.leadingAnchor),
			self.fillView.trailingAnchor.constraint(equalTo: self.effectView.contentView.trailingAnchor),
			self.fillView.topAnchor.constraint(equalTo: self.effectView.contentView.topAnchor),
			self.fillView.bottomAnchor.constraint(equalTo: self.effectView.contentView.bottomAnchor),

			self.symbolImageView.centerXAnchor.constraint(equalTo: self.effectView.contentView.centerXAnchor),
			self.symbolImageView.centerYAnchor.constraint(equalTo: self.effectView.contentView.centerYAnchor),
		])
	}

	/// Builds an alpha mask that fills the capsule and punches the symbol out of it.
	///
	/// - Parameter size: The mask size in points.
	///
	/// - Returns: A mask whose only transparent region is the symbol.
	private func knockoutMaskImage(size: CGSize) -> UIImage? {
		guard size.width > 0, size.height > 0 else { return nil }

		return UIGraphicsImageRenderer(size: size).image { _ in
			let radius = min(size.width, size.height) / 2
			UIColor.white.setFill()
			UIBezierPath(roundedRect: CGRect(origin: .zero, size: size), cornerRadius: radius).fill()

			if let symbol = self.symbolImage {
				let origin = CGPoint(x: (size.width - symbol.size.width) / 2, y: (size.height - symbol.size.height) / 2)
				symbol.draw(in: CGRect(origin: origin, size: symbol.size), blendMode: .destinationOut, alpha: 1)
			}
		}
	}
}
