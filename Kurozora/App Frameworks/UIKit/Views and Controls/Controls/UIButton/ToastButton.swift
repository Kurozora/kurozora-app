//
//  ToastButton.swift
//  Kurozora
//
//  Created by Khoren Katklian on 28/08/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import UIKit

/// A transient notice that floats over content and fades away on its own.
final class ToastButton: AdaptiveCornerButton {
	// MARK: - Properties
	/// The action performed when the toast is tapped.
	private let tapAction: (() -> Void)?

	/// The work dismissing the toast after its stay.
	private var dismissTask: Task<Void, Never>?

	/// How long the toast stays in view, in seconds.
	private static let stayDuration: TimeInterval = 4.0

	// MARK: - Initializers
	/// Creates a toast showing the given message.
	///
	/// - Parameters:
	///    - message: The message the toast shows.
	///    - systemImageName: The name of the symbol shown beside the message.
	///    - tapAction: The action performed when the toast is tapped.
	init(message: String, systemImageName: String, tapAction: (() -> Void)? = nil) {
		self.tapAction = tapAction
		super.init(frame: .zero)

		self.translatesAutoresizingMaskIntoConstraints = false
		self.alpha = 0
		self.configuration?.image = UIImage(systemName: systemImageName)
		self.configuration?.imagePlacement = .leading
		self.configuration?.imagePadding = 8
		self.configuration?.attributedTitle = self.title(for: message)
		self.configuration?.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
			var outgoing = incoming
			outgoing.font = .preferredFont(forTextStyle: .subheadline)
			return outgoing
		}

		self.addAction(UIAction { [weak self] _ in
			guard let self = self else { return }
			self.dismissTask?.cancel()
			self.tapAction?()
			self.dismiss()
		}, for: .touchUpInside)

		self.addGestureRecognizer(UIHoverGestureRecognizer(target: self, action: #selector(self.hoverChanged(_:))))
	}

	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	// MARK: - Functions
	/// Presents the toast.
	///
	/// - Parameter feedback: The haptic played as the toast appears.
	func present(feedback: UINotificationFeedbackGenerator.FeedbackType?) {
		self.superview?.subviews
			.compactMap { $0 as? ToastButton }
			.filter { $0 !== self }
			.forEach { $0.dismiss() }

		if let feedback, UserSettings.hapticsAllowed {
			UINotificationFeedbackGenerator().notificationOccurred(feedback)
		}

		UIView.animate(withDuration: 0.32, delay: 0, options: [.curveEaseOut]) {
			self.alpha = 1
		} completion: { [weak self] _ in
			self?.scheduleDismissal(after: Self.stayDuration)
		}
	}

	/// Dismisses the toast.
	func dismiss() {
		self.dismissTask?.cancel()

		UIView.animate(withDuration: 0.32, delay: 0, options: [.curveEaseIn]) {
			self.alpha = 0
		} completion: { [weak self] finished in
			guard finished else { return }
			self?.removeFromSuperview()
		}
	}

	/// Dismisses the toast once its stay runs out.
	///
	/// - Parameter seconds: How long the toast stays, in seconds.
	private func scheduleDismissal(after seconds: TimeInterval) {
		self.dismissTask?.cancel()
		self.dismissTask = Task { @MainActor [weak self] in
			try? await Task.sleep(nanoseconds: UInt64(seconds * 1_000_000_000))
			guard !Task.isCancelled else { return }
			self?.dismiss()
		}
	}

	/// Builds the title for the given message.
	///
	/// - Parameter message: The message the toast shows.
	///
	/// - Returns: The configured title.
	private func title(for message: String) -> AttributedString {
		let title = NSMutableAttributedString(string: message)

		if self.tapAction != nil {
			let titleFont = UIFont.preferredFont(forTextStyle: .subheadline)
			let symbolConfiguration = UIImage.SymbolConfiguration(font: .preferredFont(forTextStyle: .footnote))
			let chevron = NSTextAttachment()

			if let chevronImage = UIImage(systemName: "chevron.forward", withConfiguration: symbolConfiguration)?.withTintColor(.secondaryLabel, renderingMode: .alwaysOriginal) {
				chevron.image = chevronImage
				// The offset centers the glyph within the symbol's unevenly padded box.
				chevron.bounds = CGRect(x: 0.0, y: (titleFont.capHeight - chevronImage.size.height) / 2.0 + 0.75, width: chevronImage.size.width, height: chevronImage.size.height)
			}

			title.append(NSAttributedString(string: "  "))
			title.append(NSAttributedString(attachment: chevron))
		}

		return AttributedString(title)
	}

	/// Holds the toast in view while the pointer is over it.
	///
	/// - Parameter recognizer: The recognizer reporting the hover.
	@objc private func hoverChanged(_ recognizer: UIHoverGestureRecognizer) {
		switch recognizer.state {
		case .began, .changed:
			self.dismissTask?.cancel()
			self.layer.removeAllAnimations()
			self.alpha = 1
		case .ended, .cancelled, .failed:
			self.scheduleDismissal(after: 1.5)
		default:
			break
		}
	}
}
