//
//  CharactersViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 09/05/2018.
//  Copyright © 2018 Kurozora. All rights reserved.
//

import KCommonKit

enum CharacterSection: Int {
    case Character = 0
    case Cast
    
    static var allSections: [CharacterSection] = [.Character,.Cast]
}

public class CharactersViewController: AnimeBaseViewController {
//    
//    let HeaderCellHeight: CGFloat = 39
//
//    public override func viewDidLoad() {
//        super.viewDidLoad()
//        tableView.estimatedRowHeight = 150.0
//        tableView.rowHeight = UITableViewAutomaticDimension
//
//        fetchCharactersAndStaff()
//    }
//    
//    func fetchCharactersAndStaff() {
//        let characters = anime.characters.fetchIfNeededInBackground()
//        let cast = anime.cast.fetchIfNeededInBackground()
//        
//        BFTask(forCompletionOfAllTasksWithResults: [characters, cast]).continueWithExecutor(BFExecutor.mainThreadExecutor(), withSuccessBlock: { (task) -> AnyObject? in
//            self.tableView.reloadData()
//            return nil
//        })
//    }
//}
//
//
//extension CharactersViewController: UITableViewDataSource {
//    func numberOfSections(in tableView: UITableView) -> Int {
//        return anime.characters.dataAvailable ? CharacterSection.allSections.count : 0
//    }
//    
//    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        
//        var numberOfRows = 0
//        switch CharacterSection(rawValue: section)! {
//        case .Character: numberOfRows = anime.characters.dataAvailable ? anime.characters.characters.count : 0
//        case .Cast: numberOfRows = anime.cast.dataAvailable ? anime.cast.cast.count : 0
//        }
//        
//        return numberOfRows
//    }
//    
//    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        
//        switch CharacterSection(rawValue: indexPath.section)! {
//        case .Character:
//            let cell = tableView.dequeueReusableCell(withIdentifier: "CharacterCell") as! CharacterCell
//            
//            let character = anime.characters.characterAtIndex(indexPath.row)
//            
//            cell.characterImageView.setImageFrom(urlString: character.image, animated:true)
//            cell.characterName.text = character.name
//            cell.characterRole.text = character.role
//            if let japaneseVoiceActor = character.japaneseActor {
//                cell.personImageView.setImageFrom(urlString: japaneseVoiceActor.image, animated:true)
//                cell.personName.text = japaneseVoiceActor.name
//                cell.personJob.text = japaneseVoiceActor.job
//            } else {
//                cell.personImageView.image = nil
//                cell.personName.text = ""
//                cell.personJob.text = ""
//            }
//            
//            cell.layoutIfNeeded()
//            return cell
//        case .Cast:
//            let cell = tableView.dequeueReusableCell(withIdentifier: "CastCell") as! CharacterCell
//            
//            let cast = anime.cast.castAtIndex(indexPath.row)
//            
//            cell.personImageView.setImageFrom(urlString: cast.image)
//            cell.personName.text = cast.name
//            cell.personJob.text = cast.job
//            cell.layoutIfNeeded()
//            return cell
//        }
//        
//    }
//    
//    public func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
//        let cell = tableView.dequeueReusableCell(withIdentifier: "TitleCell") as! TitleCell
//        var title = ""
//        
//        switch CharacterSection(rawValue: section)! {
//        case .Character:
//            title = "Characters"
//        case .Cast:
//            title = "Cast"
//        }
//        
//        cell.titleLabel.text = title
//        return cell.contentView
//    }
//    
//    public func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
//        return self.tableView(tableView, numberOfRowsInSection: section) > 0 ? HeaderCellHeight : 0
//    }
//}
//
//extension CharactersViewController: UITableViewDelegate {
//    
}
