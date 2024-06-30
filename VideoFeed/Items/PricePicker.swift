//
//  PricePicker.swift
//  VideoFeed
//
//  Created by Abouzar Moradian on 6/4/24.
//

import SwiftUI

struct PricePicker: View {
    @Binding var selectedPrice: Double
    @Binding var step: Double
    @Binding var range: ClosedRange<Double>
    @Binding var category: String
    var priceText: String {
        var text: String
        switch category{
        
        case ListingCategory.event.rawValue:
            text = "Ticket Price: "
        case ListingCategory.sublease.rawValue:
            text = "Monthly Rent: "
        case ListingCategory.sale.rawValue:
            text = "Price: "
        default:
            text = "Offered Compensation: "
        }
        
        return text
    }

    var body: some View {
        VStack {
            Text("\(priceText)$\(formattedPrice)")
            Slider(value: $selectedPrice, in: range, step: step)
        }
    }

    private var formattedPrice: String {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        numberFormatter.maximumFractionDigits = 0 // No decimal points for whole dollars
        return numberFormatter.string(from: NSNumber(value: selectedPrice)) ?? "\(selectedPrice)"
    }
}



