//
//  KKSearchFilter.swift
//  KurozoraKit
//
//  Created by Khoren Katklian on 26/04/2023.
//

public enum KKSearchFilter {
	case appTheme(_ filter: AppThemeFilter)
	case character(_ filter: CharacterFilter)
	case episode(_ filter: EpisodeFilter)
	case game(_ filter: GameFilter)
	case literature(_ filter: LiteratureFilter)
	case person(_ filter: PersonFilter)
	case show(_ filter: ShowFilter)
	case song(_ filter: SongFilter)
	case studio(_ filter: StudioFilter)
	case user(_ filter: UserFilter)
}
