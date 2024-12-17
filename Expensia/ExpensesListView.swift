//
//  ExpensesListView.swift
//  SpendSense
//
//  Created by Varun Bhandari on 24/11/24.
//
//
//  ExpensesListView.swift
//  SpendSense
//
//  Created by Varun Bhandari on 24/11/24.
//

import SwiftUI

struct ExpensesListView: View {
    @EnvironmentObject var viewModel: ExpenseViewModel
    @State private var showAddExpenseSheet = false
    @State private var selectedYear: Int

    init() {
        let currentYear = Calendar.current.component(.year, from: Date())
        _selectedYear = State(initialValue: currentYear)
    }

    // Compute filtered monthly groups based on selectedYear
    private var filteredGroups: [MonthlyGroup] {
        let allGroups = viewModel.groupedExpenses()

        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"

        return allGroups.filter { group in
            if let date = formatter.date(from: group.monthKey) {
                let year = Calendar.current.component(.year, from: date)
                return year == selectedYear
            }
            return false
        }
    }

    // Compute total expenses for the selected year only
    private var yearTotalExpenses: Double {
        filteredGroups.reduce(0) { sum, group in
            sum + group.expenses.reduce(0.0) { $0 + ((($1.amount as? Double) ?? 0.0)) }
        }
    }

    // Dynamically generate years that have saved expenses
    private var availableYears: [Int] {
        let allGroups = viewModel.groupedExpenses()
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"

        let years = allGroups.compactMap { group -> Int? in
            if let date = formatter.date(from: group.monthKey) {
                return Calendar.current.component(.year, from: date)
            }
            return nil
        }

        let uniqueYears = Set(years)
        return uniqueYears.sorted()
    }

    var body: some View {
        NavigationView {
            ZStack {
                // Background Gradient
                LinearGradient(
                    gradient: Gradient(colors: [Color("BackgroundColor"), Color("AccentColor").opacity(0.1)]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()

                VStack(spacing: 8) {
                    // Title, Year Picker, and Filtered Total Expenses
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Expenses")
                                .font(.largeTitle)
                                .bold()
                                .foregroundColor(Color("TextColor"))

                            // Only show total if it's nonzero
                            if yearTotalExpenses != 0.0 {
                                Text("Total Expenses: ₹\(yearTotalExpenses, specifier: "%.2f")")
                                    .font(.headline)
                                    .foregroundColor(.red)
                            } else {
                                // Show empty or alternate text if total is zero
                                Text("")
                                    .font(.headline)
                                    .foregroundColor(.red)
                            }
                        }

                        Spacer()

                        Picker("Year", selection: $selectedYear) {
                            ForEach(availableYears, id: \.self) { year in
                                Text(String(year)).tag(year)
                            }
                        }
                        .pickerStyle(MenuPickerStyle())
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 16)

                    Divider()

                    if filteredGroups.isEmpty {
                        Spacer()
                        Text("No Expenses Found")
                            .font(.headline)
                            .foregroundColor(.gray)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding()
                        Spacer()
                    } else {
                        expensesList
                    }
                }
                .navigationBarTitleDisplayMode(.inline)

                // Floating "+" Button at Bottom-Right
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Button(action: {
                            showAddExpenseSheet = true
                        }) {
                            Image(systemName: "plus")
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(.white)
                                .frame(width: 56, height: 56)
                                .background(Color("AccentColor"))
                                .clipShape(Circle())
                                .shadow(color: Color.black.opacity(0.2), radius: 4, x: 0, y: 2)
                        }
                        .padding(.trailing, 24)
                        .padding(.bottom, 24)
                    }
                }
                .sheet(isPresented: $showAddExpenseSheet) {
                    AddExpenseForm(expense: createNewExpense())
                        .environmentObject(viewModel)
                }
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }

    // MARK: - Helper to create new Expense
    private func createNewExpense() -> Expense {
        let context = PersistenceController.shared.container.viewContext
        let newExpense = Expense(context: context)
        newExpense.uuid = UUID()
        newExpense.date = Date()
        // Set amount to nil or do not set it so it doesn't show 0.0 by default
        newExpense.amount = nil
        newExpense.category = "Bills"
        newExpense.desc = ""
        return newExpense
    }

    // MARK: - Expenses List
    private var expensesList: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                ForEach(filteredGroups.sorted(by: { $0.monthKey > $1.monthKey }), id: \.monthKey) { group in
                    NavigationLink(destination: ExpenseMonthView(month: group.monthKey)) {
                        let total = group.expenses.reduce(0.0) { $0 + ((($1.amount as? Double) ?? 0.0)) }
                        if total != 0.0 {
                            ExpenseMonthCard(
                                month: group.monthKey,
                                totalExpenses: total
                            )
                        } else {
                            // If total is zero, show an empty card or different UI
                            ExpenseMonthCard(
                                month: group.monthKey,
                                totalExpenses: 0.0
                            )
                            .hidden()
                        }
                    }
                    .buttonStyle(PlainButtonStyle())
                    .padding(.horizontal)
                }
            }
            .padding(.top, 10)
        }
    }
}

struct ExpensesListView_Previews: PreviewProvider {
    static var previews: some View {
        let viewModel = ExpenseViewModel()
        return NavigationStack {
            ExpensesListView()
                .environmentObject(viewModel)
        }
    }
}
