//
//  TrendView.swift
//  SpendSense
//
//  Created by Varun Bhandari on 25/11/24.
//

//
//  TrendView.swift
//  SpendSense
//
//  Created by Varun Bhandari on 25/11/24.
//

//
//  TrendView.swift
//  SpendSense
//
//  Created by Varun Bhandari on 25/11/24.
//

//
//  TrendView.swift
//  SpendSense
//
//  Created by Varun Bhandari on 25/11/24.
//

import SwiftUI
import Charts

struct MonthlyTotals: Identifiable {
    let id = UUID()
    let month: Date
    let totalIncome: Double
    let totalExpenses: Double
}

struct CategoryExpense: Identifiable {
    let id = UUID()
    let category: String
    let total: Double
}

enum TimeRange: String, CaseIterable {
    case day = "Day"
    case week = "Week"
    case month = "Month"
    case sixMonths = "6 Months"
    case year = "Year"

    func includes(_ date: Date) -> Bool {
        let calendar = Calendar.current
        let now = Date()

        switch self {
        case .day:
            return calendar.isDate(date, inSameDayAs: now)
        case .week:
            guard let startOfWeek = calendar.dateInterval(of: .weekOfMonth, for: now)?.start else { return false }
            return date >= startOfWeek && date <= now
        case .month:
            return calendar.isDate(date, equalTo: now, toGranularity: .month)
        case .sixMonths:
            guard let sixMonthsAgo = calendar.date(byAdding: .month, value: -6, to: now) else { return false }
            return date >= sixMonthsAgo && date <= now
        case .year:
            return calendar.isDate(date, equalTo: now, toGranularity: .year)
        }
    }
}

struct TrendView: View {
    @EnvironmentObject var viewModel: ExpenseViewModel
    @State private var selectedRange: TimeRange = .month

    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [Color("BackgroundColor"), Color("AccentColor").opacity(0.1)]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 24) {
                    // Title
                    Text("Trend Analysis")
                        .font(.largeTitle)
                        .bold()
                        .foregroundColor(Color("TextColor"))
                        .padding(.top, 40)

                    // Time range picker
                    Picker("Time Range", selection: $selectedRange) {
                        ForEach(TimeRange.allCases, id: \.self) { range in
                            Text(range.rawValue).tag(range)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding(.horizontal)

                    // Net Savings Summary
                    let netSavings = calculateNetSavings(for: selectedRange)
                    Text("Net Savings: ₹\(netSavings, specifier: "%.2f")")
                        .font(.headline)
                        .foregroundColor(Color("AccentColor"))
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.bottom, 16)

                    // Monthly Income vs Expenses
                    trendSectionCard(
                        title: "Monthly Income vs Expenses",
                        icon: "chart.bar.xaxis",
                        chart: AnyView(monthlyComparisonChart),
                        statsLabel: "Net Savings:",
                        statsValue: netSavings
                    )

                    // Expenses by Category
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Image(systemName: "chart.bar.fill")
                                .font(.title2)
                                .foregroundColor(Color("AccentColor"))
                            Text("Expenses by Category")
                                .font(.title2)
                                .bold()
                                .foregroundColor(Color("TextColor"))
                        }

                        categoryChart
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .padding(.top, 8)
                            .padding([.leading, .trailing], 8)
                            .frame(height: 300)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color("CardBackgroundColor"))
                            )
                            .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 5)
                    }
                    .padding(.horizontal)
                }
                .padding()
            }
        }
        .navigationTitle("Spending Trends")
    }

    // Filtered Data
    private var filteredIncomes: [Income] {
        viewModel.incomes.filter { inc in
            let date = inc.date ?? Date(timeIntervalSince1970: 0)
            return selectedRange.includes(date)
        }
    }

    private var filteredExpenses: [Expense] {
        viewModel.expenses.filter { exp in
            let date = exp.date ?? Date(timeIntervalSince1970: 0)
            return selectedRange.includes(date)
        }
    }

    // Aggregate monthly totals
    private var monthlyData: [MonthlyTotals] {
        let calendar = Calendar.current

        // Group incomes by year-month
        let groupedIncomes = Dictionary(grouping: filteredIncomes) { income -> Date in
            let d = income.date ?? Date(timeIntervalSince1970: 0)
            return calendar.date(from: calendar.dateComponents([.year, .month], from: d)) ?? d
        }

        // Group expenses by year-month
        let groupedExpenses = Dictionary(grouping: filteredExpenses) { expense -> Date in
            let d = expense.date ?? Date(timeIntervalSince1970: 0)
            return calendar.date(from: calendar.dateComponents([.year, .month], from: d)) ?? d
        }

        let allMonths = Set(groupedIncomes.keys).union(groupedExpenses.keys)
        return allMonths.compactMap { month in
            let totalIncome = groupedIncomes[month]?.reduce(0.0) { $0 + (( $1.amount as? Double ) ?? 0.0) } ?? 0.0
            let totalExpenses = groupedExpenses[month]?.reduce(0.0) { $0 + (( $1.amount as? Double ) ?? 0.0) } ?? 0.0
            return MonthlyTotals(month: month, totalIncome: totalIncome, totalExpenses: totalExpenses)
        }
        .sorted { $0.month < $1.month }
    }

    // Aggregate by category
    private var categoryExpensesData: [CategoryExpense] {
        let grouped = Dictionary(grouping: filteredExpenses, by: { $0.category ?? "" })
        return grouped.map { (category, expenses) in
            CategoryExpense(category: category, total: expenses.reduce(0.0) { $0 + (($1.amount as? Double) ?? 0.0) })
        }
        .sorted { $0.total > $1.total }
    }

    // Monthly Income vs Expenses Chart
    private var monthlyComparisonChart: some View {
        let maxY = max(maxIncome(), maxExpense())

        return Chart {
            ForEach(monthlyData) { data in
                BarMark(
                    x: .value("Month", data.month),
                    y: .value("Amount", data.totalIncome)
                )
                .foregroundStyle(Color.green)
                .position(by: .value("Type", "Income"))
                .annotation(position: .top) {
                    if data.totalIncome > 0 {
                        Text("₹\(Int(data.totalIncome))")
                            .font(.caption)
                            .foregroundColor(.green)
                    }
                }

                BarMark(
                    x: .value("Month", data.month),
                    y: .value("Amount", data.totalExpenses)
                )
                .foregroundStyle(Color.red)
                .position(by: .value("Type", "Expenses"))
                .annotation(position: .top) {
                    if data.totalExpenses > 0 {
                        Text("₹\(Int(data.totalExpenses))")
                            .font(.caption)
                            .foregroundColor(.red)
                    }
                }
            }
        }
        .chartXAxis {
            AxisMarks(values: .stride(by: .month)) {
                AxisGridLine()
                AxisValueLabel(format: .dateTime.month(.abbreviated).year(), centered: true)
            }
        }
        .chartYAxis {
            AxisMarks(position: .leading) {
                AxisGridLine()
                AxisValueLabel()
            }
        }
        .chartYScale(domain: [0, maxY])
        .chartXAxisLabel("Month")
        .chartYAxisLabel("Amount (₹)")
        .frame(height: 300)
        .padding(.horizontal, 8)
    }

    // Expenses by Category Chart
    private var categoryChart: some View {
        Chart(categoryExpensesData) { data in
            BarMark(
                x: .value("Total", data.total),
                y: .value("Category", data.category)
            )
            .foregroundStyle(Color("AccentColor"))
            .annotation(position: .trailing) {
                Text("₹\(Int(data.total))")
                    .font(.caption)
                    .foregroundColor(Color("AccentColor"))
            }
        }
        .chartXAxis {
            AxisMarks {
                AxisGridLine()
                AxisValueLabel()
            }
        }
        .chartYAxis {
            AxisMarks(position: .leading) {
                AxisValueLabel()
            }
        }
        .chartYAxisLabel("Category")
    }

    private func trendSectionCard(
        title: String,
        icon: String,
        chart: AnyView,
        statsLabel: String,
        statsValue: Double
    ) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(Color("AccentColor"))
                Text(title)
                    .font(.title2)
                    .bold()
                    .foregroundColor(Color("TextColor"))
            }

            chart
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .padding(.top, 8)
                .padding([.leading, .trailing], 8)

            HStack {
                Text(statsLabel)
                    .font(.subheadline)
                    .foregroundColor(.gray)
                Spacer()
                Text("₹\(String(format: "%.2f", statsValue))")
                    .font(.headline)
                    .foregroundColor(Color("AccentColor"))
            }
            .padding([.leading, .trailing, .bottom], 8)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color("CardBackgroundColor"))
        )
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 5)
    }

    private func maxIncome() -> Double {
        monthlyData.map { $0.totalIncome }.max() ?? 0.0
    }

    private func maxExpense() -> Double {
        monthlyData.map { $0.totalExpenses }.max() ?? 0.0
    }

    private func calculateNetSavings(for range: TimeRange) -> Double {
        let incomesInRange = viewModel.incomes.filter { inc in
            let d = inc.date ?? Date(timeIntervalSince1970: 0)
            return range.includes(d)
        }
        let expensesInRange = viewModel.expenses.filter { exp in
            let d = exp.date ?? Date(timeIntervalSince1970: 0)
            return range.includes(d)
        }
        let totalIncome = incomesInRange.reduce(0.0) { $0 + (($1.amount as? Double) ?? 0.0) }
        let totalExpenses = expensesInRange.reduce(0.0) { $0 + (($1.amount as? Double) ?? 0.0) }
        return totalIncome - totalExpenses
    }
}

struct TrendView_Previews: PreviewProvider {
    static var previews: some View {
        let viewModel = ExpenseViewModel()

        // Mock Data
        let now = Date()
        let oneMonthAgo = Calendar.current.date(byAdding: .month, value: -1, to: now) ?? now

        let testIncome1 = Income(context: PersistenceController.shared.container.viewContext)
        testIncome1.uuid = UUID()
        testIncome1.date = now
        testIncome1.amount = 15000
        testIncome1.desc = "Salary"

        let testIncome2 = Income(context: PersistenceController.shared.container.viewContext)
        testIncome2.uuid = UUID()
        testIncome2.date = oneMonthAgo
        testIncome2.amount = 20000
        testIncome2.desc = "Freelance Work"

        let testExpense1 = Expense(context: PersistenceController.shared.container.viewContext)
        testExpense1.uuid = UUID()
        testExpense1.date = now
        testExpense1.amount = 7907
        testExpense1.category = "Food"
        testExpense1.desc = "Groceries"

        let testExpense2 = Expense(context: PersistenceController.shared.container.viewContext)
        testExpense2.uuid = UUID()
        testExpense2.date = oneMonthAgo
        testExpense2.amount = 12000
        testExpense2.category = "Travel"
        testExpense2.desc = "Flight Tickets"

        viewModel.incomes = [testIncome1, testIncome2]
        viewModel.expenses = [testExpense1, testExpense2]

        return TrendView()
            .environmentObject(viewModel)
    }
}
