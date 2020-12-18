//
//  ListController.swift
//  Do Plan
//
//  Created by Hossein Akbari on 9/21/1399 AP.
//

import UIKit

class ListController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    let items = [
        (
            title: "Home Work",
            desc: "description text",
            numberitems: "1 of 5"
        ),
        (
            title: "Home Work",
            desc: "description text",
            numberitems: "1 of 5"
        ),
        (
            title: "Home Work",
            desc: "description text",
            numberitems: "1 of 5"
        ),
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.register(UINib(nibName: Constant.Identifier.categoryCell, bundle: nil), forCellReuseIdentifier: Constant.Identifier.categoryCell)
    }
    

    
}

// MARK: - TableView

extension ListController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: Constant.Identifier.categoryCell, for: indexPath) as! CategoryCell
         
        cell.titleLabel.text = items[indexPath.row].title
        cell.descLabel.text  = items[indexPath.row].desc
        cell.numberItems.text = items[indexPath.row].numberitems
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 55
    }
    
    
    
}

extension ListController: UIViewControllerTransitioningDelegate {
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        PresentationController(presentedViewController: presented, presenting: presenting)
    }
    
    @IBAction func addButtonPressed(_ sender: UITapGestureRecognizer) {
        let slideVC = NewListModal()
        slideVC.modalPresentationStyle = .custom
        slideVC.transitioningDelegate = self
        self.present(slideVC, animated: true, completion: nil)
    }
    
    
}

