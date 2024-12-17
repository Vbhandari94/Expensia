//
//  AlertManager.swift
//  Expensia
//
//  Created by Varun Bhandari on 17/12/24.
//


import SwiftUI

final class AlertManager: ObservableObject {
    @Published var showAlert: Bool = false
    @Published var alertMessage: String = ""

    func triggerAlert(message: String) {
        alertMessage = message
        showAlert = true
    }
}
