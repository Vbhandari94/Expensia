//
//  NavigationCard.swift
//  SpendSense
//
//  Created by Varun Bhandari on 25/11/24.
//


//
//  NavigationCard.swift
//  SpendSense
//
//  Created by Varun Bhandari on 25/11/24.
//

import SwiftUI

struct NavigationCard: View {
    let title: String
    let subtitle: String
    let icon: String

    var body: some View {
        HStack {
            Image(systemName: icon)
                .font(.system(size: 45))
                .foregroundColor(Color("AccentColor"))
                .padding(.trailing, 15)

            VStack(alignment: .leading, spacing: 5) {
                Text(title)
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundColor(Color("TextColor"))
                Text(subtitle)
                    .font(.footnote)
                    .foregroundColor(Color.gray)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.system(size: 18))
                .foregroundColor(Color.gray.opacity(0.6))
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(Color("CardBackgroundColor"))
                .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 5)
        )
    }
}

struct NavigationCard_Previews: PreviewProvider {
    static var previews: some View {
        NavigationCard(
            title: "Expenses",
            subtitle: "Record and view your spending",
            icon: "cart.fill"
        )
        .previewLayout(.sizeThatFits)
        .padding()
    }
}