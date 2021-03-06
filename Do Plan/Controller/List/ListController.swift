//
//  ListController.swift
//  Do Plan
//
//  Created by Hossein Akbari on 9/21/1399 AP.
//

import UIKit
import RealmSwift

class ListController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    let realm = try! Realm()
    var listArray: Results<Category>?
    var selectedList: Category?
    var realmFilePath: String {
        get {
            return realm.configuration.fileURL!.deletingLastPathComponent().path
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        print(realmFilePath)
        tableView.register(UINib(nibName: CategoryCell.identifier, bundle: nil), forCellReuseIdentifier: CategoryCell.identifier)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        loadList()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == NewListController.identifier {
            let vc = segue.destination as! NewListController
            vc.delegate = self

            if selectedList != nil {
                vc.selectedList = selectedList
                selectedList = nil
            }
        }
        
        if segue.identifier == ItemsController.identifier {
            let vc = segue.destination as! ItemsController

            if selectedList != nil {
                vc.loadItems(itemType: .category, category: selectedList)
                selectedList = nil
            }
                        
        }
    }
    
    @IBAction func addButtonPressed(_ sender: UITapGestureRecognizer) {
        performSegue(withIdentifier: NewListController.identifier, sender: self)
    }
    
    func loadList() {
        print("🔥Refresh list🔥")
        listArray = realm.objects(Category.self).sorted(byKeyPath: "createdAt", ascending: true)
        tableView.reloadData()
    }
    
}

// MARK: - TableView

extension ListController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listArray?.count ?? 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: CategoryCell.identifier, for: indexPath) as! CategoryCell
         
        cell.titleLabel.text  = listArray?[indexPath.row].name
        
        if let items = listArray?[indexPath.row].items {
            
            var doneCount: Int = 0
            var result: Double = 0
            var roundResult: Float = 0
            
            for item in items {
                if item.done {
                    doneCount += 1
                }
            }
            
            if items.count > 0 {
                result = Double(doneCount) / Double(items.count)
                roundResult = Float(String(format: "%.2f", result))!
            }
            
            cell.precentLabel.text = "\(String(Int(roundResult * 100)))%"
            cell.progressBar.progress = roundResult
        }
        
        
            
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 55
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedList = listArray?[indexPath.row]
        performSegue(withIdentifier: ItemsController.identifier, sender: self)
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let delete = UIContextualAction(style: .destructive, title: "Delete") { (action, view, completionHandler) in
            
            let alertTitle = "Delete \"\(self.listArray?[indexPath.row].name ?? "")\"?"
            let alertMessage = "This will delete all items in this list"
                
            let alert = UIAlertController(title: alertTitle, message: alertMessage, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
            alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { (action) in
                if let item = self.listArray?[indexPath.row] {
                    do {
                        try self.realm.write {
                            self.realm.delete(item)
                        }
                    } catch {
                        print("❌ Error delete list index \(error)")
                    }
                }
                self.tableView.reloadData()
            }))
            self.present(alert, animated: true, completion: nil)
            completionHandler(true)
        }
        let info = UIContextualAction(style: .normal, title: "Info") { (action, view, completionHandler) in
            
            self.selectedList = self.listArray?[indexPath.row]
            self.performSegue(withIdentifier: NewListController.identifier, sender: self)
            
            completionHandler(true)
        }
        
        
        delete.backgroundColor = .red
        delete.image = UIImage(systemName: "trash.fill")
        
        info.backgroundColor   = UIColor(named: Constant.Color.grayDark)
        info.image = UIImage(systemName: "info.circle.fill")
        
        let swipe = UISwipeActionsConfiguration(actions: [delete, info])
        return swipe
    }
    
}

// MARK: - NewListController Delegate

extension ListController: NewListDelegate {
    func fetchFreshData() {
        loadList()
    }
}

