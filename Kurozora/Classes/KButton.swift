//
//  UIKit+Kurozora.swift
//  Kurozora
//
//  Created by Khoren Katklian on 06/05/2019.
//  Copyright © 2019 Kurozora. All rights reserved.
//

import UIKit

class KButton: UIButton {
	private lazy var animator = UIViewPropertyAnimator()
	private lazy var selectionFeedbackGenerator = UISelectionFeedbackGenerator()
	var normalBackgroundColor: UIColor?
	var _highlightBackgroundColor: UIColor?

	// MARK: - IBInspectables
	@IBInspectable var highlightBackgroundColorEnabled: Bool = false
	@IBInspectable var highlightBackgroundColor: UIColor?

	override init(frame: CGRect) {
		super.init(frame: frame)
	}

	required public init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		sharedInit()
	}

	// MARK: - Functions
	private func sharedInit() {
		addTarget(self, action: #selector(touchDown), for: [.touchDown, .touchDragEnter])
		addTarget(self, action: #selector(touchUp), for: [.touchUpInside, .touchDragExit, .touchCancel])
	}

	@objc private func touchDown() {
		_highlightBackgroundColor = (backgroundColor != .white) ? backgroundColor?.lighten(by: 0.1) : backgroundColor?.darken(by: 0.15)
		if highlightBackgroundColorEnabled || highlightBackgroundColor != nil {
			normalBackgroundColor = backgroundColor
			UIViewPropertyAnimator().stopAnimation(true)
			animator.stopAnimation(true)
			backgroundColor = highlightBackgroundColor ?? _highlightBackgroundColor
		}
		selectionFeedbackGenerator.selectionChanged()
	}

	@objc private func touchUp() {
		if highlightBackgroundColorEnabled || highlightBackgroundColor != nil {
			animator = UIViewPropertyAnimator(duration: 0.5, curve: .easeOut, animations: {
				self.backgroundColor = self.normalBackgroundColor
			})
		}
		self.selectionFeedbackGenerator.selectionChanged()
		animator.startAnimation()
	}
}
