//
//  Dateformatter.swift
//  VideoFeed
//
//  Created by Abouzar Moradian on 6/4/24.
//

import Foundation
import FirebaseFirestore

class TimeFormatter{
    
    static let shared = TimeFormatter()
    private init() { }
    
    
    func timeAgoFormatter(time: Timestamp) -> String {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.second, .minute, .hour, .day, .weekOfMonth]
        formatter.maximumUnitCount = 1
        formatter.unitsStyle = .abbreviated
        return formatter.string(from: time.dateValue(), to: Date()) ?? ""
    }
    
    func timeAMPMFormatter(time: Timestamp) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return formatter.string(from: time.dateValue())
    }
    
    
    func timelineformatter(time: Timestamp) -> String {
        let calendar = Calendar.current
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM d"
        
        let now = Date()
        
        if calendar.isDateInToday(time.dateValue()) {
            return "Today"
        } else if calendar.isDate(time.dateValue(), equalTo: now, toGranularity: .year) {
            dateFormatter.dateFormat = "MMM d, EEEE"
            return dateFormatter.string(from: time.dateValue())
        } else {
            dateFormatter.dateFormat = "MMM d, yyyy"
            return dateFormatter.string(from: time.dateValue())
        }
    }
    
    

    func ActualDateFormatter(_ timestamp: Timestamp) -> String {
        let inputDate = timestamp.dateValue()
        let currentDate = Date()

        let calendar = Calendar.current
        let components = calendar.dateComponents([.day], from: inputDate, to: currentDate)

        if let dayDifference = components.day, dayDifference > 7 {
            let formatter = DateFormatter()
            formatter.dateFormat = "MM/dd/yy"
            return formatter.string(from: inputDate)
        } else {
            let formatter = DateFormatter()
            formatter.dateFormat = "EEEE"
            return formatter.string(from: inputDate)
        }
    }
    
    func textTimeformatter(_ timestamp: Timestamp) -> (dateString: String, timeString: String) {
        let date = timestamp.dateValue()

        // Date Formatter for the date
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM d, yyyy" // Example: "May 25, 2024"

        // Date Formatter for the time
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "h:mm a" // Example: "10:23 AM"

        // Get the formatted date and time strings
        let dateString = dateFormatter.string(from: date)
        let timeString = timeFormatter.string(from: date)

        return (dateString, timeString)
    }
    
    
    
    
    func standardTimeFormatted(timestamp: Timestamp) -> String {
        
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MMM d, yyyy"
            return dateFormatter.string(from: timestamp.dateValue())
        }
    

     func formattedPrice(_ price: Double) -> String {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        numberFormatter.maximumFractionDigits = 0 // No decimal points for whole dollars
        return numberFormatter.string(from: NSNumber(value: price)) ?? "\(price)"
    }
    
    
    
    func lastChatformatter(_ timestamp: Timestamp) -> String {
        let date = timestamp.dateValue()
        let calendar = Calendar.current
        let dateFormatter = DateFormatter()
        
        if calendar.isDateInToday(date) {
            dateFormatter.dateFormat = "h:mm a"
            return dateFormatter.string(from: date)
        } else if calendar.isDateInYesterday(date) {
            return "Yesterday"
        } else if calendar.isDate(date, equalTo: Date(), toGranularity: .weekOfYear) {
            dateFormatter.dateFormat = "EEEE"
            return dateFormatter.string(from: date)
        } else {
            dateFormatter.dateFormat = "MM/dd/yy"
            return dateFormatter.string(from: date)
        }
    }
    
}
