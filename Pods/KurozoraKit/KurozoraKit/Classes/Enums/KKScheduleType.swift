//
//  KKScheduleType.swift
//  Pods
//
//  Created by Khoren Katklian on 23/11/2024.
//

/// The list of available scheule types.
///
/// - `shows`: the fetched schedule should be of the `shows` type.
/// - `literatures`: the fetched schedule should be of the `literatures` type.
/// - `games`: the fetched schedule should be of the `games` type.
///
/// - Tag: KKScheduleType
public enum KKScheduleType: Int, CaseIterable {
	/// Indicates the fetched schedule should be of the `shows` type.
	///
	/// - Tag: KKScheduleType-shows
	case shows = 0

	/// Indicates the fetched schedule should be of the `literatures` type.
	///
	/// - Tag: KKScheduleType-literatures
	case literatures = 1

	/// Indicates the fetched schedule should be of the `games` type.
	///
	/// - Tag: KKScheduleType-games
	case games = 2
}
