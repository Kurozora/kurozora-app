//
//  ImageAnnotation.swift
//  Kurozora
//
//  Created by Khoren Katklian on 08/06/2019.
//  Copyright © 2019 Kurozora. All rights reserved.
//

import UIKit
import MapKit

class ImageAnnotation: NSObject, MKAnnotation {
	var coordinate: CLLocationCoordinate2D
	var title: String?
	var subtitle: String?
	var image: UIImage?
	var colour: UIColor?

	override init() {
		self.coordinate = CLLocationCoordinate2D()
		self.title = nil
		self.subtitle = nil
		self.image = nil
		self.colour = UIColor.white
	}
}

class ImageAnnotationView: MKAnnotationView {
	private var imageView: UIImageView!

	override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
		super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)

		self.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
		self.imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
		self.addSubview(self.imageView)

		self.imageView.layer.cornerRadius = self.imageView.height / 2
		self.imageView.borderColor = .green
		self.imageView.borderWidth = 2
		self.imageView.layer.masksToBounds = true
	}

	override var image: UIImage? {
		get {
			return self.imageView.image
		}
		set {
			self.imageView.image = newValue
		}
	}

	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}
