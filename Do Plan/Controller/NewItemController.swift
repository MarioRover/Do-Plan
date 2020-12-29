//
//  NewItemController.swift
//  Do Plan
//
//  Created by Hossein Akbari on 10/7/1399 AP.
//

import UIKit
import RealmSwift

protocol NewItemDelegate: class {
    func fetchFreshList()
}

class NewItemController: UIViewController {

    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var doneButton: UIButton!
    
    let realm = try! Realm()
    weak var delegate: NewItemDelegate?
    var currentCategory: Category?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func cancelPressed(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    @IBAction func donePressed(_ sender: UIButton) {
        
        if let text = textField.text, !text.isEmpty, currentCategory != nil {
            do {
                try realm.write {
                    let newItem = Item()
                    newItem.name = text
                    currentCategory?.items.append(newItem)
                }
                delegate?.fetchFreshList()
                closePage()
            } catch {
                print("❌ Error in save item \(error)")
            }

        }
    }
    
    func closePage() {
        dismiss(animated: true, completion: nil)
    }
}


// MARK: - TextField

extension NewItemController: UITextFieldDelegate {
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
        return updatedText.count <= 20
    }

}
