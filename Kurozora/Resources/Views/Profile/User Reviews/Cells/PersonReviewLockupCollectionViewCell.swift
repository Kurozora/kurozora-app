//
//  PersonReviewLockupCollectionViewCell.swift
//  Kurozora
//
//  Created by Khoren Katklian on 08/12/2025.
//  Copyright © 2025 Kurozora. All rights reserved.
//

import UIKit

class PersonReviewLockupCollectionViewCell: BaseReviewLockupCollectionViewCell {
	// MARK: - Properties
	private var posterCircleObservation: NSKeyValueObservation?

	// MARK: - View
	nonisolated override func awakeFromNib() {
		super.awakeFromNib()

		MainActor.assumeIsolated {
			self.posterCircleObservation = self.posterImageView?.observe(\.bounds, options: [.new]) { [weak self] _, _ in
				MainActor.assumeIsolated {
					self?.syncPosterBorderRadius()
				}
			}

			self.posterImageView?.layer.borderWidth = 0
			self.syncPosterBorderRadius()
		}
	}

	override func layoutSubviews() {
		super.layoutSubviews()
		self.syncPosterBorderRadius()
	}

	// MARK: - Functions
	private func syncPosterBorderRadius() {
		guard let posterBorderView = self.posterBorderView else { return }
		posterBorderView.cornerRadius = (self.posterImageView?.bounds.height ?? 0) / 2.0
	}
}
