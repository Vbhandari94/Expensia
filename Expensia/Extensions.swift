//
//  Extensions.swift
//  Expensia
//
//  Created by Varun Bhandari on 14/12/24.
//

import UIKit

extension UIApplication {
    func endEditing() {
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
