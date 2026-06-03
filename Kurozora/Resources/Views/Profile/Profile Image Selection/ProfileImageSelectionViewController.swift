//
//  ProfileImageSelectionViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 13/03/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import ImagePlayground
import Photos
import PhotosUI
import UIKit

protocol ProfileImageSelectionViewControllerDelegate: AnyObject {
	func profileImageSelectionViewController(_ viewController: ProfileImageSelectionViewController, didSelectImage image: UIImage, imageURL: URL?)
	func profileImageSelectionViewControllerDidCancel(_ viewController: ProfileImageSelectionViewController)
}

class ProfileImageSelectionViewController: KViewController {
	// MARK: - Views
	private lazy var selectionView: ProfileImageSelectionView = {
		let view = ProfileImageSelectionView(imageKind: self.imageKind)
		view.translatesAutoresizingMaskIntoConstraints = false
		return view
	}()

	// MARK: - Properties
	private let imageKind: ImageKind
	private var currentImage: UIImage?
	private var placeholderImage: UIImage?
	private var selectedImage: UIImage?
	private var selectedImageURL: URL?

	weak var delegate: ProfileImageSelectionViewControllerDelegate?

	// MARK: - Initializers
	init(currentImage: UIImage?, placeholderImage: UIImage? = nil, imageKind: ImageKind = .profile) {
		self.currentImage = currentImage
		self.placeholderImage = placeholderImage
		self.imageKind = imageKind
		super.init(nibName: nil, bundle: nil)
	}

	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	// MARK: - View
	override func viewDidLoad() {
		super.viewDidLoad()
		self.configureView()
	}

	// MARK: - Functions
	private func configureView() {
		self.title = String(localized: "Choose Photo")
		self.extendedLayoutIncludesOpaqueBars = true

		self.navigationItem.leftBarButtonItem = UIBarButtonItem(systemItem: .cancel, primaryAction: UIAction { [weak self] _ in
			self?.cancelButtonPressed()
		})

		self.navigationItem.rightBarButtonItem = UIBarButtonItem(systemItem: .done, primaryAction: UIAction { [weak self] _ in
			guard let self = self else { return }
			self.usePhotoButtonPressed()
		})

		self.navigationController?.setToolbarHidden(true, animated: false)
		self.toolbarItems = [
			UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
			UIBarButtonItem(title: String(localized: "Manage"), primaryAction: UIAction { [weak self] _ in
				self?.manageAccessButtonPressed()
			})
		]

		self.selectionView.delegate = self
		self.selectionView.parentViewController = self
		self.selectionView.configure(with: self.currentImage, placeholderImage: self.placeholderImage)

		self.view.addSubview(self.selectionView)

		NSLayoutConstraint.activate([
			self.selectionView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),
			self.selectionView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
			self.selectionView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
			self.selectionView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
		])
	}

	private func cancelButtonPressed() {
		self.delegate?.profileImageSelectionViewControllerDidCancel(self)
		if self.presentingViewController != nil {
			self.dismiss(animated: true)
		}
	}

	private func manageAccessButtonPressed() {
		let status = PHPhotoLibrary.authorizationStatus(for: .readWrite)
		if status == .notDetermined {
			PHPhotoLibrary.requestAuthorization(for: .readWrite) { [weak self] _ in
				DispatchQueue.main.async {
					self?.selectionView.reloadPhotos()
				}
			}
		} else {
			PHPhotoLibrary.shared().presentLimitedLibraryPicker(from: self) { [weak self] _ in
				DispatchQueue.main.async {
					self?.selectionView.reloadPhotos()
				}
			}
		}
	}

	private func usePhotoButtonPressed() {
		if var image = self.selectedImage {
			if let original = self.selectionView.originalSelectedImage,
			   image === original {
				image = self.autoCroppedImage(image)
				self.selectedImageURL = self.saveImageToTemporaryFile(image)
			}
			self.delegate?.profileImageSelectionViewController(self, didSelectImage: image, imageURL: self.selectedImageURL)
		}
		if self.presentingViewController != nil {
			self.dismiss(animated: true)
		}
	}

	private func presentPhotoPicker() {
		var config = PHPickerConfiguration(photoLibrary: .shared())
		config.filter = .images
		config.selectionLimit = 1
		config.preferredAssetRepresentationMode = .current

		let picker = PHPickerViewController(configuration: config)
		picker.delegate = self
		self.present(picker, animated: true)
	}

	private func presentImagePicker(sourceType: UIImagePickerController.SourceType) {
		guard UIImagePickerController.isSourceTypeAvailable(sourceType) else {
			self.presentAlertController(title: L10n.imagePickerUnavailableTitle, message: L10n.imagePickerUnavailableMessage)
			return
		}

		let picker = UIImagePickerController()
		picker.sourceType = sourceType
		picker.delegate = self
		picker.allowsEditing = false
		self.present(picker, animated: true)
	}

	@available(iOS 18.1, macOS 15.1, visionOS 2.4, *)
	private func presentImagePlayground() {
		let playgroundVC = ImagePlaygroundViewController()
		playgroundVC.delegate = self
		playgroundVC.concepts = [.text("anime"), .text("manga"), .text("game"), .text("character")]

		if #available(iOS 18.4, macOS 15.4, visionOS 2.4, *) {
			playgroundVC.allowedGenerationStyles = [.illustration]
		}

		self.present(playgroundVC, animated: true)
	}

	private func presentCharacterSearch() {
		let characterSearchVC = CharacterSearchViewController()
		characterSearchVC.delegate = self

		let navController = KNavigationController(rootViewController: characterSearchVC)
		navController.modalPresentationStyle = .formSheet
		self.present(navController, animated: true)
	}

	private func presentCropViewController(for image: UIImage) {
		let cropVC = ImageCropViewController(
			image: image,
			shapeType: self.imageKind.shapeType,
			targetOutputSize: self.imageKind.targetOutputSize
		)
		cropVC.delegate = self

		let navController = KNavigationController(rootViewController: cropVC)
		navController.modalPresentationStyle = .fullScreen
		self.present(navController, animated: true)
	}

	private static func normalizeOrientation(_ image: UIImage) -> UIImage {
		guard image.imageOrientation != .up else { return image }

		let format = UIGraphicsImageRendererFormat()
		format.scale = image.scale
		let renderer = UIGraphicsImageRenderer(size: image.size, format: format)
		return renderer.image { _ in
			image.draw(at: .zero)
		}
	}

	private func autoCroppedImage(_ image: UIImage) -> UIImage {
		let normalized = Self.normalizeOrientation(image)
		guard let cgImage = normalized.cgImage else { return image }

		let sourceWidth = CGFloat(cgImage.width)
		let sourceHeight = CGFloat(cgImage.height)
		let targetSize = self.imageKind.targetOutputSize
		let targetAspect = targetSize.width / targetSize.height

		let cropWidth: CGFloat
		let cropHeight: CGFloat

		if sourceWidth / sourceHeight > targetAspect {
			cropHeight = sourceHeight
			cropWidth = cropHeight * targetAspect
		} else {
			cropWidth = sourceWidth
			cropHeight = cropWidth / targetAspect
		}

		let cropRect = CGRect(
			x: (sourceWidth - cropWidth) / 2.0,
			y: (sourceHeight - cropHeight) / 2.0,
			width: cropWidth,
			height: cropHeight
		)

		guard let croppedCG = cgImage.cropping(to: cropRect) else { return image }

		let format = UIGraphicsImageRendererFormat()
		format.scale = 1.0
		format.opaque = true
		let renderer = UIGraphicsImageRenderer(size: targetSize, format: format)
		return renderer.image { _ in
			UIImage(cgImage: croppedCG).draw(in: CGRect(origin: .zero, size: targetSize))
		}
	}

	private func saveImageToTemporaryFile(_ image: UIImage) -> URL? {
		let imageName = UUID().uuidString + ".jpg"
		let imageURL = FileManager.default.temporaryDirectory.appendingPathComponent(imageName)

		guard let data = image.jpegData(compressionQuality: 0.8) else { return nil }

		do {
			try data.write(to: imageURL, options: [.atomic])
			return imageURL
		} catch {
			print("Failed to save image: \(error)")
			return nil
		}
	}
}

// MARK: - ProfileImageSelectionViewDelegate
extension ProfileImageSelectionViewController: ProfileImageSelectionViewDelegate {
	func profileImageSelectionView(_ view: ProfileImageSelectionView, didSelectImage image: UIImage) {
		self.selectedImage = image
		self.selectedImageURL = self.saveImageToTemporaryFile(image)
	}

	func profileImageSelectionViewDidCancel(_ view: ProfileImageSelectionView) {
		self.cancelButtonPressed()
	}

	func profileImageSelectionViewDidRequestCamera(_ view: ProfileImageSelectionView) {
		self.presentImagePicker(sourceType: .camera)
	}

	func profileImageSelectionViewDidRequestPhotos(_ view: ProfileImageSelectionView) {
		self.presentPhotoPicker()
	}

	func profileImageSelectionView(_ view: ProfileImageSelectionView, shouldShowManageAccessToolbar show: Bool) {
		self.navigationController?.setToolbarHidden(!show, animated: true)
	}

	func profileImageSelectionViewDidRequestCharacterSearch(_ view: ProfileImageSelectionView) {
		self.presentCharacterSearch()
	}

	func profileImageSelectionViewDidRequestCrop(_ view: ProfileImageSelectionView) {
		guard let originalImage = self.selectionView.originalSelectedImage else { return }
		self.presentCropViewController(for: originalImage)
	}

	@available(iOS 18.1, macOS 15.1, visionOS 2.4, *)
	func profileImageSelectionViewDidRequestImagePlayground(_ view: ProfileImageSelectionView) {
		self.presentImagePlayground()
	}
}

// MARK: - UIImagePickerControllerDelegate
extension ProfileImageSelectionViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
	func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
		picker.dismiss(animated: true)

		guard let image = info[.originalImage] as? UIImage else { return }
		self.presentCropViewController(for: image)
	}

	func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
		picker.dismiss(animated: true)
	}
}

// MARK: - PHPickerViewControllerDelegate
extension ProfileImageSelectionViewController: PHPickerViewControllerDelegate {
	func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
		picker.dismiss(animated: true)

		self.selectionView.reloadPhotos()

		guard let result = results.first else { return }

		result.itemProvider.loadObject(ofClass: UIImage.self) { [weak self] object, _ in
			guard let image = object as? UIImage else { return }

			DispatchQueue.main.async {
				self?.selectedImage = image
				self?.selectedImageURL = self?.saveImageToTemporaryFile(image)
				self?.selectionView.configure(with: image)
				self?.selectionView.setOriginalSelectedImage(image)
			}
		}
	}
}

// MARK: - ImagePlaygroundViewControllerDelegate
@available(iOS 18.1, macOS 15.1, visionOS 2.4, *)
extension ProfileImageSelectionViewController: ImagePlaygroundViewController.Delegate {
	func imagePlaygroundViewController(_ imagePlaygroundViewController: ImagePlaygroundViewController, didCreateImageAt imageURL: URL) {
		imagePlaygroundViewController.dismiss(animated: true)

		guard let image = UIImage(contentsOfFile: imageURL.path) else { return }

		self.selectedImage = image
		self.selectedImageURL = self.saveImageToTemporaryFile(image)
		self.selectionView.configure(with: image)
	}
}

// MARK: - CharacterSearchViewControllerDelegate
extension ProfileImageSelectionViewController: CharacterSearchViewControllerDelegate {
	func characterSearchViewController(_ viewController: CharacterSearchViewController, didSelectImage image: UIImage) {
		self.selectedImage = image
		self.selectedImageURL = self.saveImageToTemporaryFile(image)
		self.selectionView.configure(with: image)
		self.selectionView.originalSelectedImage = image
	}
}

// MARK: - ImageCropViewControllerDelegate
extension ProfileImageSelectionViewController: ImageCropViewControllerDelegate {
	func imageCropViewController(_ viewController: ImageCropViewController, didCropImage image: UIImage) {
		self.selectedImage = image
		self.selectedImageURL = self.saveImageToTemporaryFile(image)
		self.selectionView.configure(with: image)
	}

	func imageCropViewControllerDidCancel(_ viewController: ImageCropViewController) {
		viewController.dismiss(animated: true)
	}
}
