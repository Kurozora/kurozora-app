//
//  TrailerPausedFrameView.swift
//  Kurozora
//
//  Created by Khoren Katklian on 27/08/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import UIKit
import VisionKit

/// The still standing in for a paused trailer, readable for text selection and subject lifting.
final class TrailerPausedFrameView: UIImageView {
	// MARK: - Properties
	/// The interaction offering text selection and subject lifting.
	private var analysisInteraction: AnyObject?

	/// The task reading the frame for selection and lifting.
	private var analysisTask: Task<Void, Never>?

	// MARK: - Initializers
	init() {
		super.init(frame: .zero)

		self.contentMode = .scaleToFill
		self.isHidden = true
		self.isUserInteractionEnabled = true

		if #available(iOS 17.0, macCatalyst 17.0, *), ImageAnalyzer.isSupported {
			let analysisInteraction = ImageAnalysisInteraction()
			analysisInteraction.preferredInteractionTypes = [.textSelection, .imageSubject]
			self.addInteraction(analysisInteraction)
			self.analysisInteraction = analysisInteraction
		}

		self.addInteraction(UIContextMenuInteraction(delegate: self))
	}

	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	// MARK: - Functions
	/// Shows the given frame.
	///
	/// - Parameters:
	///    - frame: The paused frame to show.
	///    - readsFrame: Whether the frame is read for selection and lifting.
	func showFrame(_ frame: UIImage, readsFrame: Bool = true) {
		self.image = frame
		self.isHidden = false

		if readsFrame {
			self.analyzeFrame(frame)
		} else {
			self.analysisTask?.cancel()
		}
	}

	/// Takes the frame off the screen.
	func hideFrame() {
		self.isHidden = true
		self.analysisTask?.cancel()
	}

	/// Reads the frame for selection and lifting.
	///
	/// - Parameter frame: The frame to read.
	private func analyzeFrame(_ frame: UIImage) {
		guard
			#available(iOS 17.0, macCatalyst 17.0, *),
			let analysisInteraction = self.analysisInteraction as? ImageAnalysisInteraction
		else { return }

		self.analysisTask?.cancel()
		self.analysisTask = Task { @MainActor [weak self] in
			do {
				let analysis = try await ImageAnalyzer().analyze(frame, configuration: ImageAnalyzer.Configuration([.text]))
				guard !Task.isCancelled, self != nil else { return }
				analysisInteraction.analysis = analysis
			} catch {
				print("----- [Trailer] Failed to read the paused frame: \(error.localizedDescription)")
			}
		}
	}

	/// Builds the actions offering the frame itself.
	///
	/// - Returns: The configured actions.
	private func makeFrameActions() -> [UIMenuElement] {
		return [
			UIAction(title: L10n.copyImage, image: UIImage(systemName: "doc.on.doc")) { [weak self] _ in
				guard let image = self?.image else { return }
				UIPasteboard.general.image = image
			},
			UIAction(title: L10n.shareImage, image: UIImage(systemName: "square.and.arrow.up")) { [weak self] _ in
				guard let self = self, let image = self.image else { return }
				self.share(image)
			}
		]
	}

	/// Builds the element offering the frame's lifted subjects.
	///
	/// - Returns: The configured element.
	@available(iOS 17.0, macCatalyst 17.0, *)
	private func makeSubjectElement() -> UIMenuElement {
		return UIDeferredMenuElement.uncached { [weak self] completion in
			Task { @MainActor in
				guard let self = self, let analysisInteraction = self.analysisInteraction as? ImageAnalysisInteraction else {
					completion([])
					return
				}

				let subjects = await analysisInteraction.subjects
				let attributes: UIMenuElement.Attributes = subjects.isEmpty ? [.disabled] : []

				completion([
					UIAction(title: L10n.copySubject, image: UIImage(systemName: "doc.on.doc"), attributes: attributes) { _ in
						Task { @MainActor in
							guard let subjectImage = try? await analysisInteraction.image(for: subjects) else { return }
							UIPasteboard.general.image = subjectImage
						}
					},
					UIAction(title: L10n.shareSubject, image: UIImage(systemName: "square.and.arrow.up"), attributes: attributes) { [weak self] _ in
						Task { @MainActor in
							guard let self = self, let subjectImage = try? await analysisInteraction.image(for: subjects) else { return }
							self.share(subjectImage)
						}
					}
				])
			}
		}
	}

	/// Shares the given picture from the frame.
	///
	/// - Parameter image: The picture to share.
	private func share(_ image: UIImage) {
		var responder: UIResponder? = self.next
		while let current = responder {
			if let viewController = current as? UIViewController {
				let activityViewController = UIActivityViewController(activityItems: [image], applicationActivities: nil)
				activityViewController.popoverPresentationController?.sourceView = self
				(viewController.presentedViewController ?? viewController).present(activityViewController, animated: true)
				return
			}

			responder = current.next
		}
	}
}

// MARK: - UIContextMenuInteractionDelegate
extension TrailerPausedFrameView: UIContextMenuInteractionDelegate {
	func contextMenuInteraction(_ interaction: UIContextMenuInteraction, configurationForMenuAtLocation location: CGPoint) -> UIContextMenuConfiguration? {
		guard self.image != nil else { return nil }

		return UIContextMenuConfiguration(actionProvider: { [weak self] _ in
			guard let self = self else { return nil }

			var sections: [UIMenuElement] = []

			if #available(iOS 17.0, macCatalyst 17.0, *) {
				sections.append(UIMenu(options: .displayInline, children: [self.makeSubjectElement()]))
			}

			sections.append(UIMenu(options: .displayInline, children: self.makeFrameActions()))

			return UIMenu(children: sections)
		})
	}
}
