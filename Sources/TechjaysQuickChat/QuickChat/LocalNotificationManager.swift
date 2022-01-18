//
//  File.swift
//  
//
//  Created by SathyaKrishna on 25/09/21.
//

import Foundation
import UIKit
import UserNotifications


struct LocalNotification {
    var title: String?
    var subTitle: String?
    var body: String?
}


class LocalNotificationManager: NSObject {
    
    static let shared = LocalNotificationManager()
    
    func sendNotification(localNotification: LocalNotification) {
        let center = UNUserNotificationCenter.current()
        let content = UNMutableNotificationContent()
        guard let title = localNotification.title else {return}
        //        guard let subTitle = localNotification.subTitle else {return}
        guard let body = localNotification.body else {return}
        content.title = title
        content.body = body
        
        content.sound = .default
        let fireDate = Calendar.current.dateComponents([.day, .month, .year, .hour, .minute, .second], from: Date().addingTimeInterval(20))
        let trigger = UNCalendarNotificationTrigger(dateMatching: fireDate, repeats: false)
        let request = UNNotificationRequest(identifier: "reminder", content: content, trigger: trigger)
        center.add(request) { (error) in
            if error != nil {
                print("Error = \(error?.localizedDescription ?? "error local notification")")
            }
        }
        /*
         let content = UNMutableNotificationContent()
         //        UNUserNotificationCenter.current().delegate = self
         let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 0.5, repeats: false)
         let request = UNNotificationRequest(identifier: "notification.id.01", content: content, trigger: trigger)
         
         
         UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
         */
    }
    
//    func getAccessPermissionAndNotify(localNotification: LocalNotification) {
//        UNUserNotificationCenter.current().delegate = self
//        UNUserNotificationCenter.current().requestAuthorization(options: [.alert]) {
//            (granted, error) in
//            if granted {
//                self.sendNotification(localNotification: localNotification)
//            } else {
//                return
//            }
//        }
//    }
}

extension LocalNotificationManager: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        let userInfo = notification.request.content.userInfo
        print("UserNtification userInfo \(userInfo)")
        completionHandler([.alert,.sound])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        print("tap on on forground app",userInfo)
        completionHandler()
    }
}
