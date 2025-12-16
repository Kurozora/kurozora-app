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

class ManageActiveSessionsController: KTableViewController, SectionFetchable, StoryboardInstantiable {
	static var storyboardName: String = "AccountSettings"

	// MARK: - IBOutlets
	@IBOutlet var mapView: MKMapView!

	// MARK: - Properties
	var sessionIdentities: [SessionIdentity] = []

	var cache: [IndexPath: KurozoraItem] = [:]
	var isFetchingSection: Set<SectionLayoutKind> = []

	var dataSource: UITableViewDiffableDataSource<SectionLayoutKind, ItemKind>!
	var snapshot: NSDiffableDataSourceSnapshot<SectionLayoutKind, ItemKind>!

	/// The next page url of the pagination.
	var nextPageURL: String?

	/// Whether a fetch request is currently in progress.
	var isRequestInProgress: Bool = false

	// Map & Location
	var pointAnnotation: MKPointAnnotation!
	var pinAnnotationView: MKMarkerAnnotationView!
	let locationManager = CLLocationManager()

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

		// Setup refresh control
		#if !targetEnvironment(macCatalyst)
		refreshControl?.attributedTitle = NSAttributedString(string: "Pull to refresh your sessions!")
		#endif

		self.configureDataSource()

		// Fetch sessions
		Task { [weak self] in
			guard let self = self else { return }
			await self.fetchSessions()
		}

		// Configure map view
		self.mapView.showsUserLocation = true

		// Configure table view height
		self.tableView.tableHeaderView?.frame.size.height = self.view.frame.height / 3
	}

	override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
		super.viewWillTransition(to: size, with: coordinator)

		if UIDevice.isLandscape {
			self.tableView.tableHeaderView?.frame.size.height = self.view.frame.height / 3
		} else {
			DispatchQueue.main.async { [weak self] in
				guard let self = self else { return }
				self.tableView.tableHeaderView?.frame.size.height = self.view.frame.height / 3
			}
		}
	}

	// MARK: - Functions
	override func handleRefreshControl() {
		self.nextPageURL = nil
		Task { [weak self] in
			guard let self = self else { return }
			await self.fetchSessions()
		}
	}

	func endFetch() {
		self.isRequestInProgress = false
		self._prefersActivityIndicatorHidden = true

		self.createAnnotations()
		self.updateDataSource()

		#if DEBUG
		#if !targetEnvironment(macCatalyst)
		self.refreshControl?.endRefreshing()
		self.refreshControl?.attributedTitle = NSAttributedString(string: "Pull to refresh your sessions!")
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
		self.refreshControl?.attributedTitle = NSAttributedString(string: "Refreshing sessions...")
		#endif

		do {
			let sessionResponse = try await KService.getSessions(next: self.nextPageURL).value

			// Reset data if necessary
			if self.nextPageURL == nil {
				self.sessionIdentities = []
			}

			// Save next page url and append new data
			self.nextPageURL = sessionResponse.next
			self.sessionIdentities.append(contentsOf: sessionResponse.data)
			self.sessionIdentities.removeDuplicates()

			// End fetch
			self.endFetch()
		} catch {
			print(error.localizedDescription)
		}
	}

	/// Creates annotations and adds them to the map view.
	private func createAnnotations() {
		guard let sessions = cache as? [IndexPath: Session] else { return }

		sessions.forEach { [weak self] _, session in
			guard let self = self else { return }
			let annotation = ImageAnnotation()

			if let deviceName = session.relationships.platform.data.first?.attributes {
				annotation.title = deviceName.deviceModel
				annotation.image = deviceName.deviceImage
			}

			if let sessionLocation = session.relationships.location.data.first {
				if let latitude = sessionLocation.attributes.latitude, let longitude = sessionLocation.attributes.longitude {
					annotation.coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
				}
			}

			self.mapView.addAnnotation(annotation)
		}

		self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
		self.locationManager.requestWhenInUseAuthorization()
		self.locationManager.startUpdatingLocation()
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

	/// Removes the session specified by the givne index path.
	///
	/// - Parameter indexPath: The index path of the session.
	func removeSession(at indexPath: IndexPath) {
		self.sessionIdentities.remove(at: indexPath.item)
		self.updateDataSource()
	}

	// MARK: - SectionFetchable
	func extractIdentity<Element>(from item: ItemKind) -> Element? where Element: KurozoraItem {
		switch item {
		case .sessionIdentity(let id): return id as? Element
		default: return nil
		}
	}
}

// MARK: - UITableViewDataSource
extension ManageActiveSessionsController {
	override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
		guard let sectionIdentifier = self.dataSource.sectionIdentifier(for: indexPath.section) else { return false }
		return sectionIdentifier != .current
	}
}

// MARK: - MKMapViewDelegate
extension ManageActiveSessionsController: MKMapViewDelegate {
	func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
		if annotation.isEqual(mapView.userLocation) {
			return nil
		}

		if !annotation.isKind(of: ImageAnnotation.self) {
			var pinAnnotationView = mapView.dequeueReusableAnnotationView(withIdentifier: "DefaultPinView")
			if pinAnnotationView == nil {
				pinAnnotationView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: "DefaultPinView")
			}
			return pinAnnotationView
		}

		var annotationView = MKMarkerAnnotationView()
		if let markerAnnotationView: MKMarkerAnnotationView = mapView.dequeueReusableAnnotationView(withIdentifier: "imageAnnotation") as? MKMarkerAnnotationView {
			annotationView = markerAnnotationView
		} else {
			annotationView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: "imageAnnotation")
			if let annotation = annotation as? ImageAnnotation {
				annotationView.glyphImage = annotation.image
			}
		}

		annotationView.markerTintColor = .kurozora

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
	func getConfiguredCurrentSessionCell() -> UITableView.CellRegistration<SessionLockupCell, ItemKind> {
		return UITableView.CellRegistration<SessionLockupCell, ItemKind>(cellNib: SessionLockupCell.nib) { currentSessionCell, _, itemKind in
			switch itemKind {
			case .accessToken(let accessToken):
				currentSessionCell.configureCell(using: accessToken)
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
						await self.fetchSectionIfNeeded(SessionResponse.self, SessionIdentity.self, at: indexPath, itemKind: itemKind)
					}
				}

				sessionLockupCell.configureCell(using: session)
			default: break
			}
		}
	}
}
