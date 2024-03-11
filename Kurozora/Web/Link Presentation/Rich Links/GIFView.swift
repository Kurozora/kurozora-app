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
	var imageViewHeightConstraint: NSLayoutConstraint!
	var aspectRatio: CGFloat = 0.0

	// MARK: - Views
	let gifImageView: UIImageView = {
		let imageView = UIImageView()
		imageView.translatesAutoresizingMaskIntoConstraints = false
		imageView.contentMode = .scaleAspectFit
		imageView.layerCornerRadius = 10.0
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
		self.gifImageView.kf.setImage(with: self.gifURL) { [weak self] result in
			guard let self = self else { return }

			switch result {
			case .success(let value):
				// Update height constraint based on image aspect ratio
				let image = value.image
				self.aspectRatio = image.size.height / image.size.width
			case .failure(let error):
				print("Failed to load image: \(error)")
			}
		}
	}

	fileprivate func configureLayout() {
		self.addSubview(self.gifImageView)

		// Width constraint is set to superview's width
		self.gifImageView.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
		self.gifImageView.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true

		// Height constraint
		self.imageViewHeightConstraint = self.gifImageView.heightAnchor.constraint(equalToConstant: 0)
		self.imageViewHeightConstraint.isActive = true

		// Top and bottom constraints are optional depending on the usage within the superview
		// Adjust as needed
		self.gifImageView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
		self.gifImageView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
	}

	func sizeToFit(_ size: CGSize) {
		self.imageViewHeightConstraint.constant = size.width * self.aspectRatio
	}
}
