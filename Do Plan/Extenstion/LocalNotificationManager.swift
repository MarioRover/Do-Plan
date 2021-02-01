//
//  TaskNotification.swift
//  Do Plan
//
//  Created by Hossein Akbari on 11/10/1399 AP.
//

import UserNotifications
import UIKit

struct LocalNotification {
    var id: String
    var title: String
    var body: String
}

struct LocalNotificationManager {
    
    static private var notifications = [LocalNotification]()
    
    static private func requestPermission() -> Void {
        UNUserNotificationCenter
            .current()
            .requestAuthorization(options: [.alert, .badge, .alert]) { granted, error in
                if granted && error == nil {
                    // We have permission!
                }
        }
    }
    
    static private func addNotification(title: String, body: String) -> Void {
        notifications.append(LocalNotification(id: UUID().uuidString, title: title, body: body))
    }
        
    static func cancel() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
    
    static func setNotification(date: Date, repeats: Bool, title: String, body: String) {
        requestPermission()
        addNotification(title: title, body: body)
        
        for notification in notifications {
            let content = UNMutableNotificationContent()
            content.title = notification.title
            content.body  = notification.body
            content.sound = UNNotificationSound.default
            content.badge = NSNumber(value: UIApplication.shared.applicationIconBadgeNumber + 1)
            
            let trigger = UNCalendarNotificationTrigger(dateMatching: Calendar.current.dateComponents([.year,.month,.day,.hour,.minute,.second], from: date), repeats: repeats)
            let request = UNNotificationRequest(identifier: notification.id, content: content, trigger: trigger)
            
            UNUserNotificationCenter.current().add(request) { (error) in
                guard error == nil else {
                    print("❌ Error scheduling notification \(error.debugDescription)")
                    return
                }
                print("✅ Scheduling notification with id: \(notification.id)")
            }
        }
        notifications.removeAll()
        
    }

}


