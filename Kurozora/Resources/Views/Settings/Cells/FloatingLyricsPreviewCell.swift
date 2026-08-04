//
//  FloatingLyricsPreviewCell.swift
//  Kurozora
//
//  Created by Khoren Katklian on 04/08/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import UIKit

/// A cell hosting the floating lyrics preview at the window's aspect ratio.
final class FloatingLyricsPreviewCell: KTableViewCell {
	// MARK: - Views
	/// The preview the manager mirrors frames into.
	let previewView = FloatingLyricsPreviewView(frame: .zero)

	// MARK: - Properties
	/// The constraint tying the preview's height to the current canvas aspect ratio.
	private var aspectConstraint: NSLayoutConstraint?

	override var isSkeletonEnabled: Bool {
		return false
	}

	// MARK: - Initializers
	override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)

		self.backgroundColor = .clear
		self.backgroundConfiguration = .clear()
		self.backgroundView = nil
		self.selectedBackgroundView = nil
		self.contentView.theme_backgroundColor = nil
		self.contentView.backgroundColor = .clear
		self.selectionStyle = .none

		self.previewView.translatesAutoresizingMaskIntoConstraints = false
		self.contentView.addSubview(self.previewView)

		let referenceCanvasSize = FloatingLyricsRenderer.canvasSize(for: .two)
		let cellHeightConstraint = self.contentView.heightAnchor.constraint(equalTo: self.contentView.widthAnchor, multiplier: referenceCanvasSize.height / referenceCanvasSize.width)
		cellHeightConstraint.priority = .required - 1

		NSLayoutConstraint.activate([
			cellHeightConstraint,
			self.previewView.centerXAnchor.constraint(equalTo: self.contentView.centerXAnchor),
			self.previewView.centerYAnchor.constraint(equalTo: self.contentView.centerYAnchor),
			self.previewView.widthAnchor.constraint(equalTo: self.contentView.widthAnchor),
		])

		self.setRows(UserSettings.lyricsFloatingWindowRows)
	}

	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	// MARK: - View
	override func layoutSubviews() {
		super.layoutSubviews()

		self.layer.cornerRadius = 0
		self.layer.masksToBounds = false
		self.layer.mask = nil
		self.contentView.layer.cornerRadius = 0
		self.contentView.layer.masksToBounds = false
	}

	// MARK: - Functions
	/// Matches the preview's aspect ratio to the given number of rows.
	///
	/// - Parameter rows: The number of lyric rows in the window.
	func setRows(_ rows: LyricsFloatingWindowRows) {
		let canvasSize = FloatingLyricsRenderer.canvasSize(for: rows)
		let ratio = canvasSize.width / canvasSize.height

		if let aspectConstraint = self.aspectConstraint {
			guard abs(aspectConstraint.multiplier - ratio) > 0.01 else { return }
			aspectConstraint.isActive = false
		}

		let aspectConstraint = self.previewView.widthAnchor.constraint(equalTo: self.previewView.heightAnchor, multiplier: ratio)
		aspectConstraint.priority = .required - 1
		aspectConstraint.isActive = true
		self.aspectConstraint = aspectConstraint
	}
}
