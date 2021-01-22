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
        navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == ItemsController.identifier {
            let vc = segue.destination as! ItemsController
            vc.pageTitle = "All"
            vc.loadAllItems()
            vc.isHeaderHidden = false
        }
    }
    
    @IBAction func tappedAllItems(_ sender: UITapGestureRecognizer) {
        performSegue(withIdentifier: ItemsController.identifier, sender: self)
    }
}
