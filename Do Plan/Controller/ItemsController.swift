//
//  ItemsController.swift
//  Do Plan
//
//  Created by Hossein Akbari on 10/4/1399 AP.
//

import UIKit
import RealmSwift

class ItemsController: UIViewController {
    
    
    @IBOutlet weak var tableView: UITableView!
    
    var pageTitle: String?
    
    var currentCategory: Category? {
        didSet {
            loadItems()
        }
    }
    var itemArray: Results<Item>?

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
            vc.currentCategory = currentCategory
        }
    }
    
    func loadItems() {
        itemArray = currentCategory?.items.sorted(byKeyPath: "createdAt", ascending: true)
    }
}


// MARK: - Table View

extension ItemsController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemArray?.count ?? 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Constant.Identifier.itemCell, for: indexPath) as! ItemCell
        
        cell.itemTitle.text = itemArray?[indexPath.row].name
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 55
    }
}

