//
//  NetSavingsDataPoint.swift
//  SpendSense
//
//  Created by Varun Bhandari on 25/11/24.
//


import Foundation

struct NetSavingsDataPoint: Identifiable {
    let id = UUID()
    let date: Date
    let netSavings: Double
}
