//
//  PhotosProfileImageSourceView.swift
//  Kurozora
//
//  Created by Khoren Katklian on 13/03/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import Photos
import UIKit

protocol PhotosProfileImageSourceViewDelegate: AnyObject {
	func photosProfileImageSourceView(_ view: PhotosProfileImageSourceView, didSelectImage image: UIImage)
	func photosProfileImageSourceViewDidRequestCamera(_ view: PhotosProfileImageSourceView)
	func photosProfileImageSourceViewDidRequestPhotos(_ view: PhotosProfileImageSourceView)
	func photosProfileImageSourceViewDidChangeAuthorizationStatus(_ view: PhotosProfileImageSourceView)
}

class PhotosProfileImageSourceView: UIView {
	// MARK: - Properties
	let imageKind: ImageKind
	weak var delegate: PhotosProfileImageSourceViewDelegate?
	weak var parentViewController: UIViewController?

	private(set) var originalSelectedImage: UIImage?
	private(set) var currentImage: UIImage?

	private var photoAssets: [PHAsset] = []
	private var hasLimitedPhotoAccess: Bool = false
	private var dataSource: UICollectionViewDiffableDataSource<SectionLayoutKind, ItemKind>!

	var previewImageView: UIImageView? {
		didSet {
			self.updatePreviewImage()
		}
	}

	// MARK: - Views
	private lazy var emptyBackgroundView: EmptyBackgroundView = {
		let view = EmptyBackgroundView()
		view.translatesAutoresizingMaskIntoConstraints = false
		view.isHidden = true
		return view
	}()

	private lazy var collectionView: UICollectionView = {
		let layout = UICollectionViewCompositionalLayout { [weak self] (section: Int, layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? in
			guard let self = self else { return nil }
			let width = layoutEnvironment.container.effectiveContentSize.width
			let columnCount = Int((width / self.imageKind.layoutCellSize).rounded())
			let columns = columnCount > 0 ? columnCount : 1
			return Layouts.charactersSection(section, columns: columns, layoutEnvironment: layoutEnvironment, isHorizontal: false)
		}

		let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
		collectionView.translatesAutoresizingMaskIntoConstraints = false
		collectionView.backgroundColor = .clear
		collectionView.clipsToBounds = false
		collectionView.showsVerticalScrollIndicator = false
		collectionView.contentInset.top = 16
		collectionView.delegate = self
		return collectionView
	}()

	// MARK: - Initializers
	init(imageKind: ImageKind = .profile) {
		self.imageKind = imageKind
		super.init(frame: .zero)
		self.configureViews()
	}

	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	// MARK: - Configuration
	func reloadPhotos() {
		self.loadRecentPhotos()
	}

	func setOriginalSelectedImage(_ image: UIImage) {
		self.originalSelectedImage = image
		self.currentImage = image
		self.updatePreviewImage()
	}

	// MARK: - Setup
	private func configureViews() {
		self.addSubview(self.collectionView)
		self.addSubview(self.emptyBackgroundView)

		NSLayoutConstraint.activate([
			self.collectionView.topAnchor.constraint(equalTo: self.topAnchor),
			self.collectionView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
			self.collectionView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
			self.collectionView.bottomAnchor.constraint(equalTo: self.bottomAnchor),

			self.emptyBackgroundView.topAnchor.constraint(equalTo: self.topAnchor),
			self.emptyBackgroundView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
			self.emptyBackgroundView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
			self.emptyBackgroundView.bottomAnchor.constraint(equalTo: self.bottomAnchor)
		])

		self.configureDataSource()
		self.loadPhotosIfAuthorized()
		self.updateEmptyState()
	}

	private func configureDataSource() {
		let cameraCellRegistration = UICollectionView.CellRegistration<CameraButtonCollectionViewCell, ItemKind> { [weak self] cell, _, _ in
			guard let self = self else { return }
			cell.imageKind = self.imageKind
			cell.configure(with: self.buildCameraMenu())
		}

		let photoCellRegistration = UICollectionView.CellRegistration<AvatarCollectionViewCell, ItemKind> { [weak self] cell, _, itemKind in
			guard let self = self else { return }
			cell.imageKind = self.imageKind
			switch itemKind {
			case .photo(let asset):
				let scale = UIScreen.main.scale
				let cellSize = CGSize(width: self.imageKind.layoutCellSize * scale, height: self.imageKind.layoutCellSize * scale)
				self.loadImage(for: asset, targetSize: cellSize) { image in
					cell.configure(with: image)
				}
			default:
				break
			}
		}

		self.dataSource = UICollectionViewDiffableDataSource<SectionLayoutKind, ItemKind>(collectionView: self.collectionView) { collectionView, indexPath, itemKind in
			switch itemKind {
			case .camera:
				return collectionView.dequeueConfiguredReusableCell(using: cameraCellRegistration, for: indexPath, item: itemKind)
			case .photo:
				return collectionView.dequeueConfiguredReusableCell(using: photoCellRegistration, for: indexPath, item: itemKind)
			}
		}
	}

	private func buildCameraMenu() -> UIMenu {
		let takePhoto = UIAction(title: "Take Photo", image: UIImage(systemName: "camera")) { [weak self] _ in
			guard let self = self else { return }
			self.delegate?.photosProfileImageSourceViewDidRequestCamera(self)
		}

		let photoLibrary = UIAction(title: "Photo Library", image: UIImage(systemName: "photo.on.rectangle")) { [weak self] _ in
			guard let self = self else { return }
			self.delegate?.photosProfileImageSourceViewDidRequestPhotos(self)
		}

		return UIMenu(children: [takePhoto, photoLibrary])
	}

	// MARK: - Data Source Updates
	private func updateDataSource() {
		var snapshot = NSDiffableDataSourceSnapshot<SectionLayoutKind, ItemKind>()
		snapshot.appendSections([.main])
		snapshot.appendItems([.camera] + self.photoAssets.map { .photo($0) }, toSection: .main)
		self.dataSource.apply(snapshot)
	}

	func updatePreviewImage() {
		if let currentImage = self.currentImage {
			self.previewImageView?.image = currentImage
		}
	}

	// MARK: - Photo Library
	private func loadPhotosIfAuthorized() {
		let status = PHPhotoLibrary.authorizationStatus(for: .readWrite)

		switch status {
		case .limited:
			self.hasLimitedPhotoAccess = true
			self.loadRecentPhotos()
		case .authorized:
			self.hasLimitedPhotoAccess = false
			self.loadRecentPhotos()
		default:
			break
		}
	}

	func requestPhotoLibraryAccessIfNeeded() {
		let status = PHPhotoLibrary.authorizationStatus(for: .readWrite)

		guard status == .notDetermined else { return }

		Task {
			let newStatus = await PHPhotoLibrary.requestAuthorization(for: .readWrite)
			await MainActor.run {
				switch newStatus {
				case .limited:
					self.hasLimitedPhotoAccess = true
					self.loadRecentPhotos()
					self.updatePreviewImage()
				case .authorized:
					self.hasLimitedPhotoAccess = false
					self.loadRecentPhotos()
				default:
					break
				}

				self.updateEmptyState()
				self.delegate?.photosProfileImageSourceViewDidChangeAuthorizationStatus(self)
			}
		}
	}

	private func updateEmptyState() {
		let status = PHPhotoLibrary.authorizationStatus(for: .readWrite)

		switch status {
		case .authorized, .limited:
			self.emptyBackgroundView.isHidden = true
			self.collectionView.isHidden = false
		case .notDetermined:
			self.emptyBackgroundView.isHidden = false
			self.collectionView.isHidden = true
			self.emptyBackgroundView.configureImageView(image: UIImage(systemName: "photo.on.rectangle.angled")!)
			self.emptyBackgroundView.configureLabels(title: "Access Your Photos", detail: "Allow access to your photo library to choose a profile picture.")
			self.emptyBackgroundView.configureButton(title: "Allow Access") { [weak self] in
				self?.requestPhotoLibraryAccessIfNeeded()
			}
		case .denied:
			self.emptyBackgroundView.isHidden = false
			self.collectionView.isHidden = true
			self.emptyBackgroundView.configureImageView(image: UIImage(systemName: "photo.on.rectangle.angled")!)
			self.emptyBackgroundView.configureLabels(title: "Photo Access Denied", detail: "You've denied photo library access. You can change this in Settings.")
			self.emptyBackgroundView.configureButton(title: "Open Settings") {
				#if targetEnvironment(macCatalyst)
					let settingsUrl = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy")
				#else
					let settingsUrl = URL(string: UIApplication.openSettingsURLString)
				#endif
				UIApplication.shared.kOpen(nil, deepLink: settingsUrl)
			}
		case .restricted:
			self.emptyBackgroundView.isHidden = false
			self.collectionView.isHidden = true
			self.emptyBackgroundView.configureImageView(image: UIImage(systemName: "photo.on.rectangle.angled")!)
			self.emptyBackgroundView.configureLabels(title: "Photo Access Restricted", detail: "Photo library access is restricted on this device.")
		@unknown default:
			break
		}
	}

	private func loadRecentPhotos() {
		let fetchOptions = PHFetchOptions()
		fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]

		let allPhotos = PHAsset.fetchAssets(with: .image, options: fetchOptions)

		var filteredAssets: [PHAsset] = []

		allPhotos.enumerateObjects { asset, _, _ in
			filteredAssets.append(asset)
		}

		self.photoAssets = filteredAssets
		self.updateDataSource()
	}

	private func loadImage(for asset: PHAsset, targetSize: CGSize, completion: @escaping (UIImage?) -> Void) {
		let options = PHImageRequestOptions()
		options.deliveryMode = .highQualityFormat
		options.isSynchronous = false
		options.isNetworkAccessAllowed = true

		PHImageManager.default().requestImage(for: asset, targetSize: targetSize, contentMode: .aspectFill, options: options) { image, _ in
			DispatchQueue.main.async {
				completion(image)
			}
		}
	}
}

// MARK: - SectionLayoutKind
extension PhotosProfileImageSourceView {
	enum SectionLayoutKind: Int, CaseIterable {
		case main = 0
	}
}

// MARK: - ItemKind
extension PhotosProfileImageSourceView {
	enum ItemKind: Hashable {
		case camera
		case photo(_ asset: PHAsset)

		func hash(into hasher: inout Hasher) {
			switch self {
			case .camera:
				hasher.combine("camera")
			case .photo(let asset):
				hasher.combine(asset.localIdentifier)
			}
		}

		static func == (lhs: ItemKind, rhs: ItemKind) -> Bool {
			switch (lhs, rhs) {
			case (.camera, .camera):
				return true
			case (.photo(let lhsAsset), .photo(let rhsAsset)):
				return lhsAsset.localIdentifier == rhsAsset.localIdentifier
			default:
				return false
			}
		}
	}
}

// MARK: - UICollectionViewDelegate
extension PhotosProfileImageSourceView: UICollectionViewDelegate {
	func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		guard let itemKind = self.dataSource.itemIdentifier(for: indexPath) else { return }

		switch itemKind {
		case .camera:
			break
		case .photo(let asset):
			self.loadImage(for: asset, targetSize: PHImageManagerMaximumSize) { [weak self] image in
				guard let self = self, let image = image else { return }
				self.originalSelectedImage = image
				self.currentImage = image
				self.updatePreviewImage()
				self.delegate?.photosProfileImageSourceView(self, didSelectImage: image)
			}
		}
	}
}
