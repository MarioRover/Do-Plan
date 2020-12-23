//
//  NewListController.swift
//  Do Plan
//
//  Created by Hossein Akbari on 9/29/1399 AP.
//

import UIKit
import RealmSwift

protocol NewListDelegate: class {
    func fetchFreshData()
}

class NewListController: UIViewController {

    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var textField: UITextField!

    let realm = try! Realm()
    weak var delegate: NewListDelegate?
        
    override func viewDidLoad() {
        super.viewDidLoad()
        doneButton.isEnabled = false
    }
    
    @IBAction func donePressed(_ sender: UIButton) {
                
        if let text = textField.text, !text.isEmpty {
            let newList = List()
            newList.name = text
            saveRealm(list: newList)
        }

    }
    @IBAction func cancelPressed(_ sender: UIButton) {
        closePage()
    }
        
    func closePage() {
        dismiss(animated: true, completion: nil)
    }

    // MARK: - Realm Methods

    func saveRealm(list: List) {
        do {
            try realm.write {
                realm.add(list)
            }
            delegate?.fetchFreshData()
            closePage()
        } catch {
            print("❌ Error save Realm \(error)")
        }
    }
}

// MARK: - UITextField

extension NewListController: UITextFieldDelegate {
    func textFieldDidChangeSelection(_ textField: UITextField) {
        if textField.text!.isEmpty {
            doneButton.isEnabled = false
        } else {
            doneButton.isEnabled = true
        }
    }
}



