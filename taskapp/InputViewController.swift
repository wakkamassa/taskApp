//
//  InputViewController.swift
//  taskapp
//
//  Created by 　若原　昌史 on 2018/02/19.
//  Copyright © 2018年 WakaharaMasashi. All rights reserved.
//

import UIKit
import RealmSwift
import UserNotifications

class InputViewController: UIViewController {
   
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var contentsTextView: UITextView!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var category: UITextField!
    
    var task: Task!
    let realm = try! Realm()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let tapGesture:UITapGestureRecognizer = UITapGestureRecognizer(target:self,action:#selector(dismissKeyboard))
        self.view.addGestureRecognizer(tapGesture)
        titleTextField.text = task.title
        contentsTextView.text = task.contents
        datePicker.date = task.date
        category.text = task.category
        // Do any additional setup after loading the view.
    }
    
    @objc func dismissKeyboard(){
        view.endEditing(true)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        try! realm.write{
            self.task.title = self.titleTextField.text!
            self.task.contents = self.contentsTextView.text
            self.task.category = self.category.text!
            self.task.date = self.datePicker.date
            self.realm.add(self.task,update:true)
             setNotification(task: task)
        }
        
        
        super.viewWillDisappear(animated)
        
        func setNotification(task: Task){
            let content = UNMutableNotificationContent()
            if task.title == ""{
                content.title = "(タイトルなし)"
            }else{
                content.title = task.title
            }

            if task.contents == ""{
                content.body = "(内容なし)"
            }else{
                content.body = task.contents
            }
            
            content.sound = UNNotificationSound.default()
            
            let calendar = Calendar.current
            let dateComponents = calendar.dateComponents([.year, .month , .day, .hour, .minute],from: task.date)
            let trigger = UNCalendarNotificationTrigger.init(dateMatching: dateComponents, repeats: false)
            let request = UNNotificationRequest.init(identifier: String(task.id),content:content,trigger:trigger)
            let center = UNUserNotificationCenter.current()
            
            center.add(request){(error) in
                print(error ?? "ローカル通知OK")
            }
            center.getPendingNotificationRequests{(requests: [UNNotificationRequest])in
                for request in requests{
                    print("/--------")
                    print(request)
                    print("/--------/")
                }
            }
            
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
