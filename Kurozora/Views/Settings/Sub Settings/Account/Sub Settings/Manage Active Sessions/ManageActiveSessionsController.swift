//
//  ManageActiveSessionsController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 09/06/2018.
//  Copyright © 2018 Kurozora. All rights reserved.
//

import UIKit
import KurozoraKit
import CoreLocation
import MapKit

class ManageActiveSessionsController: KTableViewController {
	// MARK: - IBOutlets
	@IBOutlet weak var mapView: MKMapView!

	// MARK: - Properties
	var sessions: [Session] = [] {
		didSet {
			createAnnotations()
			tableView.reloadData {
				self._prefersActivityIndicatorHidden = true
				#if !targetEnvironment(macCatalyst)
				self.refreshControl?.endRefreshing()
				self.refreshControl?.attributedTitle = NSAttributedString(string: "Pull to refresh your sessions list!")
				#endif
			}
		}
	}
	var nextPageURL: String?

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
		return _prefersActivityIndicatorHidden
	}

	// MARK: - View
	override func viewDidLoad() {
		super.viewDidLoad()
		NotificationCenter.default.addObserver(self, selector: #selector(removeSession(_:)), name: .KSSessionIsDeleted, object: nil)

		// Setup refresh control
		#if !targetEnvironment(macCatalyst)
		refreshControl?.attributedTitle = NSAttributedString(string: "Pull to refresh your sessions!")
		#endif

		// Fetch sessions
		DispatchQueue.global(qos: .background).async {
			self.fetchSessions()
		}

		// Configure map view
		mapView.showsUserLocation = true

		// Configure table view height
		tableView.tableHeaderView?.frame.size.height = self.view.frame.height / 3
	}

	override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
		super.viewWillTransition(to: size, with: coordinator)

		if UIDevice.isLandscape {
			self.tableView.tableHeaderView?.frame.size.height = self.view.frame.height / 3
		} else {
			DispatchQueue.main.async {
				self.tableView.tableHeaderView?.frame.size.height = self.view.frame.height / 3
			}
		}
	}

	// MARK: - Functions
	/// Fetches sessions for the current user from the server.
	func fetchSessions() {
		#if !targetEnvironment(macCatalyst)
		DispatchQueue.main.async {
			self.refreshControl?.attributedTitle = NSAttributedString(string: "Refreshing sessions list...")
		}
		#endif

		KService.getSessions(next: self.nextPageURL) { [weak self] result in
			guard let self = self else { return }
			switch result {
			case .success(let sessionResponse):
				// Reset data if necessary
				if self.nextPageURL == nil {
					self.sessions = []
				}

				// Append new data and save next page url
				self.sessions.append(contentsOf: sessionResponse.data)

				self.nextPageURL = sessionResponse.next
			case .failure: break
			}
		}
	}

	/// Creates annotations and adds them to the map view.
	private func createAnnotations() {
		for session in sessions {
			let annotation = ImageAnnotation()
			if let deviceName = session.relationships.platform.data.first?.attributes.deviceModel {
				annotation.title = deviceName

				if deviceName.contains("iPhone", caseSensitive: false) {
					annotation.image = UIImage(systemName: "iphone")
				} else if deviceName.contains("iPad", caseSensitive: false) {
					annotation.image = UIImage(systemName: "ipad.landscape")
				} else if deviceName.contains("TV", caseSensitive: false) {
					annotation.image = UIImage(systemName: "appletv")
				} else if deviceName.contains("Mac", caseSensitive: false) {
					annotation.image = UIImage(systemName: "laptopcomputer")
				} else {
					annotation.image = UIImage(systemName: "bolt.horizontal")
				}
			}

			if let sessionLocation = session.relationships.location.data.first {
				if let latitude = sessionLocation.attributes.latitude, let longitude = sessionLocation.attributes.longitude {
					annotation.coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
				}
			}

			mapView.addAnnotation(annotation)
		}

		locationManager.desiredAccuracy = kCLLocationAccuracyBest
		locationManager.requestWhenInUseAuthorization()
		locationManager.startUpdatingLocation()
	}

	/**
		Removes the session specified in the received information.

		- Parameter notification: An object containing information broadcast to registered observers.
	*/
	@objc func removeSession(_ notification: NSNotification) {
		// Start delete process
		self.tableView.beginUpdates()
		if let indexPath = notification.userInfo?["indexPath"] as? IndexPath, self.sessions.count != 0 {
			self.sessions.remove(at: indexPath.section - 1)
			self.tableView.deleteSections([indexPath.section], with: .left)
		}
		self.tableView.endUpdates()
	}

	override func handleRefreshControl() {
		self.fetchSessions()
	}
}

// MARK: - UITableViewDataSource
extension ManageActiveSessionsController {
	override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		if section == 0 {
			return "Current Session"
		} else if section == 1 {
			return "Other Sessions"
		}
		return nil
	}

	override func numberOfSections(in tableView: UITableView) -> Int {
		return sessions.isEmpty ? 1 : sessions.count + 1
	}

	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return 1
	}

	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		if indexPath.section == 0 {
			guard let currentSessionCell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.currentSessionCell, for: indexPath) else {
				fatalError("Cannot dequeue reusable cell with identifier \(R.reuseIdentifier.currentSessionCell.identifier)")
			}
			currentSessionCell.session = User.current?.relationships?.sessions?.data.first
			return currentSessionCell
		} else {
			// Other sessions found
			guard let otherSessionsCell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.otherSessionsCell, for: indexPath) else {
					fatalError("Cannot dequeue reusable cell with identifier \(R.reuseIdentifier.otherSessionsCell.identifier)")
			}
			otherSessionsCell.session = self.sessions[indexPath.section-1]
			return otherSessionsCell
		}
	}

	override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
		return indexPath.section != 0
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
			let annotation = annotation as! ImageAnnotation
			annotationView.glyphImage = annotation.image
		}

		annotationView.markerTintColor = .kurozora

		return annotationView
	}
}

// MARK: - CLLocationManagerDelegate
extension ManageActiveSessionsController: CLLocationManagerDelegate {
	func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
		print("Unable to access your current location")
	}

	@available(iOS 14.0, macOS 11.0, *)
	func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
		switch manager.authorizationStatus {
		case .restricted, .denied, .notDetermined:
			locationManager.requestWhenInUseAuthorization()
		default: break
		}

		locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
		locationManager.delegate = self
		locationManager.startUpdatingLocation()
	}
}
