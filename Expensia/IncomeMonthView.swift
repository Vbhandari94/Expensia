//
//  IncomeMonthView.swift
//  SpendSense
//
//  Created by Varun Bhandari on 25/11/24.
//


//
//  IncomeMonthView.swift
//  SpendSense
//
//  Created by Varun Bhandari on 25/11/24.
//
//
//  IncomeMonthView.swift
//  SpendSense
//
//  Created by Varun Bhandari on 25/11/24.
//

//
//  IncomeMonthView.swift
//  SpendSense
//
//  Created by Varun Bhandari on 25/11/24.
//
//
//  IncomeMonthView.swift
//  SpendSense
//
//  Created by Varun Bhandari on 25/11/24.
//

import SwiftUI

struct IncomeMonthView: View {
    @EnvironmentObject var viewModel: ExpenseViewModel
    let month: String

    @State private var isMonthClosed = false
    @Environment(\.dismiss) private var dismiss

    private var incomesForMonth: [Income] {
        let formatter = DateFormatter()
        formatter.dateFormat = "LLLL yyyy"
        return viewModel.incomes.filter { income in
            // Safely unwrap optional date
            formatter.string(from: income.date ?? Date()) == month
        }
    }

    private var totalIncome: Double {
        incomesForMonth.reduce(0.0) { total, income in
            total + ((income.amount as? Double) ?? 0.0)
        }
    }

    var body: some View {
        ZStack {
            // Background Gradient
            LinearGradient(
                gradient: Gradient(colors: [Color("BackgroundColor"), Color("AccentColor").opacity(0.1)]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(alignment: .leading, spacing: 16) {
                // Title and dynamic total
                Text("\(month)")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(Color("TextColor"))
                    .padding(.top, 10)

                Text("Total Income: ₹\(totalIncome, specifier: "%.2f")")
                    .font(.headline)
                    .foregroundColor(.primary)
                    .padding(.bottom, 8)

                // Incomes List as Cards
                if incomesForMonth.isEmpty {
                    Text("No Incomes Found")
                        .font(.headline)
                        .foregroundColor(.gray)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding()
                } else {
                    ScrollView {
                        LazyVStack(spacing: 16) {
                            ForEach(incomesForMonth) { income in
                                IncomeCard(income: income)
                                    .padding(.horizontal)
                                    // Only "Delete" if not closed
                                    .contextMenu(!isMonthClosed ? ContextMenu {
                                        Button("Delete", role: .destructive) {
                                            viewModel.deleteIncome(income)
                                        }
                                    } : nil)
                            }

                            // Button at the end of the scroll view
                            if !isMonthClosed {
                                Button("Close Income Report") {
                                    viewModel.closeMonth(month)
                                    isMonthClosed = true
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
                        .padding(.top, 10)
                    }
                }
            }
            .padding()
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                // Check if month is closed
                isMonthClosed = viewModel.isMonthClosed(for: month)
            }
        }
    }
}

// MARK: - Preview
struct IncomeMonthView_Previews: PreviewProvider {
    static var previews: some View {
        let viewModel = ExpenseViewModel() // No sample data added

        return NavigationStack {
            IncomeMonthView(month: "January 2024")
                .environmentObject(viewModel)
        }
    }
}
