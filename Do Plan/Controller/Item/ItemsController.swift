//
//  ItemsController.swift
//  Do Plan
//
//  Created by Hossein Akbari on 10/4/1399 AP.
//

import UIKit
import RealmSwift

class ItemsController: UIViewController {
    static let identifier = "itemsVCIdentifier"
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var navigationBar: UINavigationBar!
    @IBOutlet weak var addButton: CustomUIView!
    
    private let realm = try! Realm()
    private var itemArray: [Item]?
    private var selectedItem: Item?
    private var currentCategory: Category?
    private var customNavigation = (show: true, title: "title")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UINib(nibName: ItemCell.identifier, bundle: nil), forCellReuseIdentifier: ItemCell.identifier)
        navigationBar.isHidden = customNavigation.show
        navigationBar.topItem?.title = customNavigation.title
        
        addButton.isHidden = customNavigation.show
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
 
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
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
    
    @IBAction func addButtonPressed(_ sender: UITapGestureRecognizer) {
        performSegue(withIdentifier: NewItemController.identifier, sender: self)
    }
}


// MARK: - Table View

extension ItemsController: UITableViewDelegate, UITableViewDataSource {
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
                loadItems(itemType: .category)
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

// MARK: - Show List From Home

extension ItemsController {    
    @IBAction func backButtonPressed(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    public func loadItems(itemType: Constant.TypeOfItems, category: Category? = nil) -> Void {
        if itemType == .category {
            if let safeCategory = category {
                itemArray = safeCategory.items.sorted(byKeyPath: "done", ascending: true).toArray()
                self.title = category?.name
            }
        } else {
            customNavigation = (show: false, title: itemType.rawValue)
            
            switch itemType {
                case .today:
                    var result = [Item]()
                    let items = realm.objects(Item.self).filter(NSPredicate(format: "done == false && reminder != nil")).toArray()
                    for item in items {
                        if let itemReminder = item.reminder {
                            if Calendar.current.isDateInToday(itemReminder) {
                                result.append(item)
                            }
                        }
                    }
                    itemArray = result
                    
                case .scheduled:
                    itemArray = realm.objects(Item.self).filter(NSPredicate(format: "done == false && reminder != nil")).toArray()
                default:
                    itemArray = realm.objects(Item.self).filter(NSPredicate(format: "done == false")).sorted(byKeyPath: "createdAt", ascending: true).toArray()
            }
        }
        tableView?.reloadData()
    }
}

// MARK: - NewItemDelegate

extension ItemsController: NewItemDelegate {
    func fetchFreshList() {
        loadItems(itemType: .category)
    }
}

// MARK: - Custom UIGestureRecongnizer

class CustomUITapGesture: UITapGestureRecognizer {
    var index: Int?
}
