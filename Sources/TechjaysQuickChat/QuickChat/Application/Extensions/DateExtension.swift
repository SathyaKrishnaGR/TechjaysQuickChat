//
//  File.swift
//  
//
//  Created by SathyaKrishna on 25/09/21.
//

import Foundation

extension Date {
    func dateToString() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM dd,yyyy"
        return dateFormatter.string(from: self)
    }
}
