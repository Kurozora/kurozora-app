//
//  KTappableLabel.swift
//  Kurozora
//
//  Created by Khoren Katklian on 06/10/2024.
//  Copyright © 2024 Kurozora. All rights reserved.
//

import UIKit

/// A themed view that displays one or more lines of read-only text, often used in conjunction with controls to describe their intended purpose.
///
/// The color of the labels is pre-configured with the currently selected theme's tint color.
/// You can add labels to your interface programmatically or by using Interface Builder.
/// The label supports tapping on links.
///
/// Usage:
/// ```
/// let label = KTappableLabel()
/// label.setLinks(with: [("Kurozora", "https://kurozora.app")])
/// ```
///
/// - Note: The label will display the text as a bullet list.
///
/// - Tag: KTappableLabel
class KTappableLabel: UILabel {
	// MARK: - Properties
	/// The ranges of the links in the text.
	private var linkRanges: [(range: NSRange, url: String)] = []

	// MARK: - Initialization
	override init(frame: CGRect) {
		super.init(frame: frame)
		self.sharedInit()
	}

	required init?(coder: NSCoder) {
		super.init(coder: coder)
		self.sharedInit()
	}

	// MARK: - Private Methods
	/// The shared settings used to initialize the label.
	private func sharedInit() {
		self.isUserInteractionEnabled = true

		let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
		self.addGestureRecognizer(tapGesture)
	}

	/// Set the text and links.
	///
	/// - Parameter urls: The URLs to be set as links.
	func setLinks(with urls: [(displayText: String, urlString: String)]) {
		var text = ""

		for (domainText, urlString) in urls {
			let displayText = "• \(domainText)\n"
			let range = NSRange(location: text.count, length: displayText.count)

			text += displayText
			self.linkRanges.append((range: range, url: urlString))
		}

		self.theme_textColor = KThemePicker.tintColor.rawValue
		self.text = text
	}

	// MARK: - Actions
	/// Open the URL if the tap is on a link.
	///
	/// - Parameter gesture: The tap gesture.
	@objc private func handleTap(_ gesture: UITapGestureRecognizer) {
		// Get the location of the tap in the label's bounds
		let tapLocation = gesture.location(in: self)

		// Get the index of the character tapped, based on the label's text size and font
		if let tappedIndex = self.getTappedCharacterIndex(at: tapLocation) {
			// Check if tapped character is in any of the ranges
			for (range, urlString) in self.linkRanges where NSLocationInRange(tappedIndex, range) {
				// Open the tapped URL
				if let url = URL(string: urlString) {
					UIApplication.shared.kOpen(url)
				}
				break
			}
		}
	}

	/// Helper function to calculate which character index was tapped.
	///
	/// - Parameter location: The location of the tap in the label's bounds.
	///
	/// - Returns: The index of the character that was tapped.
	private func getTappedCharacterIndex(at location: CGPoint) -> Int? {
		guard let labelText = self.text, let font = self.font else { return 0 }

		// Get the full text size and split into lines
		let textRect = CGRect(origin: .zero, size: CGSize(width: bounds.width, height: CGFloat.greatestFiniteMagnitude))
		let attributes: [NSAttributedString.Key: Any] = [.font: font]

		// Loop through each line of the label text
		var characterIndex = 0
		var currentY: CGFloat = 0

		for lineText in labelText.split(separator: "\n") {
			let line = String(lineText)
			let lineSize = (line as NSString).boundingRect(with: textRect.size, options: .usesLineFragmentOrigin, attributes: attributes, context: nil)

			// Check if the tap is in the vertical bounds of the current line
			if location.y >= currentY && location.y <= currentY + lineSize.height {
				// Calculate the horizontal offset of the tap
				let relativeX = location.x

				// Loop through each character in the line and find the character at the tap location
				for i in 0..<line.count {
					let substring = String(line.prefix(i + 1))
					let substringSize = (substring as NSString).boundingRect(with: textRect.size, options: .usesLineFragmentOrigin, attributes: attributes, context: nil)

					// If the tap location falls within the width of the substring, return the index
					if relativeX <= substringSize.width {
						return characterIndex + i
					}
				}
			}

			currentY += lineSize.height
			characterIndex += line.count + 1 // Account for the newline character
		}

		return characterIndex
	}
}
