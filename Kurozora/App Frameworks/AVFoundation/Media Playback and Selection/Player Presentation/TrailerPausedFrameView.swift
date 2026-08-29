//
//  TrailerPausedFrameView.swift
//  Kurozora
//
//  Created by Khoren Katklian on 27/08/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import UIKit
import VisionKit
import WebKit

/// An image view that shows a paused trailer's frame, with text selection and subject lifting.
final class TrailerPausedFrameView: UIImageView {
	// MARK: - Properties
	/// The interaction that provides text selection and subject lifting.
	private var analysisInteraction: AnyObject?

	/// The task that analyzes the frame.
	private var analysisTask: Task<Void, Never>?

	/// A Boolean value indicating whether the analyzed frame contains subjects.
	private var hasSubjects = false

	/// Builds the menu element that offers the trailer as a download.
	var downloadMenuProvider: (() -> UIMenuElement?)?

	override var next: UIResponder? {
		// A menu shown within a web view picks up the Continuity Camera items.
		guard let superview = self.superview, superview is WKWebView else { return super.next }

		return superview.next
	}

	// MARK: - Initializers
	init() {
		super.init(frame: .zero)

		self.contentMode = .scaleToFill
		self.isHidden = true
		self.isUserInteractionEnabled = true

		if #available(iOS 17.0, macCatalyst 17.0, *), ImageAnalyzer.isSupported {
			// Subject lifting answers a press with a menu of its own, in place of this view's.
			let analysisInteraction = ImageAnalysisInteraction()
			analysisInteraction.preferredInteractionTypes = [.textSelection]
			analysisInteraction.delegate = self
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
	///    - frame: The frame to show.
	///    - readsFrame: Whether the frame is analyzed for selection and lifting.
	func showFrame(_ frame: UIImage, readsFrame: Bool = true) {
		self.image = frame
		self.isHidden = false

		if readsFrame {
			self.analyzeFrame(frame)
		} else {
			self.analysisTask?.cancel()
		}
	}

	/// Hides the frame.
	func hideFrame() {
		self.isHidden = true
		self.analysisTask?.cancel()
	}

	/// Analyzes the given frame for selection and lifting.
	///
	/// - Parameter frame: The frame to analyze.
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

			guard !Task.isCancelled else { return }

			// Segmentation runs on the first request, too slowly for a menu to wait on it.
			let subjects = await analysisInteraction.subjects
			self?.hasSubjects = !subjects.isEmpty
		}
	}

	/// Builds the actions that act on the whole frame.
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

	/// Builds the actions that act on the frame's lifted subjects.
	///
	/// - Returns: The configured actions.
	@available(iOS 17.0, macCatalyst 17.0, *)
	private func makeSubjectActions() -> [UIMenuElement] {
		let attributes: UIMenuElement.Attributes = self.hasSubjects ? [] : [.disabled]

		return [
			UIAction(title: L10n.copySubject, image: UIImage(systemName: "doc.on.doc"), attributes: attributes) { [weak self] _ in
				Task { @MainActor in
					guard let subjectImage = await self?.liftSubjects() else { return }
					UIPasteboard.general.image = subjectImage
				}
			},
			UIAction(title: L10n.shareSubject, image: UIImage(systemName: "square.and.arrow.up"), attributes: attributes) { [weak self] _ in
				Task { @MainActor in
					guard let self = self, let subjectImage = await self.liftSubjects() else { return }
					self.share(subjectImage)
				}
			}
		]
	}

	/// Lifts the frame's subjects into a single image.
	///
	/// - Returns: The lifted image.
	@available(iOS 17.0, macCatalyst 17.0, *)
	private func liftSubjects() async -> UIImage? {
		guard let analysisInteraction = self.analysisInteraction as? ImageAnalysisInteraction else { return nil }

		let subjects = await analysisInteraction.subjects
		guard !subjects.isEmpty else { return nil }

		return try? await analysisInteraction.image(for: subjects)
	}

	/// Shares the given image.
	///
	/// - Parameter image: The image to share.
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

// MARK: - ImageAnalysisInteractionDelegate
@available(iOS 17.0, macCatalyst 17.0, *)
extension TrailerPausedFrameView: ImageAnalysisInteractionDelegate {
	func interaction(_ interaction: ImageAnalysisInteraction, shouldBeginAt point: CGPoint, for interactionType: ImageAnalysisInteraction.InteractionTypes) -> Bool {
		return interactionType == .textSelection
	}

	func contentsRect(for interaction: ImageAnalysisInteraction) -> CGRect {
		let wholeView = CGRect(x: 0.0, y: 0.0, width: 1.0, height: 1.0)

		// A fitted frame is inset by bars the interaction would otherwise count as image.
		guard self.contentMode == .scaleAspectFit, let frame = self.image, self.bounds.width > 0.0, self.bounds.height > 0.0, frame.size.width > 0.0, frame.size.height > 0.0 else {
			return wholeView
		}

		let scale = min(self.bounds.width / frame.size.width, self.bounds.height / frame.size.height)
		let drawnSize = CGSize(width: frame.size.width * scale, height: frame.size.height * scale)

		return CGRect(
			x: (self.bounds.width - drawnSize.width) / 2.0 / self.bounds.width,
			y: (self.bounds.height - drawnSize.height) / 2.0 / self.bounds.height,
			width: drawnSize.width / self.bounds.width,
			height: drawnSize.height / self.bounds.height
		)
	}
}

// MARK: - UIContextMenuInteractionDelegate
extension TrailerPausedFrameView: UIContextMenuInteractionDelegate {
	func contextMenuInteraction(_ interaction: UIContextMenuInteraction, configurationForMenuAtLocation location: CGPoint) -> UIContextMenuConfiguration? {
		guard self.image != nil else { return nil }

		return UIContextMenuConfiguration(actionProvider: { [weak self] _ in
			guard let self = self else { return nil }

			var sections: [UIMenuElement] = []

			sections.append(UIMenu(options: .displayInline, children: self.makeFrameActions()))

			if #available(iOS 17.0, macCatalyst 17.0, *) {
				sections.append(UIMenu(options: .displayInline, children: self.makeSubjectActions()))
			}

			if let downloadMenu = self.downloadMenuProvider?() {
				sections.append(UIMenu(options: .displayInline, children: [downloadMenu]))
			}

			return UIMenu(children: sections)
		})
	}
}
