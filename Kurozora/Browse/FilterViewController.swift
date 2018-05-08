//
//  FilterViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 25/04/2018.
//  Copyright © 2018 Kusa. All rights reserved.
//

import KCommonKit
//import ANParseKit

enum FilterSection: String {
    case View = "View"
    case Sort = "Sort"
    case FilterTitle = "Filter"
    case AnimeType = "Type"
    case Year = "Year"
    case Status = "Status"
    case Studio = "Studio"
    case Classification = "Classification"
    case Genres = "Genres"
    
}

enum SortType: String {
    case Rating = "Rating"
    case Popularity = "Popularity"
    case Title = "Title"
    case NextAiringEpisode = "Next Episode to Air"
    case NextEpisodeToWatch = "Next Episode to Watch"
    case Newest = "Newest"
    case Oldest = "Oldest"
    case None = "None"
    case MyRating = "My Rating"
}

enum LayoutType: String {
    case Chart = "Chart"
    case SeasonalChart = "SeasonalChart"
}

typealias Configuration = [(section: FilterSection, value: String?, dataSource: [String])]

//protocol FilterViewControllerDelegate: class {
//    func finishedWith(configuration configuration: Configuration, selectedGenres: [String])
//}

class FilterViewController: UIViewController {
    
//    let sectionHeaderHeight: CGFloat = 44
//
//    @IBOutlet weak var collectionView: UICollectionView!
//
//    weak var delegate: FilterViewControllerDelegate?
//
//    var expandedSection: Int?
//    var selectedGenres: [String] = []
//    var filteredDataSource: [[String]] = []
//    var sectionsDataSource: Configuration = []
//
//    var filteringSomething: Bool {
//        get {
//            for (section, value, _) in sectionsDataSource where section != .View && section != .Sort && section != .FilterTitle && value != nil {
//                return true
//            }
//            return false
//        }
//    }
//
//    func initWith(configuration configuration: Configuration, selectedGenres: [String]? = []) {
//        sectionsDataSource = configuration
//        self.selectedGenres = selectedGenres!
//        for (_, _, _) in sectionsDataSource {
//            filteredDataSource.append([])
//        }
//    }
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//    }
//
//    @IBAction func dimissViewControllerPressed(sender: AnyObject) {
//        dismiss(animated: true, completion: nil)
//    }
//    @IBAction func applyFilterPressed(sender: AnyObject) {
//
//        if let _ = InAppController.hasAnyPro() {
//            delegate?.finishedWith(configuration: sectionsDataSource, selectedGenres: selectedGenres)
//            dismiss(animated: true, completion: nil)
//        } else {
//            InAppPurchaseViewController.showInAppPurchaseWith(self)
//        }
//
//    }
}

//extension FilterViewController: UICollectionViewDataSource {
//
//    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
//        return filteredDataSource.count
//    }
//
//    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        return filteredDataSource[section].count
//    }
//
//    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("BasicCollectionCell", forIndexPath: indexPath) as! BasicCollectionCell
//
//        let (filterSection, sectionValue, _) = sectionsDataSource[indexPath.section]
//        let value = filteredDataSource[indexPath.section][indexPath.row]
//
//        cell.titleLabel.text = value
//
//        if filterSection == FilterSection.Genres {
//            if let _ = selectedGenres.indexOf(value) {
//                cell.backgroundColor = UIColor.backgroundEvenDarker()
//            } else {
//                cell.backgroundColor = UIColor.backgroundDarker()
//            }
//        } else if let sectionValue = sectionValue, sectionValue == value {
//            cell.backgroundColor = UIColor.backgroundEvenDarker()
//        } else {
//            cell.backgroundColor = UIColor.backgroundDarker()
//        }
//
//        return cell
//    }
//
//    func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
//
//        var reusableView: UICollectionReusableView!
//
//        if kind == UICollectionElementKindSectionHeader {
//
//            let headerView = collectionView.dequeueReusableSupplementaryViewOfKind(UICollectionElementKindSectionHeader, withReuseIdentifier: "HeaderView", forIndexPath: indexPath) as! BasicCollectionReusableView
//
//            let (filterSection, value, _) = sectionsDataSource[indexPath.section]
//
//            headerView.titleImageView.image = nil
//            headerView.titleLabel.text = filterSection.rawValue
//            headerView.delegate = self
//            headerView.section = indexPath.section
//
//
//            // Image
//            switch filterSection {
//            case .View:
//                if let image = UIImage(named: "icon-view") {
//                    headerView.titleImageView.image = image.imageWithRenderingMode(.AlwaysTemplate)
//                }
//            case .Sort:
//                if let image = UIImage(named: "icon-sort") {
//                    headerView.titleImageView.image = image.imageWithRenderingMode(.AlwaysTemplate)
//                }
//            case .FilterTitle:
//                if let image = UIImage(named: "icon-filter") {
//                    headerView.titleImageView.image = image.imageWithRenderingMode(.AlwaysTemplate)
//                }
//            default:
//                break
//            }
//
//            // Value
//            switch filterSection {
//            case .View: fallthrough
//            case .Sort:
//                if let value = value {
//                    headerView.subtitleLabel.text = value + " " + FontAwesome.AngleDown.rawValue
//                }
//            case .FilterTitle:
//                headerView.subtitleLabel.text = filteringSomething ? "Clear all" : ""
//            case .AnimeType: fallthrough
//            case .Year: fallthrough
//            case .Status: fallthrough
//            case .Studio: fallthrough
//            case .Classification: fallthrough
//            case .Genres:
//                if let value = value {
//                    headerView.subtitleLabel.text = value + " " + FontAwesome.TimesCircle.rawValue
//                } else {
//                    headerView.subtitleLabel.text = FontAwesome.AngleDown.rawValue
//                }
//            }
//
//            reusableView = headerView;
//        }
//
//        return reusableView
//    }
//
//    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
//
//        return CGSize(width: view.bounds.size.width, height: sectionHeaderHeight)
//    }
//}

//extension FilterViewController: UICollectionViewDelegate {
//    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        
//        let (filterSection, _, _) = sectionsDataSource[indexPath.section]
//        let string = filteredDataSource[indexPath.section][indexPath.row]
//        
//        switch filterSection {
//        case .View: fallthrough
//        case .Sort: fallthrough
//        case .AnimeType: fallthrough
//        case .Status: fallthrough
//        case .Classification: fallthrough
//        case .Studio: fallthrough
//        case .Year:
//            sectionsDataSource[indexPath.section].value = string
//            filteredDataSource[indexPath.section] = []
//            expandedSection = nil
//            collectionView.reloadData()
//        case .Genres:
//            if let index = selectedGenres.indexOf(string) {
//                selectedGenres.removeAtIndex(index)
//            } else {
//                selectedGenres.append(string)
//            }
//            sectionsDataSource[indexPath.section].value = selectedGenres.count != 0 ? "\(selectedGenres.count) genres" : nil
//            collectionView.reloadData()
//        case .FilterTitle: break
//        }
//        
//        
//    }
//}

//extension FilterViewController: UICollectionViewDelegateFlowLayout {
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//
//        let (filterSection, _, _) = sectionsDataSource[indexPath.section]
//
//        switch filterSection {
//        case .View: fallthrough
//        case .Sort: fallthrough
//        case .FilterTitle: fallthrough
//        case .AnimeType: fallthrough
//        case .Status: fallthrough
//        case .Classification:
//            return CGSize(width: (view.bounds.size.width-23), height: sectionHeaderHeight)
//        case .Studio:
//            return CGSize(width: (view.bounds.size.width-23-1)/2, height: sectionHeaderHeight)
//        case .Year:
//            return CGSize(width: (view.bounds.size.width-23-4)/5, height: sectionHeaderHeight)
//        case .Genres:
//            return CGSize(width: (view.bounds.size.width-23-2)/3, height: sectionHeaderHeight)
//        }
//    }
//}


//extension FilterViewController: BasicCollectionReusableViewDelegate {
//    func headerSelectedActionButton(cell: BasicCollectionReusableView) {
//
//        let section = cell.section!
//        let filterSection = sectionsDataSource[section].section
//
//        if filterSection == .FilterTitle {
//            // Do nothing
//            return;
//        }
//
//        if let expandedSection = expandedSection {
//            filteredDataSource[expandedSection] = []
//        }
//
//        if section != expandedSection {
//            expandedSection = section
//            filteredDataSource[section] = sectionsDataSource[section].dataSource
//        } else {
//            expandedSection = nil
//        }
//
//        collectionView.reloadData()
//    }
//
//    func headerSelectedActionButton2(cell: BasicCollectionReusableView) {
//        let section = cell.section!
//        let filterSection = sectionsDataSource[section].section
//        switch filterSection {
//        case .View: fallthrough
//        case .Sort:
//            // Show down-down
//            headerSelectedActionButton(cell)
//        case .FilterTitle:
//            // Clear all filters
//            let firstFilterIndex = section+1
//            let lastFilterIndex = sectionsDataSource.count - 1
//            for index in firstFilterIndex...lastFilterIndex {
//                sectionsDataSource[index].value = nil
//            }
//            selectedGenres.removeAll(keepingCapacity: false)
//            expandedSection = nil
//            collectionView.reloadData()
//            return
//        case .AnimeType: fallthrough
//        case .Year: fallthrough
//        case .Status: fallthrough
//        case .Studio: fallthrough
//        case .Classification: fallthrough
//        case .Genres:
//            // Clear a filter or open drop-down
//            if let _ = sectionsDataSource[section].value {
//                if filterSection == .Genres {
//                    selectedGenres.removeAll(keepingCapacity: false)
//                }
//
//                sectionsDataSource[section].value = nil
//                collectionView.reloadData()
//            } else {
//                headerSelectedActionButton(cell)
//            }
//        }
//
//    }
//}

//extension FilterViewController: UINavigationBarDelegate {
//    func positionForBar(bar: UIBarPositioning) -> UIBarPosition {
//        return UIBarPosition.topAttached
//    }
//}
//
//extension FilterViewController: ModalTransitionScrollable {
//    var transitionScrollView: UIScrollView? {
//        return collectionView
//    }
//}
