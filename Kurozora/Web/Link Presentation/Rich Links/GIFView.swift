//
//  GIFView.swift
//  Kurozora
//
//  Created by Khoren Katklian on 04/03/2024.
//  Copyright © 2024 Kurozora. All rights reserved.
//

import UIKit

class GIFView: UIView {
	// MARK: - Properties
	let gifURL: URL

	// MARK: - Views
	let gifImageView: UIImageView = {
		let imageView = UIImageView()
		imageView.translatesAutoresizingMaskIntoConstraints = false
		imageView.contentMode = .scaleAspectFill
		imageView.layerCornerRadius = 8
		return imageView
	}()

	// MARK: - Initializers
	init(url: URL) {
		self.gifURL = url
		super.init(frame: .zero)
		self.configureLayout()
		self.configureGIF()
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) is not supported. Use init(url: URL) instead.")
	}

	// MARK: - Functions
	fileprivate func configureGIF() {
		self.gifImageView.kf.setImage(with: self.gifURL)
		self.setNeedsLayout()
	}

	fileprivate func configureLayout() {
		self.addSubview(self.gifImageView)

		NSLayoutConstraint.activate([
			self.gifImageView.topAnchor.constraint(equalTo: self.topAnchor),
			self.gifImageView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
			self.gifImageView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
			self.gifImageView.bottomAnchor.constraint(equalTo: self.bottomAnchor)
		])
	}

	override func layoutSubviews() {
		super.layoutSubviews()

		// Update aspect ratio constraint based on image size
		if let imageSize = self.gifImageView.image?.size {
			let aspectRatio = imageSize.width / imageSize.height
			let aspectRatioConstraint = self.gifImageView.widthAnchor.constraint(equalTo: self.gifImageView.heightAnchor, multiplier: aspectRatio)
			aspectRatioConstraint.priority = .required - 1
			aspectRatioConstraint.isActive = true
		}
	}
}
