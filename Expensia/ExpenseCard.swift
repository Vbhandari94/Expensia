//
//  ExpenseCard.swift
//  SpendSense
//
//  Created by Varun Bhandari on 24/11/24.
//


//
//  ExpenseCard.swift
//  SpendSense
//
//  Created by Varun Bhandari on 24/11/24.
//
import SwiftUI
import CoreData

struct ExpenseCard: View {
    @ObservedObject var expense: Expense

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(expense.desc ?? "")
                .font(.headline)
                .foregroundColor(.primary)

            Text(expense.category ?? "")
                .font(.subheadline)
                .foregroundColor(.secondary)

            HStack {
                Spacer()
                if let val = expense.amount?.doubleValue, val != 0.0 {
                    Text("₹\(val, specifier: "%.2f")")
                        .font(.headline)
                        .foregroundColor(.primary)
                } else {
                    // Show empty text if amount is nil or equals 0.0
                    Text("")
                        .font(.headline)
                        .foregroundColor(.primary)
                }
            }
        }
        .padding()
        .background(
            LinearGradient(
                gradient: Gradient(colors: [Color("CardBackgroundColor"), Color("AccentColor").opacity(0.2)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .cornerRadius(10)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}

struct ExpenseCard_Previews: PreviewProvider {
    static var previews: some View {
        // Create a test expense for the preview
        let context = PersistenceController.shared.container.viewContext
        let testExpense = Expense(context: context)
        testExpense.uuid = UUID()
        testExpense.date = Date()
        testExpense.amount = 0 // Test with zero to ensure it shows empty
        testExpense.category = "Food & Beverages"
        testExpense.desc = "Dinner at a restaurant"

        return ExpenseCard(expense: testExpense)
            .environment(\.managedObjectContext, context)
            .previewLayout(.sizeThatFits)
            .padding()
    }
}
