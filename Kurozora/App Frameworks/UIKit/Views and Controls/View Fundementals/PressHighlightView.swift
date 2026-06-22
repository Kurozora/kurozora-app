//
//  PressHighlightView.swift
//  Kurozora
//
//  Created by Khoren Katklian on 27/06/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import UIKit

/// A circular highlight that grows and fades in beneath a control while pressed, matching the
/// press feedback of ``TransportButton``.
final class PressHighlightView: UIView {
	// MARK: - Initializers
	override init(frame: CGRect) {
		super.init(frame: frame)
		self.isUserInteractionEnabled = false
		self.clipsToBounds = true
		self.alpha = 0
		self.backgroundColor = .black.withAlphaComponent(0.5)
		self.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
	}

	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	// MARK: - View
	override func layoutSubviews() {
		super.layoutSubviews()
		self.layer.cornerRadius = self.bounds.height / 2
	}

	// MARK: - Functions
	/// Grows and fades the highlight in or out.
	///
	/// - Parameters:
	///    - pressed: Whether the highlight is visible.
	///    - animated: Whether to spring to the new state.
	func setPressed(_ pressed: Bool, animated: Bool) {
		let animation = { [weak self] in
			guard let self = self else { return }
			self.alpha = pressed ? 1 : 0
			self.transform = pressed ? .identity : CGAffineTransform(scaleX: 0.5, y: 0.5)
		}

		if animated {
			UIView.animate(withDuration: 0.4, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.5, options: [.allowUserInteraction, .beginFromCurrentState], animations: animation)
		} else {
			animation()
		}
	}
}
