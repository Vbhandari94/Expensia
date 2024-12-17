//
//  ContentView.swift
//  Expensia
//
//  Created by Varun Bhandari on 17/12/24.
//

//
//  ContentView.swift
//  SpendSense
//
//  Created by Varun Bhandari on 24/11/24.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var viewModel: ExpenseViewModel
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Background Gradient
                LinearGradient(
                    gradient: Gradient(colors: [Color("BackgroundColor"), Color("AccentColor").opacity(0.1)]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                
                VStack(spacing: 30) {
                    // Header Section
                    VStack(spacing: 15) {
                        Image(systemName: "chart.bar.fill")
                            .font(.system(size: 50))
                            .foregroundColor(Color("AccentColor"))
                            .shadow(color: Color("AccentColor").opacity(0.3), radius: 10, x: 0, y: 5)
                            .padding(.top, 40)
                        
                        Text("Welcome to Expensia")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(Color("TextColor"))
                            .multilineTextAlignment(.center)
                            .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 5)
                            .padding(.top, 20)
                    }
                    .padding(.top, 80)
                    .padding(.bottom, 30)
                    
                    // Cards Section
                    VStack(spacing: 20) {
                        // Expenses
                        NavigationLink(destination: ExpensesListView()) {
                            NavigationCard(
                                title: "Expenses",
                                subtitle: "Record and view your spending",
                                icon: "cart.fill"
                            )
                        }
                        
                        // Income
                        NavigationLink(destination: IncomesListView()) {
                            NavigationCard(
                                title: "Income",
                                subtitle: "Add and track your income",
                                icon: "tray.full.fill"
                            )
                        }
                        
                        // Money Trends
                        NavigationLink(destination: TrendView()) {
                            NavigationCard(
                                title: "Trends",
                                subtitle: "Analyze spending patterns",
                                icon: "chart.line.uptrend.xyaxis"
                            )
                        }
                        
                        // Settings
                        NavigationLink(destination: SettingsView()) {
                            NavigationCard(
                                title: "Settings",
                                subtitle: "Customize your experience",
                                icon: "gearshape.fill"
                            )
                        }
                    }
                    .padding(.horizontal)
                    
                    Spacer()
                }
                .padding(.horizontal, 20)
            }
            .navigationBarHidden(true) // Hide default navigation bar
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        // Initialize ExpenseViewModel for previews
        let viewModel = ExpenseViewModel()
        return ContentView()
            .environmentObject(viewModel) // Inject viewModel into the environment
    }
}
