//
//  WhatsAppStickerInstaller.swift
//  Kurozora
//
//  Created by Khoren Katklian on 18/05/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import KurozoraKit
import UIKit

@MainActor
final class WhatsAppStickerInstaller {
	// MARK: - Properties
	/// The shared instance of `WhatsAppStickerInstaller`.
	static let shared = WhatsAppStickerInstaller()

	/// The lifetime of the pasteboard entry handed off to WhatsApp in seconds.
	private let pasteboardExpirySeconds: TimeInterval = 60

	/// The pasteboard UTI WhatsApp reads the third-party pack payload from.
	private let pasteboardUTI = "net.whatsapp.third-party.sticker-pack"

	// MARK: - Initializers
	private init() {}

	// MARK: - Functions
	/// Hands the Kuro-chan sticker pack off to WhatsApp.
	///
	/// - Parameters:
	///    - context: The navigation context used as a presentation fallback.
	///    - presenter: The view controller to present error alerts from.
	func install(on context: NavigationContext?, presenter: UIViewController? = nil) async {
		guard let installURL = URL.whatsAppStickerInstallURL else {
			self.presentInstallFailure(on: context, presenter: presenter)
			return
		}

		guard UIApplication.shared.canOpenURL(installURL) else {
			self.presentAlert(
				on: context,
				presenter: presenter,
				title: L10n.whatsAppNotInstalled,
				message: nil
			)
			return
		}

		do {
			let data = try await KService.whatsAppStickerBundle().response()
			self.writePasteboard(data)
			await UIApplication.shared.open(installURL)
		} catch {
			self.presentInstallFailure(on: context, presenter: presenter)
		}
	}

	/// Resolves the actual view controller to present alerts from.
	///
	/// - Parameters:
	///    - context: The navigation context used as a fallback.
	///    - override: The explicit presenter, if the caller provided one.
	///
	/// - Returns: The deepest currently-visible view controller, or `nil`.
	private func resolvePresenter(context: NavigationContext?, override: UIViewController?) -> UIViewController? {
		let candidate = override ?? context?.topViewController ?? UIApplication.topViewController
		var top = candidate
		while let presented = top?.presentedViewController {
			top = presented
		}
		return top
	}

	/// Presents installation failure alert.
	///
	/// - Parameters:
	///    - context: The navigation context used as a presentation fallback.
	///    - presenter: The view controller to present the alert from.
	private func presentInstallFailure(on context: NavigationContext?, presenter: UIViewController?) {
		self.presentAlert(
			on: context,
			presenter: presenter,
			title: L10n.stickerInstallFailedTitle,
			message: L10n.stickerInstallFailedMessage
		)
	}

	/// Presents an alert with the given title and message.
	///
	/// - Parameters:
	///    - context: The navigation context used as a presentation fallback.
	///    - presenter: The view controller to present the alert from.
	///    - title: The title of the alert.
	///    - message: The message body of the alert.
	private func presentAlert(on context: NavigationContext?, presenter: UIViewController?, title: String, message: String?) {
		let resolvedPresenter = self.resolvePresenter(context: context, override: presenter)
		resolvedPresenter?.presentAlertController(title: title, message: message)
	}

	/// Writes the serialized pack payload to the system pasteboard for WhatsApp to read.
	///
	/// - Parameter payload: The serialized JSON payload.
	private func writePasteboard(_ payload: Data) {
		let options: [UIPasteboard.OptionsKey: Any] = [
			.localOnly: true,
			.expirationDate: Date(timeIntervalSinceNow: self.pasteboardExpirySeconds)
		]

		UIPasteboard.general.setItems([[self.pasteboardUTI: payload]], options: options)
	}
}
