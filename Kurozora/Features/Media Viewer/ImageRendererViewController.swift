//
//  ImageRendererViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 06/09/2025.
//  Copyright © 2025 Kurozora. All rights reserved.
//

import UIKit
import VisionKit

final class ImageRendererViewController: UIViewController, MediaRenderable {
	// MARK: - Views
	let scrollView = UIScrollView()
	let imageView = UIImageView()

	// MARK: - Properties
	let mediaItem: MediaItem

	/// The size the image view was last laid out for.
	private var laidOutBoundsSize: CGSize = .zero

	/// The Live Text interaction attached to the image view.
	private var liveTextController: AnyObject?

	var mediaView: UIView {
		return self.imageView
	}

	var mediaImage: UIImage? {
		return self.imageView.image
	}

	var hasActiveTextSelection: Bool {
		guard #available(iOS 16.0, macCatalyst 17.0, *) else { return false }
		return (self.liveTextController as? MediaLiveTextController)?.hasActiveTextSelection ?? false
	}

	// MARK: - Initializers
	init(mediaItem: MediaItem) {
		self.mediaItem = mediaItem
		super.init(nibName: nil, bundle: nil)
	}

	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	// MARK: - View
	override func viewDidLoad() {
		super.viewDidLoad()

		self.configureScrollView()
		self.configureImageView()
		self.configureLiveText()
		self.loadImage()
	}

	override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()

		self.scrollView.frame = self.view.bounds

		guard self.laidOutBoundsSize != self.scrollView.bounds.size else { return }
		self.laidOutBoundsSize = self.scrollView.bounds.size

		self.scrollView.setZoomScale(self.scrollView.minimumZoomScale, animated: false)
		self.layoutImageView()
	}

	// MARK: - Functions
	private func configureScrollView() {
		self.scrollView.frame = self.view.bounds
		self.scrollView.delegate = self
		self.scrollView.minimumZoomScale = 1.0
		self.scrollView.maximumZoomScale = 4.0
		self.scrollView.showsVerticalScrollIndicator = false
		self.scrollView.showsHorizontalScrollIndicator = false
		self.scrollView.contentInsetAdjustmentBehavior = .never
		self.view.addSubview(self.scrollView)

		let doubleTap = UITapGestureRecognizer(target: self, action: #selector(self.handleDoubleTap(_:)))
		doubleTap.numberOfTapsRequired = 2
		self.scrollView.addGestureRecognizer(doubleTap)
	}

	private func configureImageView() {
		self.imageView.contentMode = .scaleAspectFill
		self.imageView.clipsToBounds = true
		self.imageView.accessibilityIgnoresInvertColors = true
		self.scrollView.addSubview(self.imageView)
	}

	private func configureLiveText() {
		guard UserSettings.liveTextAnalyzerEnabled else { return }
		guard #available(iOS 16.0, macCatalyst 17.0, *) else { return }

		self.liveTextController = MediaLiveTextController(imageView: self.imageView, hostViewController: self)
	}

	private func loadImage() {
		self.imageView.kf.setImage(with: self.mediaItem.url) { [weak self] _ in
			guard let self = self else { return }
			self.layoutImageView()
			self.analyzeImage()
		}
	}

	private func analyzeImage() {
		guard #available(iOS 16.0, macCatalyst 17.0, *) else { return }
		guard let image = self.imageView.image else { return }
		(self.liveTextController as? MediaLiveTextController)?.analyze(image)
	}

	/// Sizes the image view to the image's aspect-fit rect and centers it in the scroll view.
	private func layoutImageView() {
		guard let imageSize = self.imageView.image?.size, self.scrollView.bounds.size != .zero else { return }

		let fittedRect = MediaTransitionProxy.aspectFitRect(for: imageSize, in: self.scrollView.bounds)
		self.imageView.frame = CGRect(origin: .zero, size: fittedRect.size)
		self.scrollView.contentSize = fittedRect.size

		self.centerImageView()
	}

	/// Keeps the image centered whenever it is smaller than the scroll view.
	private func centerImageView() {
		let horizontalInset = max(0, (self.scrollView.bounds.width - self.scrollView.contentSize.width) / 2.0)
		let verticalInset = max(0, (self.scrollView.bounds.height - self.scrollView.contentSize.height) / 2.0)

		self.scrollView.contentInset = UIEdgeInsets(
			top: verticalInset,
			left: horizontalInset,
			bottom: verticalInset,
			right: horizontalInset
		)
	}

	func hasInteractiveItem(at point: CGPoint) -> Bool {
		guard #available(iOS 16.0, macCatalyst 17.0, *) else { return false }
		return (self.liveTextController as? MediaLiveTextController)?.hasInteractiveItem(at: point) ?? false
	}

	@objc private func handleDoubleTap(_ gesture: UITapGestureRecognizer) {
		guard self.scrollView.zoomScale == self.scrollView.minimumZoomScale else {
			self.scrollView.setZoomScale(self.scrollView.minimumZoomScale, animated: true)
			return
		}

		let point = gesture.location(in: self.imageView)
		let zoomedSize = CGSize(
			width: self.scrollView.bounds.width / self.scrollView.maximumZoomScale,
			height: self.scrollView.bounds.height / self.scrollView.maximumZoomScale
		)
		let zoomRect = CGRect(
			x: point.x - zoomedSize.width / 2.0,
			y: point.y - zoomedSize.height / 2.0,
			width: zoomedSize.width,
			height: zoomedSize.height
		)

		self.scrollView.zoom(to: zoomRect, animated: true)
	}
}

// MARK: - UIScrollViewDelegate
extension ImageRendererViewController: UIScrollViewDelegate {
	func viewForZooming(in scrollView: UIScrollView) -> UIView? {
		return self.imageView
	}

	func scrollViewDidZoom(_ scrollView: UIScrollView) {
		self.centerImageView()
	}
}
