//
//  KurozoraKit+Schedule.swift
//  Pods
//
//  Created by Khoren Katklian on 23/11/2024.
//

import TRON

extension KurozoraKit {
	/// Fetch the schedule for the specified type and date.
	///
	/// - Parameters:
	///    - type: The type of the schedule.
	///    - date: The date for which the schedule is fetched.
	///
	/// - Returns: An instance of `RequestSender` with the results of the get schedule list response.
	public func getSchedule(for type: KKScheduleType, in date: Date) -> RequestSender<ScheduleResponse, KKAPIError> {
		// Prepare headers
		var headers = self.headers
		if !self.authenticationKey.isEmpty {
			headers.add(.authorization(bearerToken: self.authenticationKey))
		}

		// Prepare parameters
		let dateFormatter = DateFormatter()
		dateFormatter.dateFormat = "yyyy-MM-dd"

		var parameters: [String: Any] = [
			"type": type.rawValue,
			"date": dateFormatter.string(from: date)
		]

		// Prepare request
		let scheduleIndex = KKEndpoint.Schedule.index.endpointValue
		let request: APIRequest<ScheduleResponse, KKAPIError> = tron.codable.request(scheduleIndex)
			.method(.get)
			.parameters(parameters)
			.headers(headers)

		// Send request
		return request.sender()
	}
}
