//
//  ViewController.swift
//  Do Plan
//
//  Created by Hossein Akbari on 9/21/1399 AP.
//

import UIKit
import RealmSwift

class HomeController: UIViewController {
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var totalItems: UILabel!
    
    let realm = try! Realm()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        totalItems.text = String(realm.objects(Item.self).count)
    }
    
}
