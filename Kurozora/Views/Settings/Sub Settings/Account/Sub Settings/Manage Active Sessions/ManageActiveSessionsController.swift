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
			_prefersActivityIndicatorHidden = true
			tableView.reloadData()
		}
	}
	var nextPageURL: String?

	// Map & Location
	var pointAnnotation: MKPointAnnotation!
	var pinAnnotationView: MKPinAnnotationView!
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

		// Fetch sessions
		DispatchQueue.global(qos: .background).async {
			self.fetchSessions()
		}

		// Configure map view
		mapView.showsUserLocation = true

		if #available(iOS 14.0, macOS 11.0, *) {
		} else {
			if CLLocationManager.locationServicesEnabled() == true {
				let authorizationStatus: CLAuthorizationStatus!
				authorizationStatus = CLLocationManager.authorizationStatus()

				switch authorizationStatus {
				case .restricted, .denied, .notDetermined:
					locationManager.requestWhenInUseAuthorization()
				default: break
				}

				locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
				locationManager.delegate = self
				locationManager.startUpdatingLocation()

			} else {
				print("Please turn on location services or GPS")
			}
		}

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
	private func fetchSessions() {
		KService.getSessions(next: nextPageURL) { [weak self] result in
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
		let otherUserSessions = sessions

		for userSession in otherUserSessions {
			let annotation = ImageAnnotation()
			if let deviceName = userSession.relationships.platform.data.first?.attributes.deviceModel {
				annotation.title = deviceName

				switch deviceName {
				case "iPhone":
					annotation.image = R.image.devices.iPhone()
				case "iPad":
					annotation.image = R.image.devices.iPad()
				case "Apple TV":
					annotation.image = R.image.devices.appleTV()
				case "MacBook":
					annotation.image = R.image.devices.macBook()
				default:
					annotation.image = R.image.devices.other()
				}
			}

			if let userSessionLocation = userSession.relationships.location.data.first {
				if let latitude = userSessionLocation.attributes.latitude, let longitude = userSessionLocation.attributes.longitude {
					annotation.coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
				}
			}

			mapView.addAnnotation(annotation)
		}

		locationManager.desiredAccuracy = kCLLocationAccuracyBest
		locationManager.requestWhenInUseAuthorization()
		locationManager.startUpdatingLocation()
	}

	@objc func removeSession(_ notification: NSNotification) {
		// Start delete process
		self.tableView.beginUpdates()
		if let indexPath = notification.userInfo?["indexPath"] as? IndexPath, self.sessions.count != 0 {
			self.sessions.remove(at: indexPath.section - 1)
			self.tableView.deleteSections([indexPath.section], with: .left)
		}
		self.tableView.endUpdates()
	}
}

// MARK: - UITableViewDelegate
extension ManageActiveSessionsController {
	override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
		let numberOfSections = tableView.numberOfSections

		if indexPath.section == numberOfSections - 5 {
			if self.nextPageURL != nil {
				self.fetchSessions()
			}
		}
	}

	override func tableView(_ tableView: UITableView, didHighlightRowAt indexPath: IndexPath) {
		if let otherSessionsCell = tableView.cellForRow(at: indexPath) as? OtherSessionsCell {
			otherSessionsCell.contentView.theme_backgroundColor = KThemePicker.tableViewCellSelectedBackgroundColor.rawValue

			otherSessionsCell.ipAddressValueLabel.theme_textColor = KThemePicker.tableViewCellSelectedTitleTextColor.rawValue
			otherSessionsCell.deviceTypeValueLabel.theme_textColor = KThemePicker.tableViewCellSelectedTitleTextColor.rawValue
			otherSessionsCell.dateValueLabel.theme_textColor = KThemePicker.tableViewCellSelectedTitleTextColor.rawValue
		}
	}

	override func tableView(_ tableView: UITableView, didUnhighlightRowAt indexPath: IndexPath) {
		if let otherSessionsCell = tableView.cellForRow(at: indexPath) as? OtherSessionsCell {
			otherSessionsCell.contentView.theme_backgroundColor = KThemePicker.tableViewCellBackgroundColor.rawValue

			otherSessionsCell.ipAddressValueLabel.theme_textColor = KThemePicker.tableViewCellTitleTextColor.rawValue
			otherSessionsCell.deviceTypeValueLabel.theme_textColor = KThemePicker.tableViewCellTitleTextColor.rawValue
			otherSessionsCell.dateValueLabel.theme_textColor = KThemePicker.tableViewCellTitleTextColor.rawValue
		}
	}

	override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
		let signOutOfSessionAction = UIContextualAction(style: .destructive, title: "Sign Out") { [weak self] (_, _, completionHandler) in
			guard let self = self else { return }
			self.sessions[indexPath.section - 1].signOutOfSession(at: indexPath)
			completionHandler(true)
		}
		signOutOfSessionAction.backgroundColor = .red
		signOutOfSessionAction.image = UIImage(systemName: "minus.circle")

		let swipeActionsConfiguration = UISwipeActionsConfiguration(actions: [signOutOfSessionAction])
		swipeActionsConfiguration.performsFirstActionWithFullSwipe = true
		return swipeActionsConfiguration
	}

	override func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
		if indexPath.section != 0 {
			return self.sessions[indexPath.section - 1].contextMenuConfiguration(in: self, userInfo: ["indexPath": indexPath])
		}
		return nil
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
				pinAnnotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "DefaultPinView")
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
