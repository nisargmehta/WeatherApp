//
//  Extensions.swift
//  WeatherApp
//
//  Created by Nisarg Mehta on 3/12/23.
//

import Foundation
import UIKit

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

extension UIViewController {
    func showAlert(title: String = "",
                   message: String) {
        let alert = UIAlertController(
            title: title,
            message: message,
            preferredStyle: .alert
        )
        let dismissAction = UIAlertAction(
            title: NSLocalizedString("Ok", comment: "ok"),
            style: .default,
            handler: nil
        )
        alert.addAction(dismissAction)
        self.present(alert, animated: true, completion: nil)
    }
}
