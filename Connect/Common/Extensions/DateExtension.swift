//
//  DateExtension.swift
//  Connect
//
//  Created by Dino Martan on 28/07/2021.
//

import Foundation

enum DateStringStyle: String {
    
    case style1 = "HH:mm E, d MMM y"
    
}

extension Date {
    
    func getDate(style: DateFormatter.Style) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .none
        formatter.dateStyle = style
        let string = formatter.string(from: self)
        return string
    }
    
    func timeToString(style: DateFormatter.Style) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = style
        let string = formatter.string(from: self)
        return string
    }
    
    func toString(style: DateStringStyle) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = style.rawValue
        let string = formatter.string(from: self)
        return string
    }
    
    static func dates(from fromDate: Date, to toDate: Date) -> [Date] {
        var dates: [Date] = []
        var date = fromDate
        
        while date <= toDate {
            dates.append(date)
            guard let newDate = Calendar.current.date(byAdding: .day, value: 1, to: date) else { break }
            date = newDate
        }
        return dates
    }
    
}
