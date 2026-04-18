//
//  KAlert.swift
//  Kurozora
//
//  Created by Khoren Katklian on 18/04/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import UIKit

/// A compact, transient overlay alert modelled on Apple Music's "Favorited" indicator.
///
/// Displays an SF Symbol and a short title inside an adaptive system material
/// rounded rectangle, positioned near the bottom of the source window. The alert
/// enters with a spring scale-fade, holds briefly, and fades out.
@MainActor
enum KAlert {
	private static var activeHost: HostWindow?

	/// Shows the alert above any currently presented content in the source view's window.
	///
	/// - Parameters:
	///   - image: The image displayed on the leading edge of the alert.
	///   - title: The single-line label displayed after the image.
	///   - source: A view belonging to the window/scene that should host the alert.
	///   - haptic: The notification feedback to fire at enter start. Pass `nil` to suppress.
	static func show(
		image: UIImage?,
		title: String,
		from source: UIView,
		haptic: UINotificationFeedbackGenerator.FeedbackType? = .success
	) {
		self.activeHost?.hide(animated: false)

		guard let sourceWindow = source.window, let scene = sourceWindow.windowScene else { return }

		let host = HostWindow(windowScene: scene)
		host.overrideUserInterfaceStyle = sourceWindow.overrideUserInterfaceStyle
		host.present(
			image: image,
			title: title,
			bottomInset: source.safeAreaInsets.bottom,
			haptic: haptic
		) {
			if self.activeHost === host {
				self.activeHost = nil
			}
		}
		self.activeHost = host
	}
}

// MARK: - Host window
private extension KAlert {
	final class HostWindow: UIWindow {
		private static let bottomPadding: CGFloat = 24

		private let contentView = ContentView()
		private var onDismiss: (() -> Void)?
		private var bottomPositionConstraint: NSLayoutConstraint?

		override init(windowScene: UIWindowScene) {
			super.init(windowScene: windowScene)
			self.backgroundColor = .clear
			self.windowLevel = .alert + 1
			self.isUserInteractionEnabled = false
			self.rootViewController = PassthroughViewController()
			self.rootViewController?.view.backgroundColor = .clear

			self.contentView.translatesAutoresizingMaskIntoConstraints = false
			self.addSubview(self.contentView)

			let bottom = self.contentView.bottomAnchor.constraint(
				equalTo: self.bottomAnchor,
				constant: -HostWindow.bottomPadding
			)
			self.bottomPositionConstraint = bottom
			NSLayoutConstraint.activate([
				self.contentView.centerXAnchor.constraint(equalTo: self.centerXAnchor),
				bottom
			])
		}

		@available(*, unavailable)
		required init?(coder: NSCoder) {
			fatalError("init(coder:) has not been implemented")
		}

		func present(
			image: UIImage?,
			title: String,
			bottomInset: CGFloat,
			haptic: UINotificationFeedbackGenerator.FeedbackType?,
			onDismiss: @escaping () -> Void
		) {
			self.onDismiss = onDismiss
			self.contentView.configure(image: image, title: title)
			self.contentView.clearMaterial()
			self.bottomPositionConstraint?.constant = -(bottomInset + HostWindow.bottomPadding)
			self.isHidden = false

			let reduceMotion = UIAccessibility.isReduceMotionEnabled
			let shouldScale = !reduceMotion && !ContentView.usesGlassEffect
			self.contentView.alpha = 0
			self.contentView.transform = shouldScale ? CGAffineTransform(scaleX: 0.9, y: 0.9) : .identity

			let hapticGenerator: UINotificationFeedbackGenerator? = {
				guard haptic != nil, UserSettings.hapticsAllowed else { return nil }
				let generator = UINotificationFeedbackGenerator()
				generator.prepare()
				return generator
			}()

			if let haptic, let hapticGenerator {
				hapticGenerator.notificationOccurred(haptic)
			}

			UIView.animate(
				withDuration: 0.25,
				delay: 0,
				usingSpringWithDamping: 0.78,
				initialSpringVelocity: 0.3,
				options: [.curveEaseOut]
			) {
				self.contentView.alpha = 1
				self.contentView.transform = .identity
				self.contentView.applyMaterial()
			} completion: { _ in
				DispatchQueue.main.asyncAfter(deadline: .now() + 1.25) { [weak self] in
					self?.hide(animated: true)
				}
			}
		}

		func hide(animated: Bool) {
			let finish: () -> Void = { [weak self] in
				guard let self = self else { return }
				self.isHidden = true
				self.contentView.transform = .identity
				self.onDismiss?()
				self.onDismiss = nil
			}

			guard animated else {
				finish()
				return
			}

			let reduceMotion = UIAccessibility.isReduceMotionEnabled
			let shouldScale = !reduceMotion && !ContentView.usesGlassEffect
			UIView.animate(withDuration: 0.2, delay: 0, options: [.curveEaseIn]) {
				self.contentView.alpha = 0
				if shouldScale {
					self.contentView.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
				}
				self.contentView.clearMaterial()
			} completion: { _ in
				finish()
			}
		}
	}

	final class PassthroughViewController: UIViewController {
		override func loadView() {
			let view = PassthroughView()
			view.backgroundColor = .clear
			self.view = view
		}
	}

	final class PassthroughView: UIView {
		override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
			return false
		}
	}
}

// MARK: - Content view
private extension KAlert {
	final class ContentView: UIView {
		private static let height: CGFloat = 60
		private static let minWidth: CGFloat = 160
		private static let maxWidth: CGFloat = 300
		private static let horizontalInset: CGFloat = 20
		private static let verticalInset: CGFloat = 14

		private static let targetEffect: UIVisualEffect = {
			if #available(iOS 26.0, *) {
				return UIGlassEffect(style: .regular)
			}
			return UIBlurEffect(style: .systemMaterial)
		}()

		static var usesGlassEffect: Bool {
			if #available(iOS 26.0, *) { return true }
			return false
		}

		private let blurView = UIVisualEffectView(effect: nil)
		private let stackView = UIStackView()
		private let iconView = UIImageView()
		private let titleLabel = UILabel()

		override init(frame: CGRect) {
			super.init(frame: frame)
			self.translatesAutoresizingMaskIntoConstraints = false
			self.layer.cornerRadius = 20
			self.layer.cornerCurve = .continuous
			self.clipsToBounds = true

			self.blurView.translatesAutoresizingMaskIntoConstraints = false
			self.addSubview(self.blurView)

			self.iconView.contentMode = .scaleAspectFit
			self.iconView.tintColor = .label
			self.iconView.preferredSymbolConfiguration = UIImage.SymbolConfiguration(pointSize: 22, weight: .semibold)
			self.iconView.setContentHuggingPriority(.required, for: .horizontal)
			self.iconView.setContentCompressionResistancePriority(.required, for: .horizontal)

			self.titleLabel.font = .systemFont(ofSize: 17, weight: .semibold)
			self.titleLabel.textColor = .label
			self.titleLabel.numberOfLines = 1
			self.titleLabel.lineBreakMode = .byTruncatingTail

			self.stackView.axis = .horizontal
			self.stackView.alignment = .center
			self.stackView.spacing = 12
			self.stackView.translatesAutoresizingMaskIntoConstraints = false
			self.stackView.addArrangedSubview(self.iconView)
			self.stackView.addArrangedSubview(self.titleLabel)
			self.blurView.contentView.addSubview(self.stackView)

			let minWidth = self.widthAnchor.constraint(greaterThanOrEqualToConstant: ContentView.minWidth)
			let maxWidth = self.widthAnchor.constraint(lessThanOrEqualToConstant: ContentView.maxWidth)

			NSLayoutConstraint.activate([
				self.heightAnchor.constraint(equalToConstant: ContentView.height),
				minWidth,
				maxWidth,

				self.blurView.topAnchor.constraint(equalTo: self.topAnchor),
				self.blurView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
				self.blurView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
				self.blurView.bottomAnchor.constraint(equalTo: self.bottomAnchor),

				self.stackView.leadingAnchor.constraint(equalTo: self.blurView.contentView.leadingAnchor, constant: ContentView.horizontalInset),
				self.stackView.trailingAnchor.constraint(equalTo: self.blurView.contentView.trailingAnchor, constant: -ContentView.horizontalInset),
				self.stackView.topAnchor.constraint(equalTo: self.blurView.contentView.topAnchor, constant: ContentView.verticalInset),
				self.stackView.bottomAnchor.constraint(equalTo: self.blurView.contentView.bottomAnchor, constant: -ContentView.verticalInset)
			])
		}

		@available(*, unavailable)
		required init?(coder: NSCoder) {
			fatalError("init(coder:) has not been implemented")
		}

		func configure(image: UIImage?, title: String) {
			self.iconView.image = image
			self.iconView.isHidden = image == nil
			self.titleLabel.text = title
		}

		func clearMaterial() {
			self.blurView.effect = nil
		}

		func applyMaterial() {
			self.blurView.effect = ContentView.targetEffect
		}
	}
}
