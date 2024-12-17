//
//  ValidationError.swift
//  Expensia
//
//  Created by Varun Bhandari on 17/12/24.
//

import SwiftUI
import CoreData

enum ValidationError: Error, LocalizedError {
    case invalidAmount
    case emptyDescription
    case emptyCategory
    case invalidInput // New case added here

    var errorDescription: String? {
        switch self {
        case .invalidAmount:
            return "Amount must be greater than zero."
        case .emptyDescription:
            return "Description cannot be empty."
        case .emptyCategory:
            return "Category cannot be empty."
        case .invalidInput:
            return "The input provided is invalid."
        }
    }
}
