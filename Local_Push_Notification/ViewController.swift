//
//  ViewController.swift
//  Local_Push_Notification
//
//  Created by Awadhesh Pratap Singh on 22/02/24.
//

import UIKit

class ViewController: UIViewController, UITextFieldDelegate,UNUserNotificationCenterDelegate {
    @IBOutlet weak var DatePickerVC: UIDatePicker!
    @IBOutlet weak var TitleTextField: UITextField!
    @IBOutlet weak var BodyTextField: UITextField!
    @IBOutlet weak var alertLabel: UILabel!
    
    var TitleMessage = String()
    var BodyMessage = String()
    var SelectedDate = Date()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        UNUserNotificationCenter.current().delegate = self
        DatePickerVC.minimumDate = Date()
        DatePickerVC.setDate(Date().addingTimeInterval(60), animated: false) // Set the date picker to current time + 1 minute
        SelectedDate = DatePickerVC.date
        alertLabel.text = ""
        TitleTextField.delegate = self
        BodyTextField.delegate = self
    }
    
    @IBAction func submitButton(_ sender: UIButton) {
        guard let Title = TitleTextField.text?.trimmed() , Title != "" else {
            alertLabel.text = "Please fill the Title."
            alertLabel.textColor = UIColor.systemRed
            return
        }
        guard let Body = BodyTextField.text?.trimmed() , Body != "" else {
            alertLabel.text = "Please fill the Body."
            alertLabel.textColor = UIColor.systemRed
            return
        }
        TitleMessage = Title
        BodyMessage = Body
        checkForPermission()
        self.alertLabel.text = "Notification timer is set, Kindly wait till \(SelectedDate)"
        self.alertLabel.textColor = UIColor.systemGray
    }
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        // Display the notification while the app is in the foreground
        completionHandler([.alert, .sound])
    }
    func checkForPermission() {
        let noficationCenter = UNUserNotificationCenter.current()
        noficationCenter.getNotificationSettings { setting in
            switch setting.authorizationStatus {
            case .notDetermined:
                noficationCenter.requestAuthorization(options: [.alert, .sound]) { didAllow, error in
                    if didAllow{
                        self.dispatchNotification()
                    }
                }
            case .denied:
                return
            case .authorized:
                self.dispatchNotification()
            default:
                return
        }
      }
    }
    
    func dispatchNotification(){
        let identifier = "my-notification"
        let title = TitleMessage
        let body = BodyMessage
//        let hour = 15
//        let minute = 23
        let isDaily = true
        let notificatioinCenter = UNUserNotificationCenter.current()
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        
        let calendar = Calendar.current
        let dateComponents = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: SelectedDate)
    //    var dateComponents = DateComponents(calendar: calendar, timeZone: TimeZone.current)
//        dateComponents.hour = hour
//        dateComponents.minute = minute
//        dateComponents.date = SelectedDate
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: isDaily)
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        notificatioinCenter.removePendingNotificationRequests(withIdentifiers: [identifier])
        notificatioinCenter.add(request)
    }
    
    @IBAction func datePickerValueChanged(_ sender: UIDatePicker) {
           let selectedDate = sender.date
        SelectedDate = selectedDate
           // Use the selectedDate as needed
           print("Selected date: \(selectedDate)")
       }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
          textField.resignFirstResponder()
          return true
      }
      
}


extension String{
    func trimmed () -> String {
        return trimmedLeft().trimmedRight()
    }
    
    func trimmedLeft (characterSet set: CharacterSet = CharacterSet.whitespacesAndNewlines) -> String {
            
            if let range = rangeOfCharacter(from: set.inverted) {
                return String(self[range.lowerBound..<endIndex])
            }
            
            return ""
        }
    func trimmedRight (characterSet set: CharacterSet = CharacterSet.whitespacesAndNewlines) -> String {
            
            if let range = rangeOfCharacter(from: set.inverted, options: NSString.CompareOptions.backwards) {
                return String(self[startIndex..<range.upperBound])
            }
            
            return ""
        }
}
