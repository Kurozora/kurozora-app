//
//  ManageActiveSessionsController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 09/06/2018.
//  Copyright © 2018 Kurozora. All rights reserved.
//

import CoreLocation
import KurozoraKit
import MapKit
import UIKit

class SessionDataSource: UITableViewDiffableDataSource<ManageActiveSessionsController.SectionLayoutKind, ManageActiveSessionsController.ItemKind> {
	override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
		return self.sectionIdentifier(for: indexPath.section) != .current
	}
}

class ManageActiveSessionsController: KTableViewController, SectionFetchable {
	// MARK: - Views
	private let mapContainerView = UIView()
	private let mapView = MKMapView()

	// MARK: - Initializers
	init() {
		super.init(style: .insetGrouped)
	}

	required init?(coder: NSCoder) {
		super.init(coder: coder)
	}

	// MARK: - Properties
	/// The user's app sessions.
	var appSessions: [AccessToken] = []

	/// The user's web sessions.
	var webSessions: [Session] = []

	var cache: [IndexPath: KurozoraItem] = [:]
	var isFetchingSection: Set<SectionLayoutKind> = []

	var dataSource: SessionDataSource!
	var snapshot: NSDiffableDataSourceSnapshot<SectionLayoutKind, ItemKind>!

	/// The cursor for the next page of app sessions.
	var nextPageCursor: PageCursor?

	/// Whether a fetch request is currently in progress.
	var isRequestInProgress: Bool = false

	/// The access token for the device the user is currently signed in on.
	var currentAccessToken: AccessToken? {
		User.current?.relationships?.accessTokens?.data.first
	}

	// Map & Location
	let locationManager = CLLocationManager()

	// Batch edit
	/// The bar button item that hosts the select and sign-out-all actions.
	var moreBarButtonItem = UIBarButtonItem()

	/// The bar button item that exits batch-edit mode.
	var cancelEditingBarButtonItem = UIBarButtonItem()

	/// The bar button item that toggles between selecting and deselecting every loaded session.
	var selectAllBarButtonItem = UIBarButtonItem()

	/// The bar button item that hosts the destructive sign-out confirmation in batch-edit mode.
	var deleteBatchBarButtonItem = UIBarButtonItem()

	/// The label that displays the selected-session count in the bottom toolbar.
	var selectionCountLabel = UILabel()

	/// The right bar button items captured before entering batch-edit mode.
	var savedRightBarButtonItems: [UIBarButtonItem]?

	/// The left bar button items captured before entering batch-edit mode.
	var savedLeftBarButtonItems: [UIBarButtonItem]?

	/// A boolean value that indicates whether batch-edit is currently displayed.
	var batchEditIsActive: Bool = false

	/// A boolean value that indicates whether this controller hid the tab bar to enter edit mode.
	var didHideTabBarForEdit: Bool = false

	// Activity indicator
	var _prefersActivityIndicatorHidden = false {
		didSet {
			self.setNeedsActivityIndicatorAppearanceUpdate()
		}
	}

	override var prefersActivityIndicatorHidden: Bool {
		return self._prefersActivityIndicatorHidden
	}

	// MARK: - View
	override func viewWillReload() {
		super.viewWillReload()

		self.handleRefreshControl()
	}

	override func viewDidLoad() {
		super.viewDidLoad()
		NotificationCenter.default.addObserver(self, selector: #selector(self.removeSession(_:)), name: .KSSessionIsDeleted, object: nil)
		self.title = L10n.activeSessions

		// Setup refresh control
		#if !targetEnvironment(macCatalyst)
		refreshControl?.attributedTitle = NSAttributedString(string: L10n.pullToRefreshItems(L10n.sessions.lowercased(with: Locale.current)))
		#endif

		self.configureView()
		self.configureDataSource()

		self.tableView.allowsMultipleSelectionDuringEditing = true
		self.configureNavigationItems()

		// Fetch sessions
		Task { [weak self] in
			guard let self = self else { return }
			await self.fetchSessions()
		}

		// Configure map view
		self.mapView.delegate = self
		self.mapView.showsUserLocation = true
		self.mapView.pointOfInterestFilter = .excludingAll
	}

	override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
		super.viewWillTransition(to: size, with: coordinator)

		coordinator.animate(alongsideTransition: { [weak self] _ in
			self?.updateTableHeaderHeight()
		})
	}

	override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()
		self.updateTableHeaderHeight()
	}

	// MARK: - Functions
	/// Configures the navigation bar items.
	private func configureNavigationItems() {
		self.configureBatchEditBarButtonItems()
		self.configureBottomActionContainer()
		self.updateMoreBarButtonItem()
	}

	/// Rebuilds the more menu shown in the navigation bar.
	private func updateMoreBarButtonItem() {
		let selectAction = UIAction(title: L10n.select, image: UIImage(systemName: "checkmark.circle")) { [weak self] _ in
			self?.setEditing(true, animated: true)
		}
		let signOutAllAction = UIAction(title: L10n.signOutAllOtherSessions, image: UIImage(systemName: "rectangle.portrait.and.arrow.right"), attributes: .destructive) { [weak self] _ in
			self?.confirmSignOutAllOtherSessions()
		}

		self.moreBarButtonItem.image = UIImage(systemName: "ellipsis.circle")
		self.moreBarButtonItem.menu = UIMenu(children: [selectAction, signOutAllAction])
		self.navigationItem.rightBarButtonItem = self.moreBarButtonItem
	}

	/// The shared settings used to initialize the table view.
	private func configureView() {
		self.tableView.cellLayoutMarginsFollowReadableWidth = true
		self.configureTableHeaderView()
	}

	private func configureTableHeaderView() {
		self.mapContainerView.backgroundColor = .white
		self.mapContainerView.addSubview(self.mapView)
		self.mapView.translatesAutoresizingMaskIntoConstraints = false

		NSLayoutConstraint.activate([
			self.mapView.leadingAnchor.constraint(equalTo: self.mapContainerView.leadingAnchor),
			self.mapView.trailingAnchor.constraint(equalTo: self.mapContainerView.trailingAnchor),
			self.mapView.topAnchor.constraint(equalTo: self.mapContainerView.topAnchor),
			self.mapView.bottomAnchor.constraint(equalTo: self.mapContainerView.bottomAnchor)
		])

		self.tableView.tableHeaderView = self.mapContainerView
		self.updateTableHeaderHeight()
	}

	private func updateTableHeaderHeight() {
		guard self.tableView.tableHeaderView === self.mapContainerView else { return }

		let height = self.view.frame.height / 3
		let width = self.tableView.bounds.width
		guard width > 0 else { return }

		var frame = self.mapContainerView.frame
		frame.size.width = width
		frame.size.height = height

		if self.mapContainerView.frame != frame {
			self.mapContainerView.frame = frame
			self.tableView.tableHeaderView = self.mapContainerView
		}
	}

	override func handleRefreshControl() {
		self.nextPageCursor = nil
		Task { [weak self] in
			guard let self = self else { return }
			await self.fetchSessions()
		}
	}

	func endFetch() {
		self.isRequestInProgress = false
		self._prefersActivityIndicatorHidden = true

		self.updateDataSource()
		self.createAnnotations()

		#if DEBUG
		#if !targetEnvironment(macCatalyst)
		self.refreshControl?.endRefreshing()
		self.refreshControl?.attributedTitle = NSAttributedString(string: L10n.pullToRefreshItems(L10n.sessions.lowercased(with: Locale.current)))
		#endif
		#endif
	}

	/// Fetches sessions for the current user from the server.
	func fetchSessions() async {
		guard !self.isRequestInProgress else {
			return
		}

		// Set request in progress
		self.isRequestInProgress = true

		#if !targetEnvironment(macCatalyst)
		self.refreshControl?.attributedTitle = NSAttributedString(string: L10n.refreshingItems(L10n.sessions.lowercased(with: Locale.current)))
		#endif

		do {
			let accessTokenResponse = try await KService.accessTokens().cursor(self.nextPageCursor).limit(self.nextPageCursor != nil ? 100 : 25).response()

			// Reset data if necessary
			if self.nextPageCursor == nil {
				self.appSessions = []
				await self.fetchWebSessions()
			}

			// Save next page url and append new data
			self.nextPageCursor = accessTokenResponse.nextCursor
			self.appSessions.append(contentsOf: accessTokenResponse.data)
			self.appSessions.removeDuplicates()

			// End fetch
			self.endFetch()
		} catch {
			print(error.localizedDescription)
		}
	}

	/// Fetches and resolves the user's web sessions.
	private func fetchWebSessions() async {
		do {
			let sessionResponse = try await KService.sessions().limit(100).response()
			let sessionIdentities = sessionResponse.data

			guard !sessionIdentities.isEmpty else {
				self.webSessions = []
				return
			}

			var sessions: [Session] = []
			for chunk in sessionIdentities.chunked(into: 25) {
				let detailResponse = try await KService.details(chunk).response()
				sessions.append(contentsOf: detailResponse.data)
			}
			self.webSessions = sessions
		} catch {
			print(error.localizedDescription)
			self.webSessions = []
		}
	}

	/// Rebuilds the map annotations from the loaded sessions.
	func createAnnotations() {
		let staleAnnotations = self.mapView.annotations.filter { $0 is ImageAnnotation }
		self.mapView.removeAnnotations(staleAnnotations)

		var annotations: [ImageAnnotation] = self.appSessions.compactMap { session in
			self.makeAnnotation(platform: session.relationships.platform.data.first?.attributes, location: session.relationships.location.data.first?.attributes)
		}
		annotations += self.webSessions.compactMap { session in
			self.makeAnnotation(platform: session.relationships.platform.data.first?.attributes, location: session.relationships.location.data.first?.attributes)
		}

		self.mapView.addAnnotations(annotations)

		if !annotations.isEmpty {
			self.mapView.showAnnotations(annotations, animated: true)
		}

		self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
		self.locationManager.requestWhenInUseAuthorization()
		self.locationManager.startUpdatingLocation()
	}

	/// Creates a map annotation for a session's platform and location.
	///
	/// - Parameters:
	///    - platform: The platform the session was created on.
	///    - location: The location the session was created from.
	///
	/// - Returns: An annotation positioned at the session's coordinate.
	private func makeAnnotation(platform: Platform.Attributes?, location: Location.Attributes?) -> ImageAnnotation? {
		guard
			let location = location,
			let latitude = location.latitude,
			let longitude = location.longitude
		else { return nil }

		let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)

		guard CLLocationCoordinate2DIsValid(coordinate), latitude != 0 || longitude != 0 else { return nil }

		let annotation = ImageAnnotation()
		annotation.coordinate = coordinate
		annotation.title = platform?.deviceModel
		annotation.image = platform?.deviceImage
		annotation.subtitle = [location.city, location.region, location.country]
			.compactMap { $0 }
			.filter { !$0.isEmpty && $0 != "Unknown" }
			.joined(separator: ", ")

		return annotation
	}

	/// Removes the session specified in the received information.
	///
	/// - Parameter notification: An object containing information broadcast to registered observers.
	@objc func removeSession(_ notification: NSNotification) {
		guard let indexPath = notification.userInfo?["indexPath"] as? IndexPath else { return }
		DispatchQueue.main.async { [weak self] in
			guard let self = self else { return }
			self.removeSession(at: indexPath)
		}
	}

	/// Removes the session specified by the given index path.
	///
	/// - Parameter indexPath: The index path of the session.
	func removeSession(at indexPath: IndexPath) {
		guard let itemKind = self.dataSource.itemIdentifier(for: indexPath) else { return }

		switch itemKind {
		case .accessToken(let accessToken):
			self.appSessions.removeAll { $0.id == accessToken.id }
		case .sessionIdentity(let sessionIdentity):
			self.webSessions.removeAll { $0.id == sessionIdentity.id }
		}

		self.updateDataSource()
		self.createAnnotations()
	}

	// MARK: - SectionFetchable
	func extractIdentity<Element>(from item: ItemKind) -> Element? where Element: KurozoraItem {
		switch item {
		case .sessionIdentity(let id): return id as? Element
		default: return nil
		}
	}
}

// MARK: - MKMapViewDelegate
extension ManageActiveSessionsController: MKMapViewDelegate {
	func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
		if annotation is MKUserLocation {
			return nil
		}

		if let cluster = annotation as? MKClusterAnnotation {
			let identifier = "clusterAnnotation"
			let clusterView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKMarkerAnnotationView
				?? MKMarkerAnnotationView(annotation: cluster, reuseIdentifier: identifier)
			clusterView.annotation = cluster
			clusterView.markerTintColor = .kurozora
			return clusterView
		}

		guard let imageAnnotation = annotation as? ImageAnnotation else {
			let identifier = "DefaultPinView"
			let pinView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKMarkerAnnotationView
				?? MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: identifier)
			pinView.annotation = annotation
			return pinView
		}

		let identifier = "imageAnnotation"
		let annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKMarkerAnnotationView
			?? MKMarkerAnnotationView(annotation: imageAnnotation, reuseIdentifier: identifier)
		annotationView.annotation = imageAnnotation
		annotationView.glyphImage = imageAnnotation.image
		annotationView.markerTintColor = .kurozora
		annotationView.clusteringIdentifier = identifier
		annotationView.canShowCallout = true

		return annotationView
	}
}

// MARK: - CLLocationManagerDelegate
extension ManageActiveSessionsController: CLLocationManagerDelegate {
	func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
		print("Unable to access current location", error.localizedDescription)
	}

	func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
		switch manager.authorizationStatus {
		case .restricted, .denied, .notDetermined:
			self.locationManager.requestWhenInUseAuthorization()
		default: break
		}

		self.locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
		self.locationManager.delegate = self
		self.locationManager.startUpdatingLocation()
	}
}

// MARK: - SectionLayoutKind
extension ManageActiveSessionsController {
	/// List of session section layout kind.
	///
	/// - `current`: the section containing the `current` session.
	/// - `other`: the section containing the `other` sessions.
	enum SectionLayoutKind: Int, CaseIterable {
		/// Indicates the section containing the current session.
		case current = 0

		/// Indicates the section containing the other sessions.
		case other
	}

	enum ItemKind: Hashable {
		// MARK: - Cases
		/// Indicates the item is of the `AccessToken` kind.
		case accessToken(_ accessToken: AccessToken)

		/// Indicates the item is of the `SessionIdentity` kind.
		case sessionIdentity(_ sessionIdentity: SessionIdentity)

		// MARK: - Functions
		func hash(into hasher: inout Hasher) {
			switch self {
			case .accessToken(let accessToken):
				hasher.combine(accessToken)
			case .sessionIdentity(let sessionIdentity):
				hasher.combine(sessionIdentity)
			}
		}

		static func == (lhs: ItemKind, rhs: ItemKind) -> Bool {
			switch (lhs, rhs) {
			case (.accessToken(let accessToken1), .accessToken(let accessToken2)):
				return accessToken1 == accessToken2
			case (.sessionIdentity(let sessionIdentity1), .sessionIdentity(let sessionIdentity2)):
				return sessionIdentity1 == sessionIdentity2
			default:
				return false
			}
		}
	}
}

// MARK: - Cell Registration
extension ManageActiveSessionsController {
	func getConfiguredAccessTokenCell() -> UITableView.CellRegistration<SessionLockupCell, ItemKind> {
		return UITableView.CellRegistration<SessionLockupCell, ItemKind>(cellNib: SessionLockupCell.nib) { [weak self] accessTokenCell, indexPath, itemKind in
			guard let self = self else { return }

			switch itemKind {
			case .accessToken(let accessToken):
				let isCurrentDevice = self.dataSource.sectionIdentifier(for: indexPath.section) == .current
				accessTokenCell.configureCell(using: accessToken, isCurrentDevice: isCurrentDevice)
			default: break
			}
		}
	}

	func getConfiguredSessionLockupCell() -> UITableView.CellRegistration<SessionLockupCell, ItemKind> {
		return UITableView.CellRegistration<SessionLockupCell, ItemKind>(cellNib: SessionLockupCell.nib) { [weak self] sessionLockupCell, indexPath, itemKind in
			guard let self = self else { return }

			switch itemKind {
			case .sessionIdentity:
				let session: Session? = self.fetchModel(at: indexPath)

				if session == nil, let section = self.snapshot.sectionIdentifier(containingItem: itemKind), !self.isFetchingSection.contains(section) {
					Task {
						await self.fetchSectionIfNeeded(ResourceCollection<Session>.self, SessionIdentity.self, at: indexPath, itemKind: itemKind)
					}
				}

				sessionLockupCell.configureCell(using: session)
			default: break
			}
		}
	}
}
