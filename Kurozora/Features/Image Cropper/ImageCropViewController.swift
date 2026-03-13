//
//  ImageCropViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 13/03/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import UIKit

// MARK: - ShapeType
enum ShapeType {
	case circle
	case square
	case rectangle
}

// MARK: - ImageCropViewControllerDelegate
protocol ImageCropViewControllerDelegate: AnyObject {
	func imageCropViewController(_ viewController: ImageCropViewController, didCropImage image: UIImage)
	func imageCropViewControllerDidCancel(_ viewController: ImageCropViewController)
}

// MARK: - ImageCropViewController
class ImageCropViewController: KViewController {
	// MARK: - Properties
	weak var delegate: ImageCropViewControllerDelegate?

	private let image: UIImage
	private let shapeType: ShapeType
	private let targetOutputSize: CGSize?
	private let cropAspectRatio: CGFloat

	// MARK: - Views
	private let containerView: UIView = {
		let view = UIView()
		view.translatesAutoresizingMaskIntoConstraints = false
		view.clipsToBounds = true
		view.backgroundColor = .black
		return view
	}()

	private let scrollView: UIScrollView = {
		let scrollView = UIScrollView()
		scrollView.translatesAutoresizingMaskIntoConstraints = false
		scrollView.showsVerticalScrollIndicator = false
		scrollView.showsHorizontalScrollIndicator = false
		scrollView.bouncesZoom = true
		scrollView.contentInsetAdjustmentBehavior = .never
		scrollView.decelerationRate = .fast
		return scrollView
	}()

	private let imageView: UIImageView = {
		let imageView = UIImageView()
		imageView.contentMode = .scaleAspectFill
		return imageView
	}()

	private let overlayView: CropOverlayView = {
		let view = CropOverlayView()
		view.translatesAutoresizingMaskIntoConstraints = false
		return view
	}()

	// MARK: - Initializers
	init(image: UIImage, shapeType: ShapeType, targetOutputSize: CGSize? = nil) {
		self.image = Self.normalizeOrientation(image)
		self.shapeType = shapeType
		self.targetOutputSize = targetOutputSize

		if let targetOutputSize {
			self.cropAspectRatio = targetOutputSize.width / targetOutputSize.height
		} else {
			switch shapeType {
			case .circle, .square:
				self.cropAspectRatio = 1.0
			case .rectangle:
				self.cropAspectRatio = image.size.width / image.size.height
			}
		}

		super.init(nibName: nil, bundle: nil)
	}

	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	// MARK: - Lifecycle
	override func viewDidLoad() {
		super.viewDidLoad()
		self.configureNavigation()
		self.configureViewHierarchy()
	}

	override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()
		self.overlayView.cropAspectRatio = self.cropAspectRatio
		self.overlayView.layoutIfNeeded()
		self.updateScrollViewForCropRect()
	}

	// MARK: - Configuration
	private func configureNavigation() {
		self.view.backgroundColor = .black

		self.navigationItem.leftBarButtonItem = UIBarButtonItem(systemItem: .cancel, primaryAction: UIAction { [weak self] _ in
			guard let self else { return }
			self.delegate?.imageCropViewControllerDidCancel(self)
			self.dismiss(animated: true)
		})

		self.navigationItem.rightBarButtonItem = UIBarButtonItem(systemItem: .done, primaryAction: UIAction { [weak self] _ in
			guard let self else { return }
			let cropped = self.cropImage()
			self.delegate?.imageCropViewController(self, didCropImage: cropped)
			self.dismiss(animated: true)
		})
	}

	private func configureViewHierarchy() {
		self.view.addSubview(self.containerView)
		self.containerView.addSubview(self.scrollView)
		self.containerView.addSubview(self.overlayView)

		self.scrollView.delegate = self
		self.scrollView.addSubview(self.imageView)
		self.imageView.image = self.image

		let doubleTap = UITapGestureRecognizer(target: self, action: #selector(self.handleDoubleTap(_:)))
		doubleTap.numberOfTapsRequired = 2
		self.scrollView.addGestureRecognizer(doubleTap)

		self.overlayView.shapeType = self.shapeType
		self.overlayView.cropAspectRatio = self.cropAspectRatio
		self.overlayView.onCropRectChanged = { [weak self] in
			self?.updateScrollViewForCropRect()
		}

		NSLayoutConstraint.activate([
			self.containerView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),
			self.containerView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
			self.containerView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
			self.containerView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor),

			self.scrollView.topAnchor.constraint(equalTo: self.containerView.topAnchor),
			self.scrollView.leadingAnchor.constraint(equalTo: self.containerView.leadingAnchor),
			self.scrollView.trailingAnchor.constraint(equalTo: self.containerView.trailingAnchor),
			self.scrollView.bottomAnchor.constraint(equalTo: self.containerView.bottomAnchor),

			self.overlayView.topAnchor.constraint(equalTo: self.containerView.topAnchor),
			self.overlayView.leadingAnchor.constraint(equalTo: self.containerView.leadingAnchor),
			self.overlayView.trailingAnchor.constraint(equalTo: self.containerView.trailingAnchor),
			self.overlayView.bottomAnchor.constraint(equalTo: self.containerView.bottomAnchor)
		])
	}

	// MARK: - ScrollView Management
	private var lastContainerSize: CGSize = .zero

	private func updateScrollViewForCropRect() {
		let containerSize = self.containerView.bounds.size
		guard containerSize.width > 0, containerSize.height > 0 else { return }

		let cropRect = self.overlayView.cropAreaRect
		guard cropRect.width > 0, cropRect.height > 0 else { return }

		let imageSize = self.image.size
		guard imageSize.width > 0, imageSize.height > 0 else { return }

		// Size the imageView to match the image aspect ratio, fitting within the container
		let imageAspect = imageSize.width / imageSize.height
		let fitWidth = containerSize.width
		let fitHeight = fitWidth / imageAspect
		let imageViewSize: CGSize
		if fitHeight < containerSize.height {
			imageViewSize = CGSize(width: fitWidth, height: fitHeight)
		} else {
			let h = containerSize.height
			imageViewSize = CGSize(width: h * imageAspect, height: h)
		}

		self.imageView.frame = CGRect(origin: .zero, size: imageViewSize)
		self.scrollView.contentSize = imageViewSize

		// Calculate min zoom so the image covers the crop area
		let scaleW = cropRect.width / imageViewSize.width
		let scaleH = cropRect.height / imageViewSize.height
		let minZoom = max(scaleW, scaleH)
		let maxZoom = max(minZoom * 4.0, 4.0)

		self.scrollView.minimumZoomScale = minZoom
		self.scrollView.maximumZoomScale = maxZoom

		let isInitialLayout = self.lastContainerSize == .zero
		let containerSizeChanged = self.lastContainerSize != containerSize

		if isInitialLayout || containerSizeChanged {
			self.scrollView.zoomScale = minZoom
			self.lastContainerSize = containerSize
		}

		self.updateContentInset()

		if isInitialLayout || containerSizeChanged {
			self.centerScrollViewContent()
		}
	}

	private func updateContentInset() {
		let cropRect = self.overlayView.cropAreaRect
		let containerSize = self.containerView.bounds.size
		guard cropRect.width > 0, containerSize.width > 0 else { return }

		let top = cropRect.minY
		let left = cropRect.minX
		let bottom = containerSize.height - cropRect.maxY
		let right = containerSize.width - cropRect.maxX

		self.scrollView.contentInset = UIEdgeInsets(top: top, left: left, bottom: bottom, right: right)
	}

	private func centerScrollViewContent() {
		let cropRect = self.overlayView.cropAreaRect
		let contentSize = self.scrollView.contentSize
		let zoomScale = self.scrollView.zoomScale

		let scaledWidth = contentSize.width * zoomScale
		let scaledHeight = contentSize.height * zoomScale

		let offsetX = (scaledWidth - cropRect.width) / 2.0
		let offsetY = (scaledHeight - cropRect.height) / 2.0

		self.scrollView.contentOffset = CGPoint(
			x: offsetX - cropRect.minX,
			y: offsetY - cropRect.minY
		)
	}

	// MARK: - Gestures
	@objc private func handleDoubleTap(_ gesture: UITapGestureRecognizer) {
		if self.scrollView.zoomScale > self.scrollView.minimumZoomScale + 0.01 {
			self.scrollView.setZoomScale(self.scrollView.minimumZoomScale, animated: true)
		} else {
			let targetScale = min(self.scrollView.minimumZoomScale * 2.5, self.scrollView.maximumZoomScale)
			let tapPoint = gesture.location(in: self.imageView)
			let zoomWidth = self.scrollView.bounds.width / targetScale
			let zoomHeight = self.scrollView.bounds.height / targetScale
			let zoomRect = CGRect(
				x: tapPoint.x - zoomWidth / 2,
				y: tapPoint.y - zoomHeight / 2,
				width: zoomWidth,
				height: zoomHeight
			)
			self.scrollView.zoom(to: zoomRect, animated: true)
		}
	}

	// MARK: - Cropping
	private func cropImage() -> UIImage {
		let cropRect = self.overlayView.cropAreaRect
		let cropRectInImageView = self.overlayView.convert(cropRect, to: self.imageView)

		let scaleX = self.image.size.width / self.imageView.bounds.width
		let scaleY = self.image.size.height / self.imageView.bounds.height

		let pixelRect = CGRect(
			x: cropRectInImageView.origin.x * scaleX,
			y: cropRectInImageView.origin.y * scaleY,
			width: cropRectInImageView.width * scaleX,
			height: cropRectInImageView.height * scaleY
		).integral

		guard let cgImage = self.image.cgImage?.cropping(to: pixelRect) else {
			return self.image
		}

		var croppedImage = UIImage(cgImage: cgImage)

		// Downscale if targetOutputSize is set
		if let targetOutputSize {
			let format = UIGraphicsImageRendererFormat()
			format.scale = 1.0

			format.opaque = true
			let renderer = UIGraphicsImageRenderer(size: targetOutputSize, format: format)
			croppedImage = renderer.image { _ in
				croppedImage.draw(in: CGRect(origin: .zero, size: targetOutputSize))
			}
		}

		return croppedImage
	}

	// MARK: - Orientation Normalization
	private static func normalizeOrientation(_ image: UIImage) -> UIImage {
		guard image.imageOrientation != .up else { return image }

		let format = UIGraphicsImageRendererFormat()
		format.scale = image.scale
		let renderer = UIGraphicsImageRenderer(size: image.size, format: format)
		return renderer.image { _ in
			image.draw(at: .zero)
		}
	}
}

// MARK: - UIScrollViewDelegate
extension ImageCropViewController: UIScrollViewDelegate {
	func viewForZooming(in scrollView: UIScrollView) -> UIView? {
		return self.imageView
	}

	func scrollViewDidZoom(_ scrollView: UIScrollView) {
		self.updateContentInset()
	}
}

// MARK: - CropOverlayView
class CropOverlayView: UIView {
	// MARK: - Types
	private enum ResizeHandle {
		case topLeft, topRight, bottomLeft, bottomRight, none
	}

	// MARK: - Properties
	var shapeType: ShapeType = .square {
		didSet { self.setNeedsLayout() }
	}

	var cropAspectRatio: CGFloat = 1.0 {
		didSet { self.setNeedsLayout() }
	}

	var onCropRectChanged: (() -> Void)?

	private(set) var cropAreaRect: CGRect = .zero

	private let minimumCropSize: CGFloat = 60.0
	private let handleHitTolerance: CGFloat = 44.0
	private let handleSize: CGFloat = 12.0

	private let maskLayer = CAShapeLayer()
	private let borderLayer = CAShapeLayer()
	private let handleLayer = CAShapeLayer()

	private var activeHandle: ResizeHandle = .none
	private var panStartCropRect: CGRect = .zero

	// MARK: - Initializers
	override init(frame: CGRect) {
		super.init(frame: frame)
		self.setupLayers()
		self.setupGestures()
	}

	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	// MARK: - Setup
	private func setupLayers() {
		self.maskLayer.fillRule = .evenOdd
		self.maskLayer.fillColor = UIColor.black.withAlphaComponent(0.5).cgColor
		self.layer.addSublayer(self.maskLayer)

		self.borderLayer.fillColor = UIColor.clear.cgColor
		self.borderLayer.strokeColor = UIColor.white.cgColor
		self.borderLayer.lineWidth = 1.0
		self.layer.addSublayer(self.borderLayer)

		self.handleLayer.fillColor = UIColor.white.cgColor
		self.handleLayer.strokeColor = UIColor.clear.cgColor
		self.layer.addSublayer(self.handleLayer)
	}

	private func setupGestures() {
		let pan = UIPanGestureRecognizer(target: self, action: #selector(self.handlePan(_:)))
		self.addGestureRecognizer(pan)
	}

	// MARK: - Layout
	override func layoutSubviews() {
		super.layoutSubviews()
		if self.cropAreaRect == .zero || !self.bounds.contains(self.cropAreaRect) {
			self.cropAreaRect = self.calculateInitialCropRect()
		}
		self.updateLayers()
	}

	private func calculateInitialCropRect() -> CGRect {
		let bounds = self.bounds
		guard bounds.width > 0, bounds.height > 0 else { return .zero }

		let inset: CGFloat = 16.0
		let availableWidth = bounds.width - inset * 2
		let availableHeight = bounds.height - inset * 2

		let cropWidth: CGFloat
		let cropHeight: CGFloat

		let desiredHeight = availableWidth / self.cropAspectRatio
		if desiredHeight <= availableHeight {
			cropWidth = availableWidth
			cropHeight = desiredHeight
		} else {
			cropHeight = availableHeight
			cropWidth = cropHeight * self.cropAspectRatio
		}

		return CGRect(
			x: (bounds.width - cropWidth) / 2,
			y: (bounds.height - cropHeight) / 2,
			width: cropWidth,
			height: cropHeight
		)
	}

	private func updateLayers() {
		let bounds = self.bounds
		guard bounds.width > 0 else { return }

		// Dimmed overlay with cutout
		let fullPath = UIBezierPath(rect: bounds)
		let cutoutPath: UIBezierPath

		switch self.shapeType {
		case .circle:
			cutoutPath = UIBezierPath(ovalIn: self.cropAreaRect)
		case .square, .rectangle:
			cutoutPath = UIBezierPath(rect: self.cropAreaRect)
		}

		fullPath.append(cutoutPath)
		self.maskLayer.path = fullPath.cgPath
		self.maskLayer.frame = bounds

		// Border
		self.borderLayer.path = cutoutPath.cgPath
		self.borderLayer.frame = bounds

		// Corner handles
		let handlePath = UIBezierPath()
		let corners = [
			CGPoint(x: self.cropAreaRect.minX, y: self.cropAreaRect.minY),
			CGPoint(x: self.cropAreaRect.maxX, y: self.cropAreaRect.minY),
			CGPoint(x: self.cropAreaRect.minX, y: self.cropAreaRect.maxY),
			CGPoint(x: self.cropAreaRect.maxX, y: self.cropAreaRect.maxY)
		]

		let hs = self.handleSize / 2
		for corner in corners {
			let rect = CGRect(x: corner.x - hs, y: corner.y - hs, width: self.handleSize, height: self.handleSize)
			if self.shapeType == .circle {
				handlePath.append(UIBezierPath(ovalIn: rect))
			} else {
				handlePath.append(UIBezierPath(rect: rect))
			}
		}

		self.handleLayer.path = handlePath.cgPath
		self.handleLayer.frame = bounds
	}

	// MARK: - Hit Testing
	override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
		if self.handleAt(point) != .none {
			return self
		}
		return nil
	}

	private func handleAt(_ point: CGPoint) -> ResizeHandle {
		let tolerance = self.handleHitTolerance
		let rect = self.cropAreaRect

		let corners: [(ResizeHandle, CGPoint)] = [
			(.topLeft, CGPoint(x: rect.minX, y: rect.minY)),
			(.topRight, CGPoint(x: rect.maxX, y: rect.minY)),
			(.bottomLeft, CGPoint(x: rect.minX, y: rect.maxY)),
			(.bottomRight, CGPoint(x: rect.maxX, y: rect.maxY))
		]

		for (handle, corner) in corners {
			let hitRect = CGRect(
				x: corner.x - tolerance / 2,
				y: corner.y - tolerance / 2,
				width: tolerance,
				height: tolerance
			)
			if hitRect.contains(point) {
				return handle
			}
		}

		return .none
	}

	// MARK: - Resize Gesture
	@objc private func handlePan(_ gesture: UIPanGestureRecognizer) {
		let location = gesture.location(in: self)

		switch gesture.state {
		case .began:
			self.activeHandle = self.handleAt(location)
			self.panStartCropRect = self.cropAreaRect

		case .changed:
			guard self.activeHandle != .none else { return }
			let translation = gesture.translation(in: self)
			self.resizeCropRect(handle: self.activeHandle, translation: translation)

		case .ended, .cancelled:
			self.activeHandle = .none

		default:
			break
		}
	}

	private func resizeCropRect(handle: ResizeHandle, translation: CGPoint) {
		let original = self.panStartCropRect
		let bounds = self.bounds
		var newRect = original

		// Determine the primary delta based on handle position
		switch handle {
		case .topLeft:
			let dx = translation.x
			let dy = dx / self.cropAspectRatio
			newRect = CGRect(
				x: original.minX + dx,
				y: original.minY + dy,
				width: original.width - dx,
				height: original.height - dy
			)

		case .topRight:
			let dx = translation.x
			let dy = -dx / self.cropAspectRatio
			newRect = CGRect(
				x: original.minX,
				y: original.minY + dy,
				width: original.width + dx,
				height: original.height - dy
			)

		case .bottomLeft:
			let dx = translation.x
			let dy = -dx / self.cropAspectRatio
			newRect = CGRect(
				x: original.minX + dx,
				y: original.minY,
				width: original.width - dx,
				height: original.height + dy
			)

		case .bottomRight:
			let dx = translation.x
			let dy = dx / self.cropAspectRatio
			newRect = CGRect(
				x: original.minX,
				y: original.minY,
				width: original.width + dx,
				height: original.height + dy
			)

		case .none:
			return
		}

		// Clamp to minimum size
		if newRect.width < self.minimumCropSize {
			return
		}
		if newRect.height < self.minimumCropSize {
			return
		}

		// Clamp to bounds
		if newRect.minX < 0 || newRect.minY < 0 || newRect.maxX > bounds.width || newRect.maxY > bounds.height {
			return
		}

		self.cropAreaRect = newRect
		self.updateLayers()
		self.onCropRectChanged?()
	}
}
