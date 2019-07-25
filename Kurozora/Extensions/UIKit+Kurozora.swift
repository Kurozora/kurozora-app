//
//  UIKit+Kurozora.swift
//  Kurozora
//
//  Created by Khoren Katklian on 06/05/2019.
//  Copyright © 2019 Kurozora. All rights reserved.
//

import UIKit

open class KButton: UIButton {
	private lazy var animator = UIViewPropertyAnimator()
	private lazy var selectionFeedbackGenerator = UISelectionFeedbackGenerator()
	var normalBackgroundColor: UIColor?

	// MARK: - IBInspectables
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
		if highlightBackgroundColor != nil {
			normalBackgroundColor = backgroundColor
			UIViewPropertyAnimator().stopAnimation(true)
			animator.stopAnimation(true)
			backgroundColor = highlightBackgroundColor
		}
		selectionFeedbackGenerator.selectionChanged()
	}

	@objc private func touchUp() {
		if highlightBackgroundColor != nil {
			animator = UIViewPropertyAnimator(duration: 0.5, curve: .easeOut, animations: {
				self.backgroundColor = self.normalBackgroundColor
			})
		}
		self.selectionFeedbackGenerator.selectionChanged()
		animator.startAnimation()
	}
}
