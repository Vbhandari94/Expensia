//
//  ExpenseMonthCard.swift
//  SpendSense
//
//  Created by Varun Bhandari on 24/11/24.
//


import SwiftUI

struct ExpenseMonthCard: View {
    let month: String
    let totalExpenses: Double

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(month)
                .font(.headline)
                .foregroundColor(.primary)

            if totalExpenses != 0.0 {
                Text("Total Expenses: ₹\(totalExpenses, specifier: "%.2f")")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            } else {
                // Show empty text if totalExpenses is zero
                Text("")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            LinearGradient(
                gradient: Gradient(colors: [Color("BackgroundColor"), Color("AccentColor").opacity(0.2)]),
                startPoint: .top,
                endPoint: .bottom
            )
        )
        .cornerRadius(10)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}

struct ExpenseMonthCard_Previews: PreviewProvider {
    static var previews: some View {
        ExpenseMonthCard(month: "2024 November", totalExpenses: 0.0)
            .previewLayout(.sizeThatFits)
            .padding()
    }
}
