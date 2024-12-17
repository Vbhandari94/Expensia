//
//  AddExpenseForm.swift
//  Expensia
//
//  Created by Varun Bhandari on 17/12/24.
//


import SwiftUI
import CoreData

struct AddExpenseForm: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.managedObjectContext) private var context

    @ObservedObject var expense: Expense

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
                    Text("Add New Expense")
                        .font(.largeTitle)
                        .bold()
                        .foregroundColor(Color("TextColor"))

                    VStack(spacing: 10) {
                        // Amount Field using text-based binding
                        HStack {
                            Text("₹")
                                .foregroundColor(.gray)
                            TextField("Enter Amount", text: Binding(
                                get: {
                                    // If amount is nil, return an empty string so the field is empty
                                    guard let amount = expense.amount else { return "" }
                                    return String(amount.doubleValue)
                                },
                                set: {
                                    // Convert user input back to Double
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

                        // Description Field
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

                        // Date Picker
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

                        // Category Picker
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Category")
                                .font(.headline)
                                .foregroundColor(Color("TextColor"))

                            Picker("Select Category", selection: Binding(
                                get: { expense.category ?? "" },
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

                // Buttons
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
                            let nsError = error as NSError
                            print("Failed to save expense: \(nsError.localizedDescription), \(nsError.userInfo)")
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
    }

    func validateAndSave() throws {
        let amountDouble = expense.amount?.doubleValue ?? 0.0
        guard amountDouble > 0 else { throw ValidationError.invalidAmount }

        let trimmedDesc = (expense.desc ?? "").trimmingCharacters(in: .whitespaces)
        guard !trimmedDesc.isEmpty else { throw ValidationError.emptyDescription }

        let trimmedCategory = (expense.category ?? "").trimmingCharacters(in: .whitespaces)
        guard !trimmedCategory.isEmpty else { throw ValidationError.emptyCategory }

        // Ensure a UUID is set
        if expense.uuid == nil {
            expense.uuid = UUID()
        }

        do {
            try context.save()
        } catch let error as NSError {
            print("Failed to save expense: \(error), \(error.userInfo)")
            throw error
        }
    }

    func isFormValid() -> Bool {
        let descValid = (expense.desc ?? "").trimmingCharacters(in: .whitespaces).isEmpty == false
        let categoryValid = (expense.category ?? "").trimmingCharacters(in: .whitespaces).isEmpty == false
        let amountDouble = expense.amount?.doubleValue ?? 0.0
        return amountDouble > 0 && descValid && categoryValid
    }

    func hideKeyboard() {
        UIApplication.shared.endEditing()
    }
}

struct AddExpenseForm_Previews: PreviewProvider {
    static var previews: some View {
        let context = PersistenceController.shared.container.viewContext
        let testExpense = Expense(context: context)
        testExpense.uuid = UUID()
        testExpense.amount = nil // Ensure no default amount
        testExpense.desc = ""
        testExpense.date = Date()
        testExpense.category = "Bills"

        return AddExpenseForm(expense: testExpense)
            .environment(\.managedObjectContext, context)
    }
}
