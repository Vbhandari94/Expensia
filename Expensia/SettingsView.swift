//
//  SettingsView.swift
//  SpendSense
//
//  Created by Varun Bhandari on 25/11/24.
//


//
//  SettingsView.swift
//  SpendSense
//
//  Created by Varun Bhandari on 25/11/24.
//
//
//  SettingsView.swift
//  SpendSense
//
//  Created by Varun Bhandari on 25/11/24.
//

//
//  SettingsView.swift
//  SpendSense
//
//  Created by Varun Bhandari on 25/11/24.
//

//
//  SettingsView.swift
//  SpendSense
//
//  Created by Varun Bhandari on 25/11/24.
//

import SwiftUI
import PDFKit

struct SettingsView: View {
    @AppStorage("isDarkMode") private var isDarkMode: Bool = false
    @EnvironmentObject var viewModel: ExpenseViewModel

    @State private var showMonthSelection = false
    @State private var selectedMonth: String?

    @State private var showAlert = false
    @State private var alertTitle = ""
    @State private var alertMessage = ""

    @State private var isAutoBackupEnabled = false // Local state for auto backup toggle
    // Track last successful backup time
    @State private var lastBackupTime: Date?

    var body: some View {
        ZStack {
            VStack(alignment: .leading, spacing: 20) {
                // Header
                Text("Settings")
                    .font(.largeTitle)
                    .bold()
                    .foregroundColor(Color("TextColor"))

                // Dark Mode Toggle
                Toggle(isOn: $isDarkMode) {
                    HStack {
                        Image(systemName: "moon.fill")
                            .foregroundColor(isDarkMode ? .yellow : .gray)
                        Text("Dark Mode")
                            .font(.headline)
                            .foregroundColor(Color("TextColor"))
                    }
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color("CardBackgroundColor"))
                )
                .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 5)

                // Auto Backup Toggle
                Toggle(isOn: $isAutoBackupEnabled) {
                    HStack {
                        Image(systemName: "arrow.clockwise")
                            .foregroundColor(isAutoBackupEnabled ? .green : .gray)
                        Text("Auto Backup")
                            .font(.headline)
                            .foregroundColor(Color("TextColor"))
                    }
                }
                .padding()
                .onChange(of: isAutoBackupEnabled) { newValue in
                    viewModel.setAutoBackupEnabled(newValue)
                    if newValue {
                        // Attempt a backup immediately when turned on
                        backupOnToggle()
                    }
                }
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color("CardBackgroundColor"))
                )
                .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 5)

                // Show last successful backup time if available
                if let lastTime = lastBackupTime {
                    Text("Last successful backup at \(formattedDateTime(lastTime))")
                        .font(.subheadline)
                        .foregroundColor(Color("TextColor"))
                        .padding(.horizontal)
                }

                // Export Expenses Button
                Button(action: {
                    showMonthSelection = true
                }) {
                    cardLabel(imageName: "square.and.arrow.up", text: "Export Expenses", imageColor: .blue)
                }

                Spacer()
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .padding()
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [Color("BackgroundColor"), Color("AccentColor").opacity(0.2)]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
            )
            .sheet(isPresented: $showMonthSelection) {
                MonthSelectionView(
                    months: monthKeys(),
                    onSelect: { month in
                        selectedMonth = month
                        showMonthSelection = false
                        if let monthToExport = selectedMonth {
                            exportExpensesToPDF(for: monthToExport)
                        }
                    }
                )
            }
            .alert(isPresented: $showAlert) {
                Alert(title: Text(alertTitle), message: Text(alertMessage), dismissButton: .default(Text("OK")))
            }
        }
        .onAppear {
            // Sync the toggle with the actual state from Core Data
            // Remove the '!= nil' comparison since isAutoBackupEnabled is now a Bool, not optional
            isAutoBackupEnabled = viewModel.appState.isAutoBackupEnabled
            lastBackupTime = viewModel.appState.lastBackupDate
        }
    }

    /// A helper view to create a card-style label for buttons
    private func cardLabel(imageName: String, text: String, imageColor: Color) -> some View {
        HStack {
            Image(systemName: imageName)
                .foregroundColor(imageColor)
            Text(text)
                .font(.headline)
                .foregroundColor(Color("TextColor"))
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color("CardBackgroundColor"))
        )
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 5)
    }

    /// Returns a sorted array of month keys from the grouped expenses.
    private func monthKeys() -> [String] {
        let groups = viewModel.groupedExpenses()
        let keys = groups.map { $0.monthKey }
        return keys.sorted { $0 < $1 }
    }

    /// Exports the expenses for the selected month to PDF and presents the share sheet.
    private func exportExpensesToPDF(for month: String) {
        let expensesForMonth = viewModel.expenses.filter { expense in
            let formatter = DateFormatter()
            formatter.dateFormat = "MMMM yyyy"
            return formatter.string(from: expense.date ?? Date()) == month
        }

        print("Selected month: \(month), Expenses count: \(expensesForMonth.count)")

        // Generate PDF data
        let pdfData = PDFGenerator.createExpenseReport(expenses: expensesForMonth)
        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent("ExpensesReport-\(month).pdf")

        do {
            // Write the PDF data to a file
            try pdfData.write(to: tempURL)
            let activityVC = UIActivityViewController(activityItems: [tempURL], applicationActivities: nil)

            // Present the share sheet
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let rootVC = windowScene.windows.first?.rootViewController {
                DispatchQueue.main.async {
                    rootVC.present(activityVC, animated: true, completion: nil)
                }
            } else {
                print("No valid root view controller found.")
            }
        } catch {
            print("Failed to write PDF data to file: \(error)")
        }
    }

    /// Attempt a backup immediately after enabling auto backup
    private func backupOnToggle() {
        viewModel.backupDataToCloudKit { result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    // On success, update lastBackupTime
                    let current = Date()
                    viewModel.appState.lastBackupDate = current
                    viewModel.saveContext()
                    self.lastBackupTime = current
                case .failure(let error):
                    self.alertTitle = "Backup Failed"
                    self.alertMessage = "An error occurred while backing up: \(error.localizedDescription)"
                    self.showAlert = true
                }
            }
        }
    }

    private func formattedDateTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

struct MonthSelectionView: View {
    let months: [String]
    let onSelect: (String) -> Void

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 16) {
                    ForEach(months, id: \.self) { month in
                        Button(action: {
                            onSelect(month)
                        }) {
                            Text(month)
                                .font(.headline)
                                .foregroundColor(Color("TextColor"))
                                .frame(maxWidth: .infinity, minHeight: 50)
                                .padding()
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color("CardBackgroundColor"))
                                        .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
                                )
                                .padding(.horizontal)
                        }
                    }
                    .padding(.vertical)
                }
            }
            .navigationTitle("Select Month")
            .navigationBarTitleDisplayMode(.inline)
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [Color("BackgroundColor"), Color("AccentColor").opacity(0.1)]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
            )
        }
    }
}

// MARK: - Preview
struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        let viewModel = ExpenseViewModel()
        return NavigationStack {
            SettingsView()
                .environmentObject(viewModel)
        }
    }
}
