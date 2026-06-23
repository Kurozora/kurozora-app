//
//  MenuControl.swift
//  Kurozora
//
//  Created by Khoren Katklian on 30/06/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import UIKit

/// A control that presents a menu on tap without morphing its source view.
///
/// Assign ``menuProvider`` to supply the menu. It is shown through the control's context-menu
/// interaction, so the source stays in place instead of morphing as a `UIButton`'s menu would.
@available(iOS 17.0, *)
class MenuControl: IconPressControl {
	// MARK: - Properties
	/// Builds the menu presented when the control is tapped.
	var menuProvider: (() -> UIMenu?)?

	// MARK: - Initializers
	override init(frame: CGRect) {
		super.init(frame: frame)
		self.isContextMenuInteractionEnabled = true
		self.showsMenuAsPrimaryAction = true
	}

	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	// MARK: - UIContextMenuInteractionDelegate
	override func contextMenuInteraction(_ interaction: UIContextMenuInteraction, configurationForMenuAtLocation location: CGPoint) -> UIContextMenuConfiguration? {
		return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { [weak self] _ in
			self?.menuProvider?()
		}
	}
}
