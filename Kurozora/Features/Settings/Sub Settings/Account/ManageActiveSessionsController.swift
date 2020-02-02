//
//  ManageActiveSessionsController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 09/06/2018.
//  Copyright © 2018 Kurozora. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit
import SCLAlertView
import SwifterSwift
import SwiftyJSON

class ManageActiveSessionsController: KTableViewController {
	// MARK: - IBOutlets
	@IBOutlet weak var mapView: MKMapView!

	// MARK: - Properties
	var dismissEnabled: Bool = false
	var sessions: UserSessions? {
		didSet {
			createAnnotations()
			_prefersActivityIndicatorHidden = true
			tableView.reloadData()
		}
	}
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
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		if dismissEnabled {
			let closeButton = UIBarButtonItem(barButtonSystemItem: .stop, target: self, action: #selector(dismiss(_:)))
			self.navigationItem.leftBarButtonItem = closeButton
		}
	}

	override func viewDidLoad() {
		super.viewDidLoad()
		NotificationCenter.default.addObserver(self, selector: #selector(removeSessionFromTable(_:)), name: NSNotification.Name(rawValue: "removeSessionFromTable"), object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(addSessionToTable(_:)), name: NSNotification.Name(rawValue: "addSessionToTable"), object: nil)

		// Fetch sessions
		DispatchQueue.global(qos: .background).async {
			self.fetchSessions()
		}

		// Configure map view
		mapView.showsUserLocation = true

		if CLLocationManager.locationServicesEnabled() == true {
			if CLLocationManager.authorizationStatus() == .restricted ||
				CLLocationManager.authorizationStatus() == .denied ||
				CLLocationManager.authorizationStatus() == .notDetermined {
				locationManager.requestWhenInUseAuthorization()
			}

			locationManager.desiredAccuracy = 1.0
			locationManager.delegate = self
			locationManager.startUpdatingLocation()

		} else {
			print("Please turn on location services or GPS")
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
	/**
		Instantiates and returns a view controller from the relevant storyboard.

		- Returns: a view controller from the relevant storyboard.
	*/
	static func instantiateFromStoryboard() -> UIViewController? {
		let storyBoard = UIStoryboard(name: "account", bundle: nil)
		return storyBoard.instantiateViewController(withIdentifier: "ManageActiveSessionsController")
	}

	/// Fetches sessions for the current user from the server.
	private func fetchSessions() {
		KService.shared.getSessions( withSuccess: { (sessions) in
			DispatchQueue.main.async {
				self.sessions = sessions
			}
		})
	}

	/**
		Dismisses the current view controller.

		- Parameter sender: The object requesting the dismiss of the current view controller.
	*/
	@objc func dismiss(_ sender: Any?) {
		self.dismiss(animated: true, completion: nil)
	}

	/// Creates annotations and adds them to the map view.
	private func createAnnotations() {
		guard let otherSessions = sessions?.otherSessions else { return }

		for session in otherSessions {
			let annotation = ImageAnnotation()
			if let deviceString = session.device, let range = deviceString.range(of: " on ") {
				let device = deviceString[deviceString.startIndex..<range.lowerBound]
				annotation.title = "\(device)"

				if device.contains("iPhone") {
					annotation.image = #imageLiteral(resourceName: "iphone")
				} else if device.contains("iPad") {
					annotation.image = #imageLiteral(resourceName: "ipad")
				} else if device.contains("Apple TV") {
					annotation.image = #imageLiteral(resourceName: "apple_tv")
				} else if device.contains("MacBook") {
					annotation.image = #imageLiteral(resourceName: "macbook")
				} else {
					annotation.image = #imageLiteral(resourceName: "other_devices")
				}
			}

			if let latitude = session.location?.latitude, let longitude = session.location?.longitude {
				annotation.coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
			}

			mapView.addAnnotation(annotation)
		}

		locationManager.desiredAccuracy = kCLLocationAccuracyBest
		locationManager.requestWhenInUseAuthorization()
		locationManager.startUpdatingLocation()
	}

	/**
		Removes a session with the given session cell as data source.

		- Parameter otherSessionsCell: The session cell from which the data is fetched to decide which session to remove.
	*/
	private func removeSession(_ otherSessionsCell: OtherSessionsCell) {
		let alertView = SCLAlertView()
		alertView.addButton("Yes!", action: {
			let sessionSecret = otherSessionsCell.sessions?.id

			KService.shared.deleteSession(with: sessionSecret, withSuccess: { (success) in
				if success {
					// Get index path for cell
					if let indexPath = self.tableView.indexPath(for: otherSessionsCell) {
						// Start delete process
						self.tableView.beginUpdates()
						self.sessions?.otherSessions?.remove(at: indexPath.row)
						self.tableView.deleteRows(at: [indexPath], with: .left)
						self.tableView.endUpdates()
					}
				}
			})
		})

		alertView.showNotice("Confirm deletion", subTitle: "Are you sure you want to delete this session?", closeButtonTitle: "Maybe not now")
	}

	/**
		Removes session from the table view with the given notification object.

		- Parameter notification: The notification object from which the data is fetched to decide which session to remove.
	*/
	@objc func removeSessionFromTable(_ notification: NSNotification) {
		if let sessionID = notification.userInfo?["session_id"] as? Int {
			self.tableView.beginUpdates()
			let sessionIndex = self.sessions?.otherSessions?.firstIndex(where: { (json) -> Bool in
				return json.id == sessionID
			})

			if let sessionIndex = sessionIndex, sessionIndex != 0 {
				self.sessions?.otherSessions?.remove(at: sessionIndex)
				self.tableView.deleteRows(at: [IndexPath(row: 0, section: sessionIndex)], with: .left)
			}
			self.tableView.endUpdates()
		}
	}

	/**
		Adds a new session to the table view from the given notification object.

		- Parameter notification: the notification object from which a new notification cell is added to the table view.
	*/
	@objc func addSessionToTable(_ notification: NSNotification) {
		if let sessionID = notification.userInfo?["id"] as? Int, let device = notification.userInfo?["device"] as? String, let ip = notification.userInfo?["ip"] as? String, let lastValidated = notification.userInfo?["last_validated"] as? String {
			guard let sessionsCount = sessions?.otherSessions?.count else { return }
			let newSession: JSON = ["id": sessionID,
									"device": device,
									"ip": ip,
									"last_validated": lastValidated
			]

			if let newSessionElement = try? UserSessionsElement(json: newSession) {
				self.tableView.beginUpdates()
				self.sessions?.otherSessions?.append(newSessionElement)
				self.tableView.insertRows(at: [[1, sessionsCount]], with: .right)
				self.tableView.endUpdates()
			}
		}
	}
}

// MARK: - UITableViewDataSource
extension ManageActiveSessionsController {
	override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		if section == 0 {
			return "Current Session"
		} else {
			return "Other Sessions"
		}
	}

	override func numberOfSections(in tableView: UITableView) -> Int {
		return 2
	}

	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		if section == 0 {
			return 1
		} else {
			guard let sessionsCount = sessions?.otherSessions?.count else { return 1 }
			return sessionsCount
		}
	}

	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		if indexPath.section == 0 {
			let currentSessionCell = tableView.dequeueReusableCell(withIdentifier: "CurrentSessionCell", for: indexPath) as! CurrentSessionCell
			currentSessionCell.session = sessions?.currentSessions
			return currentSessionCell
		} else {
			let otherSessionsCount = sessions?.otherSessions?.count

			// No other sessions
			if otherSessionsCount == nil || otherSessionsCount == 0 {
				let noSessionsCell = self.tableView.dequeueReusableCell(withIdentifier: "NoSessionsCell", for: indexPath) as! NoSessionsCell
				return noSessionsCell
			}

			// Other sessions found
			let otherSessionsCell = tableView.dequeueReusableCell(withIdentifier: "OtherSessionsCell", for: indexPath) as! OtherSessionsCell

			otherSessionsCell.delegate = self
			otherSessionsCell.sessions = sessions?.otherSessions?[indexPath.row]

			return otherSessionsCell
		}
	}
}

// MARK: - OtherSessionsCellDelegate
extension ManageActiveSessionsController: OtherSessionsCellDelegate {
	func removeSession(for otherSessionsCell: OtherSessionsCell) {
		self.removeSession(otherSessionsCell)
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
}
