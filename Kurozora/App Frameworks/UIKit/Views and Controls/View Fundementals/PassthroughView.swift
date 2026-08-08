//
//  PassthroughView.swift
//  Kurozora
//
//  Created by Khoren Katklian on 05/08/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import UIKit

/// A view that passes touches on its own area through to the views behind it.
class PassthroughView: UIView {
	// MARK: - Functions
	override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
		let hitView = super.hitTest(point, with: event)
		return hitView === self ? nil : hitView
	}
}
