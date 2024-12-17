//
//  EditExpenseForm.swift
//  Expensia
//
//  Created by Varun Bhandari on 27/11/24.
//
import SwiftUI
import CoreData
import UIKit

struct EditExpenseForm: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.managedObjectContext) private var context

    @ObservedObject var expense: Expense
    var onSave: (Expense) -> Void

    @StateObject private var alertManager = AlertManager()

    let categories = [
        "Bills",
        "Subscriptions",
        "Shopping",
        "Food & Beverages",
        "Investments",
        "Recreation",
        "Travel",
        "Medical Expense",
        "Fuel",
        "Education",
        "Personal Care",
        "Gifts & Donations",
        "EMI Payment"
    ]

    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [Color("BackgroundColor"), Color("AccentColor").opacity(0.1)]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 20) {
                VStack(spacing: 16) {
                    Text("Edit Expense")
                        .font(.largeTitle)
                        .bold()
                        .foregroundColor(Color("TextColor"))

                    VStack(spacing: 10) {
                        // Amount TextField using text-based binding
                        HStack {
                            Text("₹")
                                .foregroundColor(.gray)
                            TextField("Enter Amount", text: Binding(
                                get: {
                                    guard let amount = expense.amount else { return "" }
                                    return String(amount.doubleValue)
                                },
                                set: {
                                    if let val = Double($0) {
                                        expense.amount = NSNumber(value: val)
                                    } else {
                                        expense.amount = nil
                                    }
                                }
                            ))
                            .keyboardType(.decimalPad)
                            .autocapitalization(.none)
                            .disableAutocorrection(true)
                            .submitLabel(.done)
                            .onSubmit { hideKeyboard() }
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color("CardBackgroundColor"))
                                .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
                        )

                        // Description
                        TextField("Enter Description", text: Binding(
                            get: { expense.desc ?? "" },
                            set: { expense.desc = $0 }
                        ))
                        .padding()
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                        .submitLabel(.done)
                        .onSubmit { hideKeyboard() }
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color("CardBackgroundColor"))
                                .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
                        )

                        // Date
                        DatePicker("Select Date", selection: Binding(
                            get: { expense.date ?? Date() },
                            set: { expense.date = $0 }
                        ), displayedComponents: .date)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color("CardBackgroundColor"))
                                .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
                        )

                        // Category
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Category")
                                .font(.headline)
                                .foregroundColor(Color("TextColor"))

                            Picker("Select Category", selection: Binding(
                                get: { expense.category ?? "Bills" },
                                set: { expense.category = $0 }
                            )) {
                                ForEach(categories, id: \.self) { category in
                                    Text(category)
                                        .foregroundColor(Color("TextColor"))
                                }
                            }
                            .pickerStyle(MenuPickerStyle())
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color("CardBackgroundColor"))
                                    .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
                            )
                            .onTapGesture { hideKeyboard() }
                        }
                    }
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color("BackgroundColor"))
                        .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
                )
                .padding(.horizontal, 16)

                Spacer()

                HStack(spacing: 20) {
                    Button(action: {
                        dismiss()
                    }) {
                        Label("Cancel", systemImage: "xmark.circle")
                            .font(.headline)
                            .foregroundColor(.red)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color("CardBackgroundColor"))
                                    .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
                            )
                    }

                    Button(action: {
                        do {
                            try validateAndSave()
                            dismiss()
                        } catch {
                            debugPrint("Error saving expense: \(error)")
                            alertManager.triggerAlert(message: "Failed to save expense: \(error.localizedDescription)")
                        }
                    }) {
                        Label("Save", systemImage: "checkmark.circle")
                            .font(.headline)
                            .foregroundColor(.green)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color("CardBackgroundColor"))
                                    .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
                            )
                    }
                    .disabled(!isFormValid())
                    .opacity(isFormValid() ? 1 : 0.6)
                }
                .padding(.horizontal, 16)
            }
        }
        .alert(isPresented: $alertManager.showAlert) {
            Alert(
                title: Text("Invalid Input"),
                message: Text(alertManager.alertMessage),
                dismissButton: .default(Text("OK"))
            )
        }
    }

    private func isFormValid() -> Bool {
        let desc = expense.desc ?? ""
        // If amount is nil or can't be parsed to double, treat as invalid
        guard let amountVal = expense.amount?.doubleValue, amountVal > 0 else {
            return false
        }
        return !desc.trimmingCharacters(in: .whitespaces).isEmpty && !(expense.category ?? "").isEmpty
    }

    private func validateAndSave() throws {
        guard isFormValid() else {
            throw ValidationError.invalidInput
        }

        // Ensure UUID is set
        if expense.uuid == nil {
            expense.uuid = UUID()
        }

        // Save changes
        onSave(expense)
        try context.save()
    }

    func hideKeyboard() {
        UIApplication.shared.endEditing()
    }
}

// MARK: - Preview
struct EditExpenseForm_Previews: PreviewProvider {
    static var previews: some View {
        let context = PersistenceController.shared.container.viewContext

        let testExpense = Expense(context: context)
        testExpense.uuid = UUID()
        testExpense.date = Date()
        // Set amount to nil so the field is empty initially
        testExpense.amount = nil
        testExpense.category = "Food & Beverages"
        testExpense.desc = "Groceries"

        return EditExpenseForm(expense: testExpense) { _ in }
            .environment(\.managedObjectContext, context)
    }
}
