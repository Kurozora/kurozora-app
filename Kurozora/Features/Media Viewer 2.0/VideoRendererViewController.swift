//
//  VideoRendererViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 06/09/2025.
//  Copyright © 2025 Kurozora. All rights reserved.
//

import AVKit

final class VideoRendererViewController: UIViewController, MediaRenderable, UIScrollViewDelegate {
	let mediaItem: MediaItemV2
	private var player: AVPlayer!
	private let playerView = UIView()
	private let rotationContainer = UIView()
	private let scrollView = UIScrollView()

	init(mediaItem: MediaItemV2) {
		self.mediaItem = mediaItem
		super.init(nibName: nil, bundle: nil)
	}

	@available(*, unavailable)
	required init?(coder: NSCoder) { fatalError() }

	override func viewDidLoad() {
		super.viewDidLoad()

		self.scrollView.frame = view.bounds
		self.scrollView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
		self.scrollView.delegate = self
		self.scrollView.minimumZoomScale = 1.0
		self.scrollView.maximumZoomScale = 4.0
		self.scrollView.showsVerticalScrollIndicator = false
		self.scrollView.showsHorizontalScrollIndicator = false

		self.rotationContainer.frame = view.bounds
		self.rotationContainer.autoresizingMask = [.flexibleWidth, .flexibleHeight]
		view.addSubview(self.rotationContainer)
		self.rotationContainer.addSubview(self.scrollView)

		self.playerView.frame = self.scrollView.bounds
		self.scrollView.addSubview(self.playerView)

		self.player = AVPlayer(url: self.mediaItem.url)
		let layer = AVPlayerLayer(player: player)
		layer.videoGravity = .resizeAspect
		layer.frame = self.playerView.bounds
		self.playerView.layer.addSublayer(layer)

		self.player.play()

		let doubleTap = UITapGestureRecognizer(target: self, action: #selector(self.handleDoubleTap(_:)))
		doubleTap.numberOfTapsRequired = 2
		self.scrollView.addGestureRecognizer(doubleTap)
	}

	func viewForZooming(in scrollView: UIScrollView) -> UIView? { self.playerView }

	@objc private func handleDoubleTap(_ gesture: UITapGestureRecognizer) {
		if self.scrollView.zoomScale == 1.0 {
			self.scrollView.setZoomScale(2.0, animated: true)
		} else {
			self.scrollView.setZoomScale(1.0, animated: true)
		}
	}

	var mediaView: UIView { self.playerView }
}
