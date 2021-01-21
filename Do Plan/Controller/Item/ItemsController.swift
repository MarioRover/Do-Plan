//
//  ItemsController.swift
//  Do Plan
//
//  Created by Hossein Akbari on 10/4/1399 AP.
//

import UIKit
import RealmSwift

class ItemsController: MyUIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    var pageTitle: String?
    var itemArray: Results<Item>?
    let realm = try! Realm()
    var selectedItem: Item?
    var currentCategory: Category? {
        didSet {
            loadItems()
        }
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = pageTitle
        tableView.register(UINib(nibName: Constant.Identifier.itemCell, bundle: nil), forCellReuseIdentifier: Constant.Identifier.itemCell)
    }
    
    @IBAction func addButtonPressed(_ sender: UITapGestureRecognizer) {
        performSegue(withIdentifier: Constant.Segue.newItem, sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Constant.Segue.newItem {
            let vc = segue.destination as! NewItemController
            vc.delegate = self
            vc.currentCategory = currentCategory
            
            if selectedItem != nil {
                vc.selectedItem = selectedItem
                selectedItem = nil
            } 
        }
    }
    
    func loadItems(doReload: Bool = false) {
        itemArray = currentCategory?.items.sorted(byKeyPath: "createdAt", ascending: true)
        if doReload {
            tableView.reloadData()
        }
    }
}


// MARK: - Table View

extension ItemsController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemArray?.count ?? 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Constant.Identifier.itemCell, for: indexPath) as! ItemCell
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
            } else {
                cellDoneIcon?.image = UIImage.systemIcon(name: .circle)
                cellDoneIcon?.tintColor = UIColor.customColor(color: .grayDesc)
            }
            
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
            
            if let safeReminder = item.reminder {
                reminderView?.isHidden = false
                reminderLabel?.text = Date.dateFormatToString(date: safeReminder, type: .standard)
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
                loadItems(doReload: true)
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
        performSegue(withIdentifier: Constant.Segue.newItem, sender: self)
    }
    
}

// MARK: - SearchBar

extension ItemsController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            loadItems(doReload: true)
        } else {
            itemArray = itemArray?.filter("name CONTAINS[cd] %@", searchText).sorted(byKeyPath: "createdAt", ascending: true)
            tableView.reloadData()
        }
    }
}

// MARK: - NewItemDelegate

extension ItemsController: NewItemDelegate {
    func fetchFreshList() {
        loadItems(doReload: true)
    }
}

// MARK: - Custom UIGestureRecongnizer

class CustomUITapGesture: UITapGestureRecognizer {
    var index: Int?
}
