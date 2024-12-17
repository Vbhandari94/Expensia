//
//  IncomeCard.swift
//  SpendSense
//
//  Created by Varun Bhandari on 25/11/24.
//


//
//  IncomeCard.swift
//  SpendSense
//
//  Created by Varun Bhandari on 25/11/24.
//


//
//  IncomeCard.swift
//  SpendSense
//
//  Created by Varun Bhandari on 25/11/24.
//

import SwiftUI
import CoreData

struct IncomeCard: View {
    @ObservedObject var income: Income

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(income.desc ?? "")
                .font(.headline)
                .foregroundColor(.primary)

            // Convert income.amount from NSNumber? to Double before using specifier
            Text("Amount: ₹\((income.amount as? Double) ?? 0.0, specifier: "%.2f")")
                .font(.subheadline)
                .foregroundColor(.secondary)

            Text("Date: \(formattedDate(income.date ?? Date()))")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(
            LinearGradient(
                gradient: Gradient(colors: [Color("CardBackgroundColor"), Color("AccentColor").opacity(0.2)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
    }

    // Helper function to format date
    func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}

struct IncomeCard_Previews: PreviewProvider {
    static var previews: some View {
        let context = PersistenceController.shared.container.viewContext
        let testIncome = Income(context: context)
        testIncome.uuid = UUID()
        testIncome.date = Date()
        testIncome.amount = 5000.00
        testIncome.desc = "Salary"

        return IncomeCard(income: testIncome)
            .previewLayout(.sizeThatFits)
            .padding()
    }
}
