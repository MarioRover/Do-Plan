//
//  ViewController.swift
//  Do Plan
//
//  Created by Hossein Akbari on 9/21/1399 AP.
//

import UIKit
import RealmSwift

class HomeController: UIViewController, NewItemDelegate {
    func fetchFreshList(type: Constant.TypeOfItems, category: Category?) {
        searchItems()
    }
    
    
    @IBOutlet weak var allLabel: UILabel!
    @IBOutlet weak var todayLabel: UILabel!
    @IBOutlet weak var scheduledLabel: UILabel!
    @IBOutlet weak var homeView: UIView!
    @IBOutlet weak var resultView: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: CustomSearchBar!
    private var itemArray: [Item]?
    private var selectedItem: Item?
    private var currentCategory: Category?
    private var searchBarText: String = ""
    
    
    private let realm = try! Realm()
    private var itemBoxTapped: Constant.TypeOfItems?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UINib(nibName: ItemCell.identifier, bundle: nil), forCellReuseIdentifier: ItemCell.identifier)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
    
        let allDoItems = realm.objects(Item.self).filter(NSPredicate(format: "done == false"))
        let allReminderItems = allDoItems.filter(NSPredicate(format: "reminder != null"))
        var countTodayTask = 0
        
        allLabel.text = String(allDoItems.count)
        scheduledLabel.text = String(allReminderItems.count)
        
        for item in allReminderItems {
            if let itemRemider = item.reminder {
                if Calendar.current.isDateInToday(itemRemider) {
                    countTodayTask += 1
                }
            }
        }
        todayLabel.text = String(countTodayTask)
        
        navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == ItemsController.identifier {
            let vc = segue.destination as! ItemsController
            vc.loadItems(itemType: itemBoxTapped!)
        }
        
        if segue.identifier == NewItemController.identifier {
            let vc = segue.destination as! NewItemController
            vc.delegate = self
            vc.currentCategory = currentCategory
            
            if selectedItem != nil {
                vc.selectedItem = selectedItem
                selectedItem = nil
            }
        }
    }
        
    @IBAction func allTapped(_ sender: UITapGestureRecognizer) {
        itemBoxTapped = .all
        performItemsSegue()
    }
    @IBAction func todayTapped(_ sender: UITapGestureRecognizer) {
        itemBoxTapped = .today
        performItemsSegue()
    }
    @IBAction func scheduledTapped(_ sender: UITapGestureRecognizer) {
        itemBoxTapped = .scheduled
        performItemsSegue()
    }
    
    private func performItemsSegue() {
        performSegue(withIdentifier: ItemsController.identifier, sender: self)
    }
}


extension HomeController: UISearchBarDelegate {
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        showHomeView(false, clearInput: false)
    }
        
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        showHomeView(true, clearInput: true)
        self.view.endEditing(true)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchBarText = searchText
        searchItems()
    }
    
    private func showHomeView(_ isShow: Bool, clearInput: Bool) {
        print(isShow)
        searchBar.setShowsCancelButton(!isShow, animated: true)
        homeView.isHidden   = !isShow
        resultView.isHidden = isShow
        itemArray = []
        if clearInput { searchBar.text = "" }
        tableView.reloadData()
    }
    
    private func searchItems() {
        if searchBarText.isEmpty {
            itemArray = []
        } else {
            itemArray = realm.objects(Item.self).filter(NSPredicate(format: "name CONTAINS[c] %@", searchBarText)).sorted(byKeyPath: "done", ascending: true).toArray()
        }
        tableView.reloadData()
    }

}

extension HomeController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemArray?.count ?? 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ItemCell.identifier, for: indexPath) as! ItemCell
        let cellTitle     = cell.itemTitle
        let cellPriority  = cell.priorityIcon
        let cellDoneIcon  = cell.doneCircle
        let reminderLabel = cell.reminderLabel
        let reminderView  = cell.reminderView
        
        
        if let item = itemArray?[indexPath.row] {
            // Create Custom Gusture for done image
            let recognizer = CustomUITapGesture(target: self, action: #selector(doneCirclePressed(sender:)))
            recognizer.index = indexPath.row
            cellDoneIcon?.addGestureRecognizer(recognizer)
            
            cellTitle?.text = item.name
            // Check Done Status
            if item.done == true {
                cellDoneIcon?.image = UIImage.systemIcon(name: .checkmarkCircleFill)
                cellDoneIcon?.tintColor = UIColor.customColor(color: .main)
                cellTitle?.textColor = UIColor.customColor(color: .grayDesc)
            } else {
                cellDoneIcon?.image = UIImage.systemIcon(name: .circle)
                cellDoneIcon?.tintColor = UIColor.customColor(color: .grayDesc)
                cellTitle?.textColor = .white
            }
            
            // Check Priority
            switch item.priority {
                case Priority.None.rawValue:
                        cell.priorityIcon.isHidden = true
                case Priority.High.rawValue:
                        cellPriority?.image = UIImage.systemIcon(name: .arrowUpCircle)
                        cellPriority?.tintColor = UIColor.customColor(color: .red)
                case Priority.Medium.rawValue:
                        cellPriority?.image = UIImage.systemIcon(name: .arrowUpRightCircle)
                        cellPriority?.tintColor = UIColor.customColor(color: .yellow)
                case Priority.Low.rawValue:
                        cellPriority?.image = UIImage.systemIcon(name: .arrowDownCircle)
                        cellPriority?.tintColor = UIColor.customColor(color: .green)
                default:
                    cell.priorityIcon.isHidden = true
            }
            
            // Check Reminder
            if let safeReminder = item.reminder, !item.done {
                reminderView?.isHidden = false
                reminderLabel?.text = Date.dateFormatToString(date: safeReminder, type: .standard)
                
                if safeReminder < Date() {
                    reminderLabel?.textColor = UIColor.customColor(color: .red)
                } else {
                    reminderLabel?.textColor = UIColor.customColor(color: .grayWhite)
                }
            } else {
                reminderView?.isHidden = true
            }
        }
    
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 55
    }
    
    @objc func doneCirclePressed(sender: CustomUITapGesture) {
        if let index = sender.index, let item = itemArray?[index] {
            do {
                try realm.write {
                    item.done = !item.done
                }
                searchItems()
            } catch {
                print("❌ Error in doneCirclePressed \(error)")
            }
        }
    }

    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let delete = UIContextualAction(style: .destructive, title: "Delete") { (action, view, completionHandler) in
            if let item = self.itemArray?[indexPath.row] {
                do {
                    try self.realm.write {
                        self.realm.delete(item)
                    }
                } catch {
                    print("❌ Error delete list index \(error)")
                }
            }
            self.tableView.reloadData()
            completionHandler(true)
        }
        
        delete.backgroundColor = .red
        
        let swipe = UISwipeActionsConfiguration(actions: [delete])
        return swipe
    
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        selectedItem = itemArray?[indexPath.row]
        currentCategory = itemArray?[indexPath.row].parentCategory[0]
        performSegue(withIdentifier: NewItemController.identifier, sender: self)
    }
    
    
}
