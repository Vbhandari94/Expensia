//
//  ExpenseMonthView.swift
//  SpendSense
//
//  Created by Varun Bhandari on 24/11/24.
//
import Foundation
import SwiftUI
import CloudKit

struct ExpenseMonthView: View {
    @EnvironmentObject var viewModel: ExpenseViewModel
    let month: String

    @State private var isMonthClosed: Bool

    init(month: String) {
        self.month = month
        _isMonthClosed = State(initialValue: false)
    }

    var expenses: [Expense] {
        viewModel.expenses.filter { expense in
            let formatter = DateFormatter()
            formatter.dateFormat = "MMMM yyyy"
            return formatter.string(from: expense.date ?? Date()) == month
        }
    }

    @State private var selectedExpense: Expense?

    private var groupedExpenses: [String: [Expense]] {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, yyyy"
        return Dictionary(grouping: expenses, by: { formatter.string(from: $0.date ?? Date()) })
    }

    // Make averageDailySpending optional. Return nil if no valid amounts.
    private var averageDailySpending: Double? {
        let calendar = Calendar.current
        guard let firstExpenseDate = expenses.first?.date else { return nil }
        let dateComponents = calendar.dateComponents([.year, .month], from: firstExpenseDate)

        if let monthStart = calendar.date(from: dateComponents),
           let daysRange = calendar.range(of: .day, in: .month, for: monthStart) {
            let totalDays = daysRange.count
            let totalExpenses = expenses.reduce(0.0) { result, expense in
                // Only add if amount is available and valid
                guard let amountVal = expense.amount as? Double else { return result }
                return result + amountVal
            }
            // If totalExpenses is 0 or no valid amounts, return nil
            let avg = totalExpenses > 0 ? totalExpenses / Double(totalDays) : nil
            return avg
        }
        return nil
    }

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [Color("BackgroundColor"), Color("AccentColor").opacity(0.1)]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(alignment: .leading, spacing: 16) {
                Text("\(month)")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(Color("TextColor"))
                    .padding(.top, 10)

                if expenses.isEmpty {
                    Text("No Expenses Found")
                        .font(.headline)
                        .foregroundColor(.gray)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding()
                } else {
                    ScrollView {
                        LazyVStack(spacing: 16) {
                            ForEach(groupedExpenses.sorted(by: { lhs, rhs in
                                let formatter = DateFormatter()
                                formatter.dateFormat = "MMM d, yyyy"
                                guard let lhsDate = formatter.date(from: lhs.key),
                                      let rhsDate = formatter.date(from: rhs.key) else { return false }
                                return lhsDate > rhsDate
                            }), id: \.key) { date, expenses in
                                VStack(alignment: .leading, spacing: 8) {
                                    Text(date)
                                        .font(.headline)
                                        .foregroundColor(Color("AccentColor"))
                                        .padding(.leading)

                                    ForEach(expenses) { expense in
                                        ExpenseCard(expense: expense)
                                            .padding(.horizontal)
                                            .if(!isMonthClosed) { view in
                                                view.contextMenu {
                                                    Button {
                                                        selectedExpense = expense
                                                    } label: {
                                                        Label("Edit Expense", systemImage: "pencil")
                                                    }

                                                    Button(role: .destructive) {
                                                        deleteExpense(expense)
                                                    } label: {
                                                        Label("Delete Expense", systemImage: "trash")
                                                    }
                                                }
                                            }
                                    }
                                }
                            }
                        }
                        .padding(.top, 10)

                        // Only show if averageDailySpending is not nil and not 0.0
                        if let avg = averageDailySpending, avg != 0.0 {
                            Text("Average Daily Spending: ₹\(avg, specifier: "%.2f")")
                                .font(.headline)
                                .foregroundColor(Color("AccentColor"))
                                .frame(maxWidth: .infinity, alignment: .center)
                                .padding(.top, 16)
                        }

                        if !isMonthClosed {
                            Button("Close report for this month") {
                                isMonthClosed = true
                                viewModel.closeMonth(month)
                            }
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.red)
                            .cornerRadius(12)
                            .padding(.top, 20)
                            .frame(maxWidth: .infinity, alignment: .center)
                        }

                        Spacer().frame(height: 30)
                    }
                }
            }
            .padding()
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                isMonthClosed = viewModel.isMonthClosed(for: month)
            }
            .if(!isMonthClosed) { view in
                view.sheet(item: $selectedExpense, onDismiss: {
                    selectedExpense = nil
                }) { expenseToEdit in
                    EditExpenseForm(expense: expenseToEdit) { updatedExpense in
                        updateExpense(updatedExpense)
                    }
                }
            }
        }
    }

    private func deleteExpense(_ expense: Expense) {
        viewModel.deleteExpense(expense)
    }

    private func updateExpense(_ updatedExpense: Expense) {
        viewModel.updateExpense(updatedExpense)
    }
}

extension View {
    @ViewBuilder
    func `if`<Transform: View>(_ condition: Bool, transform: (Self) -> Transform) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
}

// MARK: - Preview
struct ExpenseMonthView_Previews: PreviewProvider {
    static var previews: some View {
        let viewModel = ExpenseViewModel()
        // Add sample data if needed
        return NavigationStack {
            ExpenseMonthView(month: "January 2024")
                .environmentObject(viewModel)
        }
    }
}
