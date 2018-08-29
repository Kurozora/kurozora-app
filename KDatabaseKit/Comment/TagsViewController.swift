//
//  TagsViewController.swift
//  KDatabaseKit
//
//  Created by Khoren Katklian on 17/05/2018.
//  Copyright © 2018 Kusa. All rights reserved.
//

import Foundation
import KCommonKit
//import Bolts
//import Parse

//protocol TagsViewControllerDelegate: class {
//    func tagsViewControllerSelected(tags: [PFObject])
//}

public let AllThreadTagsPin = "Pin.ThreadTag"
public let PinnedThreadsPin = "Pin.PinnedThreads"

public class TagsViewController: UIViewController {
//
//    @IBOutlet weak var searchBar: UISearchBar!
//    @IBOutlet weak var collectionView: UICollectionView!
//    @IBOutlet weak var segmentedControl: UISegmentedControl!
//
//    weak var delegate: TagsViewControllerDelegate?
//    var dataSource: [PFObject] = []
//    var selectedDataSource: [PFObject] = []
//
//    var cachedGeneralTags: [ThreadTag] = []
//
//    override public func viewDidLoad() {
//        super.viewDidLoad()
//
//        let searchBarTextField = searchBar.value(forKey: "searchField") as? UITextField
//        searchBarTextField?.textColor = UIColor.black
//
//        guard let collectionView = collectionView,
//            let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout else {
//                return
//        }
//        let size = CGSize(width: view.bounds.size.width, height: 44)
//        layout.itemSize = size
//
//        let uiButton = searchBar.value(forKey: "cancelButton") as! UIButton
//        uiButton.setTitle("Done", for: UIControlState.normal)
//
//        fetchGeneralTags()
//        searchBar.enableCancelButton()
//    }
//
//    public override func viewWillDisappear(_ animated: Bool) {
//        super.viewWillDisappear(animated)
//        delegate?.tagsViewControllerSelected(tags: selectedDataSource)
//        view.endEditing(true)
//    }
//
//    func fetchGeneralTags() {
//        if cachedGeneralTags.count != 0 {
//            dataSource = cachedGeneralTags
//            collectionView.reloadData()
//            return
//        }
//
//        let query = ThreadTag.query()!
//
//        if !User.currentUser()!.isAdmin() {
//            query.whereKey("privateTag", equalTo: false)
//        }
//
//        query.whereKey("visible", equalTo: true)
//        query.orderByAscending("order")
//        query.findObjectsInBackground().continueWithExecutor(BFExecutor.mainThreadExecutor(),
//                                                             withSuccessBlock: { (task: BFTask!) -> AnyObject? in
//
//                                                                self.dataSource = task.result as! [ThreadTag]
//                                                                self.collectionView.reloadData()
//
//                                                                return nil
//        })
//    }
//
//    func fetchAnimeTags(text: String) {
//
//        let query = Anime.query()!
//        query.includeKey("details")
//        if text.count == 0 {
//            query.whereKey("startDate", greaterThanOrEqualTo: NSDate().dateByAddingTimeInterval(-3*30*24*60*60))
//            query.whereKey("status", equalTo: "currently airing")
//            query.orderByAscending("rank")
//        } else {
//            query.whereKey("title", matchesRegex: text, modifiers: "i")
//        }
//
//        query.limit = 100
//        query.findObjectsInBackgroundWithBlock { (result, error) -> Void in
//            if let _ = error {
//                // Show error
//            } else {
//                self.dataSource = result as! [Anime]
//                self.collectionView.reloadData()
//            }
//        }
//    }
//
//    // MARK: - IBAction
//
//    @IBAction func segmentedControlValueChanged(sender: AnyObject) {
//        dataSource = []
//        collectionView.reloadData()
//        let searchingGeneral = segmentedControl.selectedSegmentIndex == 0 ? true : false
//        if searchingGeneral {
//            fetchGeneralTags()
//        } else {
//            fetchAnimeTags(text: searchBar.text!)
//        }
//    }
//
//}
//
//extension TagsViewController: UICollectionViewDataSource {
//
//    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        return dataSource.count
//    }
//
//    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//
//        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TagCell", for: indexPath) as! BasicCollectionCell
//
//        let tag = dataSource[indexPath.row]
//
//        if let tag = tag as? ThreadTag {
//            cell.titleLabel.text = "#"+tag.name
//            cell.subtitleLabel.text = tag.detail ?? " "
//        } else if let anime = tag as? Anime {
//            cell.titleLabel.text = "#"+anime.title!
//            cell.subtitleLabel.text = anime.informationString()
//        }
//
//        if selectedDataSource.contains(tag) {
//            cell.backgroundColor = UIColor.backgroundDarker()
//        } else {
//            cell.backgroundColor = UIColor.backgroundWhite()
//        }
//
//        cell.layoutIfNeeded()
//
//        return cell
//    }
//}
//
//extension TagsViewController: UICollectionViewDelegate {
//
//    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        let tag = dataSource[indexPath.row]
//
//        if let index = selectedDataSource.indexOf(tag) {
//            selectedDataSource.removeAtIndex(index)
//        } else {
//            selectedDataSource.append(tag)
//        }
//        collectionView.reloadData()
//    }
//}
//
//extension TagsViewController: UISearchBarDelegate {
//
//    public func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
//        segmentedControl.selectedSegmentIndex = 1
//        fetchAnimeTags(text: searchBar.text!)
//        view.endEditing(true)
//        searchBar.enableCancelButton()
//    }
//
//    public func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
//        dismiss(animated: true, completion: nil)
//    }
//
//}
//
//extension TagsViewController: ModalTransitionScrollable {
//    public var transitionScrollView: UIScrollView? {
//        return collectionView
//    }
}
