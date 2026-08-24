//
//  MediaLiveTextController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 25/08/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import UIKit
import VisionKit

/// Makes the text and subjects inside an image selectable.
@available(iOS 16.0, macCatalyst 17.0, *)
@MainActor
final class MediaLiveTextController: NSObject {
	// MARK: - Properties
	/// The analyzer shared by every renderer.
	private static let imageAnalyzer = ImageAnalyzer()

	private let interaction = ImageAnalysisInteraction()
	private weak var hostViewController: UIViewController?
	private var analysisTask: Task<Void, Never>?

	/// The bounds of every subject the framework found, in the image view's coordinate space.
	private var subjectBounds: [CGRect] = []

	/// A Boolean value that indicates whether text inside the image is selected.
	var hasActiveTextSelection: Bool {
		return self.interaction.hasActiveTextSelection
	}

	// MARK: - Initializers
	/// Creates a controller that makes the given image view's contents selectable.
	///
	/// - Parameters:
	///    - imageView: The view that displays the image.
	///    - hostViewController: The controller that presents the interaction's interface.
	init(imageView: UIImageView, hostViewController: UIViewController) {
		self.hostViewController = hostViewController
		super.init()

		self.interaction.delegate = self
		self.interaction.preferredInteractionTypes = [.textSelection, .imageSubject]
		self.interaction.isSupplementaryInterfaceHidden = true
		imageView.addInteraction(self.interaction)
	}

	deinit {
		self.analysisTask?.cancel()
	}

	// MARK: - Functions
	/// Analyzes the given image for selectable text and subjects.
	///
	/// - Parameter image: The image to analyze.
	func analyze(_ image: UIImage) {
		self.analysisTask?.cancel()
		self.subjectBounds = []

		guard ImageAnalyzer.isSupported else { return }

		self.analysisTask = Task { [weak self] in
			let configuration = ImageAnalyzer.Configuration([.text, .machineReadableCode])
			let analysis = try? await Self.imageAnalyzer.analyze(image, configuration: configuration)

			guard let self = self, !Task.isCancelled else { return }
			self.interaction.analysis = analysis

			#if !targetEnvironment(macCatalyst)
			guard #available(iOS 17.0, *) else { return }
			#endif

			let subjects = await self.interaction.subjects

			guard !Task.isCancelled else { return }
			self.subjectBounds = subjects.map(\.bounds)
		}
	}

	/// Returns a Boolean value that indicates whether the framework recognized selectable content at the given point.
	///
	/// - Parameter point: A point in the image view's coordinate space.
	/// - Returns: `true` if selectable content exists at `point`.
	func hasInteractiveItem(at point: CGPoint) -> Bool {
		if self.interaction.hasInteractiveItem(at: point) {
			return true
		}

		return self.subjectBounds.contains { $0.contains(point) }
	}
}

// MARK: - ImageAnalysisInteractionDelegate
@available(iOS 16.0, macCatalyst 17.0, *)
extension MediaLiveTextController: ImageAnalysisInteractionDelegate {
	func presentingViewController(for interaction: ImageAnalysisInteraction) -> UIViewController? {
		return self.hostViewController
	}
}
