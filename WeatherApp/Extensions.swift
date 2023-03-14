//
//  Extensions.swift
//  WeatherApp
//
//  Created by Nisarg Mehta on 3/12/23.
//

import Foundation

extension DateFormatter {
    static let dayWithDateAndTime: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE, MMM d, h:mm a"
        formatter.calendar = Calendar(identifier: .iso8601)
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter
    }()
}
