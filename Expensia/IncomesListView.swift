//
//  IncomesListView.swift
//  SpendSense
//
//  Created by Varun Bhandari on 25/11/24.
//

//
//  IncomesListView.swift
//  SpendSense
//
//  Created by Varun Bhandari on 25/11/24.
//
//  IncomesListView.swift
//  SpendSense
//
//  Created by Varun Bhandari on 25/11/24.
//

import SwiftUI

struct IncomesListView: View {
    @EnvironmentObject var viewModel: ExpenseViewModel
    @State private var showAddIncomeSheet = false
    @State private var selectedYear: Int

    init() {
        let currentYear = Calendar.current.component(.year, from: Date())
        _selectedYear = State(initialValue: currentYear)
    }

    // All grouped incomes
    private var grouped: [MonthlyGroup] {
        viewModel.groupedIncomes()
    }

    // Filtered groups based on selectedYear
    private var filteredGroups: [MonthlyGroup] {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return grouped.filter { group in
            if let date = formatter.date(from: group.monthKey) {
                let year = Calendar.current.component(.year, from: date)
                return year == selectedYear
            }
            return false
        }
    }

    // Extract available years from the data
    private var availableYears: [Int] {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        let years = grouped.compactMap { monthGroup -> Int? in
            if let date = formatter.date(from: monthGroup.monthKey) {
                return Calendar.current.component(.year, from: date)
            }
            return nil
        }
        let uniqueYears = Set(years)
        return uniqueYears.sorted()
    }

    // Calculate year-based totals
    private var yearTotalIncome: Double {
        filteredGroups.reduce(0.0) { sum, group in
            sum + group.income.reduce(0.0) { innerSum, income in
                innerSum + ((income.amount as? Double) ?? 0.0)
            }
        }
    }

    private var yearTotalExpenses: Double {
        let year = selectedYear
        let yearExpenses = viewModel.expenses.filter { expense in
            Calendar.current.component(.year, from: expense.date ?? Date()) == year
        }
        return yearExpenses.reduce(0.0) { sum, expense in
            sum + ((expense.amount as? Double) ?? 0.0)
        }
    }

    private var yearNetBalance: Double {
        yearTotalIncome - yearTotalExpenses
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
                    // Title and Net Balance for Selected Year
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Income")
                                .font(.largeTitle)
                                .bold()
                                .foregroundColor(Color("TextColor"))

                            // Show net balance for the selected year
                            Text("Net Balance: ₹\(yearNetBalance, specifier: "%.2f")")
                                .font(.headline)
                                .foregroundColor(yearNetBalance >= 0 ? .green : .red)
                        }

                        Spacer()

                        // Year Picker
                        Picker("Year", selection: $selectedYear) {
                            ForEach(availableYears, id: \.self) { year in
                                Text(String(year)).tag(year)
                            }
                        }
                        .pickerStyle(MenuPickerStyle())
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 8)

                    Divider()

                    if filteredGroups.isEmpty {
                        Spacer()
                        Text("No Incomes Found")
                            .font(.headline)
                            .foregroundColor(.gray)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding()
                        Spacer()
                    } else {
                        ScrollView {
                            LazyVStack(spacing: 16) {
                                ForEach(filteredGroups) { monthGroup in
                                    NavigationLink(destination: IncomeMonthView(month: monthGroup.monthKey)) {
                                        IncomeMonthCard(month: monthGroup.monthKey)
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                    .padding(.horizontal)
                                }
                            }
                            .padding(.top, 10)
                        }
                    }
                }
                .navigationBarTitleDisplayMode(.inline)
                .padding(.top, 0)

                // Floating "+" Button at Bottom-Right
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Button(action: {
                            showAddIncomeSheet.toggle()
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
                .sheet(isPresented: $showAddIncomeSheet) {
                    // Create new income outside the closure
                    AddIncomeForm(income: createNewIncome())
                        .environmentObject(viewModel)
                }
            }
            .navigationViewStyle(StackNavigationViewStyle())
        }
    }

    // Helper to create a new Income object
    private func createNewIncome() -> Income {
        let context = PersistenceController.shared.container.viewContext
        let newIncome = Income(context: context)
        newIncome.uuid = UUID()
        newIncome.date = Date()
        newIncome.amount = 0.0
        newIncome.desc = ""
        return newIncome
    }
}

struct IncomesListView_Previews: PreviewProvider {
    static var previews: some View {
        let viewModel = ExpenseViewModel()
        return NavigationStack {
            IncomesListView()
                .environmentObject(viewModel)
        }
    }
}
