//
//  AddIncomeForm.swift
//  Expensia
//
//  Created by Varun Bhandari on 17/12/24.
//
import SwiftUI
import CoreData

struct AddIncomeForm: View {
    @EnvironmentObject var viewModel: ExpenseViewModel
    @Environment(\.dismiss) var dismiss
    @Environment(\.managedObjectContext) private var context

    @StateObject var alertManager = AlertManager()

    @ObservedObject var income: Income

    var body: some View {
        ZStack {
            // Background Gradient
            LinearGradient(
                gradient: Gradient(colors: [Color("BackgroundColor"), Color("AccentColor").opacity(0.1)]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 20) {
                // Form Section
                VStack(spacing: 16) {
                    Text("Add New Income")
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
                                    // If amount is nil, return empty string
                                    guard let amount = income.amount else { return "" }
                                    return String(amount.doubleValue)
                                },
                                set: {
                                    // Convert user input to Double
                                    if let val = Double($0) {
                                        income.amount = NSNumber(value: val)
                                    } else {
                                        income.amount = nil
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

                        // Description TextField
                        TextField("Enter Description", text: Binding(
                            get: { income.desc ?? "" },
                            set: { income.desc = $0 }
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

                        // DatePicker
                        DatePicker("Select Date", selection: Binding(
                            get: { income.date ?? Date() },
                            set: { income.date = $0 }
                        ), displayedComponents: .date)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color("CardBackgroundColor"))
                                .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
                        )
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

                // Save and Cancel Buttons
                HStack(spacing: 20) {
                    // Cancel Button
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

                    // Save Button
                    Button(action: {
                        do {
                            try validateAndSave()
                            dismiss()
                        } catch {
                            alertManager.triggerAlert(message: "Failed to save income: \(error.localizedDescription)")
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

    // MARK: - Functions

    func validateAndSave() throws {
        let amountValue = income.amount?.doubleValue ?? 0.0
        guard amountValue > 0 else { throw ValidationError.invalidAmount }
        guard let desc = income.desc, !desc.trimmingCharacters(in: .whitespaces).isEmpty else {
            throw ValidationError.emptyDescription
        }

        let date = income.date ?? Date()

        // Ensure a UUID is set if needed
        if income.uuid == nil {
            income.uuid = UUID()
        }

        let formatter = DateFormatter()
        formatter.dateFormat = "LLLL yyyy"
        let monthKey = formatter.string(from: date)

        if viewModel.isMonthClosed(for: monthKey) {
            alertManager.triggerAlert(message: "The report for \(monthKey) is closed. You cannot add new incomes to a closed month.")
            return
        }

        viewModel.addIncome(date: date, amount: amountValue, description: desc)
    }

    func isFormValid() -> Bool {
        (income.amount?.doubleValue ?? 0.0) > 0 && !(income.desc ?? "").trimmingCharacters(in: .whitespaces).isEmpty
    }

    func hideKeyboard() {
        UIApplication.shared.endEditing()
    }
}

// MARK: - Preview
struct AddIncomeForm_Previews: PreviewProvider {
    static var previews: some View {
        let context = PersistenceController.shared.container.viewContext

        let testIncome = Income(context: context)
        testIncome.uuid = UUID()
        testIncome.amount = nil // Start with nil so the field is empty
        testIncome.desc = ""
        testIncome.date = Date()

        return AddIncomeForm(income: testIncome)
            .environment(\.managedObjectContext, context)
            .environmentObject(ExpenseViewModel(context: context))
    }
}
