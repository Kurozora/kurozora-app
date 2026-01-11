//
//  GIFView.swift
//  Kurozora
//
//  Created by Khoren Katklian on 04/03/2024.
//  Copyright © 2024 Kurozora. All rights reserved.
//

import UIKit

protocol GIFViewDelegate: AnyObject {
	func gifViewDidLoadGIF(_ gifView: GIFView)
}

class GIFView: UIView {
	// MARK: - Properties
	weak var delegate: GIFViewDelegate?

	let gifURL: URL
	private let _superview: UIView
	var imageViewHeightConstraint: NSLayoutConstraint!

	// MARK: - Views
	let gifImageView: AspectRatioImageView = {
		let imageView = AspectRatioImageView()
		imageView.translatesAutoresizingMaskIntoConstraints = false
		imageView.contentMode = .scaleAspectFill
		imageView.layerCornerRadius = 10.0
		return imageView
	}()

	// MARK: - Initializers
	init(url: URL, in superview: UIView) {
		self.gifURL = url
		self._superview = superview
		super.init(frame: .zero)
		self.configureLayout()
		self.configureGIF()
	}

	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) is not supported. Use init(url: URL) instead.")
	}

	// MARK: - Functions
	fileprivate func configureGIF() {
		self.gifImageView.kf.setImage(with: self.gifURL) { [weak self] result in
			guard let self = self else { return }

			switch result {
			case .success:
				self.delegate?.gifViewDidLoadGIF(self)
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

		// Top and bottom constraints are optional depending on the usage within the superview
		// Adjust as needed
		self.gifImageView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
		self.gifImageView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
	}
}
