//
//  BaseDetailHeaderCollectionViewCell.swift
//  Kurozora
//
//  Created by Khoren Katklian on 06/01/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import SwiftUI
import UIKit

protocol BaseDetailHeaderCollectionViewCellDelegate: AnyObject {
	func baseDetailHeaderCollectionViewCell(_ cell: BaseDetailHeaderCollectionViewCell, didPressStatus button: UIButton) async
}

class BaseDetailHeaderCollectionViewCell: UICollectionViewCell, MediaViewerHeaderCell {
	// MARK: - IBOutlet
	@IBOutlet var bannerImageView: UIImageView!
	@IBOutlet var visualEffectView: KVisualEffectView!

	// Quick details view
	@IBOutlet weak var quickDetailsView: UIView!
	@IBOutlet weak var primaryLabel: KLabel!
	@IBOutlet weak var secondaryLabel: KLabel!
	@IBOutlet weak var rankButton: UIButton?
	@IBOutlet weak var shadowView: UIView!
	@IBOutlet weak var posterImageView: PosterImageView!
	@IBOutlet weak var posterBorderView: BorderView?

	// MARK: - Views
	/// The view holding the header's media, hosted by the surround.
	private var mediaView: UIView?

	/// The view hosting the trailer's controls above the mirrored media.
	private var controlsOverlayView: PassthroughView?

	// MARK: - Properties
	weak var delegate: BaseDetailHeaderCollectionViewCellDelegate?
	weak var mediaViewerDelegate: MediaViewerViewDelegate?

	/// The trailer playing over the header's banner, when the screen has one.
	///
	/// The player sits beside the banner, whether the media stays in the cell or moves into the
	/// surround, so it is found through the banner's own superview.
	var hostedTrailerPlayerView: KTrailerPlayerView? {
		self.bannerImageView?.superview?.subviews.compactMap { $0 as? KTrailerPlayerView }.first
	}

	/// The controller hosting the media surround.
	private var surroundController: UIViewController?

	/// The letterbox gaps the surround fills around the media.
	private let mediaGapState = HeaderMediaGapState()

	// MARK: - View
	override func layoutSubviews() {
		super.layoutSubviews()

		if #available(iOS 26.0, *) {
			self.updateMediaGaps()
		}
	}

	// MARK: - Functions
	override func awakeFromNib() {
		super.awakeFromNib()

		// Configure visual effect
		if #available(iOS 26.0, macOS 26.0, tvOS 26.0, visionOS 26.0, watchOS 26.0, *) {
			self.visualEffectView.effect = UIGlassEffect(style: .clear)
		}
		self.visualEffectView.layerCornerRadius = 30.0

		self.rankButton?.layerCornerRadius = 6.0

		// Configure poster
		self.posterImageView.tag = 0
		self.posterImageView.isUserInteractionEnabled = true
		let posterTap = UITapGestureRecognizer(target: self, action: #selector(self.didTapImage))
		self.posterImageView.addGestureRecognizer(posterTap)

		// Configure banner
		self.bannerImageView.tag = 1
		self.bannerImageView.isUserInteractionEnabled = true
		let bannerTap = UITapGestureRecognizer(target: self, action: #selector(self.didTapImage))
		self.bannerImageView.addGestureRecognizer(bannerTap)

		if #available(iOS 26.0, *) {
			self.extendHeaderMediaBeyondSafeArea()
		}
	}

	/// Fills the space around the header's media with a mirrored, blurred continuation of it,
	/// leaving the media itself centered in the content area.
	@available(iOS 26.0, *)
	private func extendHeaderMediaBeyondSafeArea() {
		guard let container = self.bannerImageView.superview else { return }

		let bannerConstraints = container.constraints.filter { $0.firstItem === self.bannerImageView || $0.secondItem === self.bannerImageView }
		NSLayoutConstraint.deactivate(bannerConstraints)

		let mediaView = UIView()
		mediaView.addSubview(self.bannerImageView)
		self.mediaView = mediaView

		let surroundController = UIHostingController(rootView: HeaderMediaSurroundView(mediaView: mediaView, gapState: self.mediaGapState))
		surroundController.view.backgroundColor = .clear
		surroundController.view.translatesAutoresizingMaskIntoConstraints = false
		container.insertSubview(surroundController.view, at: container.subviews.firstIndex(of: self.bannerImageView) ?? 0)
		self.surroundController = surroundController

		// Above the quick-details wrapper, which would otherwise swallow the buttons' taps.
		let controlsOverlayView = PassthroughView()
		controlsOverlayView.translatesAutoresizingMaskIntoConstraints = false
		(container.superview ?? container).addSubview(controlsOverlayView)
		self.controlsOverlayView = controlsOverlayView

		NSLayoutConstraint.activate([
			surroundController.view.topAnchor.constraint(equalTo: container.topAnchor),
			surroundController.view.bottomAnchor.constraint(equalTo: container.bottomAnchor),
			surroundController.view.leadingAnchor.constraint(equalTo: container.leadingAnchor),
			surroundController.view.trailingAnchor.constraint(equalTo: container.trailingAnchor),

			controlsOverlayView.topAnchor.constraint(equalTo: container.topAnchor),
			controlsOverlayView.bottomAnchor.constraint(equalTo: container.bottomAnchor),
			controlsOverlayView.leadingAnchor.constraint(equalTo: container.leadingAnchor),
			controlsOverlayView.trailingAnchor.constraint(equalTo: container.trailingAnchor),

			self.bannerImageView.topAnchor.constraint(equalTo: mediaView.topAnchor),
			self.bannerImageView.bottomAnchor.constraint(equalTo: mediaView.bottomAnchor),
			self.bannerImageView.leadingAnchor.constraint(equalTo: mediaView.leadingAnchor),
			self.bannerImageView.trailingAnchor.constraint(equalTo: mediaView.trailingAnchor)
		])
	}

	/// Sizes the media to the video's aspect ratio while a trailer's picture is on screen.
	@available(iOS 26.0, *)
	private func updateMediaGaps() {
		guard let surroundView = self.surroundController?.viewIfLoaded else { return }

		let trailerView = self.hostedTrailerPlayerView
		if let trailerView {
			trailerView.controlsHost = self.controlsOverlayView

			if trailerView.onPictureVisibilityChanged == nil {
				trailerView.onPictureVisibilityChanged = { [weak self] in
					self?.setNeedsLayout()
				}
			}
		}

		var gapInsets = EdgeInsets()

		if trailerView?.isShowingPicture == true {
			let safeAreaInsets = surroundView.safeAreaInsets
			let areaSize = CGSize(
				width: surroundView.bounds.width - safeAreaInsets.left - safeAreaInsets.right,
				height: surroundView.bounds.height - safeAreaInsets.top - safeAreaInsets.bottom
			)

			if areaSize.width > 0, areaSize.height > 0 {
				// Rounded to device pixels so the seam between video and mirror stays crisp.
				let displayScale = max(self.traitCollection.displayScale, 1.0)
				let scale = min(areaSize.width / 16.0, areaSize.height / 9.0)
				let horizontalGap = max(((areaSize.width - 16.0 * scale) / 2.0 * displayScale).rounded() / displayScale, 0.0)
				let verticalGap = max(((areaSize.height - 9.0 * scale) / 2.0 * displayScale).rounded() / displayScale, 0.0)
				gapInsets = EdgeInsets(top: verticalGap, leading: horizontalGap, bottom: verticalGap, trailing: horizontalGap)
			}
		}

		guard self.mediaGapState.gapInsets != gapInsets else { return }
		self.mediaGapState.gapInsets = gapInsets
	}

	@objc private func didTapImage(_ sender: UITapGestureRecognizer) {
		guard let view = sender.view as? UIImageView else { return }
		self.mediaViewerDelegate?.mediaViewerViewDelegate(self, didTapImage: view, at: view.tag)
	}

	// MARK: - MediaViewerHeaderCell
	func imageView(at index: Int) -> UIImageView? {
		switch index {
		case 0: return self.posterImageView
		case 1: return self.bannerImageView
		default: return nil
		}
	}

	// MARK: - IBActions
	@IBAction func chooseStatusButtonPressed(_ sender: UIButton) {
		Task { [weak self] in
			guard let self = self else { return }
			await self.delegate?.baseDetailHeaderCollectionViewCell(self, didPressStatus: sender)
		}
	}
}

// MARK: - HeaderMediaGapState
/// The letterbox gaps the media surround reserves around its content.
private final class HeaderMediaGapState: ObservableObject {
	@Published var gapInsets = EdgeInsets()
}

// MARK: - HeaderMediaSurroundView
/// A view that mirrors the header's media into the safe area around it.
@available(iOS 26.0, *)
private struct HeaderMediaSurroundView: View {
	/// The view holding the header's media.
	let mediaView: UIView

	/// The letterbox gaps to reserve around the media.
	@ObservedObject var gapState: HeaderMediaGapState

	var body: some View {
		HeaderMediaBox(mediaView: self.mediaView)
			.backgroundExtensionEffect()
			.safeAreaPadding(self.gapState.gapInsets)
	}
}

// MARK: - HeaderMediaBox
/// Bridges the header's media view into SwiftUI.
@available(iOS 26.0, *)
private struct HeaderMediaBox: UIViewRepresentable {
	/// The view holding the header's media.
	let mediaView: UIView

	func makeUIView(context: Context) -> UIView {
		return self.mediaView
	}

	func updateUIView(_ uiView: UIView, context: Context) {}
}
