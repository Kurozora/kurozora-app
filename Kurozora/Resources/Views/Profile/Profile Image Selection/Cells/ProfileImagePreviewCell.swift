//
//  ProfileImagePreviewCell.swift
//  Kurozora
//
//  Created by Khoren Katklian on 13/03/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import UIKit

class ProfileImagePreviewCell: UICollectionViewCell {
	static let reuseIdentifier = "ProfileImagePreviewCell"

	private let circularView: CircularView = {
		let view = CircularView(frame: .zero)
		view.translatesAutoresizingMaskIntoConstraints = false
		return view
	}()

	let profileImageView: UIImageView = {
		let imageView = UIImageView()
		imageView.translatesAutoresizingMaskIntoConstraints = false
		imageView.contentMode = .scaleAspectFill
		imageView.clipsToBounds = true
		imageView.backgroundColor = .clear
		return imageView
	}()

	override init(frame: CGRect) {
		super.init(frame: frame)
		self.configureViews()
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	private func configureViews() {
		self.contentView.addSubview(self.circularView)
		self.circularView.addSubview(self.profileImageView)

		NSLayoutConstraint.activate([
			self.circularView.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 8),
			self.circularView.centerXAnchor.constraint(equalTo: self.contentView.centerXAnchor),
			self.circularView.widthAnchor.constraint(equalToConstant: 100),
			self.circularView.heightAnchor.constraint(equalToConstant: 100),

			self.profileImageView.topAnchor.constraint(equalTo: self.circularView.topAnchor),
			self.profileImageView.leadingAnchor.constraint(equalTo: self.circularView.leadingAnchor),
			self.profileImageView.trailingAnchor.constraint(equalTo: self.circularView.trailingAnchor),
			self.profileImageView.bottomAnchor.constraint(equalTo: self.circularView.bottomAnchor)
		])
	}

	func configure(with image: UIImage?) {
		if let image = image {
			self.profileImageView.image = image
			self.profileImageView.isHidden = false
		} else {
			self.profileImageView.isHidden = true
		}
	}
}
