//
//  ShowDetailCell.swift
//  Kurozora
//
//  Created by Khoren Katklian on 13/08/2018.
//  Copyright © 2018 Kurozora. All rights reserved.
//

import UIKit

class ShowDetailCell: UITableViewCell {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var detailLabel: UILabel!
}

//import UIKit
//
//class ShowDetailCell: BaseCell {
//
//    var showDetails: Show? {
//        didSet {
//            guard let showDetails = showDetails else { return }
//            configure(showDetails)
//        }
//    }
//
//    private let view: UIView = {
//        let v = UIView()
//        v.backgroundColor = .clear
//        return v
//    }()
//
//    private let informationLabel: UILabel = {
//        let il = UILabel()
//        il.text = "Information"
//        il.textColor = .white
//        il.font = UIFont.systemFont(ofSize: 18, weight: .medium)
//        return il
//    }()
//
//    private let typeLabel: UILabel = {
//        let tl = UILabel()
//        tl.textColor = .white
//        tl.font = UIFont.systemFont(ofSize: 13)
//        return tl
//    }()
//
//    private let episodesLabel: UILabel = {
//        let el = UILabel()
//        el.textColor = .white
//        el.font = UIFont.systemFont(ofSize: 13)
//        return el
//    }()
//
//    private let statusLabel: UILabel = {
//        let sl = UILabel()
//        sl.textColor = .white
//        sl.font = UIFont.systemFont(ofSize: 13)
//        return sl
//    }()
//
//    private let airedLabel: UILabel = {
//        let al = UILabel()
//        al.textColor = .white
//        al.font = UIFont.systemFont(ofSize: 13)
//        return al
//    }()
//
//    private let genreLabel: UILabel = {
//        let gl = UILabel()
//        gl.textColor = .white
//        gl.font = UIFont.systemFont(ofSize: 13)
//        return gl
//    }()
//
//    let runtimeLabel: UILabel = {
//        let rl = UILabel()
//        rl.textColor = .white
//        rl.font = UIFont.systemFont(ofSize: 13)
//        return rl
//    }()
//
//    let ratingLabel: UILabel = {
//        let rl = UILabel()
//        rl.textColor = .white
//        rl.font = UIFont.systemFont(ofSize: 13)
//        return rl
//    }()
//
//    private let synopsisLabel: UILabel = {
//        let il = UILabel()
//        il.text = "Synopsis"
//        il.textColor = .white
//        il.font = UIFont.systemFont(ofSize: 18, weight: .medium)
//        return il
//    }()
//
//    private let synopsisDetailLabel: UILabel = {
//        let sdl = UILabel()
//        sdl.numberOfLines = 0
//        sdl.textColor = .white
//        sdl.font = UIFont.systemFont(ofSize: 13)
//        return sdl
//    }()
//
//    private let dividerLineView: UIView = {
//        let view = UIView()
//        view.backgroundColor = UIColor(white: 0.4, alpha: 0.6)
//        return view
//    }()
//
//    override func setupViews() {
//        super.setupViews()
//
//        synopsisDetailLabel.setContentCompressionResistancePriority(UILayoutPriority(rawValue: 751), for: .horizontal)
//        synopsisDetailLabel.setContentCompressionResistancePriority(UILayoutPriority(rawValue: 751), for: .vertical)
//
//        // Prepare auto layout
//        view.translatesAutoresizingMaskIntoConstraints = false
//        informationLabel.translatesAutoresizingMaskIntoConstraints = false
//        typeLabel.translatesAutoresizingMaskIntoConstraints = false
//        episodesLabel.translatesAutoresizingMaskIntoConstraints = false
//        statusLabel.translatesAutoresizingMaskIntoConstraints = false
//        airedLabel.translatesAutoresizingMaskIntoConstraints = false
//        genreLabel.translatesAutoresizingMaskIntoConstraints = false
//        runtimeLabel.translatesAutoresizingMaskIntoConstraints = false
//        ratingLabel.translatesAutoresizingMaskIntoConstraints = false
//        dividerLineView.translatesAutoresizingMaskIntoConstraints = false
//        synopsisLabel.translatesAutoresizingMaskIntoConstraints = false
//        synopsisDetailLabel.translatesAutoresizingMaskIntoConstraints = false
//
//        // Add them to the view
//        addSubview(view)
//        addSubview(informationLabel)
//        addSubview(typeLabel)
//        addSubview(episodesLabel)
//        addSubview(statusLabel)
//        addSubview(airedLabel)
//        addSubview(genreLabel)
//        addSubview(runtimeLabel)
//        addSubview(ratingLabel)
//        addSubview(dividerLineView)
//        addSubview(synopsisLabel)
//        addSubview(synopsisDetailLabel)
//
//        // Information label constraint
//        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[view]|", options: NSLayoutFormatOptions(), metrics: nil, views: ["view": view]))
//        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[view]|", options: NSLayoutFormatOptions(), metrics: nil, views: ["view": view]))
//
//        // Information label constraint
//        addConstraint(NSLayoutConstraint(item: informationLabel, attribute: .leading, relatedBy: .equal, toItem: view, attribute: .leading, multiplier: 1.0, constant: 15))
//
//        addConstraint(NSLayoutConstraint(item: informationLabel, attribute: .top, relatedBy: .equal, toItem: view, attribute: .top, multiplier: 1.0, constant: 0))
//
//
//        // Type label constraint
//        addConstraint(NSLayoutConstraint(item: typeLabel, attribute: .leading, relatedBy: .equal, toItem: informationLabel, attribute: .leading, multiplier: 1.0, constant: 0))
//
//        addConstraint(NSLayoutConstraint(item: typeLabel, attribute: .top, relatedBy: .equal, toItem: informationLabel, attribute: .bottom, multiplier: 1.0, constant: 8))
//
//        // Episodes label constraint
//        addConstraint(NSLayoutConstraint(item: episodesLabel, attribute: .leading, relatedBy: .equal, toItem: typeLabel, attribute: .leading, multiplier: 1.0, constant: 0))
//
//        addConstraint(NSLayoutConstraint(item: episodesLabel, attribute: .top, relatedBy: .equal, toItem: typeLabel, attribute: .bottom, multiplier: 1.0, constant: 4))
//
//        // Status label constraint
//        addConstraint(NSLayoutConstraint(item: statusLabel, attribute: .leading, relatedBy: .equal, toItem: episodesLabel, attribute: .leading, multiplier: 1.0, constant: 0))
//
//        addConstraint(NSLayoutConstraint(item: statusLabel, attribute: .top, relatedBy: .equal, toItem: episodesLabel, attribute: .bottom, multiplier: 1.0, constant: 4))
//
//        // Aired label constraint
//        addConstraint(NSLayoutConstraint(item: airedLabel, attribute: .leading, relatedBy: .equal, toItem: statusLabel, attribute: .leading, multiplier: 1.0, constant: 0))
//
//        addConstraint(NSLayoutConstraint(item: airedLabel, attribute: .top, relatedBy: .equal, toItem: statusLabel, attribute: .bottom, multiplier: 1.0, constant: 4))
//
//        // Genres label constraint
//        addConstraint(NSLayoutConstraint(item: genreLabel, attribute: .leading, relatedBy: .equal, toItem: airedLabel, attribute: .leading, multiplier: 1.0, constant: 0))
//
//        addConstraint(NSLayoutConstraint(item: genreLabel, attribute: .top, relatedBy: .equal, toItem: airedLabel, attribute: .bottom, multiplier: 1.0, constant: 4))
//
//        // Runtime label constraint
//        addConstraint(NSLayoutConstraint(item: runtimeLabel, attribute: .leading, relatedBy: .equal, toItem: genreLabel, attribute: .leading, multiplier: 1.0, constant: 0))
//
//        addConstraint(NSLayoutConstraint(item: runtimeLabel, attribute: .top, relatedBy: .equal, toItem: genreLabel, attribute: .bottom, multiplier: 1.0, constant: 4))
//
//        // Rating label constraint
//        addConstraint(NSLayoutConstraint(item: ratingLabel, attribute: .leading, relatedBy: .equal, toItem: runtimeLabel, attribute: .leading, multiplier: 1.0, constant: 0))
//
//        addConstraint(NSLayoutConstraint(item: ratingLabel, attribute: .top, relatedBy: .equal, toItem: runtimeLabel, attribute: .bottom, multiplier: 1.0, constant: 4))
//
//        // Synopsis header label constraint
//        addConstraint(NSLayoutConstraint(item: synopsisLabel, attribute: .leading, relatedBy: .equal, toItem: ratingLabel, attribute: .leading, multiplier: 1.0, constant: 0))
//
//        addConstraint(NSLayoutConstraint(item: synopsisLabel, attribute: .top, relatedBy: .equal, toItem: ratingLabel, attribute: .bottom, multiplier: 1.0, constant: 8))
//
//        // Synopsis detail label
//        addConstraint(NSLayoutConstraint(item: synopsisDetailLabel, attribute: .leading, relatedBy: .equal, toItem: synopsisLabel, attribute: .leading, multiplier: 1.0, constant: 0))
//        addConstraint(NSLayoutConstraint(item: view, attribute: .trailing, relatedBy: .equal, toItem: synopsisDetailLabel, attribute: .trailing, multiplier: 1.0, constant: 15))
//
//        addConstraint(NSLayoutConstraint(item: synopsisDetailLabel, attribute: .top, relatedBy: .equal, toItem: synopsisLabel, attribute: .bottom, multiplier: 1.0, constant: 4))
//
//
//    }
//
//    private func configure(_ show: Show?) {
//
//        // Configure type label
//        if let type = show?.type {
//            typeLabel.text = "Type: " + type
//        } else {
//            typeLabel.text = "Type: Unknown"
//        }
//
//        // Configure episodes label
//        if let episodes = show?.episodes {
//            episodesLabel.text = "Episodes: " + String(episodes)
//        } else {
//            episodesLabel.text = "Episodes: 0"
//        }
//
//        // Configure status label
//        if let status = show?.status {
//            statusLabel.text = "Status: " + status
//        } else {
//            statusLabel.text = "Status: Unknown"
//        }
//
//        // Configure aired label
//        if let aired = show?.aired {
//            airedLabel.text = "Aired: " + aired
//        } else {
//            airedLabel.text = "Aired: Unknown"
//        }
//
//        // Configure genre label
//        if let genre = show?.genre {
//            genreLabel.text = "Genre: " + genre
//        } else {
//            genreLabel.text = "Genre: Unkown"
//        }
//
//        // Configure runtime label
//        if let runtime = show?.runtime {
//            runtimeLabel.text = "Duration: " + String(runtime)
//        } else {
//            runtimeLabel.text = "Duration: 0"
//        }
//
//        // Configure rating label
//        if let rating = show?.watchRating {
//            ratingLabel.text = "Rating: " + rating
//        } else {
//            ratingLabel.text = "Rating: Unknown"
//        }
//
//        // Synopsis detail label
//        if let synopsis = show?.synopsis {
//            synopsisDetailLabel.text = synopsis
//        } else {
//            synopsisDetailLabel.text = "No synopsis added yet..."
//        }
//    }
//
//}
//
//extension UIView {
//
//    func addConstraintsWithFormat(format: String, views: UIView...) {
//        var viewsDictionary = [String: UIView]()
//        for (index, view) in views.enumerated() {
//            let key = "v\(index)"
//            viewsDictionary[key] = view
//            view.translatesAutoresizingMaskIntoConstraints = false
//        }
//        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: format, options: NSLayoutFormatOptions(), metrics: nil, views: viewsDictionary))
//    }
//}
