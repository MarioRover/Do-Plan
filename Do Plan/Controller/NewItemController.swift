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
    @IBOutlet weak var notesLabel: UILabel!
    @IBOutlet weak var notesText: UILabel!
    
    let realm = try! Realm()
    var currentCategory: Category?
    
    weak var delegate: NewItemDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Constant.Segue.notes {
            let vc = segue.destination as! NotesController
            vc.delegate = self
            if let text = notesText.text, !text.isEmpty {
                vc.notes = text
            }
        }
    }
    
    @IBAction func cancelPressed(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    @IBAction func donePressed(_ sender: UIButton) {
        saveItem()
    }
    
    @IBAction func noteViewTapped(_ sender: UITapGestureRecognizer) {
        performSegue(withIdentifier: Constant.Segue.notes, sender: self)
    }
    
    func closePage() {
        dismiss(animated: true, completion: nil)
    }
    
    func saveItem() {
        var title: String = ""
        var notes: String = ""
        
        if let textTitle = textField.text, !textTitle.isEmpty { title = textTitle }
        if let textNotes = notesText.text, !textNotes.isEmpty { notes = textNotes }
        
        if !title.isEmpty && currentCategory != nil {
            do {
                try realm.write {
                    let newItem   = Item()
                    newItem.name  = title
                    newItem.notes = notes
                    currentCategory?.items.append(newItem)
                }
                delegate?.fetchFreshList()
                closePage()
            } catch {
                print("❌ Error in save item \(error)")
            }
        }
        
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

// MARK: - NoteDelegate

extension NewItemController: NotesDelegate {
    func setNotes(text: String = "") {
        if text.isEmpty {
            notesLabel.isHidden = false
            notesText.isHidden  = true
        } else {
            notesLabel.isHidden = true
            notesText.isHidden  = false
            notesText.text      = text
        }
        notesText.text = text
    }
}
