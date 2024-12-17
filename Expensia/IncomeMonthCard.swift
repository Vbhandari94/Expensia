//
//  IncomeMonthCard.swift
//  SpendSense
//
//  Created by Varun Bhandari on 25/11/24.
//


//
//  IncomeMonthCard.swift
//  SpendSense
//
//  Created by Varun Bhandari on 25/11/24.
//

import SwiftUI

struct IncomeMonthCard: View {
    @EnvironmentObject var viewModel: ExpenseViewModel
    let month: String
    
    private var totalIncomeForMonth: Double {
        let formatter = DateFormatter()
        formatter.dateFormat = "LLLL yyyy"
        let monthIncomes = viewModel.incomes.filter { income in
            formatter.string(from: income.date ?? Date()) == month
        }
        return monthIncomes.reduce(0) { $0 + ($1.amount?.doubleValue ?? 0.0) }
    }
    
    private var totalExpensesForMonth: Double {
        let formatter = DateFormatter()
        formatter.dateFormat = "LLLL yyyy"
        let monthExpenses = viewModel.expenses.filter { expense in
            formatter.string(from: expense.date ?? Date()) == month
        }
        return monthExpenses.reduce(0) { $0 + ($1.amount?.doubleValue ?? 0.0) }
    }
    
    private var netTotalForMonth: Double {
        totalIncomeForMonth - totalExpensesForMonth
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(month)
                .font(.headline)
                .foregroundColor(.primary)
            
            // Display net total = Total Income - Total Expenses
            Text("Total Income: ₹\(netTotalForMonth, specifier: "%.2f")")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [Color("BackgroundColor"), Color("AccentColor").opacity(0.2)]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
        )
        .cornerRadius(10)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}
    // MARK: - Preview
#if DEBUG
    struct IncomeMonthCard_Previews: PreviewProvider {
        static var previews: some View {
            let context = PersistenceController.shared.container.viewContext
            let viewModel = ExpenseViewModel(context: context)
            
            let formatter = DateFormatter()
            formatter.dateFormat = "LLLL yyyy"
            let sampleDate = formatter.date(from: "January 2024") ?? Date()
            
            // Create Core Data Income objects
            let income1 = Income(context: context)
            income1.uuid = UUID()
            income1.date = sampleDate
            income1.amount = NSNumber(value: 2000.00)
            income1.desc = "Salary"
            
            let income2 = Income(context: context)
            income2.uuid = UUID()
            income2.date = sampleDate
            income2.amount = NSNumber(value: 500.00)
            income2.desc = "Bonus"
            
            viewModel.incomes = [income1, income2]
            
            // Create Core Data Expense objects
            let expense1 = Expense(context: context)
            expense1.uuid = UUID()
            expense1.date = sampleDate
            expense1.amount = NSNumber(value: 300.00)
            expense1.category = "Groceries"
            expense1.desc = "Monthly groceries"
            
            let expense2 = Expense(context: context)
            expense2.uuid = UUID()
            expense2.date = sampleDate
            expense2.amount = NSNumber(value: 200.00)
            expense2.category = "Utilities"
            expense2.desc = "Electricity bill"
            
            viewModel.expenses = [expense1, expense2]
            
            return IncomeMonthCard(month: "January 2024")
                .environmentObject(viewModel)
                .previewLayout(.sizeThatFits)
                .padding()
        }
    }
#endif


