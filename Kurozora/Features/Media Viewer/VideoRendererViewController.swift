//
//  VideoRendererViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 06/09/2025.
//  Copyright © 2025 Kurozora. All rights reserved.
//

import AVKit

final class VideoRendererViewController: UIViewController, MediaRenderable {
	// MARK: - Views
	let scrollView = UIScrollView()
	private let playerView = MediaPlayerView()

	// MARK: - Properties
	let mediaItem: MediaItem

	private let player: AVPlayer
	private var presentationSizeObservation: NSKeyValueObservation?

	/// The video's display size, once the player has resolved it.
	private var videoSize: CGSize = .zero

	/// The size the player view was last laid out for.
	private var laidOutBoundsSize: CGSize = .zero

	var mediaView: UIView {
		return self.playerView
	}

	var mediaImage: UIImage? {
		return nil
	}

	var hasActiveTextSelection: Bool {
		return false
	}

	// MARK: - Initializers
	init(mediaItem: MediaItem) {
		self.mediaItem = mediaItem
		self.player = AVPlayer(url: mediaItem.url)
		super.init(nibName: nil, bundle: nil)
	}

	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	deinit {
		self.presentationSizeObservation?.invalidate()
	}

	// MARK: - View
	override func viewDidLoad() {
		super.viewDidLoad()

		self.configureScrollView()
		self.configurePlayerView()
		self.observePresentationSize()

		self.player.play()
	}

	override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()

		self.scrollView.frame = self.view.bounds

		guard self.laidOutBoundsSize != self.scrollView.bounds.size else { return }
		self.laidOutBoundsSize = self.scrollView.bounds.size

		self.scrollView.setZoomScale(self.scrollView.minimumZoomScale, animated: false)
		self.layoutPlayerView()
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

	private func configurePlayerView() {
		self.playerView.player = self.player
		self.playerView.playerLayer?.videoGravity = .resize
		self.playerView.clipsToBounds = true
		self.scrollView.addSubview(self.playerView)
	}

	/// Lays the player view out as soon as the player resolves the video's display size.
	private func observePresentationSize() {
		self.presentationSizeObservation = self.player.observe(\.currentItem?.presentationSize, options: [.initial, .new]) { [weak self] player, _ in
			guard let self = self else { return }
			guard let presentationSize = player.currentItem?.presentationSize, presentationSize != .zero else { return }

			DispatchQueue.main.async {
				self.videoSize = presentationSize
				self.layoutPlayerView()
			}
		}
	}

	/// Sizes the player view to the video's aspect-fit rect and centers it in the scroll view.
	private func layoutPlayerView() {
		guard self.videoSize != .zero, self.scrollView.bounds.size != .zero else { return }

		let fittedRect = MediaTransitionProxy.aspectFitRect(for: self.videoSize, in: self.scrollView.bounds)
		self.playerView.frame = CGRect(origin: .zero, size: fittedRect.size)
		self.scrollView.contentSize = fittedRect.size

		self.centerPlayerView()
	}

	/// Keeps the video centered whenever it is smaller than the scroll view.
	private func centerPlayerView() {
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
		return false
	}

	@objc private func handleDoubleTap(_ gesture: UITapGestureRecognizer) {
		let targetScale = self.scrollView.zoomScale == self.scrollView.minimumZoomScale ? 2.0 : self.scrollView.minimumZoomScale
		self.scrollView.setZoomScale(targetScale, animated: true)
	}
}

// MARK: - UIScrollViewDelegate
extension VideoRendererViewController: UIScrollViewDelegate {
	func viewForZooming(in scrollView: UIScrollView) -> UIView? {
		return self.playerView
	}

	func scrollViewDidZoom(_ scrollView: UIScrollView) {
		self.centerPlayerView()
	}
}
