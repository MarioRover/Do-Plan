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

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.register(UINib(nibName: Constant.Identifier.categoryCell, bundle: nil), forCellReuseIdentifier: Constant.Identifier.categoryCell)
        
        self.loadList()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Constant.Identifier.newListSegue {
            let vc = segue.destination as! NewListController
            vc.delegate = self
        }
    }
    
    func fetchFreshData() {
        loadList()
    }
    // MARK: - Realm Methods
    
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
         
        cell.titleLabel.text = listArray?[indexPath.row].name
//        cell.descLabel.text  = items[indexPath.row].desc
//        cell.numberItems.text = items[indexPath.row].numberitems
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 55
    }
    
    @IBAction func addButtonPressed(_ sender: UITapGestureRecognizer) {
        performSegue(withIdentifier: Constant.Identifier.newListSegue, sender: self)
    }
    
}

