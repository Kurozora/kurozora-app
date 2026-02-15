//
//  MusicPlaybackControlView.swift
//  Kurozora
//
//  Created by Khoren Katklian on 15/02/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import Combine
import UIKit

@available(iOS 26.0, *)
final class MusicPlaybackControlView: UIView {
	// MARK: - Properties
	/// The playback controller that drives this view.
	weak var playbackController: MediaPlaybackControlling? {
		didSet { self.bind() }
	}

	/// The set of subscriptions for the playback controller's publishers.
	private var subscriptions = Set<AnyCancellable>()

	/// The Kurozora song model for the currently playing song.
	private var currentKKSong: KKSong?

	// MARK: - Views
	private let artworkImageView: UIImageView = {
		let imageView = UIImageView()
		imageView.translatesAutoresizingMaskIntoConstraints = false
		imageView.contentMode = .scaleAspectFill
		imageView.clipsToBounds = true
		imageView.layer.cornerRadius = 8
		imageView.image = .Placeholders.musicAlbum
		return imageView
	}()

	private let titleLabel: KMarqueeLabel = {
		let label = KMarqueeLabel()
		label.translatesAutoresizingMaskIntoConstraints = false
		label.font = .preferredFont(forTextStyle: .caption1).bold
		return label
	}()

	private let subtitleLabel: KMarqueeLabel = {
		let label = KMarqueeLabel()
		label.translatesAutoresizingMaskIntoConstraints = false
		label.font = .preferredFont(forTextStyle: .caption2)
		label.textColor = .secondaryLabel
		return label
	}()

	private let playPauseButton: UIButton = {
		let button = UIButton(type: .system)
		button.translatesAutoresizingMaskIntoConstraints = false
		let config = UIImage.SymbolConfiguration(pointSize: 20, weight: .medium)
		button.setImage(UIImage(systemName: "play.fill", withConfiguration: config), for: .normal)
		button.tintColor = .label
		return button
	}()

	private let labelStack: UIStackView = {
		let stack = UIStackView()
		stack.translatesAutoresizingMaskIntoConstraints = false
		stack.axis = .vertical
		stack.spacing = 2
		return stack
	}()

	// MARK: - Initializers
	override init(frame: CGRect) {
		super.init(frame: frame)
		self.sharedInit()
	}

	@available(*, unavailable)
	required init?(coder: NSCoder) {
		super.init(coder: coder)
		fatalError("init(coder:) has not been implemented")
	}

	// MARK: - Functions
	private func sharedInit() {
		self.configureView()
		self.configureViewHierarchy()
		self.configureViewConstraints()
	}

	private func configureView() {
		self.playPauseButton.addAction(UIAction { [weak self] _ in
			guard let self = self else { return }
			self.playPauseTapped()
		}, for: .touchUpInside)

		// Add the interaction
		let interaction = UIContextMenuInteraction(delegate: self)
		self.addInteraction(interaction)
	}

	private func configureViewHierarchy() {
		self.labelStack.addArrangedSubview(self.titleLabel)
		self.labelStack.addArrangedSubview(self.subtitleLabel)

		self.addSubview(self.artworkImageView)
		self.addSubview(self.labelStack)
		self.addSubview(self.playPauseButton)
	}

	private func configureViewConstraints() {
		NSLayoutConstraint.activate([
			// Artwork
			self.artworkImageView.topAnchor.constraint(equalTo: self.topAnchor, constant: 8),
			self.artworkImageView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -8),
			self.artworkImageView.leadingAnchor.constraint(equalTo: self.layoutMarginsGuide.leadingAnchor, constant: 8),
			self.artworkImageView.centerYAnchor.constraint(equalTo: self.centerYAnchor),
			self.artworkImageView.widthAnchor.constraint(equalTo: self.artworkImageView.heightAnchor),

			// Label stack
			self.labelStack.topAnchor.constraint(equalTo: self.topAnchor, constant: 8),
			self.labelStack.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -8),
			self.labelStack.leadingAnchor.constraint(equalTo: self.artworkImageView.trailingAnchor),
			self.labelStack.centerYAnchor.constraint(equalTo: self.centerYAnchor),
			self.labelStack.trailingAnchor.constraint(equalTo: self.playPauseButton.leadingAnchor),

			// Play/pause button
			self.playPauseButton.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -12),
			self.playPauseButton.centerYAnchor.constraint(equalTo: self.centerYAnchor),
			self.playPauseButton.widthAnchor.constraint(equalToConstant: 44),
			self.playPauseButton.heightAnchor.constraint(equalToConstant: 44),
		])

		self.titleLabel.setContentHuggingPriority(.defaultHigh + 1, for: .vertical)
		self.subtitleLabel.setContentHuggingPriority(.defaultHigh, for: .vertical)
	}

	/// Subscribes to the playback controller's publishers.
	private func bind() {
		self.subscriptions.removeAll()

		guard let controller = self.playbackController else { return }

		controller.currentSongPublisher
			.receive(on: RunLoop.main)
			.sink { [weak self] song in
				guard let self = self else { return }
				self.titleLabel.text = song?.song.title
				self.subtitleLabel.text = song?.song.artistName
				print("----- Now playing: \(song?.song.title ?? "None") by \(song?.song.artistName ?? "Unknown Artist")")
				self.loadArtwork(for: song)
			}
			.store(in: &self.subscriptions)

		controller.currentKKSongPublisher
			.receive(on: RunLoop.main)
			.sink { [weak self] kkSong in
				guard let self = self else { return }
				self.currentKKSong = kkSong
			}
			.store(in: &self.subscriptions)

		controller.isPlayingPublisher
			.receive(on: RunLoop.main)
			.sink { [weak self] isPlaying in
				guard let self = self else { return }
				let config = UIImage.SymbolConfiguration(pointSize: 20, weight: .medium)
				let symbolName = isPlaying ? "pause.fill" : "play.fill"
				self.playPauseButton.setImage(UIImage(systemName: symbolName, withConfiguration: config), for: .normal)
			}
			.store(in: &self.subscriptions)
	}

	/// Loads the artwork image for the given song.
	private func loadArtwork(for song: MKSong?) {
		guard let artworkURL = song?.song.artwork?.url(width: 96, height: 96)?.absoluteString else {
			self.artworkImageView.image = .Placeholders.musicAlbum
			return
		}
		self.artworkImageView.setImage(with: artworkURL, placeholder: .Placeholders.musicAlbum)
	}

	private func playPauseTapped() {
		self.playbackController?.togglePlayPause()
	}
}

// MARK: - UIContextMenuInteractionDelegate
@available(iOS 26.0, *)
extension MusicPlaybackControlView: UIContextMenuInteractionDelegate {
	func contextMenuInteraction(_ interaction: UIContextMenuInteraction, configurationForMenuAtLocation location: CGPoint) -> UIContextMenuConfiguration? {
		guard
			let kkSong = self.currentKKSong,
			let viewController = UIApplication.topViewController
		else { return nil }

		let userInfo: [AnyHashable: Any]? = if let mkSong = self.playbackController?.currentSong {
			["song": mkSong]
		} else {
			nil
		}

		return kkSong.contextMenuConfiguration(
			in: viewController,
			userInfo: userInfo,
			sourceView: self,
			barButtonItem: nil
		)
	}

	func contextMenuInteraction(_ interaction: UIContextMenuInteraction, willPerformPreviewActionForMenuWith configuration: UIContextMenuConfiguration, animator: UIContextMenuInteractionCommitAnimating) {
		guard let previewVC = animator.previewViewController else { return }

		animator.addCompletion {
			guard let viewController = UIApplication.topViewController else { return }
			viewController.show(previewVC, sender: self)
		}
	}
}
