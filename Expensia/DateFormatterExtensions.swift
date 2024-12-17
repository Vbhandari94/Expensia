//
//  DateFormatterExtensions.swift.swift
//  SpendSense
//
//  Created by Varun Bhandari on 26/11/24.
//

import Foundation

extension DateFormatter {
    static var monthAndYearFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM yyyy" // Example: "Dec 2024"
        return formatter
    }
}
