//
//  ImageRendererViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 06/09/2025.
//  Copyright © 2025 Kurozora. All rights reserved.
//

import UIKit

final class ImageRendererViewController: UIViewController, MediaRenderable, UIScrollViewDelegate {
	let mediaItem: MediaItemV2
	private let scrollView = UIScrollView()
	let imageView = UIImageView()

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
		view.addSubview(self.scrollView)

		self.imageView.contentMode = .scaleAspectFit
		self.imageView.frame = self.scrollView.bounds
		self.imageView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
		self.imageView.kf.setImage(with: self.mediaItem.url)
		self.scrollView.addSubview(self.imageView)

		let doubleTap = UITapGestureRecognizer(target: self, action: #selector(self.handleDoubleTap(_:)))
		doubleTap.numberOfTapsRequired = 2
		self.scrollView.addGestureRecognizer(doubleTap)
	}

	func viewForZooming(in scrollView: UIScrollView) -> UIView? { self.imageView }

	@objc private func handleDoubleTap(_ gesture: UITapGestureRecognizer) {
		if self.scrollView.zoomScale == 1.0 {
			let point = gesture.location(in: self.imageView)
			let zoomRect = CGRect(x: point.x - 50, y: point.y - 50, width: 100, height: 100)
			self.scrollView.zoom(to: zoomRect, animated: true)
		} else {
			self.scrollView.setZoomScale(1.0, animated: true)
		}
	}

	var mediaView: UIView { self.imageView }
}
