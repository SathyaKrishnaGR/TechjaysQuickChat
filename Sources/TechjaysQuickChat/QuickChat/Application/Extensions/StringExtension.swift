//  MIT License

//  Copyright (c) 2019 Haik Aslanyan

//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:

//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.

//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.

import Foundation
import CoreLocation

extension String {
  
  func isValidEmail() -> Bool {
    let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
    let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
    return emailTest.evaluate(with: self)
  }
  
  var location: CLLocationCoordinate2D? {
    let coordinates = self.components(separatedBy: ":")
    guard coordinates.count == 2 else { return nil }
    return CLLocationCoordinate2D(latitude: Double(coordinates.first!)!, longitude: Double(coordinates.last!)!)
  }
    func getElapsedIntervalWithAgo() -> String {
        let components: Set<Calendar.Component> = [.year, .month, .day, .hour, .minute]
//        let dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        let dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        guard let date = self.toDate(dateFormat: dateFormat) else { return "" }
        
        var utcCalender = Calendar.current
        utcCalender.timeZone = TimeZone(abbreviation: "UTC")!
        let fromDate = utcCalender.dateComponents(components, from: date)
        
        var localCalender = Calendar.current
        localCalender.timeZone = TimeZone(abbreviation: "UTC")!
        let localDate = localCalender.dateComponents(components, from: Date())
        
        let interval = Calendar.current.dateComponents(components, from: fromDate, to: localDate)
        
        if let year = interval.year, year > 0 {
            return year == 1 ? "\(year)" + " " + "year ago" :
                "\(year)" + " " + "years ago"
        } else if let month = interval.month, month > 0 {
            return month == 1 ? "\(month)" + " " + "month ago" :
                "\(month)" + " " + "months ago"
        } else if let day = interval.day, day > 0 {
            return day == 1 ? "\(day)" + " " + "day ago" :
                "\(day)" + " " + "days ago"
        } else if let hour = interval.hour, hour > 0 {
            return hour == 1 ? "\(hour)" + " " + "hour ago" :
                "\(hour)" + " " + "hours ago"
        } else if let min = interval.minute, min > 0 {
            return min == 1 ? "\(min)" + " " + "min ago" :
                "\(min)" + " " + "mins ago"
        } else {
            return "moment ago"
        }
    }
    
    func toDate(dateFormat: String, timezone: TimeZone = TimeZone(abbreviation: "UTC")!) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = dateFormat
        dateFormatter.timeZone = timezone
        guard let date = dateFormatter.date(from: self) else { return nil }
        return date
    }
    
    func stringToDate() -> Date {
        let dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        if let date = self.toDate(dateFormat: dateFormat) {
            return date
        }
        return Date()
    }
}
