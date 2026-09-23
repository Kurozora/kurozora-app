//
//  ReCapContextMenuHandler.swift
//  Kurozora
//
//  Created by Khoren Katklian on 23/09/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import UIKit

/// The context menus of the titles inside a Re:CAP card.
final class ReCapContextMenuHandler: NSObject, UIContextMenuInteractionDelegate {
	// MARK: - Properties
	/// Returns the context menu of the title at the given index.
	var configurationProvider: ((_ index: Int, _ sourceView: UIView) -> UIContextMenuConfiguration?)?

	/// Shows the preview of a committed context menu.
	var previewCommitHandler: ((UIViewController) -> Void)?

	/// The corner radius of the highlighted title.
	var previewCornerRadius: CGFloat = 12.0

	// MARK: - Functions
	/// Adds a context menu to the given view of the title at the given index.
	///
	/// - Parameters:
	///    - view: The view of the title.
	///    - index: The index of the title.
	func addInteraction(to view: UIView, index: Int) {
		view.tag = index
		view.isUserInteractionEnabled = true
		view.interactions.filter { $0 is UIContextMenuInteraction }.forEach { view.removeInteraction($0) }
		view.addInteraction(UIContextMenuInteraction(delegate: self))
	}

	// MARK: - UIContextMenuInteractionDelegate
	func contextMenuInteraction(_ interaction: UIContextMenuInteraction, configurationForMenuAtLocation location: CGPoint) -> UIContextMenuConfiguration? {
		guard let view = interaction.view else { return nil }
		return self.configurationProvider?(view.tag, view)
	}

	func contextMenuInteraction(_ interaction: UIContextMenuInteraction, previewForHighlightingMenuWithConfiguration configuration: UIContextMenuConfiguration) -> UITargetedPreview? {
		return self.targetedPreview(for: interaction)
	}

	func contextMenuInteraction(_ interaction: UIContextMenuInteraction, previewForDismissingMenuWithConfiguration configuration: UIContextMenuConfiguration) -> UITargetedPreview? {
		return self.targetedPreview(for: interaction)
	}

	func contextMenuInteraction(_ interaction: UIContextMenuInteraction, willPerformPreviewActionForMenuWith configuration: UIContextMenuConfiguration, animator: any UIContextMenuInteractionCommitAnimating) {
		guard let previewViewController = animator.previewViewController else { return }

		animator.addCompletion { [weak self] in
			self?.previewCommitHandler?(previewViewController)
		}
	}

	/// Returns the preview of the title the given interaction belongs to.
	private func targetedPreview(for interaction: UIContextMenuInteraction) -> UITargetedPreview? {
		guard let view = interaction.view, view.window != nil else { return nil }

		let parameters = UIPreviewParameters()
		parameters.backgroundColor = .clear
		parameters.visiblePath = UIBezierPath(roundedRect: view.bounds, cornerRadius: self.previewCornerRadius)
		return UITargetedPreview(view: view, parameters: parameters)
	}
}
