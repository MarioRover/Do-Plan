//
//  ListController.swift
//  Do Plan
//
//  Created by Hossein Akbari on 9/21/1399 AP.
//

import UIKit
import RealmSwift

class ListController: UIViewController, NewListDelegate {

    @IBOutlet weak var tableView: UITableView!
    
    let realm = try! Realm()

    var realmFilePath: String {
        get {
            return realm.configuration.fileURL!.deletingLastPathComponent().path
        }
    }
    
    var listArray: Results<List>?
    var selectedList: List?

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.register(UINib(nibName: Constant.Identifier.categoryCell, bundle: nil), forCellReuseIdentifier: Constant.Identifier.categoryCell)
        
        self.loadList()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Constant.Identifier.newListSegue {
            let vc = segue.destination as! NewListController
            vc.delegate = self

            if selectedList != nil {
                vc.selectedList = selectedList
                selectedList = nil
            }
        }
    }
    
    @IBAction func addButtonPressed(_ sender: UITapGestureRecognizer) {
        performSegue(withIdentifier: Constant.Identifier.newListSegue, sender: self)
    }
    // MARK: - Realm Methods
    func fetchFreshData() {
        loadList()
    }
    
    func loadList() {
        print("🔥Refresh list🔥")
        listArray = realm.objects(List.self).sorted(byKeyPath: "createdAt", ascending: true)
        tableView.reloadData()
    }
    
}

// MARK: - TableView

extension ListController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listArray?.count ?? 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: Constant.Identifier.categoryCell, for: indexPath) as! CategoryCell
         
        cell.titleLabel.text  = listArray?[indexPath.row].name
        cell.numberItems.text = "0"
            
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 55
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // TODO: - send data to controller
        performSegue(withIdentifier: Constant.Identifier.itemsSegue, sender: self)
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
            self.performSegue(withIdentifier: Constant.Identifier.newListSegue, sender: self)
            
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

