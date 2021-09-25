//
//  File.swift
//  
//
//  Created by SathyaKrishna on 25/09/21.
//

import Foundation

extension Date {
    func dateToString() -> String {
        let dateFormatterPrint = DateFormatter()
        dateFormatterPrint.dateFormat = "MMM dd,yyyy"
        return dateFormatterGet.date(from: self)
    }
}
