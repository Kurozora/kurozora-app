//
//  TrailerAirPlayNoticeView.swift
//  Kurozora
//
//  Created by Khoren Katklian on 29/08/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import UIKit

/// A notice covering a trailer's picture while it plays on an AirPlay device.
final class TrailerAirPlayNoticeView: UIView {
	// MARK: - Views
	/// The notice's wording, naming the device when it is known.
	private let noticeLabel: UILabel = {
		let label = UILabel()
		label.translatesAutoresizingMaskIntoConstraints = false
		label.font = .preferredFont(forTextStyle: .subheadline)
		label.textColor = UIColor(white: 0.65, alpha: 1.0)
		label.textAlignment = .center
		label.numberOfLines = 0
		return label
	}()

	// MARK: - Initializers
	override init(frame: CGRect) {
		super.init(frame: frame)
		self.sharedInit()
	}

	required init?(coder: NSCoder) {
		super.init(coder: coder)
		self.sharedInit()
	}

	// MARK: - View
	/// Configures the notice's view hierarchy and layout.
	private func sharedInit() {
		self.translatesAutoresizingMaskIntoConstraints = false
		self.backgroundColor = .black
		self.isUserInteractionEnabled = false
		self.isHidden = true

		let deviceImageView = UIImageView(image: UIImage(systemName: "tv", withConfiguration: UIImage.SymbolConfiguration(pointSize: 40.0, weight: .light)))
		deviceImageView.translatesAutoresizingMaskIntoConstraints = false
		deviceImageView.tintColor = UIColor(white: 0.65, alpha: 1.0)
		deviceImageView.contentMode = .scaleAspectFit

		let noticeStackView = UIStackView(arrangedSubviews: [deviceImageView, self.noticeLabel])
		noticeStackView.translatesAutoresizingMaskIntoConstraints = false
		noticeStackView.axis = .vertical
		noticeStackView.spacing = 12.0
		noticeStackView.alignment = .center
		self.addSubview(noticeStackView)

		NSLayoutConstraint.activate([
			noticeStackView.centerXAnchor.constraint(equalTo: self.centerXAnchor),
			noticeStackView.centerYAnchor.constraint(equalTo: self.centerYAnchor),
			noticeStackView.leadingAnchor.constraint(greaterThanOrEqualTo: self.leadingAnchor, constant: 16.0),
			noticeStackView.trailingAnchor.constraint(lessThanOrEqualTo: self.trailingAnchor, constant: -16.0)
		])
	}

	// MARK: - Functions
	/// Freshens the wording with the streaming device's name.
	func refresh() {
		let deviceName = TrailerAirPlayStreamer.shared.deviceName
		self.noticeLabel.text = deviceName.map { L10n.videoPlayingOn($0) } ?? L10n.videoPlayingOnTV
	}
}
