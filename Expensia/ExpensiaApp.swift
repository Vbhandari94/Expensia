//
//  ExpensiaApp.swift
//  Expensia
//
//  Created by Varun Bhandari on 17/12/24.
//

import SwiftUI

@main
struct ExpensiaApp: App {
    @StateObject private var viewModel = ExpenseViewModel()
    let persistenceController = PersistenceController.shared

    
    // Observe the Dark Mode preference
    @AppStorage("isDarkMode") private var isDarkMode: Bool = false
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(viewModel) // Inject ExpenseViewModel
                .preferredColorScheme(isDarkMode ? .dark : .light) // Apply color scheme
        }
    }
}
