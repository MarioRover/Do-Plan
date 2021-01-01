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
    @IBOutlet weak var pageTitleLabel: UILabel!

    let realm = try! Realm()
    weak var delegate: NewListDelegate?
    var selectedList: Category?
        
    override func viewDidLoad() {
        super.viewDidLoad()
        textField.becomeFirstResponder()
        
        if let list = selectedList {
            pageTitleLabel.text = list.name
            textField.text = list.name
            doneButton.setTitle("Update", for: .normal)
            doneButton.isEnabled = true
        } else {
            pageTitleLabel.text = "New List"
            doneButton.setTitle("Create", for: .normal)
            doneButton.isEnabled = false
        }
        
    }
    
    @IBAction func donePressed(_ sender: UIButton) {
                
        if let text = textField.text, !text.isEmpty {
            if selectedList != nil {
                do {
                    try realm.write {
                        selectedList?.name = text
                    }
                    delegate?.fetchFreshData()
                    closePage()
                } catch {
                    print("❌ Error update list \(error)")
                }
            } else {
                let newList = Category()
                newList.name = text
                saveRealm(list: newList)
            }

        }

    }
    @IBAction func cancelPressed(_ sender: UIButton) {
        closePage()
    }
        
    func closePage() {
        dismiss(animated: true, completion: nil)
    }

    // MARK: - Realm Methods

    func saveRealm(list: Category) {
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
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentText = textField.text ?? ""
        guard let stringRange = Range(range, in: currentText) else { return false }
        let updatedText = currentText.replacingCharacters(in: stringRange, with: string)
        return updatedText.count <= 30
    }
}



