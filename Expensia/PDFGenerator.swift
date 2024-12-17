//
//  PDFGenerator.swift
//  SpendSense
//
//  Created by Varun Bhandari on 25/11/24.
//


//
//  PDFGenerator.swift
//  SpendSense
//
//  Created by Varun Bhandari on 25/11/24.
//

//
//  PDFGenerator.swift
//  SpendSense
//
//  Created by Varun Bhandari on 25/11/24.
//

//
//  PDFGenerator.swift
//  SpendSense
//
//  Created by Varun Bhandari on 25/11/24.
//

import UIKit
import PDFKit

struct PDFGenerator {
    static func createExpenseReport(expenses: [Expense]) -> Data {
        // Metadata for the report
        let pdfMeta = """
        Expense Report
        Generated on: \(DateFormatter.localizedString(from: Date(), dateStyle: .medium, timeStyle: .short))
        
        """

        // Formatting the content of the report
        let content = expenses.map { expense in
            """
            Date: \(DateFormatter.localizedString(from: expense.date ?? Date(), dateStyle: .medium, timeStyle: .none))
            Amount: ₹\(String(format: "%.2f", (expense.amount as? Double) ?? 0.0))
            Category: \(expense.category ?? "")
            Description: \(expense.description)
            
            """
        }.joined(separator: "\n")

        let fullText = pdfMeta + content

        // Create an attributed string for measurement and drawing
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .left
        let attributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 12),
            .paragraphStyle: paragraphStyle
        ]

        let attributedText = NSAttributedString(string: fullText, attributes: attributes)

        // Page bounds
        let pageRect = CGRect(x: 0, y: 0, width: 612, height: 792) // Letter size
        let textInset = CGRect(x: 20, y: 20, width: 572, height: 752)

        // Prepare a framesetter
        let framesetter = CTFramesetterCreateWithAttributedString(attributedText)
        
        // Iterate through the text to paginate it
        var currentIndex = 0
        let pdfRenderer = UIGraphicsPDFRenderer(bounds: pageRect)

        return pdfRenderer.pdfData { context in
            while currentIndex < attributedText.length {
                context.beginPage()
                
                // Determine how much text fits on this page
                let path = CGMutablePath()
                path.addRect(textInset)
                let frameRef = CTFramesetterCreateFrame(framesetter, CFRange(location: currentIndex, length: 0), path, nil)
                let frameRange = CTFrameGetVisibleStringRange(frameRef)

                // Draw the text for this page
                let cgContext = context.cgContext
                cgContext.textMatrix = .identity
                cgContext.translateBy(x: 0, y: pageRect.size.height)
                cgContext.scaleBy(x: 1.0, y: -1.0)

                CTFrameDraw(frameRef, cgContext)

                // Move the index forward by the length that was drawn
                currentIndex += frameRange.length
            }
        }
    }
}
