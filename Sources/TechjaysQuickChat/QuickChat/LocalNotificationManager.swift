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


class LocalNotificationManager {
    
    static let shared = LocalNotificationManager()
    
    func sendNotification(localNotification: LocalNotification) {
        let content = UNMutableNotificationContent()

        guard let title = localNotification.title else {return}
        guard let subTitle = localNotification.subTitle else {return}
        guard let body = localNotification.body else {return}
        content.title = title
        content.body = body
        content.setValue("YES", forKeyPath: "shouldAlwaysAlertWhileAppIsForeground")
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 60, repeats: true)
        let request = UNNotificationRequest(identifier: "notification.id.01", content: content, trigger: trigger)
        

        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
    }
    
    func getAccessPermissionAndNotify(localNotification: LocalNotification) {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert]) {
            (granted, error) in
            if granted {
                self.sendNotification(localNotification: localNotification)
            } else {
                return
            }
        }
    }
}
