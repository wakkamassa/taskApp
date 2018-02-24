//
//  ViewController.swift
//  taskapp
//
//  Created by 　若原　昌史 on 2018/02/17.
//  Copyright © 2018年 WakaharaMasashi. All rights reserved.
//

import UIKit
import RealmSwift
import UserNotifications

class ViewController: UIViewController,UITableViewDelegate,UITableViewDataSource,UISearchBarDelegate {
    @IBOutlet weak var tableView: UITableView!
    var task :Task!
    @IBOutlet weak var seachCategory: UISearchBar!
    
    let realm = try! Realm()
    
    var taskArray = try! Realm().objects(Task.self).sorted(byKeyPath:"date",ascending:false)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        seachCategory.delegate = self
        
        let tapGesture:UITapGestureRecognizer = UITapGestureRecognizer(target:self,action:#selector(dismissKeyboard))
        self.view.addGestureRecognizer(tapGesture)
        
        
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    @objc func dismissKeyboard(){
        view.endEditing(true)
    }
    
    func tableView(_ tableView:UITableView, numberOfRowsInSection section: Int) -> Int{
        return taskArray.count
    }
    
    func tableView( _ tableView: UITableView,cellForRowAt indexPath:IndexPath) ->UITableViewCell{
        let cell = tableView.dequeueReusableCell(withIdentifier:"Cell",for: indexPath)
        
        let task = taskArray[indexPath.row]
        
        cell.textLabel?.text = task.title
        
        let formatter = DateFormatter()
        
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
       
        let dateString:String = formatter.string(from: task.date )
        
        cell.detailTextLabel?.text = dateString
        
        return cell
    }
    
    func tableView(_ tableView:UITableView, didSelectRowAt indexPath:IndexPath){
        
        performSegue(withIdentifier: "cellSegue",sender:nil)
    }
    
    func tableView(_
        tableView:UITableView,editingStyleForRowAt indexPath:IndexPath)->UITableViewCellEditingStyle{
        return .delete
    }
    
    func tableView(_ tableView:UITableView, commit editingStyle: UITableViewCellEditingStyle,forRowAt indexPath:IndexPath){
        
        if editingStyle == .delete{
            let task = self.taskArray[indexPath.row]
            let center = UNUserNotificationCenter.current()
            center.removePendingNotificationRequests(withIdentifiers: [String(task.id)])
            
            try! realm.write{
                self.realm.delete(self.taskArray[indexPath.row])
                tableView.deleteRows(at:[indexPath],with: .fade)
            }
            
                center.getPendingNotificationRequests{(requests:[UNNotificationRequest]) in
                for request in requests{
                print("/-----")
                print("request")
                print("/-------/")
                }
        
        }
    }
    }
    
        override func prepare(for segue:UIStoryboardSegue,sender: Any?){
        let inputViewController:InputViewController = segue.destination as! InputViewController
        if segue.identifier == "cellSegue"{
            let indexPath = self.tableView.indexPathForSelectedRow
            inputViewController.task = taskArray[indexPath!.row]
        }else{
            let task = Task()
            task.date = Date()
            let taskArray = realm.objects(Task.self)
            if taskArray.count != 0{
                task.id = taskArray.max(ofProperty: "id")! + 1
            }
            inputViewController.task = task
        }
    }
    override func viewWillAppear(_ animated: Bool){
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
   

    
    func searchBarSearchButtonClicked(_ seachBar:UISearchBar){
        if seachCategory.text != "" {
            let predicate = NSPredicate(format: "category CONTAINS[c]%@",self.seachCategory.text!)
         taskArray = realm.objects(Task.self).filter(predicate).sorted(byKeyPath:"date",ascending:false)
            
        }else if seachCategory.text! == ""{
            taskArray = try! Realm().objects(Task.self).sorted(byKeyPath:"date",ascending:false)
        }
        tableView.reloadData()
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

