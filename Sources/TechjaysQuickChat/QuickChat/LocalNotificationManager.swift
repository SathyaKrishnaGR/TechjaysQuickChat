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
        let content = UNMutableNotificationContent()
        UNUserNotificationCenter.current().delegate = self
        guard let title = localNotification.title else {return}
//        guard let subTitle = localNotification.subTitle else {return}
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

extension LocalNotificationManager: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                    willPresent notification: UNNotification,
                                    withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
            let userInfo = notification.request.content.userInfo
            print(userInfo) // the payload that is attached to the push notification
            // you can customize the notification presentation options. Below code will show notification banner as well as play a sound. If you want to add a badge too, add .badge in the array.
            completionHandler([.alert,.sound])
        }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                       didReceive response: UNNotificationResponse,
                                       withCompletionHandler completionHandler: @escaping () -> Void) {
               let userInfo = response.notification.request.content.userInfo
               // Print full message.
               print("tap on on forground app",userInfo)
               completionHandler()
           }
}
